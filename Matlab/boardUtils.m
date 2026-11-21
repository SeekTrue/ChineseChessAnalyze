function out = boardUtils(action, varargin)
%BOARDUTILS 棋盘矩阵公共工具集合（命令式分派）
%   boardUtils('boardToPieces', board)      10x9矩阵 -> [val,row,col] 列表
%   boardUtils('pieceType', val)            棋子值 -> 类型编号 1-7
%   boardUtils('side', val)                 棋子值 -> 阵营 1红 2黑
%   boardUtils('mirror', board)             棋盘上下左右翻转（换边视角）
%   boardUtils('findKing', board, side)     找将/帅位置 [row,col]
%   boardUtils('isInCheck', board, side)    是否被将军（基于攻击引擎）
%   boardUtils('countPieces', board)        各兵种数量 14维向量
%   boardUtils('boardToKey', board)         局面 -> 紧凑字符串签名

    switch lower(action)
        case 'boardtopieces'
            board = varargin{1};
            [r, c, v] = find(board ~= 0);
            out = [v, r, c];
            out = sortrows(out, [1, 2, 3]);   % 固定排序：按棋子值再按位置

        case 'piecetype'
            val = varargin{1};
            out = mod(val - 1, 7) + 1;
            % 1帅/将 2仕/士 3相/象 4马 5车 6炮 7兵/卒

        case 'side'
            val = varargin{1};
            out = ones(size(val));
            out(val > 7) = 2;                 % 1红(1-7) 2黑(8-14)

        case 'mirror'
            board = varargin{1};
            out = rot90(board, 2);            % 红黑视角互换

        case 'findking'
            board = varargin{1}; side = varargin{2};
            kv = 1; if side == 2, kv = 8; end
            [r, c] = find(board == kv);
            if isempty(r), out = []; else out = [r(1), c(1)]; end

        case 'isincheck'
            board = varargin{1}; side = varargin{2};
            kp = boardUtils('findKing', board, side);
            if isempty(kp), out = false; return; end
            atk = attackEngine(board, 3 - side);   % 对方攻击图
            out = atk(kp(1), kp(2));

        case 'countpieces'
            board = varargin{1};
            out = zeros(1, 14);
            for v = 1:14
                out(v) = sum(board(:) == v);
            end

        case 'boardtokey'
            board = varargin{1};
            % 行优先扫描，每格编码为一个字符（0空，1-14棋子用可见ASCII）
            chars = repmat('.', 1, 90);
            idx = 0;
            for r = 1:10
                for c = 1:9
                    idx = idx + 1;
                    v = board(r, c);
                    if v > 0, chars(idx) = char(64 + v); end   % A-N
                end
            end
            out = chars;

        otherwise
            error('boardUtils: unknown action %s', action);
    end
end
