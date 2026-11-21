function paths = exportCards(tree, cs, cfg)
%EXPORTCARDS 记忆卡片导出（第6层）
%   把标签树导出为 Markdown 卡片文件（按大类分文件），便于复习
%
% 输出 paths - 生成的文件路径 cell

    if ~exist(cfg.outDir, 'dir'), mkdir(cfg.outDir); end
    paths = {};
    cardsDir = fullfile(cfg.outDir, 'cards');
    if ~exist(cardsDir, 'dir'), mkdir(cardsDir); end

    for i = 1:numel(tree.L1)
        L1 = tree.L1(i);
        lines = {};
        lines{end+1} = sprintf('# %s', L1.name);
        lines{end+1} = '';
        lines{end+1} = sprintf('本类模式数：%d', L1.nPatterns);
        lines{end+1} = '';
        cardNo = 0;
        for j = 1:numel(L1.L2)
            fam = L1.L2(j);
            if ~isfield(fam,'leaves') || isempty(fam.leaves), continue; end
            lines{end+1} = sprintf('## %s', fam.name);
            lines{end+1} = '';
            for k = 1:numel(fam.leaves)
                lf = fam.leaves(k);
                if isempty(lf.key), continue; end
                cardNo = cardNo + 1;
                lines{end+1} = sprintf('### 卡片 %d：%s', cardNo, lf.name);
                lines{end+1} = '';
                lines{end+1} = sprintf('- **关键度**：%.3f', lf.criticality);
                lines{end+1} = sprintf('- **出现频率**：%d 次，跨 %d 局', lf.freq, lf.docFreq);
                lines{end+1} = sprintf('- **红方胜率**：%.0f%%（基于有胜负标注的对局）', lf.winRate*100);
                lines{end+1} = sprintf('- **平均回合**：第 %.0f 手', lf.avgPly);
                lines{end+1} = sprintf('- **模式签名**：`%s`', lf.key);
                lines{end+1} = '';
            end
        end
        fp = fullfile(cardsDir, sprintf('%s.md', L1.name));
        writeLines(fp, lines);
        paths{end+1} = fp;
    end

    % 总览文件
    ov = {};
    ov{end+1} = '# 象棋认知编码 · 标签树总览';
    ov{end+1} = '';
    ov{end+1} = sprintf('生成时间：%s', datestr(now));
    ov{end+1} = sprintf('叶节点总数：%d', tree.totalLeaves);
    ov{end+1} = sprintf('MDL 覆盖率：%.1f%%', cs.coverage*100);
    ov{end+1} = sprintf('描述长度比：%.2f', cs.compressionRatio);
    ov{end+1} = '';
    for i = 1:numel(tree.L1)
        ov{end+1} = sprintf('- %s：%d 族', tree.L1(i).name, numel(tree.L1(i).L2));
    end
    fp = fullfile(cfg.outDir, '标签树总览.md');
    writeLines(fp, ov);
    paths{end+1} = fp;
end

function writeLines(fp, lines)
    fid = fopen(fp, 'w', 'n', 'UTF-8');
    if fid == -1, return; end
    for i = 1:numel(lines)
        fprintf(fid, '%s\n', lines{i});
    end
    fclose(fid);
end
