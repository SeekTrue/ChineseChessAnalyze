function danger_status = analyze_danger(board, pieces_cell)
    % 分析每个棋子是否处于"危"状态（被对方攻击）
    % 输入：
    %   board - 10x9棋盘矩阵
    %   pieces_cell - 32x3元胞数组，每行表示一个棋子
    % 输出：
    %   danger_status - 32x1逻辑向量，true表示该棋子处于危险中
    
    % 初始化输出
    danger_status = false(32, 1);
    
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
        
        % 计算该棋子的攻击范围
        if piece_val <= 7 % 红方棋子
            [~, attacks] = calculate_attacks(board, piece_val, r, c);
            red_attack_map = red_attack_map | attacks;
        else % 黑方棋子
            [~, attacks] = calculate_attacks(board, piece_val, r, c);
            black_attack_map = black_attack_map | attacks;
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
        
        % 检查是否处于对方攻击范围内
        if piece_val <= 7 % 红方棋子
            danger_status(i) = black_attack_map(r, c);
        else % 黑方棋子
            danger_status(i) = red_attack_map(r, c);
        end
    end
end

function [moves, attacks] = calculate_attacks(board, piece_val, r, c)
    % 计算指定棋子的移动范围和攻击范围
    % 根据棋子类型调用不同的计算函数
    
    moves = [];
    attacks = [];
    
    switch piece_val
        case {1, 8} % 帅/将
            [moves, attacks] = king_moves_attacks(board, r, c);
        case {2, 9} % 仕/士
            [moves, attacks] = advisor_moves_attacks(board, r, c);
        case {3, 10} % 相/象
            [moves, attacks] = elephant_moves_attacks(board, r, c);
        case {4, 11} % 马
            [moves, attacks] = horse_moves_attacks(board, r, c);
        case {5, 12} % 车
            [moves, attacks] = chariot_moves_attacks(board, r, c);
        case {6, 13} % 炮
            [moves, attacks] = cannon_moves_attacks(board, r, c);
        case {7, 14} % 兵/卒
            [moves, attacks] = pawn_moves_attacks(board, r, c, piece_val);
    end
end

function [moves, attacks] = king_moves_attacks(board, r, c)
    % 帅/将的移动和攻击范围
    moves = [];
    attacks = [];
    possible_moves = [r-1,c; r+1,c; r,c-1; r,c+1];
    
    % 检查是否在九宫格内
    is_red = board(r,c) <= 7;
    for i = 1:size(possible_moves,1)
        new_r = possible_moves(i,1);
        new_c = possible_moves(i,2);
        
        % 检查边界
        if new_r < 1 || new_r > 10 || new_c < 1 || new_c > 9
            continue;
        end
        
        % 检查是否在九宫格内
        in_palace = false;
        if is_red % 红方九宫（下方7-9行）
            in_palace = (new_r >= 8 && new_r <= 10) && (new_c >= 4 && new_c <= 6);
        else % 黑方九宫（上方1-3行）
            in_palace = (new_r >= 1 && new_r <= 3) && (new_c >= 4 && new_c <= 6);
        end
        
        if in_palace
            % 移动范围：可以移动到空位
            if board(new_r, new_c) == 0
                moves = [moves; new_r, new_c];
            end
            
            % 攻击范围：可以攻击敌方棋子位置
            if board(new_r, new_c) > 0 && (board(new_r, new_c) <= 7) ~= is_red
                attacks = [attacks; new_r, new_c];
            end
        end
    end
end

function [moves, attacks] = advisor_moves_attacks(board, r, c)
    % 仕/士的移动和攻击范围
    moves = [];
    attacks = [];
    possible_moves = [r-1,c-1; r-1,c+1; r+1,c-1; r+1,c+1];
    
    % 检查是否在九宫格内
    is_red = board(r,c) <= 7;
    for i = 1:size(possible_moves,1)
        new_r = possible_moves(i,1);
        new_c = possible_moves(i,2);
        
        % 检查边界
        if new_r < 1 || new_r > 10 || new_c < 1 || new_c > 9
            continue;
        end
        
        % 检查是否在九宫格内
        in_palace = false;
        if is_red % 红方九宫
            in_palace = (new_r >= 8 && new_r <= 10) && (new_c >= 4 && new_c <= 6);
        else % 黑方九宫
            in_palace = (new_r >= 1 && new_r <= 3) && (new_c >= 4 && new_c <= 6);
        end
        
        if in_palace
            % 移动范围：可以移动到空位
            if board(new_r, new_c) == 0
                moves = [moves; new_r, new_c];
            end
            
            % 攻击范围：可以攻击敌方棋子位置
            if board(new_r, new_c) > 0 && (board(new_r, new_c) <= 7) ~= is_red
                attacks = [attacks; new_r, new_c];
            end
        end
    end
end

