function result = parseNotation(filePath)
%PARSENOTATION 解析中文文字记谱棋谱文件为棋盘矩阵序列
%
% 输入:
%   filePath - 棋谱 txt 文件路径 (UTF-8 编码)
% 输出:
%   result.boards{k} - 10x9 矩阵, k=1 为初始局面, k=i+1 为第 i 步后局面
%                      0=空, 1-7 红方(帅仕相马车炮兵), 8-14 黑方(将士象马车炮卒)
%   result.moves(i)  - 第 i 步的解析详情: raw/side/piece/from/to/capture/valid/err
%   result.date      - 对局日期字符串
%   result.nSteps    - 总步数
%   result.nValid    - 成功解析的步数
%
% 坐标系: row=1 黑方底线, row=10 红方底线
%         红方纵线 N -> col=10-N, 黑方纵线 N -> col=N

    emptyMove = struct('raw', {}, 'side', {}, 'piece', {}, 'from', {}, ...
                       'to', {}, 'capture', {}, 'valid', {}, 'err', {});
    result = struct('boards', {{}}, 'moves', emptyMove, 'date', '', ...
                    'nSteps', 0, 'nValid', 0, 'quality', 1.0, 'errors', {{}});

    fid = fopen(filePath, 'r', 'n', 'UTF-8');
    if fid == -1
        result.errors{end+1} = ['无法打开文件: ' filePath];
        return;
    end
    rawLines = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
    fclose(fid);
    lines = rawLines{1};

    % 提取对局日期
    for i = 1:numel(lines)
        m = regexp(lines{i}, '^对局日期[:：]\s*(.*)$', 'tokens', 'once');
        if ~isempty(m)
            result.date = strtrim(m{1});
            break;
        end
    end

    % 定位"棋局开始"之后的行
    startIdx = 0;
    for i = 1:numel(lines)
        if ~isempty(strfind(lines{i}, '棋局开始'))
            startIdx = i + 1;
            break;
        end
    end
    if startIdx == 0
        startIdx = 1;
    end

    board = initBoard();
    result.boards{1} = board;
    stepIdx = 0;

    for i = startIdx:numel(lines)
        line = strtrim(lines{i});
        if isempty(line), continue; end
        % 去掉回合号前缀 "12. "
        m = regexp(line, '^\d+\.\s*(.+)$', 'tokens', 'once');
        if ~isempty(m), line = strtrim(m{1}); else continue; end
        toks = strsplit(line);
        toks = toks(~cellfun(@isempty, toks));
        for t = 1:numel(toks)
            stepIdx = stepIdx + 1;
            [board, mv] = applyMove(board, toks{t}, stepIdx);
            result.moves(stepIdx) = mv;
            result.boards{stepIdx+1} = board;
            if mv.valid
                result.nValid = result.nValid + 1;
            else
                result.errors{end+1} = sprintf('第%d步 [%s]: %s', stepIdx, toks{t}, mv.err);
            end
        end
    end
    result.nSteps = stepIdx;
    if stepIdx > 0
        result.quality = result.nValid / stepIdx;
    end
end

function board = initBoard()
    board = zeros(10, 9);
    % 红方 (底线 row=10)
    board(10,5) = 1;                 % 帅 (红五线 -> col=5)
    board(10,4) = 2; board(10,6) = 2;   % 仕 (红四/六线 -> col=6/4)
    board(10,3) = 3; board(10,7) = 3;   % 相 (红三/七线 -> col=7/3)
    board(10,1) = 5; board(10,9) = 5;   % 车 (红九/一线 -> col=1/9)
    board(10,2) = 4; board(10,8) = 4;   % 马 (红八/二线 -> col=2/8)
    board(8,2) = 6;  board(8,8) = 6;    % 炮 (红八/二线 -> col=2/8)
    board(7,[1 3 5 7 9]) = 7;           % 兵 (红一三五七九线)
    % 黑方 (底线 row=1)
    board(1,5) = 8;                  % 将 (黑5线 -> col=5)
    board(1,4) = 9;  board(1,6) = 9;    % 士 (黑4/6线)
    board(1,3) = 10; board(1,7) = 10;   % 象 (黑3/7线)
    board(1,1) = 12; board(1,9) = 12;   % 车 (黑1/9线)
    board(1,2) = 11; board(1,8) = 11;   % 马 (黑2/8线)
    board(3,2) = 13; board(3,8) = 13;   % 炮 (黑2/8线)
    board(4,[1 3 5 7 9]) = 14;          % 卒 (黑1/3/5/7/9线)
end

