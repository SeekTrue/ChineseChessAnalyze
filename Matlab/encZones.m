function f = encZones(board)
%ENCZONES 区域编码：子力在关键区域的密度（"重心在哪里"）
%   区域：九宫 / 河界 / 三路七路 / 左右侧翼 / 前后场
%   红黑分别统计，输出固定长度向量

    red = board > 0 & board <= 7;
    blk = board >= 8;
    f = [];
    for side = 1:2
        m = red; if side==2, m = blk; end
        % 九宫 (红8-10行/黑1-3行, 4-6列)
        rows = 8:10; if side==2, rows = 1:3; end
        palace = sum(sum(m(rows, 4:6)));
        % 河界带 (红5-6行, 黑5-6行)
        river = sum(sum(m(5:6, :)));
        % 三路/七路 (红col=7/3, 黑col=3/7)
        c3 = 7; c7 = 3; if side==2, c3 = 3; c7 = 7; end
        flankFiles = sum(m(:, c3)) + sum(m(:, c7));
        % 左/右侧翼 (以棋盘col分)
        leftWing = sum(sum(m(:, 1:3)));
        rightWing = sum(sum(m(:, 7:9)));
        % 前场/后场
        if side==1
            front = sum(sum(m(1:5, :))); back = sum(sum(m(6:10, :)));
        else
            front = sum(sum(m(6:10, :))); back = sum(sum(m(1:5, :)));
        end
        % 中心列(4-6)
        center = sum(sum(m(:, 4:6)));
        f = [f, palace, river, flankFiles, leftWing, rightWing, front, back, center];
    end
    f = f / 16;   % 归一化
end
