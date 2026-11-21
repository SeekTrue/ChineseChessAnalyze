function samples = slidingWindow(game, cfg)
%SLIDINGWINDOW 从单局提取候选结构样本（第4层）
%   两类样本：
%     1) 静态阵型：在指定回合处切局面，生成编码 key + 特征
%     2) 走法序列：N-gram 走法套路
%
% 输出 samples 结构体数组，每个:
%       type('pattern'/'ngram'), key, vector, phase, ply, gameId

    samples = struct('type', {}, 'key', {}, 'vector', {}, 'phase', {}, 'ply', {}, 'gameId', {});
    if isempty(game.boards), return; end
    nBoards = numel(game.boards);
    maxPly = game.nPly;

    % --- 静态阵型：在窗口大小对应的回合处采样 ---
    for w = cfg.windowSizes
        if w > maxPly, continue; end
        % 采样点：w 附近 + 中段 + 末段（受 earlyPhaseOnly 约束）
        pts = [w, round(maxPly/2), min(maxPly, cfg.earlyPhaseOnly)];
        pts = unique(pts(pts >= 1 & pts <= maxPly));
        for p = pts
            b = game.boards{p+1};
            f = encodePosition(b, cfg);
            s = struct('type','pattern','key',['P_' f.key],'vector',f.vector, ...
                       'phase',f.phase,'ply',p,'gameId',game.id);
            samples(end+1) = s; %#ok<AGROW>
        end
    end

    % --- 走法 N-gram（用走法原文，捕捉开局套路）---
    if isfield(game, 'moveTexts') && ~isempty(game.moveTexts)
        mts = game.moveTexts;
        for N = cfg.nGramRange(1):cfg.nGramRange(2)
            limit = min(maxPly, cfg.earlyPhaseOnly);
            for i = 1:(limit - N + 1)
                seq = strjoin(mts(i:i+N-1), '_');
                s = struct('type','ngram','key',['G' num2str(N) '_' seq], ...
                           'vector',[],'phase',0,'ply',i,'gameId',game.id);
                samples(end+1) = s; %#ok<AGROW>
            end
        end
    end
end
