function plotTree(tree, cfg)
%PLOTTREE 标签树可视化（第6层）
%   用 MATLAB 基础绘图画三层树状结构

    if ~exist(cfg.outDir, 'dir'), mkdir(cfg.outDir); end
    figure('Visible', 'off', 'Position', [100 100 1200 800]);
    axis off; hold on;
    nL1 = numel(tree.L1);
    yL1 = linspace(0.9, 0.1, nL1);
    xL1 = 0.08; xL2 = 0.45; xL3 = 0.78;

    totalL3 = 0;
    for i = 1:nL1
        L1 = tree.L1(i);
        plot(xL1, yL1(i), 'o', 'MarkerSize', 12, 'MarkerFaceColor', [0.27 0.45 0.77], 'MarkerEdgeColor', 'k');
        text(xL1+0.02, yL1(i), L1.name, 'FontSize', 11, 'FontWeight', 'bold');
        fams = L1.L2;
        nF = numel(fams);
        yF = linspace(yL1(i)+0.03, yL1(i)-0.03, max(2,nF));
        for j = 1:nF
            plot([xL1+0.015, xL2-0.015], [yL1(i), yF(j)], '-', 'Color', [0.6 0.6 0.6]);
            plot(xL2, yF(j), 'o', 'MarkerSize', 8, 'MarkerFaceColor', [0.44 0.68 0.28], 'MarkerEdgeColor', 'k');
            text(xL2+0.015, yF(j), fams(j).name, 'FontSize', 9);
            if ~isfield(fams(j),'leaves'), continue; end
            leaves = fams(j).leaves;
            nLeaf = numel(leaves);
            if nLeaf > 0
                yLeaf = linspace(yF(j)+0.012, yF(j)-0.012, max(2,nLeaf));
                for k = 1:nLeaf
                    lf = leaves(k);
                    if isempty(lf.key), continue; end
                    plot([xL2+0.012, xL3-0.012], [yF(j), yLeaf(k)], '-', 'Color', [0.75 0.75 0.75]);
                    plot(xL3, yLeaf(k), '.', 'MarkerSize', 10, 'Color', [0.93 0.49 0.19]);
                    text(xL3+0.012, yLeaf(k), lf.name, 'FontSize', 8, 'Color', [0.3 0.3 0.3]);
                    totalL3 = totalL3 + 1;
                end
            end
        end
    end
    title(sprintf('象棋认知编码 · 三层标签树（%d 大类 / %d 叶节点）', nL1, totalL3), 'FontSize', 14);
    text(xL1, 0.97, 'L1 大类', 'FontSize', 10, 'Color', [0.27 0.45 0.77]);
    text(xL2, 0.97, 'L2 族', 'FontSize', 10, 'Color', [0.44 0.68 0.28]);
    text(xL3, 0.97, 'L3 叶节点', 'FontSize', 10, 'Color', [0.93 0.49 0.19]);

    out = fullfile(cfg.outDir, '标签树.png');
    saveas(gcf, out);
    close(gcf);
    fprintf('  标签树图已保存: %s\n', out);
end
