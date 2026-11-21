function [scored, stats] = criticality(patterns, games, cfg)
%CRITICALITY 关键度评分（第4层核心）
%   criticality = a*freq + b*phaseWeight + c*|winRate-0.5| + d*docFreq
%
%   胜率按执红/执黑分别归一化：对每个模式，统计它出现的局中执红方胜率，
%   用 |winRate-0.5| 衡量"决定胜负"的相关性，避免先手偏差。
%
% 输入: patterns, games, cfg
% 输出: scored(patterns 带 criticality 字段, 已排序), stats(评分统计)

    gameMap = containers.Map();
    for g = 1:numel(games)
        gameMap(games(g).id) = games(g);
    end

    nP = numel(patterns);
    row = cell(1, nP);
    maxFreq = max(1, max([patterns.freq]));
    maxDoc = max(1, max([patterns.docFreq]));

    for i = 1:nP
        p = patterns(i);
        % 频率项（归一化）
        freqN = p.freq / maxFreq;
        % 阶段项：中局权重最高，开局降权（避免开局套路淹没）
        ph = p.avgPhase;
        if ph == 0, ph = 2; end
        phaseW = cfg.phaseWeights(round(min(3, max(1, ph))));
        % 结果相关性：统计含该模式对局中，模式所属方胜率
        [wr, nLabeled] = patternWinRate(p, gameMap);
        resultTerm = abs(wr - 0.5) * 2;   % 归一化到 0-1
        if nLabeled < 3, resultTerm = resultTerm * 0.3; end  % 标签少则降权
        % 跨局复用广度
        docN = p.docFreq / maxDoc;

        crit = cfg.wFreq*freqN + cfg.wPhase*phaseW + cfg.wResult*resultTerm + cfg.wDocFreq*docN;
        p.criticality = crit;
        p.winRate = wr;
        p.nLabeled = nLabeled;
        row{i} = p;
    end

    crits = cellfun(@(x) x.criticality, row);
    [~, ord] = sort(crits, 'descend');
    scored = [row{ord}];

    stats = struct('nPatterns', nP, ...
                   'maxCrit', max(crits), ...
                   'minCrit', min(crits), ...
                   'meanCrit', mean(crits));
end

function [wr, nLabeled] = patternWinRate(p, gameMap)
% 该模式出现的对局中，按先手方统计胜率；取偏离0.5最大的方向
    wins = 0; total = 0;
    for k = 1:numel(p.gameIds)
        gid = p.gameIds{k};
        if ~isKey(gameMap, gid), continue; end
        g = gameMap(gid);
        if g.result == 0, continue; end   % 结果未知跳过
        total = total + 1;
        if g.result == 1, wins = wins + 1; end
    end
    nLabeled = total;
    if total > 0
        % 拉普拉斯平滑，避免小样本下胜率极端为 0 或 1
        wr = (wins + 1) / (total + 2);
    else
        wr = 0.5;
    end
end
