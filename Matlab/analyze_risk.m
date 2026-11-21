function risk_status = analyze_risk(board, pieces_cell)
    % 分析每个棋子是否处于"险"状态（移动一步后会进入对方攻击范围）
    % 输入：
    %   board - 10x9棋盘矩阵
    %   pieces_cell - 32x3元胞数组，每行表示一个棋子
    % 输出：
    %   risk_status - 32x1逻辑向量，true表示该棋子处于危险中
    
    % 初始化输出
    risk_status = false(32, 1);
    
    % 计算对方所有棋子的攻击范围
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
        if piece_val > 7 % 黑方棋子（对红方来说是对方）
            [~, attacks] = calculate_attacks(board, piece_val, r, c);
            enemy_attack_map = enemy_attack_map | attacks;
        elseif piece_val <= 7 % 红方棋子（对黑方来说是对方）
            [~, attacks] = calculate_attacks(board, piece_val, r, c);
            enemy_attack_map = enemy_attack_map | attacks;
        end
    end
    
    % 分析每个棋子的危险状态
    for i = 1:32
        piece_data = pieces_cell{i, 1};
        
        % 跳过已被吃掉的棋子
        if isequal(piece_data, 0)
            continue;
        end
        
        piece_val = piece_data(1);
        r = piece_data(2);
        c = piece_data(3);
        move_range = pieces_cell{i, 3}; % 获取该棋子的移动范围
        
        % 检查当前是否在对方攻击范围内（危状态）
        current_in_danger = enemy_attack_map(r, c);
        
        % 检查移动后是否会进入对方攻击范围（险状态）
        will_be_in_danger = false;
        
        if ~isempty(move_range)
            for j = 1:size(move_range, 1)
                new_r = move_range(j, 1);
                new_c = move_range(j, 2);
                
                % 检查移动后位置是否在对方攻击范围内
                if enemy_attack_map(new_r, new_c)
                    will_be_in_danger = true;
                    break;
                end
            end
        end
        
        % 险状态：当前不在危险中，但移动后会进入危险
        risk_status(i) = ~current_in_danger && will_be_in_danger;
    end
end