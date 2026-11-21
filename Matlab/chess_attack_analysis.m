function chess_attack_analysis(board)
    % 创建主图形窗口
    fig = figure('Name', '中国象棋攻击范围分析', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 1200, 800], 'Color', 'white');
    
    % 创建主棋盘
    ax_board = subplot(1,3,1);
    draw_chess_board(ax_board, board);
    title(ax_board, '原始棋盘');
    
    % 创建红方攻击图
    ax_red_attack = subplot(1,3,2);
    draw_chess_board(ax_red_attack, board);
    [red_attack_map, red_attack_list] = calculate_attack(board, 1:7);
    plot_attack_range(ax_red_attack, red_attack_map, [1, 0, 0]);
    title(ax_red_attack, '红方攻击范围');
    
    % 创建黑方攻击图
    ax_black_attack = subplot(1,3,3);
    draw_chess_board(ax_black_attack, board);
    [black_attack_map, black_attack_list] = calculate_attack(board, 8:14);
    plot_attack_range(ax_black_attack, black_attack_map, [0, 0, 1]);
    title(ax_black_attack, '黑方攻击范围');
    
    % 在窗口底部显示攻击点列表
    display_attack_positions(fig, red_attack_list, black_attack_list);
    
    % 打印总攻击点数
    fprintf('总攻击点统计:\n');
    fprintf('红方攻击点: %d\n', length(red_attack_list));
    fprintf('黑方攻击点: %d\n\n', length(black_attack_list));
end

function draw_chess_board(ax, board)
    % 设置坐标轴属性
    axes(ax);
    axis equal;
    axis off;
    hold on;
    set(ax, 'YDir', 'reverse');
    
    % 定义棋盘参数
    x_min = 0; x_max = 8; y_min = 0; y_max = 9;
    
    % 绘制棋盘网格
    for y = y_min:y_max
        plot([x_min, x_max], [y, y], 'k', 'LineWidth', 1.5);
    end
    for x = x_min:x_max
        plot([x, x], [y_min, 4], 'k', 'LineWidth', 1.5);
        plot([x, x], [5, y_max], 'k', 'LineWidth', 1.5);
    end
    plot([x_min, x_min, x_max, x_max, x_min], ...
         [y_min, y_max, y_max, y_min, y_min], 'k', 'LineWidth', 2.5);
    
    % 绘制九宫斜线
    plot([3,5], [0,2], 'k', 'LineWidth', 1.5);
    plot([5,3], [0,2], 'k', 'LineWidth', 1.5);
    plot([3,5], [8,10]-1, 'k', 'LineWidth', 1.5);
    plot([5,3], [8,10]-1, 'k', 'LineWidth', 1.5);
    
    % 添加楚河汉界标记
    text(1.5, 4.5, '楚 河', 'FontSize', 14, 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'center', 'Color', [0.3, 0.1, 0]);
    text(6.5, 4.5, '汉 界', 'FontSize', 14, 'FontWeight', 'bold', ...
         'HorizontalAlignment', 'center', 'Color', [0.3, 0.1, 0]);
    
    % 绘制棋子
    piece_names = {'', '帅', '仕', '相', '马', '车', '炮', '兵', ...
                  '将', '士', '象', '马', '车', '炮', '卒'};
    for row = 1:size(board,1)
        for col = 1:size(board,2)
            piece_val = board(row,col);
            if piece_val > 0
                x = col-1; y = row-1;
                
                if piece_val <= 7 % 红方棋子
                    color = [0.8, 0.1, 0.1];
                    text_color = 'white';
                else % 黑方棋子
                    color = [0.1, 0.1, 0.6];
                    text_color = 'white';
                end
                
                % 绘制棋子
                rectangle('Position', [x-0.4, y-0.4, 0.8, 0.8], ...
                         'Curvature', [1,1], 'FaceColor', color, ...
                         'EdgeColor', 'black', 'LineWidth', 1);
                text(x, y, piece_names{piece_val+1}, ...
                     'Color', text_color, 'FontSize', 14, ...
                     'FontWeight', 'bold', 'FontName', 'SimHei', ...
                     'HorizontalAlignment', 'center', ...
                     'VerticalAlignment', 'middle');
            end
        end
    end
    
    % 添加坐标标签
    for x = 0:8
        text(x, y_min-0.2, char('a'+x), 'FontSize', 10, ...
            'HorizontalAlignment', 'center');
    end
    for y = 0:9
        text(x_min-0.2, y, num2str(9-y), 'FontSize', 10, ...
            'HorizontalAlignment', 'center');
    end
    
    hold off;
    xlim([-1,10]);
    ylim([-1,11]);
