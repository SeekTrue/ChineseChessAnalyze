function [result, detail] = detectCheckmate(board, sideToMove)
%DETECTCHECKMATE 从末步局面推断胜负（将死检测）
%   sideToMove 是被将死检验的一方（即 lastMove 走完后轮到走的一方）
%
% 输入:
%   board       - 10x9 末步局面
%   sideToMove  - 1红 2黑（轮到谁走）
% 输出:
%   result - 1 将死(sideToMove负) / 0 未将死
%   detail - struct: inCheck(是否被将), nLegalMoves(合法应手数), reason
%
% 注意: 只能识别"将死/困毙"；对局中认输无法从棋谱推断，将返回 0。

    detail = struct('inCheck', false, 'nLegalMoves', 0, 'reason', '');
    inCheck = boardUtils('isInCheck', board, sideToMove);
    detail.inCheck = inCheck;
    legal = legalMoves(board, sideToMove);
    detail.nLegalMoves = numel(legal);

    if inCheck && isempty(legal)
        result = 1;
        detail.reason = '将死';
    elseif ~inCheck && isempty(legal)
        result = 1;
        detail.reason = '困毙(无子可动)';
    else
        result = 0;
        if inCheck
            detail.reason = '被将但有应手';
        else
            detail.reason = '未将死(可能认输/和棋/局面未终)';
        end
    end
end

function moves = legalMoves(board, side)
% 生成所有合法走法：伪合法走法 -> 过滤走后己方被将
    pseudo = pseudoMoves(board, side);
    moves = {};
    for i = 1:numel(pseudo)
        mv = pseudo{i};
        b2 = board;
        b2(mv.fr, mv.fc) = 0;
        b2(mv.tr, mv.tc) = mv.val;
        if ~boardUtils('isInCheck', b2, side)
            moves{end+1} = mv; %#ok<AGROW>
        end
    end
end

function moves = pseudoMoves(board, side)
% 伪合法走法（不考虑己方被将）
    moves = {};
    pieces = boardUtils('boardToPieces', board);
    for i = 1:size(pieces, 1)
        val = pieces(i,1); r = pieces(i,2); c = pieces(i,3);
        if boardUtils('side', val) ~= side, continue; end
        kind = boardUtils('pieceType', val);
        targets = targetsFor(board, val, r, c, kind, side);
        for t = 1:size(targets,1)
            tr = targets(t,1); tc = targets(t,2);
            if board(tr,tc) ~= 0 && boardUtils('side', board(tr,tc)) == side
                continue;   % 不能吃己方子
            end
            moves{end+1} = struct('val',val,'fr',r,'fc',c,'tr',tr,'tc',tc); %#ok<AGROW>
        end
    end
end

function targets = targetsFor(board, val, r, c, kind, side) %#ok<INUSD>
% 返回棋子的候选落点（未过滤己方子）
    atk = pieceAttackLocal(board, val, r, c);
    [rr, cc] = find(atk);
    targets = [rr, cc];
    if kind == 6
        % 炮的攻击范围只是炮架后的子，还需补上"移动"范围（炮架前的空格）
        dirs = [-1 0; 1 0; 0 -1; 0 1];
        extra = [];
        for d = 1:4
            nr = r + dirs(d,1); nc = c + dirs(d,2);
            while nr>=1 && nr<=10 && nc>=1 && nc<=9 && board(nr,nc) == 0
                extra = [extra; nr, nc]; %#ok<AGROW>
                nr = nr + dirs(d,1); nc = nc + dirs(d,2);
            end
        end
        targets = [targets; extra];
    end
end

function m = pieceAttackLocal(board, val, r, c)
% 复用 attackEngine 的单子逻辑：构造只含该子的临时盘调用攻击引擎
    tmp = zeros(10,9);
    tmp(r,c) = val;
    full = board;
    % 直接复制 attackEngine 的计算，避免依赖私有函数
    kind = boardUtils('pieceType', val);
    side = boardUtils('side', val);
    m = false(10,9);
    switch kind
        case 1
            for dr=-1:1, for dc=-1:1
                if abs(dr)+abs(dc)~=1, continue; end
                rr=r+dr; cc=c+dc;
                if inPal(rr,cc,side), m(rr,cc)=true; end
            end, end
        case 2
            for dr=[-1 1], for dc=[-1 1]
                rr=r+dr; cc=c+dc;
                if inPal(rr,cc,side), m(rr,cc)=true; end
            end, end
        case 3
            for dr=[-2 2], for dc=[-2 2]
                rr=r+dr; cc=c+dc;
                if ~inB(rr,cc), continue; end
                if side==1 && rr<6, continue; end
                if side==2 && rr>5, continue; end
                if full(r+dr/2, c+dc/2)~=0, continue; end
                m(rr,cc)=true;
            end, end
        case 4
            mv=[-2 -1;-2 1;2 -1;2 1;-1 -2;-1 2;1 -2;1 2];
            for k=1:8
                rr=r+mv(k,1); cc=c+mv(k,2);
                if ~inB(rr,cc), continue; end
                if abs(mv(k,1))==2, lr=r+sign(mv(k,1)); lc=c; else lr=r; lc=c+sign(mv(k,2)); end
                if full(lr,lc)~=0, continue; end
                m(rr,cc)=true;
            end
        case 5
            dirs=[-1 0;1 0;0 -1;0 1];
            for d=1:4
                rr=r+dirs(d,1); cc=c+dirs(d,2);
                while inB(rr,cc)
                    m(rr,cc)=true;
                    if full(rr,cc)~=0, break; end
                    rr=rr+dirs(d,1); cc=cc+dirs(d,2);
                end
            end
        case 6
            dirs=[-1 0;1 0;0 -1;0 1];
            for d=1:4
                rr=r+dirs(d,1); cc=c+dirs(d,2); screen=false;
                while inB(rr,cc)
                    if screen
                        if full(rr,cc)~=0, m(rr,cc)=true; break; end
                    else
                        if full(rr,cc)~=0, screen=true; end
                    end
                    rr=rr+dirs(d,1); cc=cc+dirs(d,2);
                end
            end
        case 7
            if side==1
                fr=r-1; if inB(fr,c), m(fr,c)=true; end
                if r<=5, if c>1, m(r,c-1)=true; end; if c<9, m(r,c+1)=true; end; end
            else
                fr=r+1; if inB(fr,c), m(fr,c)=true; end
                if r>=6, if c>1, m(r,c-1)=true; end; if c<9, m(r,c+1)=true; end; end
            end
    end
end

function tf = inB(r,c), tf = r>=1 && r<=10 && c>=1 && c<=9; end
function tf = inPal(r,c,side)
    tf = c>=4 && c<=6;
    if side==1, tf = tf && r>=8 && r<=10; else tf = tf && r>=1 && r<=3; end
end
