function chess_situation_analysis(board)
    % 计算双方攻击范围
    [red_attack_map, ~] = calculate_attack(board, 1:7);
    [black_attack_map, ~] = calculate_attack(board, 8:14);
    
    % 分析红方局势
    red_pieces = find_pieces(board, 1:7);
    red_analysis = analyze_situation(board, red_pieces, black_attack_map, red_attack_map);
    
    % 分析黑方局势
    black_pieces = find_pieces(board, 8:14);
    black_analysis = analyze_situation(board, black_pieces, red_attack_map, black_attack_map);
    
    % 输出结果
    fprintf('\n===== 按棋子组织分析结果 =====\n');
    display_by_piece(red_analysis, '红方');
    display_by_piece(black_analysis, '黑方');
    
    fprintf('\n===== 按状态组织分析结果 =====\n');
    display_by_status(red_analysis, '红方');
    display_by_status(black_analysis, '黑方');
end

function pieces = find_pieces(board, side)
    % 查找指定方的所有棋子位置
    pieces = [];
    for r = 1:size(board,1)
        for c = 1:size(board,2)
            if ismember(board(r,c), side)
                pieces = [pieces; r, c, board(r,c)];
            end
        end
    end
end

function analysis = analyze_situation(board, pieces, enemy_attack_map, own_attack_map)
    % 分析每个棋子的局势状态
    analysis = struct();
    
    for i = 1:size(pieces,1)
        r = pieces(i,1);
        c = pieces(i,2);
        piece_val = pieces(i,3);
        
        % 获取棋子基本信息
        piece_info = get_piece_info(piece_val);
        piece_name = piece_info.name;
        piece_type = piece_info.type;
        
        % 计算理论移动范围
        [theoretical_moves, max_moves] = calculate_theoretical_moves(piece_type, r, c);
        
        % 计算实际移动范围
        actual_moves = calculate_actual_moves(board, piece_type, r, c);
        
        % 分析七种状态
        status = struct();
        
        % 1. 危：棋子处于对方攻击范围内
        status.危 = enemy_attack_map(r, c);
        
        % 2. 险：棋子一步内会进入对方攻击范围
        status.险 = false;
        for move = actual_moves'
            new_r = move(1);
            new_c = move(2);
            if enemy_attack_map(new_r, new_c)
                status.险 = true;
                break;
            end
        end
        
        % 3. 疲：棋子承担重要任务（防守其他棋子或通道）
        status.疲 = is_overburdened(board, r, c, own_attack_map);
        
        % 4. 困：移动范围受限（实际移动范围 ≤ 理论移动范围的1/4）
        status.困 = length(actual_moves) <= max_moves/4;
        
        % 5. 串：与其他棋子在同一直线上易受串打
        status.串 = is_skewer_threat(board, r, c);
        
        % 6. 双：易被同时攻击两个棋子
        status.双 = is_double_attack_threat(board, r, c, enemy_attack_map);
        
        % 7. 游：无根子（无其他棋子保护）
        status.游 = is_orphaned(board, r, c, own_attack_map);
        
        % 保存分析结果
        analysis(i).position = [r, c];
        analysis(i).name = piece_name;
        analysis(i).type = piece_type;
        analysis(i).status = status;
        analysis(i).theoretical_moves = theoretical_moves;
        analysis(i).actual_moves = actual_moves;
        analysis(i).num_moves = length(actual_moves);
    end
end

function piece_info = get_piece_info(piece_val)
    % 获取棋子信息
    piece_names = {'帅', '仕', '相', '马', '车', '炮', '兵', ...
                   '将', '士', '象', '马', '车', '炮', '卒'};
    piece_types = {'帅将', '仕士', '相象', '马', '车', '炮', '兵卒', ...
                   '帅将', '仕士', '相象', '马', '车', '炮', '兵卒'};
    
    piece_info.name = piece_names{piece_val};
    piece_info.type = piece_types{piece_val};
end