end

function [attack_map, attack_list] = calculate_attack(board, side)
    % 创建攻击图矩阵（10行9列）
    attack_map = false(size(board));
    attack_list = [];
    
    % 棋子类型映射
    % 1(帅)/8(将), 2(仕)/9(士), 3(相)/10(象), 4(马)/11(马), 
    % 5(车)/12(车), 6(炮)/13(炮), 7(兵)/14(卒)
    
    for r = 1:size(board,1)
        for c = 1:size(board,2)
            piece = board(r,c);
            if ismember(piece, side)
                % 根据棋子类型调用对应的攻击计算函数
                switch piece
                    case {1,8} % 帅/将
                        attacks = attack_king(board, r, c);
                    case {2,9} % 仕/士
                        attacks = attack_advisor(board, r, c);
                    case {3,10} % 相/象
                        attacks = attack_elephant(board, r, c);
                    case {4,11} % 马
                        attacks = attack_horse(board, r, c);
                    case {5,12} % 车
                        attacks = attack_chariot(board, r, c);
                    case {6,13} % 炮
                        attacks = attack_cannon(board, r, c);
                    case {7,14} % 兵/卒
                        attacks = attack_pawn(board, r, c, piece);
                end
                
                % 更新攻击图
                for i = 1:size(attacks,1)
                    attack_r = attacks(i,1);
                    attack_c = attacks(i,2);
                    attack_map(attack_r, attack_c) = true;
                    attack_list = [attack_list; attack_r, attack_c];
                end
            end
        end
    end
    
    % 去除重复攻击点
    attack_list = unique(attack_list, 'rows');
end

function attacks = attack_king(board, r, c)
    % 帅/将的移动：九宫格内上下左右移动一格
    attacks = [];
    moves = [0,1; 0,-1; 1,0; -1,0];
    
    for move = moves'
        new_r = r + move(1);
        new_c = c + move(2);
        
        % 检查是否在九宫格内
        is_red = board(r,c) <= 7;
        in_palace = false;
        if is_red % 红方九宫（下方7-9行）
            in_palace = (new_r >= 8 && new_r <= 10) && (new_c >= 4 && new_c <= 6);
        else % 黑方九宫（上方1-3行）
            in_palace = (new_r >= 1 && new_r <= 3) && (new_c >= 4 && new_c <= 6);
        end
        
        % 检查边界和目标位置是否有己方棋子
        if new_r >= 1 && new_r <= 10 && new_c >= 1 && new_c <= 9 && ...
           in_palace && (board(new_r, new_c) == 0 || ...
           (board(new_r, new_c) <= 7) ~= is_red)
            attacks = [attacks; new_r, new_c];
        end
    end
end

function attacks = attack_advisor(board, r, c)
    % 仕/士的移动：九宫格内斜线移动一格
    attacks = [];
    moves = [1,1; 1,-1; -1,1; -1,-1];
    
    for move = moves'
        new_r = r + move(1);
        new_c = c + move(2);
        
        % 检查是否在九宫格内
        is_red = board(r,c) <= 7;
        in_palace = false;
        if is_red % 红方九宫
            in_palace = (new_r >= 8 && new_r <= 10) && (new_c >= 4 && new_c <= 6);
        else % 黑方九宫
            in_palace = (new_r >= 1 && new_r <= 3) && (new_c >= 4 && new_c <= 6);
        end
        
        % 检查边界和目标位置是否有己方棋子
        if new_r >= 1 && new_r <= 10 && new_c >= 1 && new_c <= 9 && ...
           in_palace && (board(new_r, new_c) == 0 || ...
           (board(new_r, new_c) <= 7) ~= is_red)
            attacks = [attacks; new_r, new_c];
        end
    end
end

