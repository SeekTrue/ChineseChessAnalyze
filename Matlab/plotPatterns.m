function plotPatterns(scored, games, cfg)
%PLOTPATTERNS 模式可视化（第6层）
%   1) 关键度 Top-N 柱状图
%   2) 局面热度图（子力密度平均）
%
% 输入 scored(已评分模式), games, cfg

    if ~exist(cfg.outDir, 'dir'), mkdir(cfg.outDir); end

    % --- Top-N 关键度柱状图 ---
    nShow = min(20, numel(scored));
    if nShow > 0
        figure('Visible', 'off', 'Position', [100 100 1000 600]);
        vals = [scored(1:nShow).criticality];
        names = cell(1, nShow);
        for i = 1:nShow
            names{i} = scored(i).key;
            if numel(names{i}) > 24, names{i} = names{i}(1:24); end
        end
        barh(vals);
        set(gca, 'YTick', 1:nShow, 'YTickLabel', names, 'FontSize', 8);
        xlabel('关键度');
        title('Top-20 高频关键结构');
        set(gca, 'YDir', 'reverse');
        out = fullfile(cfg.outDir, '关键结构Top20.png');
        saveas(gcf, out);
        close(gcf);
        fprintf('  关键结构图已保存: %s\n', out);
    end

    % --- 棋盘热度图（采样若干局的中局局面平均子力分布）---
    heat = zeros(10, 9);
    nSample = min(100, numel(games));
    for g = 1:nSample
        gm = games(g);
        if isempty(gm.boards), continue; end
        idx = min(numel(gm.boards), round(gm.nPly/2)+1);
        b = gm.boards{idx};
        heat = heat + double(b ~= 0);
    end
    heat = heat / max(1, nSample);
    figure('Visible', 'off', 'Position', [100 100 600 700]);
    imagesc(heat);
    colormap('hot'); colorbar;
    title(sprintf('中局子力密度热度图（%d 局平均）', nSample));
    axis equal tight;
    set(gca, 'XTick', 1:9, 'YTick', 1:10);
    out = fullfile(cfg.outDir, '局面热度图.png');
    saveas(gcf, out);
    close(gcf);
    fprintf('  热度图已保存: %s\n', out);
end
