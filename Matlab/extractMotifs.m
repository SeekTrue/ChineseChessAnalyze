function motifs = extractMotifs(games, cfg)
%EXTRACTMOTIFS 战术 motif 提取（第4层）
%   从关系编码特征中识别战术结构倾向：侧翼进攻/中路突破/子力集结/防守反击
%   输出每个 motif 的统计（作为 L1 大类"战术motif"的输入）
%
% 输出 motifs 结构体数组: name, count, avgCriticalityHint

    cats = {'侧翼进攻', '中路突破', '子力集结', '防守反击', '子力分散'};
    counts = zeros(1, numel(cats));
    for gi = 1:numel(games)
        gm = games(gi);
        if isempty(gm.boards), continue; end
        % 取中局代表局面
        idx = min(numel(gm.boards), round(gm.nPly/2)+1);
        b = gm.boards{idx};
        f = encodePosition(b, cfg);
        z = f.zones;
        % 红方区域编码(8维): [palace river flank left right front back center]
        zr = z(1:8); zb = z(9:16);
        % 判定红方战术倾向: 侧翼/中路/子力集结(河界)/防守/分散
        [~, kind] = max([zr(3)+zr(4)+zr(5), zr(8), zr(2), zr(7), zr(6)]);
        counts(kind) = counts(kind) + 1;
    end
    motifs = repmat(struct('name','','count',0), numel(cats), 1);
    for i = 1:numel(cats)
        motifs(i).name = cats{i};
        motifs(i).count = counts(i);
    end
    [~, ord] = sort([motifs.count], 'descend');
    motifs = motifs(ord);
end
