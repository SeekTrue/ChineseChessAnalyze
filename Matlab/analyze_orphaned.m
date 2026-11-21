function orphaned_status = analyze_orphaned(board, pieces_cell)
    % 分析每个棋子是否处于"游"状态（无根子，无其他子力守护）
    % 输入：
    %   board - 10x9棋盘矩阵
    %   pieces_cell - 32x3元胞数组，每行表示一个棋子
    % 输出：
    %   orphaned_status - 32x1逻辑向量，true表示该棋子处于游状态
    
    % 初始化输出
    orphaned_status = false(32, 1);
    
    % 计算友方攻击范围（用于保护）
    friendly_attack_map = false(10, 9);
    
    % 遍历所有棋子，计算友方攻击范围
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
        for j = 1:size(attacks,1)
            attack_r = attacks(j,1);
            attack_c = attacks(j,2);
            friendly_attack_map(attack_r, attack_c) = true;
        end
    end
    
    % 分析每个棋子的游状态
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
        
        % 检查是否处于游状态（无保护）
        is_orphaned = true;
        
        % 情况1：有友方棋子保护该位置
        if friendly_attack_map(r, c)
            % 检查是否有其他友方棋子可以保护此位置（不包括自己）
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
                    % 检查该棋子的攻击范围是否包含此位置
                    attacks = pieces_cell{j, 2};
                    if any(attacks(:,1) == r & attacks(:,2) == c)
                        is_orphaned = false;
                        break;
                    end
                end
            end
        else
            % 没有友方棋子攻击范围覆盖此位置
            is_orphaned = true;
        end
        
        % 特殊情况：将/帅通常不视为游子
        if piece_val == 1 || piece_val == 8
            is_orphaned = false;
        end
        
        orphaned_status(i) = is_orphaned;
    end
end