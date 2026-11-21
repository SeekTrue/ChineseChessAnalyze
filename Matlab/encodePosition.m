function feat = encodePosition(board, cfg)
%ENCODEPOSITION 多尺度编码综合（第3层总入口）
%   拼接子力 + 区域 + 关系三种视角，生成局面特征向量和签名
%
% 输入: board (10x9), cfg
% 输出: feat struct:
%       vector  - 拼接特征向量
%       key     - 局面签名字符串（boardToKey）
%       pieces  - 子力编码
%       zones   - 区域编码
%       relRed  - 红方关系编码
%       relBlack- 黑方关系编码
%       phase   - 阶段 1开/2中/3残（由子力数估计）

    if nargin < 2, cfg = cfg_default(); end

    fPieces = encPieces(board);
    fZones = encZones(board);
    fRelRed = encRelations(board, 1);
    fRelBlack = encRelations(board, 2);

    % 阶段判定（按双方剩余大子数）
    major = fPieces(5) + fPieces(12) + fPieces(6) + fPieces(13);  % 车马
    if major >= 4
        phase = 1;
    elseif major >= 2
        phase = 2;
    else
        phase = 3;
    end

    feat = struct();
    feat.vector = [fPieces, fZones, fRelRed, fRelBlack];
    feat.key = boardUtils('boardToKey', board);
    feat.pieces = fPieces;
    feat.zones = fZones;
    feat.relRed = fRelRed;
    feat.relBlack = fRelBlack;
    feat.phase = phase;
end
