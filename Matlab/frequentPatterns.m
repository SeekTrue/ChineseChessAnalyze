function patterns = frequentPatterns(games, cfg)
%FREQUENTPATTERNS 频繁模式统计（第4层）
%   汇总所有局的样本，统计每个模式的频率、跨局复用度、平均阶段、例局
%
% 输入: games, cfg
% 输出: patterns 结构体数组:
%       key, type, freq, docFreq, avgPly, avgPhase, vector, gameIds

    if cfg.verbose, fprintf('[frequentPatterns] 提取样本...\n'); end
    allSamples = struct('type',{},'key',{},'vector',{},'phase',{},'ply',{},'gameId',{});
    for g = 1:numel(games)
        ss = slidingWindow(games(g), cfg);
        allSamples = [allSamples, ss]; %#ok<AGROW>
    end
    if cfg.verbose, fprintf('  样本总数 %d\n', numel(allSamples)); end

    keys = {allSamples.key};
    [uKeys, ~, idx] = unique(keys);
    patterns = repmat(struct('key','','type','','freq',0,'docFreq',0, ...
                             'avgPly',0,'avgPhase',0,'vector',[],'gameIds',{{}}), numel(uKeys), 1);
    for i = 1:numel(uKeys)
        members = find(idx == i);
        patterns(i).key = uKeys{i};
        patterns(i).type = allSamples(members(1)).type;
        patterns(i).freq = numel(members);
        gids = {allSamples(members).gameId};
        patterns(i).gameIds = unique(gids);
        patterns(i).docFreq = numel(patterns(i).gameIds);
        ples = [allSamples(members).ply];
        patterns(i).avgPly = mean(ples);
        phs = [allSamples(members).phase];
        if ~isempty(phs(phs>0)), patterns(i).avgPhase = mean(phs(phs>0)); else patterns(i).avgPhase = 0; end
        % 取第一个非空向量作为模板
        for mi = 1:numel(members)
            m = members(mi);
            candVec = allSamples(m).vector;
            if ~isempty(candVec)
                patterns(i).vector = candVec; break;
            end
        end
    end

    % 过滤低频
    keep = [patterns.freq] >= cfg.minPatternFreq;
    patterns = patterns(keep);
    % 按频率排序
    [~, ord] = sort([patterns.freq], 'descend');
    patterns = patterns(ord);
    if cfg.verbose, fprintf('  频繁模式 %d 个 (minFreq=%d)\n', numel(patterns), cfg.minPatternFreq); end
end
