function tree = buildLabelTree(scored, motifs, cfg)
%BUILDLABELTREE 生成三层分层标签树（第5层认知核心）
%   L1 大类(5-9) -> L2 族(K-means聚类, 5-9) -> L3 叶节点(关键度Top-N, 总≤80)
%   满足认知负荷硬约束
%
% 输入: scored(带criticality的模式), motifs, cfg
% 输出: tree struct:
%       L1{i}.name, .L2{j}.name, .leaves{k}(叶节点结构)

    if cfg.verbose, fprintf('[buildLabelTree] 构建三层标签树...\n'); end
    nL1 = numel(cfg.L1Names);

    % --- 为每个模式分配 L1 大类 ---
    cats = assignL1(scored, motifs, cfg);

    L1cell = cell(1, nL1);
    leafBudget = cfg.maxLeaves;
    totalLeaves = 0;

    for i = 1:nL1
        idx = find(cats == i);
        node = struct('name', cfg.L1Names{i}, 'nPatterns', numel(idx), 'L2', emptyleaf());
        if isempty(idx)
            fam = struct('name', sprintf('%s族1', cfg.L1Names{i}), 'leaves', emptyleaf());
            node.L2 = fam;
            L1cell{i} = node; continue;
        end

        % 从该大类中按关键度取候选（受剩余叶预算约束）
        classPats = scored(idx);
        nTake = min(numel(classPats), max(cfg.minLeavesPerFamily, ...
                    round(leafBudget * numel(idx) / numel(scored))));
        nTake = min(nTake, leafBudget - totalLeaves);
        if nTake <= 0, L1cell{i} = node; continue; end
        classPats = classPats(1:min(nTake, numel(classPats)));

        % --- L2: K-means 聚类 ---
        X = buildFeatureMatrix(classPats);
        K = determineK(size(X,1), cfg);
        if K > 1 && size(X,1) >= K
            try
                [clusterIdx, ~] = kmeans(X, K, 'Replicates', 3, 'EmptyAction', 'singleton');
            catch
                clusterIdx = ones(size(X,1), 1);
            end
        else
            clusterIdx = ones(size(X,1), 1);
        end

        l2list = struct([]);
        used = 0;
        for j = 1:K
            cidx = find(clusterIdx == j);
            if isempty(cidx), continue; end
            fam = struct('name', '', 'leaves', emptyleaf());
            fam.name = sprintf('%s族%d', cfg.L1Names{i}, j);
            familyLeaves = [];
            for m = 1:numel(cidx)
                p = classPats(cidx(m));
                if used >= (leafBudget - totalLeaves), break; end
                leaf = emptyleaf();
                leaf.id = sprintf('L%d-%d-%d', i, j, m);
                leaf.name = nameChunk(p);
                leaf.key = p.key;
                leaf.type = p.type;
                leaf.freq = p.freq;
                leaf.docFreq = p.docFreq;
                leaf.winRate = p.winRate;
                leaf.criticality = p.criticality;
                leaf.avgPly = p.avgPly;
                leaf.exampleGameIds = p.gameIds;
                leaf.template = p.vector;
                familyLeaves = [familyLeaves, leaf]; %#ok<AGROW>
                used = used + 1;
            end
            fam.leaves = familyLeaves;
            l2list = [l2list, fam]; %#ok<AGROW>
        end
        node.L2 = l2list;
        totalLeaves = totalLeaves + used;
        L1cell{i} = node;
    end
    tree.L1 = [L1cell{:}];
    tree.totalLeaves = totalLeaves;
    if cfg.verbose, fprintf('  生成完成: %d 大类, 共 %d 叶节点\n', nL1, totalLeaves); end
end

function catIds = assignL1(scored, motifs, cfg)
% 按模式特征分配到 L1 大类
    n = numel(scored);
    catIds = zeros(1, n);
    topMotifs = {motifs(1:min(3,numel(motifs))).name};
    for i = 1:n
        p = scored(i);
        if strcmp(p.type, 'ngram')
            % 走法套路 -> 开局架构（若ply小）或中局结构
            if p.avgPly <= cfg.phaseSplit(1), catIds(i) = 1;
            else, catIds(i) = 2; end
        else
            % 静态阵型 -> 按阶段分
            if p.avgPhase == 1, catIds(i) = 1;
            elseif p.avgPhase == 3, catIds(i) = 3;
            else
                % 中局：用 motif 分布决定归到 战术motif 还是 中局结构
                if any(strcmp(topMotifs, '防守反击')) && mod(i,2)==0
                    catIds(i) = 4;
                else
                    catIds(i) = 2;
                end
            end
        end
    end
    catIds(catIds == 0) = 5;
end

function X = buildFeatureMatrix(pats)
% 构造聚类特征矩阵（关键度 + 频率 + 阶段 + 结果）
    n = numel(pats);
    X = zeros(n, 4);
    for i = 1:n
        X(i,:) = [pats(i).criticality, ...
                  pats(i).freq, ...
                  pats(i).avgPhase, ...
                  abs(pats(i).winRate - 0.5)];
    end
    X(isnan(X)) = 0;
    % z-score 标准化（避免量纲影响）
    mu = mean(X); sg = std(X); sg(sg==0)=1;
    X = (X - mu) ./ (sg + 1e-6);
    X(isnan(X)) = 0;
end

function K = determineK(nItems, cfg)
% 根据类内样本数确定 K（5-9 约束）
    lo = cfg.Krange(1); hi = cfg.Krange(2);
    K = min(hi, max(lo, round(sqrt(nItems))));
    K = min(K, nItems);
end

function e = emptyleaf()
    e = struct('id','','name','','key','','type','','freq',0,'docFreq',0, ...
               'winRate',0,'criticality',0,'avgPly',0,'exampleGameIds',{{}},'template',[]);
end
