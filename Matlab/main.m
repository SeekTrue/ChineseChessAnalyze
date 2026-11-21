function result = main(cfg)
%MAIN 象棋认知编码分析 · 总入口（配置驱动，六层流水线）
%
% 用法:
%   result = main();                    % 用默认配置
%   cfg = cfg_default(); cfg.maxGames = 5000; result = main(cfg);
%
% 流程: 棋谱导入(1-2层) -> 多尺度编码(3层) -> 模式挖掘+关键度(4层)
%       -> 标签树+MDL(5层) -> 记忆输出与可视化(6层)

    if nargin < 1, cfg = cfg_default(); end
    t0 = tic;
    result = struct();

    fprintf('\n========================================\n');
    fprintf('  象棋认知编码分析 v1.0\n');
    fprintf('========================================\n');

    % 第1-2层：导入 + 解析 + 终局推断
    fprintf('\n[1/6] 棋谱解析与局面数字化...\n');
    games = loadGames(cfg);
    result.games = games;
    if isempty(games)
        error('没有可用的棋谱，请检查 cfg.gameDirs');
    end

    % 第3层：多尺度编码（在挖掘时按需调用，这里做一次全量验证）
    fprintf('\n[2/6] 多尺度编码引擎就绪（子力/区域/关系）\n');

    % 第4层：模式挖掘 + 关键度
    fprintf('\n[3/6] 频繁模式挖掘...\n');
    patterns = frequentPatterns(games, cfg);
    fprintf('\n[4/6] 关键度评分（利用终局推断的胜负）...\n');
    [scored, stats] = criticality(patterns, games, cfg);
    motifs = extractMotifs(games, cfg);
    result.scored = scored;
    result.stats = stats;
    result.motifs = motifs;

    % 第5层：标签树 + MDL
    fprintf('\n[5/6] 分层标签树生成...\n');
    tree = buildLabelTree(scored, motifs, cfg);
    cs = compressScore(games, tree, cfg);
    result.tree = tree;
    result.compress = cs;

    % 第6层：记忆输出
    fprintf('\n[6/6] 记忆卡片与可视化输出...\n');
    paths = exportCards(tree, cs, cfg);
    try
        plotTree(tree, cfg);
        plotPatterns(scored, games, cfg);
    catch err
        fprintf('  警告: 绘图失败 (%s)，文本输出不受影响\n', err.message);
    end
    result.outputFiles = paths;

    % 汇总
    fprintf('\n========================================\n');
    fprintf('  完成！耗时 %.1f 秒\n', toc(t0));
    fprintf('  分析棋局: %d 局\n', numel(games));
    fprintf('  频繁模式: %d 个\n', numel(scored));
    fprintf('  标签树: %d 大类 / %d 叶节点\n', numel(tree.L1), tree.totalLeaves);
    fprintf('  MDL 覆盖率: %.1f%%  描述长度比: %.2f\n', cs.coverage*100, cs.compressionRatio);
    fprintf('  输出目录: %s\n', cfg.outDir);
    fprintf('========================================\n');
end