function [board, mv] = applyMove(board, token, stepIdx)
    mv = struct('raw', token, 'side', 0, 'piece', 0, 'from', [], ...
                'to', [], 'capture', 0, 'valid', false, 'err', '');

    pat = '^(前|后|中)?([帅仕相马车炮兵将士象卒])([一二三四五六七八九０-９1-9]*)(进|退|平)([一二三四五六七八九０-９1-9]+)$';
    tok = regexp(token, pat, 'tokens', 'once');
    if isempty(tok)
        mv.err = ['无法解析记谱: ' token];
        return;
    end
    prefix = tok{1}; pieceChar = tok{2}; startFileStr = tok{3};
    action = tok{4}; targetStr = tok{5};

    if mod(stepIdx, 2) == 1, side = 1; else side = 2; end
    pieceVal = pieceValue(pieceChar, side);
    if pieceVal < 0
        mv.err = ['未知棋子: ' pieceChar];
        return;
    end

    startFile = [];
    if ~isempty(startFileStr), startFile = fileNum(startFileStr); end
    target = fileNum(targetStr);
    if isempty(target)
        mv.err = ['目标数字无法解析: ' targetStr];
        return;
    end

    % 找出所有候选源位置, 再用目标合法性消歧
    cands = findSources(board, pieceVal, side, startFile, prefix);
    if isempty(cands)
        mv.err = ['找不到源棋子: ' token];
        return;
    end

    from = []; to = []; lastErr = '';
    for ci = 1:size(cands,1)
        c = cands(ci,:);
        [t, ok, err] = calcTarget(c, pieceVal, side, action, target, token);
        if ~ok, lastErr = err; continue; end
        [legal, lerr] = checkMove(board, c, t, pieceVal, side, action);
        if legal
            from = c; to = t; break;
        else
            lastErr = lerr;
        end
    end
    if isempty(from)
        mv.err = lastErr;
        if isempty(mv.err), mv.err = ['无法落子: ' token]; end
        return;
    end

    capture = board(to(1), to(2));
    board(from(1), from(2)) = 0;
    board(to(1), to(2)) = pieceVal;
    mv.side = side; mv.piece = pieceVal; mv.from = from;
    mv.to = to; mv.capture = capture; mv.valid = true;
end

function n = fileNum(s)
    cn = '一二三四五六七八九';
    fw = '０１２３４５６７８９';
    hw = '0123456789';
    n = [];
    if numel(s) ~= 1, return; end
    k = find(cn == s, 1); if ~isempty(k), n = k; return; end
    k = find(fw == s, 1); if ~isempty(k), n = k - 1; return; end
    k = find(hw == s, 1); if ~isempty(k), n = k - 1; return; end
end

function v = pieceValue(ch, side)
    v = -1;
    if side == 1
        switch ch
            case '帅', v = 1;
            case '仕', v = 2;
            case '相', v = 3;
            case '马', v = 4;
            case '车', v = 5;
            case '炮', v = 6;
            case '兵', v = 7;
        end
    else
        switch ch
            case '将', v = 8;
            case '士', v = 9;
            case '象', v = 10;
            case '马', v = 11;
            case '车', v = 12;
            case '炮', v = 13;
            case '卒', v = 14;
        end
    end
end

function col = fileToCol(n, side)
    if side == 1, col = 10 - n; else col = n; end
end

function cands = findSources(board, pieceVal, side, startFile, prefix)
    [r, c] = find(board == pieceVal);
    cands = [r, c];
    if ~isempty(startFile) && ~isempty(cands)
        wantCol = fileToCol(startFile, side);
        cands = cands(cands(:,2) == wantCol, :);
    end
    if ~isempty(prefix) && ~isempty(cands)
        if side == 1, cands = sortrows(cands, 1); else cands = sortrows(cands, -1); end
        switch prefix
            case '前', cands = cands(1, :);
            case '后', cands = cands(end, :);
            case '中', cands = cands(ceil(size(cands,1)/2), :);
        end
    end
end

function [to, ok, errmsg] = calcTarget(from, pieceVal, side, action, target, token)
    to = []; ok = false; errmsg = '';
    r = from(1); c = from(2);
    forward = -1;
    if side == 2, forward = 1; end

    switch action
        case '平'
            to = [r, fileToCol(target, side)];
            ok = true;
        case {'进','退'}
            dir = forward;
            if strcmp(action, '退'), dir = -forward; end
            kind = mod(pieceVal - 1, 7) + 1;
            switch kind
                case {1, 5, 6, 7}
                    to = [r + dir*target, c];
                    ok = true;
                case {2, 3, 4}
                    wantCol = fileToCol(target, side);
                    switch kind
                        case 4
                            cand = [r-2,c-1; r-2,c+1; r+2,c-1; r+2,c+1; ...
                                    r-1,c-2; r-1,c+2; r+1,c-2; r+1,c+2];
                        case 2
                            cand = [r-1,c-1; r-1,c+1; r+1,c-1; r+1,c+1];
                        case 3
                            cand = [r-2,c-2; r-2,c+2; r+2,c-2; r+2,c+2];
                    end
                    valid = [];
                    for i = 1:size(cand,1)
                        p = cand(i,:);
                        if p(2) == wantCol && sign(p(1)-r) == dir
                            valid = [valid; p];
                        end
                    end
                    if ~isempty(valid)
                        to = valid(1,:); ok = true;
                    else
                        errmsg = ['目标不可达: ' token];
                    end
            end
    end
