function trapped_status = analyze_trapped(board, pieces_cell)
    % 分析每个棋子是否处于"困"状态（移动范围受限或被封锁）
    % 输入：
    %   board - 10x9棋盘矩阵
    %   pieces_cell - 32x3元胞数组，每行表示一个棋子
    % 输出：
    %   trapped_status - 32x1逻辑向量，true表示该棋子处于困状态
    
    % 初始化输出
    trapped_status = false(32, 1);
    
    % 计算对方攻击范围
    enemy_attack_map = false(10, 9);
    
    % 遍历所有棋子，计算对方攻击范围
    for i = 1:32
        piece_data = pieces_cell{i, 1};
        
        % 跳过已被吃掉的棋子
        if isequal(piece_data, 0)
            continue;
        end
        
        piece_val = piece_data(1);
        r = piece_data(2);
        c = piece_data(3);
        
        % 计算该棋子的攻击范围（如果是对方棋子）
        if piece_val <= 7 % 红方棋子（对黑方来说是对方）
            [~, attacks] = calculate_attacks(board, piece_val, r, c);
            enemy_attack_map = enemy_attack_map | attacks;
        else % 黑方棋子（对红方来说是对方）
            [~, attacks] = calculate_attacks(board, piece_val, r, c);
            enemy_attack_map = enemy_attack_map | attacks;
        end
    end
    
    % 分析每个棋子的困状态
    for i = 1:32
        piece_data = pieces_cell{i, 1};
        
        % 跳过已被吃掉的棋子
        if isequal(piece_data, 0)
            continue;
        end
        
        piece_val = piece_data(1);
        r = piece_data(2);
        c = piece_data(3);
        moves = pieces_cell{i, 3}; % 获取该棋子的移动范围
        
        % 计算理论移动范围
        [theoretical_moves, max_moves] = calculate_theoretical_moves(piece_val, r, c);
        
        % 计算实际移动范围比例
        actual_moves_count = size(moves, 1);
        move_ratio = actual_moves_count / max_moves;
        
        % 情况1：移动范围受限（实际移动范围 ≤ 理论移动范围的1/4）
        is_restricted = move_ratio <= 0.25;
        
        % 情况2：所有移动位置都被封锁（被对方攻击）
        all_blocked = true;
        if ~isempty(moves)
            for j = 1:size(moves,1)
                new_r = moves(j,1);
                new_c = moves(j,2);
                
                % 检查移动位置是否被对方攻击
                if ~enemy_attack_map(new_r, new_c)
                    all_blocked = false;
                    break;
                end
            end
        else
            all_blocked = false; % 没有移动位置
        end
        
        % 综合判断困状态
        trapped_status(i) = is_restricted || all_blocked;
    end
end

function [moves, max_moves] = calculate_theoretical_moves(piece_val, r, c)
    % 计算棋子的理论移动范围（不考虑阻挡）
    moves = [];
    
    switch piece_val
        case {1,8} % 帅/将
            moves = [r-1,c; r+1,c; r,c-1; r,c+1];
            max_moves = 4;
        case {2,9} % 仕/士
            moves = [r-1,c-1; r-1,c+1; r+1,c-1; r+1,c+1];
            max_moves = 4;
        case {3,10} % 相/象
            moves = [r-2,c-2; r-2,c+2; r+2,c-2; r+2,c+2];
            max_moves = 4;
        case {4,11} % 马
            moves = [r-2,c-1; r-2,c+1; r-1,c-2; r-1,c+2; ...
                     r+1,c-2; r+1,c+2; r+2,c-1; r+2,c+1];
            max_moves = 8;
        case {5,12} % 车
            % 车理论上可以移动到同一直线的所有位置
            moves = [];
            for i = 1:10
                if i ~= r, moves = [moves; i, c]; end
                if i ~= c, moves = [moves; r, i]; end
            end
            max_moves = 17; % 9(行)+8(列)-1(自身位置)
        case {6,13} % 炮
            % 炮理论上可以移动到同一直线的所有位置
            moves = [];
            for i = 1:10
                if i ~= r, moves = [moves; i, c]; end
                if i ~= c, moves = [moves; r, i]; end
            end
            max_moves = 17;
        case {7,14} % 兵/卒
            % 兵卒理论移动范围
            if piece_val <= 7 % 红兵
                moves = [r-1, c]; % 前进
            else % 黑卒
                moves = [r+1, c]; % 前进
            end
            max_moves = 1;
    end
    
    % 过滤边界外的位置
    valid_idx = moves(:,1) >= 1 & moves(:,1) <= 10 & moves(:,2) >= 1 & moves(:,2) <= 9;
    moves = moves(valid_idx, :);
end