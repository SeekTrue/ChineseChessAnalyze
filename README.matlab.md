# 中国象棋认知编码分析

用 MATLAB 分析中国象棋棋谱，从棋谱中挖掘高频/关键结构，生成一套分层标签树式的认知编码，
以降低认知负担、提升棋力。

## 理论背景

基于认知心理学的组块（chunking）理论：象棋高手的记忆优势来自对棋局结构的组块化编码，
而非天生记忆力（de Groot / Simon 经典实验）。本项目核心不是"记住更多棋谱"，而是
**发现并命名那些值得作为记忆单元的棋局结构**。

## 六层流水线（已全部完成）

```
棋谱文本 → 1解析 → 2数字化 → 3多尺度编码 → 4模式挖掘 → 5标签树 → 6记忆输出
```

| 层 | 模块 | 说明 |
|---|---|---|
| 1-2 | `parseNotation.m` `loadGames.m` `detectCheckmate.m` | 中文记谱解析、批量导入、末步将死推断胜负 |
| 3 | `encPieces/encZones/encRelations/encodePosition.m` | 子力+区域+关系三视角编码（含七状态分析、攻击引擎） |
| 4 | `slidingWindow/frequentPatterns/criticality/extractMotifs.m` | 频繁模式挖掘与关键度评分 |
| 5 | `buildLabelTree/nameChunk/compressScore.m` | 三层标签树、自动命名、MDL 压缩率 |
| 6 | `exportCards/plotTree/plotPatterns.m` | 记忆卡片与可视化 |

入口：`main.m`（配置驱动）；配置：`cfg_default.m`。

## 快速使用

```matlab
addpath('E:\程序\ChineseChessAnalyze\Matlab');
result = main();              % 默认跑 2000 局

cfg = cfg_default();
cfg.maxGames = 5000;
result = main(cfg);
```

输出目录包含：标签树总览、5 类记忆卡片（Markdown）、标签树图、Top20 关键结构图、局面热度图。

## 关键设计

- **胜负标签**：棋谱无胜负字段，通过末步将死/困毙推断（约 51% 对局可判定），其余认输局无法恢复。
- **关系编码**：移植自原项目的七状态分析（危/险/疲/困/串/双/游）与攻击范围引擎。
- **认知约束**：树深≤3、每层分支 5–9（Miller 魔数）、叶节点≤80。
- **关键度**：`0.25·频率 + 0.15·阶段 + 0.35·|胜率−0.5| + 0.25·跨局复用度`。
- **命名**：传统定式名锚定（中炮、屏风马…）优先，其次特征自动生成。

## 验证

- 解析器：500 局 42993 步，99.916% 通过率。
- 端到端：2977 局 / 5259 模式 / 80 叶节点，MATLAB R2018a 实测通过（约 4 分钟）。
- Top 结构与真实定式吻合（中炮、屏风马、出车等）。

## 目录

```
.
├── Matlab/   # 35 个 .m 文件（13 原始 + 22 新开发），GBK 编码
└── docs/     # 架构设计、代码评估、数据盘点、解析器说明、完整交付说明
```

> 编码说明：.m 文件为 GBK（适配 MATLAB R2018a 中文 Windows）；棋谱 .txt 为 UTF-8。
> 本仓库内容由 AI 辅助整理。
