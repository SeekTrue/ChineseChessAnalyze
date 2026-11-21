function skewer_status = analyze_skewer(board, pieces_cell)
    % 分析每个棋子是否处于"串"状态（与其他友方棋子同一直线且无阻挡）
    % 输入：
    %   board - 10x9棋盘矩阵
    %   pieces_cell - 32x3元胞数组，每行表示一个棋子
    % 输出：
    %   skewer_status - 32x1逻辑向量，true表示该棋子处于串状态
    
    % 初始化输出
    skewer_status = false(32, 1);
    
    % 创建位置到棋子索引的映射
    position_to_index = zeros(10, 9);
    for i = 1:32
        piece_data = pieces_cell{i, 1};
        if ~isequal(piece_data, 0)
            r = piece_data(2);
            c = piece_data(3);
            position_to_index(r, c) = i;
        end
    end
    
    % 分析每个棋子的串状态
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
        
        % 检查行方向
        for j = 1:9
            if j == c, continue; end % 跳过自身位置
            
            % 检查是否有友方棋子
            if board(r, j) > 0 && ((board(r, j) <= 7) == is_red)
                % 检查中间是否为空
                min_c = min(c, j);
                max_c = max(c, j);
                empty_between = true;
                
                for k = min_c+1:max_c-1
                    if board(r, k) ~= 0
                        empty_between = false;
                        break;
                    end
                end
                
                if empty_between
                    % 标记两个棋子都处于串状态
                    skewer_status(i) = true;
                    other_idx = position_to_index(r, j);
                    if other_idx > 0
                        skewer_status(other_idx) = true;
                    end
                end
            end
        end
        
        % 检查列方向
        for k = 1:10
            if k == r, continue; end % 跳过自身位置
            
            % 检查是否有友方棋子
            if board(k, c) > 0 && ((board(k, c) <= 7) == is_red)
                % 检查中间是否为空
                min_r = min(r, k);
                max_r = max(r, k);
                empty_between = true;
                
                for m = min_r+1:max_r-1
                    if board(m, c) ~= 0
                        empty_between = false;
                        break;
                    end
                end
                
                if empty_between
                    % 标记两个棋子都处于串状态
                    skewer_status(i) = true;
                    other_idx = position_to_index(k, c);
                    if other_idx > 0
                        skewer_status(other_idx) = true;
                    end
                end
            end
        end
    end
end