end

function [ok, errmsg] = checkMove(board, from, to, pieceVal, side, action)
    ok = false; errmsg = '';
    r = from(1); c = from(2); tr = to(1); tc = to(2);
    if tr < 1 || tr > 10 || tc < 1 || tc > 9
        errmsg = '目标越界'; return;
    end
    if board(tr,tc) ~= 0 && (board(tr,tc) <= 7) == (pieceVal <= 7)
        errmsg = '目标是己方棋子'; return;
    end
    kind = mod(pieceVal - 1, 7) + 1;
    switch kind
        case 1
            if abs(tr-r) + abs(tc-c) ~= 1, errmsg = '将帅走法非法'; return; end
            if tc < 4 || tc > 6, errmsg = '将帅出九宫'; return; end
            if side == 1 && (tr < 8 || tr > 10), errmsg = '帅出九宫'; return; end
            if side == 2 && (tr < 1 || tr > 3), errmsg = '将出九宫'; return; end
        case 2
            if abs(tr-r) ~= 1 || abs(tc-c) ~= 1, errmsg = '士走法非法'; return; end
            if tc < 4 || tc > 6, errmsg = '士出九宫'; return; end
            if side == 1 && (tr < 8 || tr > 10), errmsg = '仕出九宫'; return; end
            if side == 2 && (tr < 1 || tr > 3), errmsg = '士出九宫'; return; end
        case 3
            if abs(tr-r) ~= 2 || abs(tc-c) ~= 2, errmsg = '象走法非法'; return; end
            if board((r+tr)/2, (c+tc)/2) ~= 0, errmsg = '塞象眼'; return; end
            if side == 1 && tr < 6, errmsg = '相过河'; return; end
            if side == 2 && tr > 5, errmsg = '象过河'; return; end
        case 4
            if ~((abs(tr-r)==2 && abs(tc-c)==1) || (abs(tr-r)==1 && abs(tc-c)==2))
                errmsg = '马走法非法'; return;
            end
            if abs(tr-r) == 2, lr = r + sign(tr-r); lc = c;
            else lr = r; lc = c + sign(tc-c); end
            if board(lr,lc) ~= 0, errmsg = '蹩马腿'; return; end
        case 5
            if r ~= tr && c ~= tc, errmsg = '车走法非法'; return; end
            [pathOK, perr] = checkPath(board, from, to, false);
            if ~pathOK, errmsg = perr; return; end
        case 6
            if r ~= tr && c ~= tc, errmsg = '炮走法非法'; return; end
            isCapture = (board(tr,tc) ~= 0);
            [pathOK, perr] = checkPath(board, from, to, isCapture);
            if ~pathOK, errmsg = perr; return; end
        case 7
            if c ~= tc
                if abs(tr-r) ~= 0, errmsg = '兵卒横走非法'; return; end
                if side == 1 && r > 5, errmsg = '兵未过河不能横走'; return; end
                if side == 2 && r < 6, errmsg = '卒未过河不能横走'; return; end
            else
                if side == 1 && tr >= r, errmsg = '兵只能前进'; return; end
                if side == 2 && tr <= r, errmsg = '卒只能前进'; return; end
                if abs(tr-r) ~= 1, errmsg = '兵卒每次一步'; return; end
            end
    end
    ok = true;
end

function [ok, errmsg] = checkPath(board, from, to, isCapture)
    ok = false; errmsg = '';
    r = from(1); c = from(2); tr = to(1); tc = to(2);
    if r == tr
        lo = min(c,tc) + 1; hi = max(c,tc) - 1;
    else
        lo = min(r,tr) + 1; hi = max(r,tr) - 1;
    end
    cnt = 0;
    for k = lo:hi
        if r == tr
            if board(r,k) ~= 0, cnt = cnt + 1; end
        else
            if board(k,c) ~= 0, cnt = cnt + 1; end
        end
    end
    if isCapture
        if cnt ~= 1, errmsg = '炮吃子需恰好一个炮架'; return; end
    else
        if cnt ~= 0, errmsg = '路径被阻挡'; return; end
    end
    ok = true;
end
