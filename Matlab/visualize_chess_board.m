function visualize_chess_board(board)
    % 定义棋子映射关系
    piece_map = containers.Map(...
        [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], ...
        {' ','帅','仕','相','马','车','炮','兵','将','士','象','马','车','炮','卒'});
    
    % 创建字符棋盘
    char_board = char(zeros(10,9));
    for i = 1:10
        for j = 1:9
            piece = board(i,j);
            char_board(i,j) = piece_map(piece);
        end
    end
    
    % 打印顶部列号
    fprintf('\n    a   b   c   d   e   f   g   h   i\n');
    
    % 打印顶部边框
    fprintf('  ┌───┬───┬───┬───┬───┬───┬───┬───┬───┐\n');
    
    % 打印棋盘内容
    for i = 1:10
        % 左侧行号 (9到0)
        row_num = 10 - i;
        
        % 行开头
        fprintf('%d │', row_num);
        
        % 打印棋子
        for j = 1:9
            piece_char = char_board(i,j);
            
            % 设置颜色（红方红色，黑方蓝色）
            if board(i,j) >= 1 && board(i,j) <= 7
                fprintf( ' %s │',piece_char); % 红色棋子
            elseif board(i,j) >= 8
                fprintf( ' %s │',piece_char); % 蓝色棋子
            else
                fprintf(' %s │', piece_char); % 空格
            end
        end
        
        % 右侧行号
        fprintf('%d\n', row_num);
        
        % 打印行间分隔线（最后一行特殊处理）
        if i < 10
            fprintf('  ├───┼───┼───┼───┼───┼───┼───┼───┼───┤\n');
        else
            fprintf('  └───┴───┴───┴───┴───┴───┴───┴───┴───┘\n');
        end
    end
    
    % 打印底部列号
    fprintf('    a   b   c   d   e   f   g   h   i\n');
    fprintf('\n');
    
    % 添加图例
    fprintf('红方: 帅K 仕A 相B 马H 车R 炮C 兵P\n');
    fprintf('黑方: 将k 士a 象b 马h 车r 炮c 卒p\n');
    fprintf('注: 彩色显示可能需要终端支持ANSI颜色\n');
end



% 可视化棋盘
