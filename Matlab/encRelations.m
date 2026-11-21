function f = encRelations(board, side)
%ENCRELATIONS 关系编码：七种战术状态 + 攻击压力（"子力之间怎么配合"）
%   移植自原有 analyze_*.m 七状态分析（危/险/疲/困/串/双/游），统一到 board 接口
%
% 输入: board, side(1红2黑，计算该方视角的状态)
% 输出: 特征向量 [7状态计数, 攻击压力统计, 受威胁子力比例]

    atkSelf = attackEngine(board, side);
    atkOpp = attackEngine(board, 3 - side);

    pieces = boardUtils('boardToPieces', board);
    nDanger = 0; nRooted = 0; nIsolated = 0; nDouble = 0; nFatigue = 0; nTrapped = 0; nSkewer = 0;
    myPieces = 0;

    for i = 1:size(pieces,1)
        val = pieces(i,1); r = pieces(i,2); c = pieces(i,3);
        if boardUtils('side', val) ~= side, continue; end
        myPieces = myPieces + 1;
        threatened = atkOpp(r, c);
        protected = atkSelf(r, c);

        % 危：处于对方攻击范围
        if threatened, nDanger = nDanger + 1; end
        % 疲：承担防守（保护了至少一个己方重要子）
        if protected, nFatigue = nFatigue + 1; end
        % 游(孤)：无根子（既不被保护也不保护别人）— 简化：不被保护
        if ~protected, nIsolated = nIsolated + 1; end
        % 有根子：被保护
        if protected, nRooted = nRooted + 1; end
    end

    % 双：同时有两个及以上己方子被攻击（成对受攻）
    if nDanger >= 2, nDouble = nDanger; end

    % 困：受威胁子中，可逃格比例低（简化：被攻击且无保护视为受困）
    nTrapped = sum(sum(atkOpp & ~atkSelf & (board>0))) ;

    % 串：同一直线上三个子（两己一敌）无阻挡 — 简化统计同线密度
    nSkewer = lineClusterCount(board, side);

    n = max(1, myPieces);
    f = [
        nDanger/n, nFatigue/n, nIsolated/n, nRooted/n, ...
        nDouble/n, nTrapped/n, nSkewer/n, ...
        sum(atkOpp(:))/90, sum(atkSelf(:))/90, ...
        sum(sum(atkOpp & atkSelf))/90
    ];
end

function cnt = lineClusterCount(board, side)
% 统计同行/同列上"己-敌-己"夹击结构的近似数量
    cnt = 0;
    for r = 1:10
        row = board(r, :);
        cnt = cnt + countLine(row, side);
    end
    for c = 1:9
        col = board(:, c)';
        cnt = cnt + countLine(col, side);
    end
end

function n = countLine(line, side)
    n = 0;
    for i = 2:numel(line)-1
        a = line(i-1); b = line(i); cc = line(i+1);
        if a==0 || b==0 || cc==0, continue; end
        sa = boardUtils('side', a); sb = boardUtils('side', b); sc = boardUtils('side', cc);
        % 两端同方、中间对方
        if sa==sc && sb~=sa && sa==side, n = n + 1; end
    end
end
