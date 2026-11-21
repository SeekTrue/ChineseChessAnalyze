function cs = compressScore(games, tree, cfg)
%COMPRESSSCORE MDL 压缩率评估（第5层）
%   用标签树的走法套路字典，对每局走法序列做贪心最长匹配编码，
%   衡量"原始走法序列" vs "模式字典编码" 的描述长度下降（MDL 思想）
%
% 输入: games, tree, cfg
% 输出 cs struct: rawBits, encodedBits, compressionRatio, coverage, leafCount, matchedMoves

    % 收集叶节点中的走法套路 key -> 走法cell + id
    dict = containers.Map();
    leafCount = 0;
    for i = 1:numel(tree.L1)
        for j = 1:numel(tree.L1(i).L2)
            if ~isfield(tree.L1(i).L2(j), 'leaves'), continue; end
            leaves = tree.L1(i).L2(j).leaves;
            for k = 1:numel(leaves)
                lf = leaves(k);
                if isempty(lf.key) || isempty(strfind(lf.key, '_')), continue; end
                % key 形如 G3_炮二平五_马８进７_马二进三
                parts = strsplit(lf.key, '_');
                if numel(parts) < 2, continue; end
                moves = parts(2:end);
                leafCount = leafCount + 1;
                dict(strjoin(moves, '|')) = leafCount;
            end
        end
    end

    % 字典按长度分组，便于贪心最长匹配
    dictKeys = keys(dict);
    dictLens = cellfun(@(x) numel(strsplit(x,'|')), dictKeys);

    rawBits = 0; encodedBits = 0; matchedMoves = 0; totalMoves = 0;
    idBits = max(1, ceil(log2(max(2, leafCount))));
    MOVE_BITS = 11;   % 每个走法原始描述约需 log2(约1600种合法走法)≈11bit

    for g = 1:numel(games)
        gm = games(g);
        if ~isfield(gm,'moveTexts') || isempty(gm.moveTexts), continue; end
        mts = gm.moveTexts;
        n = numel(mts);
        rawBits = rawBits + n * MOVE_BITS;
        totalMoves = totalMoves + n;
        i = 1;
        while i <= n
            bestLen = 0;
            % 从长到短尝试匹配
            maxTry = min(8, n - i + 1);
            for L = maxTry:-1:2
                seq = strjoin(mts(i:i+L-1), '|');
                if isKey(dict, seq)
                    bestLen = L; break;
                end
            end
            if bestLen > 0
                encodedBits = encodedBits + idBits;
                matchedMoves = matchedMoves + bestLen;
                i = i + bestLen;
            else
                encodedBits = encodedBits + MOVE_BITS;
                i = i + 1;
            end
        end
    end

    cs = struct();
    cs.rawBits = rawBits;
    cs.encodedBits = encodedBits;
    cs.matchedMoves = matchedMoves;
    cs.coverage = matchedMoves / max(1, totalMoves);
    cs.leafCount = leafCount;
    if encodedBits > 0
        cs.compressionRatio = rawBits / encodedBits;
    else
        cs.compressionRatio = 1;
    end
end
