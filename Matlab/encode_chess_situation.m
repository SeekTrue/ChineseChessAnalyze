function situation_code = encode_chess_situation(board)
    % 初始化16字符编码
    situation_code = '';
    
    % 1. 红方兵状态（1字符）
    red_pawns = get_pawn_status(board, 7);
    situation_code(1) = encode_status(red_pawns);
    
    % 2. 红方帅士相状态（1字符）
    red_king_group = get_king_group_status(board, 1:3);
    situation_code(2) = encode_status(red_king_group);
    
    % 3. 红方车马炮状态（3字符）
    red_chariots = get_piece_status(board, 5);
    red_horses = get_piece_status(board, 4);
    red_cannons = get_piece_status(board, 6);
    situation_code(3) = encode_position(red_chariots(1,:));
    situation_code(4) = encode_position(red_chariots(2,:));
    situation_code(5) = encode_position(red_horses(1,:));
    situation_code(6) = encode_position(red_horses(2,:));
    situation_code(7) = encode_position(red_cannons(1,:));
    situation_code(8) = encode_position(red_cannons(2,:));
    
    % 4. 黑方卒状态（1字符）
    black_pawns = get_pawn_status(board, 14);
    situation_code(9) = encode_status(black_pawns);
    
    % 5. 黑方将士象状态（1字符）
    black_king_group = get_king_group_status(board, 8:10);
    situation_code(10) = encode_status(black_king_group);
    
    % 6. 黑方车马炮状态（3字符）
    black_chariots = get_piece_status(board, 12);
    black_horses = get_piece_status(board, 11);
    black_cannons = get_piece_status(board, 13);
    situation_code(11) = encode_position(black_chariots(1,:));
    situation_code(12) = encode_position(black_chariots(2,:));
    situation_code(13) = encode_position(black_horses(1,:));
    situation_code(14) = encode_position(black_horses(2,:));
    situation_code(15) = encode_position(black_cannons(1,:));
    situation_code(16) = encode_position(black_cannons(2,:));
end

function status = get_pawn_status(board, piece_val)
    % 获取兵/卒状态
    [rows, cols] = find(board == piece_val);
    all_positions = [rows, cols];
    
    % 初始化5个兵的状态
    status = zeros(1,5);
    
    % 标准兵位置（红方：第3,5,7列；黑方：第3,5,7列）
    standard_cols = [3,5,7];
    
    for i = 1:5
        if i <= size(all_positions,1)
            r = all_positions(i,1);
            c = all_positions(i,2);
            
            if piece_val == 7 % 红兵
                if r <= 6 % 过河
                    if r == 1 % 底线
                        status(i) = 3;
                    else
                        status(i) = 2;
                    end
                else % 未过河
                    status(i) = 1;
                end
            else % 黑卒
                if r >= 5 % 过河
                    if r == 10 % 底线
                        status(i) = 3;
                    else
                        status(i) = 2;
                    end
                else % 未过河
                    status(i) = 1;
                end
            end
        else
            status(i) = 0; % 被吃
        end
    end
end

function status = get_king_group_status(board, piece_vals)
    % 获取将帅士象状态
    % 初始化8位状态
    status_bits = zeros(1,8);
    
    % 1. 帅/将状态（2位）
    king_val = piece_vals(1);
    [king_r, king_c] = find(board == king_val, 1);
    if isempty(king_r)
        status_bits(1:2) = [0,0]; % 被吃
    else
        % 是否在九宫中心（4,5列）
        in_center = (king_c >= 4 && king_c <= 6);
        status_bits(1) = 1; % 存在
        status_bits(2) = in_center;
    end
    
    % 2. 士/象状态（各2位）
    advisor_val = piece_vals(2);
    elephant_val = piece_vals(3);
    
    % 获取所有士/象
    advisors = find(board == advisor_val);
    elephants = find(board == elephant_val);
    
    % 左士/象状态
    if numel(advisors) >= 1
        status_bits(3) = 1; % 存在
        [r,c] = ind2sub(size(board), advisors(1));
        status_bits(4) = (c == 4); % 是否在标准位置
    end
    
    if numel(elephants) >= 1
        status_bits(5) = 1; % 存在
        [r,c] = ind2sub(size(board), elephants(1));
        status_bits(6) = (c == 3); % 是否在标准位置
    end
    
    % 右士/象状态
    if numel(advisors) >= 2
        status_bits(7) = 1; % 存在
        [r,c] = ind2sub(size(board), advisors(2));
        status_bits(8) = (c == 6); % 是否在标准位置
    end
    
    % 转换为十进制
    status = bin2dec(num2str(status_bits));
end

function positions = get_piece_status(board, piece_val)
    % 获取车/马/炮状态
    [rows, cols] = find(board == piece_val);
    all_positions = [rows, cols];
    
    % 初始化2个位置
    positions = zeros(2,2) + 127; % 127表示被吃
    
    for i = 1:min(2, size(all_positions,1))
        positions(i,:) = all_positions(i,:);
    end
end

function char_code = encode_status(status_value)
    % 将状态值编码为汉字
    % 状态值范围：0-255
    % 映射到Unicode：4E00-4EFF（基本汉字）
    unicode_val = 19968 + status_value; % 4E00 = 19968
    char_code = char(unicode_val);
end

function char_code = encode_position(position)
    % 将位置编码为汉字
    % position: [行, 列]
    if all(position == 127) % 被吃
        char_code = char(19968); % "一"
    else
        r = position(1);
        c = position(2);
        % 编码：前3位行，后3位列
        encoded_value = (r-1)*9 + (c-1);
        unicode_val = 19968 + encoded_value;
        char_code = char(unicode_val);
    end
end