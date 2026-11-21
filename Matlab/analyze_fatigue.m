function fatigue_status = analyze_fatigue(board, pieces_cell)
    % 分析每个棋子是否处于"疲"状态（承担重要任务导致受限）
    % 输入：
    %   board - 10x9棋盘矩阵
    %   pieces_cell - 32x3元胞数组，每行表示一个棋子
    % 输出：
    %   fatigue_status - 32x1逻辑向量，true表示该棋子处于疲状态
    
    % 初始化输出
    fatigue_status = false(32, 1);
    
    % 计算双方攻击范围
    red_attack_map = false(10, 9);
    black_attack_map = false(10, 9);
    
    % 遍历所有棋子，计算攻击范围
    for i = 1:32
        piece_data = pieces_cell{i, 1};
        
        % 跳过已被吃掉的棋子
        if isequal(piece_data, 0)
            continue;
        end
        
        piece_val = piece_data(1);
        r = piece_data(2);
        c = piece_data(3);
        
        % 获取该棋子的攻击范围
        attacks = pieces_cell{i, 2};
        if isempty(attacks)
            continue;
        end
        
        % 更新攻击范围图
        if piece_val <= 7 % 红方棋子
            for j = 1:size(attacks,1)
                red_attack_map(attacks(j,1), attacks(j,2)) = true;
            end
        else % 黑方棋子
            for j = 1:size(attacks,1)
                black_attack_map(attacks(j,1), attacks(j,2)) = true;
            end
        end
    end
    
    % 分析每个棋子的疲状态
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
        attacks = pieces_cell{i, 2}; % 获取该棋子的攻击范围
        
        % 检查是否承担重要任务
        is_fatigued = false;
        
        % 1. 检查是否防守其他棋子
        defended_pieces = 0;
        is_red = piece_val <= 7;
        
        for j = 1:32
            if i == j, continue; end % 跳过自身
            
            other_data = pieces_cell{j, 1};
            if isequal(other_data, 0)
                continue; % 跳过已被吃掉的棋子
            end
            
            other_val = other_data(1);
            other_r = other_data(2);
            other_c = other_data(3);
            
            % 检查是否为友方棋子
            if (other_val <= 7) == is_red
                % 检查该棋子是否在攻击范围内
                if any(attacks(:,1) == other_r & attacks(:,2) == other_c)
                    defended_pieces = defended_pieces + 1;
                end
            end
        end
        
        % 2. 检查是否防守重要位置
        defense_duty = false;
        
        % 重要位置：将/帅位置、九宫中心、河界等
        if is_red
            % 红方重要位置
            important_positions = [
                10,5; % 帅位置
                9,4; 9,5; 9,6; % 九宫
                8,4; 8,5; 8,6;
                7,4; 7,5; 7,6;
                5,1;5,2;5,3;5,4;5,5;5,6;5,7;5,8;5,9 % 河界
            ];
        else
            % 黑方重要位置
            important_positions = [
                1,5; % 将位置
                2,4;2,5;2,6; % 九宫
                3,4;3,5;3,6;
                4,4;4,5;4,6;
                6,1;6,2;6,3;6,4;6,5;6,6;6,7;6,8;6,9 % 河界
            ];
        end
        
        % 检查棋子是否防守重要位置
        for j = 1:size(important_positions,1)
            pos_r = important_positions(j,1);
            pos_c = important_positions(j,2);
            
            % 检查该位置是否在攻击范围内
            if any(attacks(:,1) == pos_r & attacks(:,2) == pos_c)
                defense_duty = true;
                break;
            end
        end
        
        % 3. 检查是否被限制移动范围
        restricted_movement = false;
        
        % 获取该棋子的理论移动范围
        [theoretical_moves, max_moves] = calculate_theoretical_moves(piece_val, r, c);
        
        % 计算实际移动范围比例
        if ~isempty(moves) && max_moves > 0
            actual_moves_count = size(moves, 1);
            move_ratio = actual_moves_count / max_moves;
            
            % 如果实际移动范围小于理论范围的1/4，视为受限
            if move_ratio < 0.25
                restricted_movement = true;
            end
        end
        
        % 综合判断疲状态
        % 条件1：防守至少1个棋子
        % 条件2：防守重要位置
        % 条件3：移动范围受限
        if defended_pieces >= 1 || defense_duty || restricted_movement
            is_fatigued = true;
        end
        
        fatigue_status(i) = is_fatigued;
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