function attacks = attack_elephant(board, r, c)
    % 相/象的移动：田字对角线移动，不能过河
    attacks = [];
    moves = [2,2; 2,-2; -2,2; -2,-2];
    obstacles = [1,1; 1,-1; -1,1; -1,-1]; % 象眼位置
    
    for i = 1:size(moves,1)
        move = moves(i,:);
        obs_move = obstacles(i,:);
        
        new_r = r + move(1);
        new_c = c + move(2);
        obs_r = r + obs_move(1);
        obs_c = c + obs_move(2);
        
        % 检查边界和象眼是否被阻挡
        if new_r >= 1 && new_r <= 10 && new_c >= 1 && new_c <= 9 && ...
           board(obs_r, obs_c) == 0
           
           % 检查是否过河
           is_red = board(r,c) <= 7;
           not_crossed = false;
           if is_red % 红方（下方，不能低于第6行）
               not_crossed = new_r >= 6;
           else % 黑方（上方，不能高于第5行）
               not_crossed = new_r <= 5;
           end
           
           % 检查目标位置是否有己方棋子
           if not_crossed && (board(new_r, new_c) == 0 || ...
              (board(new_r, new_c) <= 7) ~= is_red)
                attacks = [attacks; new_r, new_c];
           end
        end
    end
end

function attacks = attack_horse(board, r, c)
    % 马的移动：走日字，马腿不能被阻挡
    attacks = [];
    moves = [1,2; 2,1; -1,2; 2,-1; 1,-2; -2,1; -1,-2; -2,-1];
    obstacles = [0,1; 1,0; 0,1; 1,0; 0,-1; -1,0; 0,-1; -1,0]; % 马腿位置
    
    for i = 1:size(moves,1)
        move = moves(i,:);
        obs_move = obstacles(i,:);
        
        new_r = r + move(1);
        new_c = c + move(2);
        obs_r = r + obs_move(1);
        obs_c = c + obs_move(2);
        
        % 检查边界和马腿是否被阻挡
        if new_r >= 1 && new_r <= 10 && new_c >= 1 && new_c <= 9 && ...
           board(obs_r, obs_c) == 0
           
           % 检查目标位置是否有己方棋子
           is_red = board(r,c) <= 7;
           if board(new_r, new_c) == 0 || ...
              (board(new_r, new_c) <= 7) ~= is_red
                attacks = [attacks; new_r, new_c];
           end
        end
    end
end

function attacks = attack_chariot(board, r, c)
    % 车的移动：直线任意格，直到被阻挡
    attacks = [];
    directions = [0,1; 0,-1; 1,0; -1,0]; % 右、左、下、上
    
    for dir = directions'
        for dist = 1:9
            new_r = r + dir(1)*dist;
            new_c = c + dir(2)*dist;
            
            % 检查边界
            if new_r < 1 || new_r > 10 || new_c < 1 || new_c > 9
                break;
            end
            
            is_red = board(r,c) <= 7;
            target = board(new_r, new_c);
            
            if target == 0
                % 可以移动到空位
                attacks = [attacks; new_r, new_c];
            else
                % 检查是否可以吃掉对方棋子
                if (target <= 7) ~= is_red
                    attacks = [attacks; new_r, new_c];
                end
                % 被阻挡，停止搜索这个方向
                break;
            end
        end
    end
end

function [ attack_range,move_range] = attack_cannon(board, r, c)
    % 炮的移动范围：直线移动直到被阻挡（不含跳跃吃子）
    % 炮的攻击范围：炮架后直到阻挡棋子（含阻挡棋子）的全部位置
    
    move_range = [];
    attack_range = [];
    directions = [0,1; 0,-1; 1,0; -1,0]; % 右、左、下、上
    piece_val = board(r,c);
    is_red = piece_val <= 7;
    
    for dir = directions'
        % 初始化方向搜索
        dist = 1;
        found_screen = false;
        
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
                    move_range = [move_range; new_r, new_c];
                else
                    % 遇到第一个非空位置（炮架）
                    found_screen = true;
                    
                    % 记录炮架位置（用于攻击范围起点）
                    screen_r = new_r;
                    screen_c = new_c;
                end
            else
                % 攻击范围：炮架后所有位置（含阻挡棋子）
                attack_range = [attack_range; new_r, new_c];
                
                % 如果遇到阻挡棋子（任何棋子），停止搜索这个方向
                if target > 0
                    break;
                end
            end
            
            dist = dist + 1;
        end
    end
    
    % 过滤攻击范围：只保留敌方棋子或空位（不含己方棋子）
    valid_attacks = [];
    for i = 1:size(attack_range,1)
        ar = attack_range(i,1);
        ac = attack_range(i,2);
        target_val = board(ar,ac);
        
        if target_val == 0 || (target_val <= 7) ~= is_red
            valid_attacks = [valid_attacks; ar, ac];
        end
    end
    attack_range = valid_attacks;
