function atk = attackEngine(board, side)
%ATTACKENGINE 攻击范围引擎（移植自原有 analyze_danger.m / chess_attack_analysis.m）
%   计算指定阵营对本方所有棋子的攻击范围
%
% 输入:
%   board - 10x9 矩阵，0空/1-7红/8-14黑
%   side  - 1红 2黑（计算该方棋子的攻击范围）
% 输出:
%   atk - 10x9 逻辑矩阵，true 表示该方攻击/保护的格子
%
% 坐标系: row=1黑底线, row=10红底线; 红方col=10-纵线, 黑方col=纵线

    atk = false(10, 9);
    pieces = boardUtils('boardToPieces', board);
    for i = 1:size(pieces, 1)
        val = pieces(i, 1); r = pieces(i, 2); c = pieces(i, 3);
        if boardUtils('side', val) ~= side, continue; end
        atk = atk | pieceAttack(board, val, r, c);
    end
end

function m = pieceAttack(board, val, r, c)
% 单个棋子的攻击范围（含保护的己方格、含可吃的敌方格）
    kind = boardUtils('pieceType', val);
    side = boardUtils('side', val);
    m = false(10, 9);
    switch kind
        case 1   % 帅/将：九宫内一步
            m = kingAttack(r, c, side);
        case 2   % 仕/士：九宫斜一步
            m = advisorAttack(r, c, side);
        case 3   % 相/象：斜两步，塞象眼，不过河
            m = elephantAttack(board, r, c, side);
        case 4   % 马：日字，蹩马腿
            m = horseAttack(board, r, c);
        case 5   % 车：直线
            m = rookAttack(board, r, c);
        case 6   % 炮：隔子攻击（炮架）
            m = cannonAttack(board, r, c);
        case 7   % 兵/卒
            m = pawnAttack(r, c, side);
    end
end

function m = kingAttack(r, c, side)
    m = false(10, 9);
    for dr = -1:1
        for dc = -1:1
            if abs(dr) + abs(dc) ~= 1, continue; end
            rr = r+dr; cc = c+dc;
            if inPalace(rr, cc, side), m(rr, cc) = true; end
        end
    end
end

function m = advisorAttack(r, c, side)
    m = false(10, 9);
    for dr = [-1 1]
        for dc = [-1 1]
            rr = r+dr; cc = c+dc;
            if inPalace(rr, cc, side), m(rr, cc) = true; end
        end
    end
end

function m = elephantAttack(board, r, c, side)
    m = false(10, 9);
    for dr = [-2 2]
        for dc = [-2 2]
            rr = r+dr; cc = c+dc;
            if ~inBoard(rr, cc), continue; end
            % 不过河
            if side == 1 && rr < 6, continue; end
            if side == 2 && rr > 5, continue; end
            % 象眼
            eyeR = r + dr/2; eyeC = c + dc/2;
            if board(eyeR, eyeC) ~= 0, continue; end
            m(rr, cc) = true;
        end
    end
end

function m = horseAttack(board, r, c)
    m = false(10, 9);
    moves = [ -2 -1; -2 1; 2 -1; 2 1; -1 -2; -1 2; 1 -2; 1 2 ];
    for i = 1:size(moves, 1)
        dr = moves(i,1); dc = moves(i,2);
        rr = r+dr; cc = c+dc;
        if ~inBoard(rr, cc), continue; end
        % 蹩马腿：先判断该方向上的马腿格
        if abs(dr) == 2
            legR = r + sign(dr); legC = c;
        else
            legR = r; legC = c + sign(dc);
        end
        if board(legR, legC) ~= 0, continue; end
        m(rr, cc) = true;
    end
end

function m = rookAttack(board, r, c)
    m = false(10, 9);
    dirs = [-1 0; 1 0; 0 -1; 0 1];
    for d = 1:size(dirs,1)
        rr = r + dirs(d,1); cc = c + dirs(d,2);
        while inBoard(rr, cc)
            m(rr, cc) = true;
            if board(rr, cc) ~= 0, break; end   % 遇子停止（该格可攻击）
            rr = rr + dirs(d,1); cc = cc + dirs(d,2);
        end
    end
end

function m = cannonAttack(board, r, c)
    m = false(10, 9);
    dirs = [-1 0; 1 0; 0 -1; 0 1];
    for d = 1:size(dirs,1)
        rr = r + dirs(d,1); cc = c + dirs(d,2);
        hasScreen = false;
        while inBoard(rr, cc)
            if hasScreen
                if board(rr, cc) ~= 0
                    m(rr, cc) = true;            % 炮架后第一个子可被攻击
                    break;
                end
            else
                if board(rr, cc) ~= 0, hasScreen = true; end
            end
            rr = rr + dirs(d,1); cc = cc + dirs(d,2);
        end
    end
end

function m = pawnAttack(r, c, side)
    m = false(10, 9);
    if side == 1
        fr = r - 1;                 % 红兵向上（row减小）
        if inBoard(fr, c), m(fr, c) = true; end
        if r <= 5                   % 过河后可横走
            if c > 1, m(r, c-1) = true; end
            if c < 9, m(r, c+1) = true; end
        end
    else
        fr = r + 1;                 % 黑卒向下（row增大）
        if inBoard(fr, c), m(fr, c) = true; end
        if r >= 6                   % 过河后可横走
            if c > 1, m(r, c-1) = true; end
            if c < 9, m(r, c+1) = true; end
        end
    end
end

function tf = inBoard(r, c)
    tf = r >= 1 && r <= 10 && c >= 1 && c <= 9;
end

function tf = inPalace(r, c, side)
    tf = c >= 4 && c <= 6;
    if side == 1
        tf = tf && r >= 8 && r <= 10;
    else
        tf = tf && r >= 1 && r <= 3;
    end
end
