function cfg = cfg_default()
%CFG_DEFAULT 默认配置（配置驱动总入口）
%   返回项目全部可调参数。用户可复制此函数修改后传给 main。

    % ---- 数据输入 ----
    cfg.gameDirs = {
        'D:\棋局抓取\棋谱序列\大师对局 - 副本'
        'D:\棋局抓取\棋谱序列\大师对局 - 副本 (2)'
        'D:\棋局抓取\棋谱序列\大师对局'
    };
    cfg.maxGames = 2000;          % 本次分析最大局数（0=全部）；MVP 先用 2000
    cfg.minQuality = 0.99;        % 解析器质量阈值，低于此值跳过
    cfg.randomSeed = 20261121;

    % ---- 阶段切分（回合数）----
    cfg.phaseSplit = [12, 45];    % <=12 开局, 13-45 中局, >45 残局
    cfg.phaseWeights = [0.8, 1.0, 1.2];   % 开/中/残权重

    % ---- 模式挖掘 ----
    cfg.nGramRange = [3, 6];      % 走法 N-gram 的 N 范围
    cfg.windowSizes = [20, 40];   % 静态阵型采样：每局在这些回合数处切片
    cfg.topNPatterns = 200;       % 进入标签树候选的模式数
    cfg.minPatternFreq = 5;       % 频繁模式最小支持度
    cfg.earlyPhaseOnly = 45;      % 只统计前 N 回合的结构（避免赢定局面污染），0=不限制

    % ---- 关键度评分权重 α β γ δ ----
    cfg.wFreq = 0.25;
    cfg.wPhase = 0.15;
    cfg.wResult = 0.35;
    cfg.wDocFreq = 0.25;

    % ---- 标签树认知约束 ----
    cfg.treeDepth = 3;
    cfg.L1Names = {'开局架构', '中局结构', '残局定式', '战术 motif', '子力配置'};
    cfg.Krange = [5, 9];          % L2 每层分支数范围（Miller 魔数）
    cfg.maxLeaves = 80;           % L3 叶节点总数上限
    cfg.minLeavesPerFamily = 3;

    % ---- 输出 ----
    cfg.outDir = fullfile(pwd, 'xiangqi_output');
    cfg.saveBoards = true;        % 是否保存每局局面序列（占内存）
    cfg.verbose = true;
end
