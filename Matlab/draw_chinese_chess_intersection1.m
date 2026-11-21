function draw_chinese_chess_intersection1(board)
    % 创建一个新图形窗口
    fig = figure('Name', '中国象棋局势可视化', 'NumberTitle', 'off', ...
                 'Position', [100, 100, 800, 900], 'Color', 'white');
    
    % 创建坐标轴并设置属性
    ax = axes('Parent', fig);
    axis(ax, 'equal');
    axis(ax, 'off');
    hold(ax, 'on');
    
    % 设置坐标系方向（棋盘方向）
    set(ax, 'YDir', 'reverse');
    
    % 定义棋盘参数
    x_min = 0;
    y_min = 0;
    x_max = 8;  % 9列
    y_max = 9; % 10行
    
    % 绘制棋盘网格
    draw_grid(ax, x_min, x_max, y_min, y_max);
    
    % 绘制九宫斜线
    draw_palace_lines(ax);
    
    % 添加楚河汉界标记
    draw_river_label(ax);
    
    % 绘制棋子（在交点处）
    draw_pieces(ax, board, x_min, y_min);
    
%     % 添加坐标标签
%     add_coordinate_labels(ax, x_min, x_max, y_min, y_max);
%     
%     % 添加图例
%     add_legend(ax);
    
    hold(ax, 'off');
end

function draw_grid(ax, x_min, x_max, y_min, y_max)
    % 绘制10条水平线（9条横线+1条底线）
    for y = y_min:y_max
        plot(ax, [x_min, x_max], [y, y], 'k', 'LineWidth', 2);
    end
    
    % 绘制9条垂直线（8条纵线+1条边线）
    for x = x_min:x_max
        plot(ax, [x, x], [y_min, 4], 'k', 'LineWidth', 2);
        plot(ax, [x, x], [5, y_max], 'k', 'LineWidth', 2);
    end
    
    % 绘制棋盘边界
    plot(ax, [x_min, x_min, x_max, x_max, x_min], ...
              [y_min, y_max, y_max, y_min, y_min], 'k', 'LineWidth', 3);
end

function draw_palace_lines(ax)
    % 绘制上方九宫格（黑方）
    plot(ax, [3, 5], [0, 2], 'k', 'LineWidth', 1.5);
    plot(ax, [5, 3], [0, 2], 'k', 'LineWidth', 1.5);
    
    % 绘制下方九宫格（红方）
    plot(ax, [3, 5], [8, 10]-1, 'k', 'LineWidth', 1.5);
    plot(ax, [5, 3], [8, 10]-1, 'k', 'LineWidth', 1.5);
end

function draw_river_label(ax)
    % 在河界处添加标记
    text(ax, 1.5, 4.5, '楚 河', 'FontSize', 20, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0.3, 0.1, 0]);
    text(ax, 6.5, 4.5, '汉 界', 'FontSize', 20, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0.3, 0.1, 0]);
end

function draw_pieces(ax, board, x_min, y_min)
    % 定义棋子名称（索引从1开始）
    piece_names = {'帅', '仕', '相', '马', '车', '炮', '兵', ...
                   '将', '士', '象', '马', '车', '炮', '卒'};
    
    % 获取棋盘尺寸
    [rows, cols] = size(board);
    
    % 在交点处绘制棋子
    for row = 1:rows
        for col = 1:cols
            piece_val = board(row, col);
            if piece_val > 0
                % 计算交点坐标
                x = col - 1;  % 列坐标：0到8
                y = row - 1;  % 行坐标：0到9
                
                % 确定棋子属性
                if piece_val <= 7 % 红方棋子
                    name = piece_names{piece_val};
                    piece_color = [0.8, 0.1, 0.1];  % 红色
                    text_color = 'white';
                else % 黑方棋子
                    name = piece_names{piece_val };
                    piece_color = [0.15, 0.15, 0.4]; % 深蓝色
                    text_color = 'white';
                end
                
                % 绘制棋子圆形背景
                radius = 0.4;
                rectangle(ax, 'Position', [x-radius, y-radius, 2*radius, 2*radius], ...
                         'Curvature', [1, 1], 'FaceColor', piece_color, ...
                         'EdgeColor', 'black', 'LineWidth', 1.5);
                
                % 添加棋子文字（使用交点坐标）
                text(ax, x, y, name, 'Color', text_color, 'FontSize', 18, ...
                     'FontWeight', 'bold', 'FontName', 'SimHei', ...
                     'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
            end
        end
    end
end

function add_coordinate_labels(ax, x_min, x_max, y_min, y_max)
    % 添加横向坐标标签（字母a-i）
    for x = 0:8
        text(ax, x, y_max + 0.2, char('a' + x), 'FontSize', 14, ...
            'HorizontalAlignment', 'center');
        text(ax, x, y_min - 0.2, char('a' + x), 'FontSize', 14, ...
            'HorizontalAlignment', 'center');
    end
    
    % 添加纵向坐标标签（数字0-9）
    for y = 0:9
        text(ax, x_min - 0.2, y, num2str(9 - y), 'FontSize', 14, ...
            'HorizontalAlignment', 'center');
        text(ax, x_max + 0.2, y, num2str(9 - y), 'FontSize', 14, ...
            'HorizontalAlignment', 'center');
    end
end

function add_legend(ax)
    % 在图形顶部添加标题
    text(ax, 4.5, -0.8, '中国象棋局势', 'FontSize', 24, ...
         'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    % 添加红方图例
    text(ax, 1.5, -1.5, '红方: 帅仕相马车炮兵', ...
         'FontSize', 16, 'FontName', 'SimHei', ...
         'Color', 'red', 'HorizontalAlignment', 'center');
    
    % 添加黑方图例
    text(ax, 7.5, -1.5, '黑方: 将士象马车炮卒', ...
         'FontSize', 16, 'FontName', 'SimHei', ...
         'Color', 'blue', 'HorizontalAlignment', 'center');
end