function [moves, max_moves] = calculate_theoretical_moves(piece_type, r, c)
    % 计算理论移动范围（不考虑阻挡）
    moves = [];
    
    switch piece_type
        case '帅将'
            moves = [r-1,c; r+1,c; r,c-1; r,c+1];
            max_moves = 4;
        case '仕士'
            moves = [r-1,c-1; r-1,c+1; r+1,c-1; r+1,c+1];
            max_moves = 4;
        case '相象'
            moves = [r-2,c-2; r-2,c+2; r+2,c-2; r+2,c+2];
            max_moves = 4;
        case '马'
            moves = [r-2,c-1; r-2,c+1; r-1,c-2; r-1,c+2; ...
                     r+1,c-2; r+1,c+2; r+2,c-1; r+2,c+1];
            max_moves = 8;
        case '车'
            % 车理论上可以移动到同一直线的所有位置
            moves = [];
            for i = 1:10
                if i ~= r, moves = [moves; i, c]; end
                if i ~= c, moves = [moves; r, i]; end
            end
            max_moves = 17; % 9(行)+8(列)-1(自身位置)
        case '炮'
            % 炮理论上可以移动到同一直线的所有位置
            moves = [];
            for i = 1:10
                if i ~= r, moves = [moves; i, c]; end
                if i ~= c, moves = [moves; r, i]; end
            end
            max_moves = 17;
        case '兵卒'
            % 兵卒理论移动范围
            if contains(piece_type, '兵') % 红兵
                moves = [r-1, c]; % 前进
            else % 黑卒
                moves = [r+1, c]; % 前进
            end
            max_moves = 1;
    end
    
    % 过滤边界外的位置
    valid_idx = moves(:,1) >= 1 & moves(:,1) <= 10 & moves(:,2) >= 1 & moves(:,2) <= 9;
    moves = moves(valid_idx, :);
end

function moves = calculate_actual_moves(board, piece_type, r, c)
    % 计算实际可移动位置（考虑阻挡和规则）
    moves = [];
    
    switch piece_type
        case '帅将'
            moves = calculate_king_moves(board, r, c);
        case '仕士'
            moves = calculate_advisor_moves(board, r, c);
        case '相象'
            moves = calculate_elephant_moves(board, r, c);
        case '马'
            moves = calculate_horse_moves(board, r, c);
        case '车'
            moves = calculate_chariot_moves(board, r, c);
        case '炮'
            moves = calculate_cannon_moves(board, r, c);
        case '兵卒'
            moves = calculate_pawn_moves(board, r, c);
    end
end

function overburdened = is_overburdened(board, r, c, own_attack_map)
    % 判断棋子是否承担重要任务（防守其他棋子或通道）
    overburdened = false;
    piece_val = board(r,c);
    is_red = piece_val <= 7;
    
    % 检查是否防守其他棋子
    defended_pieces = 0;
    for i = 1:size(board,1)
        for j = 1:size(board,2)
            if board(i,j) > 0 && ((board(i,j) <= 7) == is_red) && (i ~= r || j ~= c)
                % 如果该位置在攻击范围内，说明正在防守
                if own_attack_map(i,j)
                    defended_pieces = defended_pieces + 1;
                end
            end
        end
    end
    
    % 检查是否防守重要通道（如九宫、河界等）
    defense_duty = false;
    
    % 如果是帅/将，总是承担重要任务
    if piece_val == 1 || piece_val == 8
        defense_duty = true;
    end
    
    % 如果防守超过1个棋子或承担重要通道防守
    overburdened = (defended_pieces >= 1) || defense_duty;
end

function skewer_threat = is_skewer_threat(board, r, c)
    % 判断棋子是否与其他棋子在同一直线上易受串打
    skewer_threat = false;
    piece_val = board(r,c);
    is_red = piece_val <= 7;
    
    % 检查同一行
    for j = 1:9
        if j == c, continue; end
        if board(r,j) > 0 && ((board(r,j) <= 7) == is_red)
            % 检查中间是否有棋子
            min_c = min(c, j);
            max_c = max(c, j);
            empty_between = true;
            for k = min_c+1:max_c-1
                if board(r,k) > 0
                    empty_between = false;
                    break;
                end
            end
            
            if empty_between
                skewer_threat = true;
                return;
            end
        end
    end
    
    % 检查同一列
    for i = 1:10
        if i == r, continue; end
        if board(i,c) > 0 && ((board(i,c) <= 7) == is_red)
            % 检查中间是否有棋子
            min_r = min(r, i);
            max_r = max(r, i);
            empty_between = true;
            for k = min_r+1:max_r-1
                if board(k,c) > 0
                    empty_between = false;
                    break;
                end
            end
            
            if empty_between
                skewer_threat = true;
                return;
            end
        end
    end
end