function [moves, attacks] = elephant_moves_attacks(board, r, c)
    % 相/象的移动和攻击范围
    moves = [];
    attacks = [];
    possible_moves = [r-2,c-2; r-2,c+2; r+2,c-2; r+2,c+2];
    obstacles = [r-1,c-1; r-1,c+1; r+1,c-1; r+1,c+1]; % 象眼位置
    
    is_red = board(r,c) <= 7;
    
    for i = 1:size(possible_moves,1)
        new_r = possible_moves(i,1);
        new_c = possible_moves(i,2);
        obs_r = obstacles(i,1);
        obs_c = obstacles(i,2);
        
        % 检查边界
        if new_r < 1 || new_r > 10 || new_c < 1 || new_c > 9
            continue;
        end
        
        % 检查象眼是否被阻挡
        if board(obs_r, obs_c) > 0
            continue;
        end
        
        % 检查是否过河
        not_crossed = false;
        if is_red % 红方（下方，不能低于第6行）
            not_crossed = new_r >= 6;
        else % 黑方（上方，不能高于第5行）
            not_crossed = new_r <= 5;
        end
        
        if not_crossed
            % 移动范围：可以移动到空位
            if board(new_r, new_c) == 0
                moves = [moves; new_r, new_c];
            end
            
            % 攻击范围：可以攻击敌方棋子位置
            if board(new_r, new_c) > 0 && (board(new_r, new_c) <= 7) ~= is_red
                attacks = [attacks; new_r, new_c];
            end
        end
    end
end

function [moves, attacks] = horse_moves_attacks(board, r, c)
    % 马的移动和攻击范围
    moves = [];
    attacks = [];
    possible_moves = [r-2,c-1; r-2,c+1; r-1,c-2; r-1,c+2; ...
                     r+1,c-2; r+1,c+2; r+2,c-1; r+2,c+1];
    obstacles = [r-1,c; r-1,c; r,c-1; r,c+1; ...
                r,c-1; r,c+1; r+1,c; r+1,c]; % 马腿位置
    
    for i = 1:size(possible_moves,1)
        new_r = possible_moves(i,1);
        new_c = possible_moves(i,2);
        obs_r = obstacles(i,1);
        obs_c = obstacles(i,2);
        
        % 检查边界
        if new_r < 1 || new_r > 10 || new_c < 1 || new_c > 9
            continue;
        end
        
        % 检查马腿是否被阻挡
        if board(obs_r, obs_c) > 0
            continue;
        end
        
        is_red = board(r,c) <= 7;
        
        % 移动范围：可以移动到空位
        if board(new_r, new_c) == 0
            moves = [moves; new_r, new_c];
        end
        
        % 攻击范围：可以攻击敌方棋子位置
        if board(new_r, new_c) > 0 && (board(new_r, new_c) <= 7) ~= is_red
            attacks = [attacks; new_r, new_c];
        end
    end
end

function [moves, attacks] = chariot_moves_attacks(board, r, c)
    % 车的移动和攻击范围
    moves = [];
    attacks = [];
    directions = [0,1; 0,-1; 1,0; -1,0]; % 右、左、下、上
    
    is_red = board(r,c) <= 7;
    
    for dir = directions'
        for dist = 1:9
            new_r = r + dir(1)*dist;
            new_c = c + dir(2)*dist;
            
            % 检查边界
            if new_r < 1 || new_r > 10 || new_c < 1 || new_c > 9
                break;
            end
            
            target = board(new_r, new_c);
            
            if target == 0
                % 可以移动到空位
                moves = [moves; new_r, new_c];
            else
                % 可以攻击敌方棋子
                if (target <= 7) ~= is_red
                    attacks = [attacks; new_r, new_c];
                end
                % 被阻挡，停止搜索这个方向
                break;
            end
        end
    end
end

function [moves, attacks] = cannon_moves_attacks(board, r, c)
    % 炮的移动和攻击范围
    moves = [];
    attacks = [];
    directions = [0,1; 0,-1; 1,0; -1,0]; % 右、左、下、上
    is_red = board(r,c) <= 7;
    
    for dir = directions'
        % 第一阶段：寻找炮架
        found_screen = false;
        dist = 1;
        
        while true
            new_r = r + dir(1)*dist;
            new_c = c + dir(2)*dist;
            
            % 检查边界
            if new_r < 1 || new_r > 10 || new_c < 1 || new_c > 9
                break;
            end
            
            target = board(new_r, new_c);
            
            if ~found_screen
                % 移动范围：可以移动到空位
                if target == 0
                    moves = [moves; new_r, new_c];
                else
                    % 遇到炮架
                    found_screen = true;
                end
            else
                % 攻击范围：炮架后可以攻击敌方棋子位置
                if target > 0
                    if (target <= 7) ~= is_red
                        attacks = [attacks; new_r, new_c];
                    end
                    break;
                end
            end
            
            dist = dist + 1;
        end
    end
end

function [moves, attacks] = pawn_moves_attacks(board, r, c, piece_val)
    % 兵/卒的移动和攻击范围
    moves = [];
    attacks = [];
    is_red = piece_val <= 7;
    
    % 基本移动方向
    if is_red
        basic_moves = [-1, 0]; % 前进
    else
        basic_moves = [1, 0]; % 前进
    end
    
    % 过河后可左右移动
    if (is_red && r <= 6) || (~is_red && r >= 5)
        moves_list = [basic_moves; 0,1; 0,-1];
    else
        moves_list = basic_moves;
    end
    
    for move = moves_list'
        new_r = r + move(1);
        new_c = c + move(2);
        
        % 检查边界
        if new_r < 1 || new_r > 10 || new_c < 1 || new_c > 9
            continue;
        end
        
        target = board(new_r, new_c);
        
        % 移动范围：可以移动到空位
        if target == 0
            moves = [moves; new_r, new_c];
        end
        
        % 攻击范围：可以攻击敌方棋子位置
        if target > 0 && (target <= 7) ~= is_red
            attacks = [attacks; new_r, new_c];
        end
    end
end