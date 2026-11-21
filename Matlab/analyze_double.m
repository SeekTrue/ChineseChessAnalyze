function double_status = analyze_double(board, pieces_cell)
    % 分析每个棋子是否处于"双"状态（易被同时攻击两个子）
    % 输入：
    %   board - 10x9棋盘矩阵
    %   pieces_cell - 32x3元胞数组，每行表示一个棋子
    % 输出：
    %   double_status - 32x1逻辑向量，true表示该棋子处于双状态
    
    % 初始化输出
    double_status = false(32, 1);
    
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
    
    % 分析每个棋子的双状态
    for i = 1:32
        piece_data = pieces_cell{i, 1};
        
        % 跳过已被吃掉的棋子
        if isequal(piece_data, 0)
            continue;
        end
        
        piece_val = piece_data(1);
        r = piece_data(2);
        c = piece_data(3);
        is_red = piece_val <= 7;
        
        % 检查是否处于双状态
        is_double = false;
        
        % 情况1：该棋子与相邻友方棋子同时被攻击
        adjacent_pieces = [
            r-1, c; % 上
            r+1, c; % 下
            r, c-1; % 左
            r, c+1; % 右
        ];
        
        for j = 1:size(adjacent_pieces,1)
            adj_r = adjacent_pieces(j,1);
            adj_c = adjacent_pieces(j,2);
            
            % 检查边界
            if adj_r < 1 || adj_r > 10 || adj_c < 1 || adj_c > 9
                continue;
            end
            
            % 检查是否为友方棋子
            if board(adj_r, adj_c) > 0 && ((board(adj_r, adj_c) <= 7) == is_red)
                % 检查两个棋子是否都被攻击
                if enemy_attack_map(r, c) && enemy_attack_map(adj_r, adj_c)
                    is_double = true;
                    break;
                end
            end
        end
        
        % 情况2：该棋子与同一直线上的友方棋子同时被攻击
        if ~is_double
            % 检查同一行
            for j = 1:9
                if j == c, continue; end
                
                % 检查是否为友方棋子
                if board(r, j) > 0 && ((board(r, j) <= 7) == is_red)
                    % 检查两个棋子是否都被攻击
                    if enemy_attack_map(r, c) && enemy_attack_map(r, j)
                        is_double = true;
                        break;
                    end
                end
            end
            
            % 检查同一列
            if ~is_double
                for k = 1:10
                    if k == r, continue; end
                    
                    % 检查是否为友方棋子
                    if board(k, c) > 0 && ((board(k, c) <= 7) == is_red)
                        % 检查两个棋子是否都被攻击
                        if enemy_attack_map(r, c) && enemy_attack_map(k, c)
                            is_double = true;
                            break;
                        end
                    end
                end
            end
        end
        
        % 情况3：该棋子与对角位置的友方棋子同时被攻击
        if ~is_double
            diagonal_positions = [
                r-1, c-1; % 左上
                r-1, c+1; % 右上
                r+1, c-1; % 左下
                r+1, c+1; % 右下
            ];
            
            for j = 1:size(diagonal_positions,1)
                diag_r = diagonal_positions(j,1);
                diag_c = diagonal_positions(j,2);
                
                % 检查边界
                if diag_r < 1 || diag_r > 10 || diag_c < 1 || diag_c > 9
                    continue;
                end
                
                % 检查是否为友方棋子
                if board(diag_r, diag_c) > 0 && ((board(diag_r, diag_c) <= 7) == is_red)
                    % 检查两个棋子是否都被攻击
                    if enemy_attack_map(r, c) && enemy_attack_map(diag_r, diag_c)
                        is_double = true;
                        break;
                    end
                end
            end
        end
        
        double_status(i) = is_double;
    end
end