end

function attacks = attack_pawn(board, r, c, piece)
    % 兵/卒的移动：只能向前或横向移动（过河后）
    attacks = [];
    is_red = piece <= 7;
    
    % 前进方向（红方向上（矩阵行号减少），黑方向下（矩阵行号增加））
    forward_dir = [-1, 0]; % 红方向前（行号-1）
    if ~is_red
        forward_dir = [1, 0]; % 黑方向前（行号+1）
    end
    
    % 基本移动：只能向前
    moves = forward_dir;
    
    % 红兵：当行号<=6时，可以左右移动
    if is_red && r <= 5
        moves = [moves; 0,1; 0,-1];
    end
    % 黑卒：当行号>=5时，可以左右移动
    if ~is_red && r >= 6
        moves = [moves; 0,1; 0,-1];
    end
    
    % 遍历所有可能的移动
    for i = 1:size(moves,1)
        move = moves(i,:);
        new_r = r + move(1);
        new_c = c + move(2);
        
        % 检查边界
        if new_r >= 1 && new_r <= 10 && new_c >= 1 && new_c <= 9
            target = board(new_r, new_c);
            
            % 只能移动到空位或吃对方棋子
            if target == 0 || (target <= 7) ~= is_red
                attacks = [attacks; new_r, new_c];
            end
        end
    end
end

function plot_attack_range(ax, attack_map, color)
    % 在指定坐标轴上绘制攻击范围
    axes(ax);
    hold on;
    
    [rows, cols] = size(attack_map);
    marker_size = 150;
    
    for r = 1:rows
        for c = 1:cols
            if attack_map(r,c)
                % 绘制攻击点（转换为交点的坐标）
                x = c-1;
                y = r-1;
                scatter(x, y, marker_size, color, 'filled', ...
                        'MarkerFaceAlpha', 0.3, 'MarkerEdgeColor', color);
            end
        end
    end
    
    hold off;
end

function display_attack_positions(fig, red_attacks, black_attacks)
    % 在图形窗口底部显示攻击点列表
    pos = get(fig, 'Position');
    uipanel_height = 120;
    
    % 创建面板
    panel = uipanel('Parent', fig, 'Position', [0, 0, 1, uipanel_height/pos(4)], ...
                    'BackgroundColor', [0.95, 0.95, 0.95], ...
                    'BorderType', 'etchedin');
    
    % 红方攻击点列表
    uicontrol('Parent', panel, 'Style', 'text', 'String', '红方攻击点:', ...
              'Position', [20, 80, 100, 20], 'FontSize', 10, ...
              'FontWeight', 'bold', 'ForegroundColor', [0.8, 0, 0], ...
              'BackgroundColor', [0.95, 0.95, 0.95], 'HorizontalAlignment', 'left');
    
    attack_str = '';
    for i = 1:size(red_attacks,1)
        r = red_attacks(i,1);
        c = red_attacks(i,2);
        letter = char('a' + c-1);
        num = 10 - (r-1);
        attack_str = [attack_str, sprintf('(%s%d) ', letter, num)];
    end
    uicontrol('Parent', panel, 'Style', 'text', 'String', attack_str, ...
              'Position', [20, 60, pos(3)-40, 20], 'FontSize', 9, ...
              'ForegroundColor', 'black', 'BackgroundColor', [0.95, 0.95, 0.95], ...
              'HorizontalAlignment', 'left');
    
    % 黑方攻击点列表
    uicontrol('Parent', panel, 'Style', 'text', 'String', '黑方攻击点:', ...
              'Position', [20, 30, 100, 20], 'FontSize', 10, ...
              'FontWeight', 'bold', 'ForegroundColor', [0, 0, 0.8], ...
              'BackgroundColor', [0.95, 0.95, 0.95], 'HorizontalAlignment', 'left');
    
    attack_str = '';
    for i = 1:size(black_attacks,1)
        r = black_attacks(i,1);
        c = black_attacks(i,2);
        letter = char('a' + c-1);
        num = 10 - (r-1);
        attack_str = [attack_str, sprintf('(%s%d) ', letter, num)];
    end
    uicontrol('Parent', panel, 'Style', 'text', 'String', attack_str, ...
              'Position', [20, 10, pos(3)-40, 20], 'FontSize', 9, ...
              'ForegroundColor', 'black', 'BackgroundColor', [0.95, 0.95, 0.95], ...
              'HorizontalAlignment', 'left');
end
