function f = encPieces(board)
%ENCPIECES 子力编码：各兵种数量 + 存活情况（"谁还在场上"）
%   输出 14 维向量 + 归一化版本

    cnt = boardUtils('countPieces', board);       % 1x14
    f = zeros(1, 28);
    f(1:14) = cnt;                                % 绝对数量
    f(15:28) = cnt / 16;                          % 归一化（每兵种最多约16）
end
