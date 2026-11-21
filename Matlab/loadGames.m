function games = loadGames(cfg)
%LOADGAMES 批量导入棋谱 + 胜负标签（第1-2层）
%   遍历 cfg.gameDirs，调用 parseNotation 解析，detectCheckmate 补胜负
%
% 输入: cfg (cfg_default)
% 输出: games 结构体数组，每个元素:
%       id, date, quality, boards{1..N+1}, nPly, result(1红胜 2黑胜 0未知)

    if cfg.verbose, fprintf('[loadGames] 开始批量导入...\n'); end
    rng(cfg.randomSeed);

    % 收集所有文件
    allFiles = {};
    for d = 1:numel(cfg.gameDirs)
        dirPath = cfg.gameDirs{d};
        if exist(dirPath, 'dir') ~= 7, continue; end
        fs = dir(fullfile(dirPath, '*.txt'));
        for i = 1:numel(fs)
            allFiles{end+1} = fullfile(fs(i).folder, fs(i).name); %#ok<AGROW>
        end
    end
    if cfg.verbose, fprintf('  发现 %d 个棋谱文件\n', numel(allFiles)); end

    % 抽样
    if cfg.maxGames > 0 && cfg.maxGames < numel(allFiles)
        idx = randperm(numel(allFiles), cfg.maxGames);
        allFiles = allFiles(idx);
    end

    games = repmat(struct('id','','date','','quality',0,'boards',{{}}, ...
                          'nPly',0,'result',0,'mateInfo',[],'moveTexts',{{}}), numel(allFiles), 1);
    kept = 0;
    t0 = tic;
    for i = 1:numel(allFiles)
        fp = allFiles{i};
        [~, fn, ~] = fileparts(fp);
        res = parseNotation(fp);
        if res.quality < cfg.minQuality
            continue;   % 跳过低质量解析
        end
        kept = kept + 1;
        games(kept).id = fn;
        games(kept).date = res.date;
        games(kept).quality = res.quality;
        games(kept).boards = res.boards;
        games(kept).nPly = res.nSteps;
        % 保存走法原文（用于 N-gram 套路挖掘）
        mts = cell(1, res.nSteps);
        for mi = 1:res.nSteps, mts{mi} = res.moves(mi).raw; end
        games(kept).moveTexts = mts;

        % 终局推断胜负：最后一步是 sideToMove 之前那方走的
        if res.nSteps > 0
            lastSide = res.moves(res.nSteps).side;   % 走最后一手的一方
            finalBoard = res.boards{end};
            nextSide = 3 - lastSide;                 % 轮到对方走
            [mate, detail] = detectCheckmate(finalBoard, nextSide);
            if mate
                % 被将死的一方负，走最后一手的一方胜
                games(kept).result = lastSide;
            else
                games(kept).result = 0;              % 无法从棋谱确定
            end
            games(kept).mateInfo = detail;
        end

        if cfg.verbose && mod(kept, 200) == 0
            fprintf('  已解析 %d 局 (耗时 %.1fs)\n', kept, toc(t0));
        end
    end
    games = games(1:kept);
    if cfg.verbose
        nWin = sum([games.result] > 0);
        fprintf('[loadGames] 完成，保留 %d 局；将死可判胜负 %d 局 (%.1f%%)\n', ...
            kept, nWin, 100*nWin/max(1,kept));
    end
end
