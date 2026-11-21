function name = nameChunk(pattern)
%NAMECHUNK 自动命名（第5层）——降低记忆成本的关键
%   优先级：1) 传统定式名锚定  2) 特征自动生成名 [核心子力]+[位置]+[关系]
%
% 输入 pattern (含 key), 输出 name 字符串

    k = pattern.key;
    name = '';

    % 1) 传统定式名锚定
    dict = {
        '炮二平五', '中炮'
        '炮八平五', '中炮'
        '马二进三', '屏风马'
        '马８进７', '屏风马'
        '马２进３', '屏风马'
        '车九平八', '出车'
        '车一平二', '出车'
        '兵七进一', '挺七兵'
        '兵三进一', '挺三兵'
        '卒７进１', '挺7卒'
        '炮二平三', '卒底炮'
        '相三进五', '飞相'
        '仕四进五', '补仕'
    };
    for i = 1:size(dict, 1)
        if ~isempty(strfind(k, dict{i,1}))
            name = dict{i, 2};
            break;
        end
    end

    % 2) 特征自动生成名
    if isempty(name)
        if strncmp(k, 'G', 1)
            % N-gram: 取套路前几个关键着法
            toks = strsplit(k, '_');
            n = numel(toks);
            core = toks{2};
            if n >= 3, core = [toks{2} '-' toks{3}]; end
            name = sprintf('%s套路', core);
        elseif strncmp(k, 'P', 1)
            name = '常见阵型';
        else
            name = k(1:min(12, numel(k)));
        end
    end

    % 去除可能的多余空格
    name = strtrim(name);
end
