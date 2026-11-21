function draw_chinese_chess(board)
    % 创建一个新图形窗口
    figure('Name', '中国象棋局势可视化', 'NumberTitle', 'off', ...
           'Position', [100, 100, 800, 800], 'Color', 'white');
    hold on;
    axis equal;
    axis off;
    set(gca, 'YDir', 'reverse');  % 确保棋盘方向正确
    
    % 定义棋盘参数
    board_width = 9;   % 9列
    board_height = 10;  % 10行
    square_size = 1;   % 单位尺寸
    border = 0.5;      % 边框大小
    
    % 绘制棋盘网格
    draw_board_grid(board_width, board_height, square_size);
    
    % 添加楚河汉界标记
    draw_river_label(board_width);
    
    % 绘制棋子
    draw_chess_pieces(board, square_size, border);
    
    % 添加坐标标签
    add_coordinate_labels(board_width, board_height, square_size, border);
    
    % 添加图例
    add_legend();
    
    hold off;
end

function draw_board_grid(width, height, size)
    % 绘制水平线
    for y = 0:height
        if y == 0 || y == height
            line_width = 2.0;  % 边缘线加粗
        else
            line_width = 1.5;
        end
        plot([0, width*size], [y*size, y*size], 'k', 'LineWidth', line_width);
    end
    
    % 绘制垂直线
    for x = 0:width
        if x == 0 || x == width
            line_width = 2.0;  % 边缘线加粗
        else
            line_width = 1.5;
        end
        plot([x*size, x*size], [0, height*size], 'k', 'LineWidth', line_width);
    end
    
    % 绘制九宫斜线
    % 黑方九宫
    plot([3*size, 5*size], [0, 2*size], 'k', 'LineWidth', 1.5);
    plot([3*size, 5*size], [2*size, 0], 'k', 'LineWidth', 1.5);
    % 红方九宫
    plot([3*size, 5*size], [7*size, 9*size], 'k', 'LineWidth', 1.5);
    plot([3*size, 5*size], [9*size, 7*size], 'k', 'LineWidth', 1.5);
    
    % 绘制边界
    rectangle('Position', [0, 0, width*size, height*size], ...
              'EdgeColor', 'k', 'LineWidth', 3);
end

function draw_river_label(width)
    % 在河界处添加标记
    size = 1;
    text(width*size/2, 4.7*size, '楚 河', 'FontSize', 16, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    text(width*size/2, 5.3*size, '汉 界', 'FontSize', 16, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end

function draw_chess_pieces(board, Square_size, border)
    % 定义棋子名称
    piece_names = {'', '帅', '仕', '相', '马', '车', '炮', '兵', ...
                      '将', '士', '象', '马', '车', '炮', '卒'};
    
    % 计算交叉点位置并放置棋子
    for row = 1:size(board,1)
        for col = 1:size(board,2)
            piece_value = board(row, col);
            if piece_value ~= 0
                % 计算棋子位置坐标
                x = (col-1) * Square_size + border;
                y = (row-1) * Square_size + border;
                
                % 选择颜色（红方红色，黑方蓝色）
                if piece_value <= 7
                    color = [0.8, 0.1, 0.1];  % 红色
                    text_color = 'red';
                else
                    color = [0.1, 0.1, 0.6];  % 深蓝色
                    text_color = 'blue';
                end
                
                % 绘制棋子底部的圆形
                rectangle('Position', [x-0.4, y-0.4, 0.8, 0.8], ...
                          'Curvature', [1,1], 'FaceColor', color, ...
                          'EdgeColor', 'black', 'LineWidth', 1.5);
                
                % 添加棋子名称
                text(x, y, piece_names{piece_value+1}, ...
                     'Color', 'white', 'FontSize', 16, ...
                     'FontWeight', 'bold', ...
                     'HorizontalAlignment', 'center', ...
                     'VerticalAlignment', 'middle');
            end
        end
    end
end

function add_coordinate_labels(width, height, size, border)
    % 添加横向坐标标签（字母a-i）
    for i = 1:width
        x = (i-1)*size + border;
        text(x, height*size + 0.3, char('a' + i - 1), ...
            'FontSize', 12, 'HorizontalAlignment', 'center');
    end
    
    % 添加纵向坐标标签（数字9-0）
    for i = 1:height
        y = (i-1)*size + border;
        text(-0.3, y, num2str(10-i), ...
            'FontSize', 12, 'HorizontalAlignment', 'center');
    end
end

function add_legend()
    % 在图形底部添加图例
    legend_x = 0.5;
    legend_y = -1.8;
    
    % 红方棋子图例
    text(legend_x, legend_y, '红方: 帅 仕 相 马 车 炮 兵', ...
         'Color', 'red', 'FontSize', 14, ...
         'HorizontalAlignment', 'center');
    
    % 黑方棋子图例
    text(legend_x, legend_y-0.6, '黑方: 将 士 象 马 车 炮 卒', ...
         'Color', 'blue', 'FontSize', 14, ...
         'HorizontalAlignment', 'center');
end