function double_attack = is_double_attack_threat(board, r, c, enemy_attack_map)
    % 判断棋子是否易被同时攻击两个棋子
    double_attack = false;
    piece_val = board(r,c);
    is_red = piece_val <= 7;
    
    % 查找附近的友方棋子
    for i = max(1,r-2):min(10,r+2)
        for j = max(1,c-2):min(9,c+2)
            if (i ~= r || j ~= c) && board(i,j) > 0 && ((board(i,j) <= 7) == is_red)
                % 检查是否有敌方棋子可以同时攻击这两个位置
                for enemy_r = 1:10
                    for enemy_c = 1:9
                        enemy_val = board(enemy_r,enemy_c);
                        if enemy_val > 0 && ((enemy_val <= 7) ~= is_red)
                            % 获取该敌方棋子的攻击范围
                            enemy_attacks = calculate_attack_for_piece(board, enemy_r, enemy_c);
                            
                            % 检查是否同时攻击两个位置
                            if any(enemy_attacks(:,1) == r & enemy_attacks(:,2) == c) && ...
                               any(enemy_attacks(:,1) == i & enemy_attacks(:,2) == j)
                                double_attack = true;
                                return;
                            end
                        end
                    end
                end
            end
        end
    end
end

function orphaned = is_orphaned(board, r, c, own_attack_map)
    % 判断棋子是否为无根子（无其他棋子保护）
    orphaned = true;
    piece_val = board(r,c);
    is_red = piece_val <= 7;
    
    % 检查是否有其他友方棋子可以保护此位置
    for i = 1:10
        for j = 1:9
            if (i ~= r || j ~= c) && board(i,j) > 0 && ((board(i,j) <= 7) == is_red)
                % 如果该友方棋子可以攻击到此位置，说明有保护
                if own_attack_map(i,j)
                    orphaned = false;
                    return;
                end
            end
        end
    end
end

function display_by_piece(analysis, side)
    % 按棋子组织输出分析结果
    fprintf('\n--- %s分析 ---\n', side);
    for i = 1:length(analysis)
        piece = analysis(i);
        r = piece.position(1);
        c = piece.position(2);
        coord = sprintf('%s%d', char('a'+c-1), 10-(r-1));
        
        fprintf('棋子: %s (%s)\n', piece.name, coord);
        fprintf('类型: %s\n', piece.type);
        fprintf('实际移动范围: %d 位置\n', piece.num_moves);
        
        status_str = '';
        if piece.status.危, status_str = [status_str, '危 ']; end
        if piece.status.险, status_str = [status_str, '险 ']; end
        if piece.status.疲, status_str = [status_str, '疲 ']; end
        if piece.status.困, status_str = [status_str, '困 ']; end
        if piece.status.串, status_str = [status_str, '串 ']; end
        if piece.status.双, status_str = [status_str, '双 ']; end
        if piece.status.游, status_str = [status_str, '游 ']; end
        
        if isempty(status_str)
            fprintf('状态: 安全\n');
        else
            fprintf('状态: %s\n', status_str);
        end
        fprintf('----------------\n');
    end
end

function display_by_status(analysis, side)
    % 按状态组织输出分析结果
    fprintf('\n--- %s状态分析 ---\n', side);
    
    % 初始化状态列表
    status_list = {'危', '险', '疲', '困', '串', '双', '游'};
    status_pieces = cell(1, length(status_list));
    
    % 收集每个状态的棋子
    for i = 1:length(analysis)
        piece = analysis(i);
        for j = 1:length(status_list)
            status = status_list{j};
            if piece.status.(status)
                r = piece.position(1);
                c = piece.position(2);
                coord = sprintf('%s%d', char('a'+c-1), 10-(r-1));
                status_pieces{j} = [status_pieces{j}, sprintf('%s(%s) ', piece.name, coord)];
            end
        end
    end
    
    % 输出每个状态的棋子
    for j = 1:length(status_list)
        if ~isempty(status_pieces{j})
            fprintf('%s: %s\n', status_list{j}, status_pieces{j});
        else
            fprintf('%s: 无\n', status_list{j});
        end
    end
end

% 以下是之前定义的棋子移动计算函数（简略版）
function moves = calculate_king_moves(board, r, c)
    % 帅/将移动计算
    moves = [];
    % 实现逻辑...
end

function moves = calculate_advisor_moves(board, r, c)
    % 仕/士移动计算
    moves = [];
    % 实现逻辑...
end

% 其他棋子移动计算函数类似...

