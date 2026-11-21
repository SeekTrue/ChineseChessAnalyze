function validateParser()
%VALIDATEPARSER 抽样验证 parseNotation 的解析正确率
% 从三个棋谱目录各抽若干局, 检查每一步的合法性

    dirs = { ...
        'D:\棋局抓取\棋谱序列\大师对局 - 副本', ...
        'D:\棋局抓取\棋谱序列\大师对局 - 副本 (2)', ...
        'D:\棋局抓取\棋谱序列\大师对局' ...
    };
    perDir = [7, 7, 6];
    seed = 20261121;
    rng(seed);

    totalFiles = 0; totalSteps = 0; totalValid = 0;
    fprintf('=== 初始局面自检 ===\n');
    b = initBoardForTest();
    expected = [10 5 1; 10 4 2; 10 6 2; 10 3 3; 10 7 3; ...
                10 1 5; 10 9 5; 10 2 4; 10 8 4; 8 2 6; 8 8 6; ...
                1 5 8; 1 4 9; 1 6 9; 1 3 10; 1 7 10; ...
                1 1 12; 1 9 12; 1 2 11; 1 8 11; 3 2 13; 3 8 13];
    ok0 = true;
    for i = 1:size(expected,1)
        if b(expected(i,1), expected(i,2)) ~= expected(i,3)
            fprintf('  初始局面错误: (%d,%d) 期望%d 实际%d\n', ...
                expected(i,1), expected(i,2), expected(i,3), b(expected(i,1),expected(i,2)));
            ok0 = false;
        end
    end
    if ok0, fprintf('  初始局面 22 个关键棋子位置全部正确\n'); end
    fprintf('  红兵位置: %s\n', mat2str(find(b(7,:) == 7)));
    fprintf('  黑卒位置: %s\n', mat2str(find(b(4,:) == 14)));
    fprintf('\n');

    for d = 1:numel(dirs)
        files = dir(fullfile(dirs{d}, '*.txt'));
        n = perDir(d);
        idx = randperm(numel(files), n);
        for k = 1:n
            f = files(idx(k));
            fp = fullfile(f.folder, f.name);
            res = parseNotation(fp);
            totalFiles = totalFiles + 1;
            totalSteps = totalSteps + res.nSteps;
            totalValid = totalValid + res.nValid;
            rate = 0;
            if res.nSteps > 0, rate = res.nValid / res.nSteps * 100; end
            fprintf('[%d/%d] %s | 日期=%s | 步数=%d 成功=%d (%.1f%%)\n', ...
                totalFiles, sum(perDir), f.name, res.date, res.nSteps, res.nValid, rate);
            for e = 1:min(numel(res.errors), 3)
                fprintf('      ! %s\n', res.errors{e});
            end
            if numel(res.errors) > 3
                fprintf('      ... 另有 %d 个错误\n', numel(res.errors)-3);
            end
        end
    end

    fprintf('\n=== 汇总 ===\n');
    fprintf('文件数: %d, 总步数: %d, 成功: %d, 总成功率: %.2f%%\n', ...
        totalFiles, totalSteps, totalValid, totalValid/totalSteps*100);
end

function board = initBoardForTest()
    board = zeros(10,9);
    board(10,5)=1; board(10,4)=2; board(10,6)=2; board(10,3)=3; board(10,7)=3;
    board(10,1)=5; board(10,9)=5; board(10,2)=4; board(10,8)=4;
    board(8,2)=6; board(8,8)=6; board(7,[1 3 5 7 9])=7;
    board(1,5)=8; board(1,4)=9; board(1,6)=9; board(1,3)=10; board(1,7)=10;
    board(1,1)=12; board(1,9)=12; board(1,2)=11; board(1,8)=11;
    board(3,2)=13; board(3,8)=13; board(4,[1 3 5 7 9])=14;
end
