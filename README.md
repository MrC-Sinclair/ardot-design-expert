# Ardot 设计专家

> ⚠️ **非官方声明**：本专家由社区个人维护（作者 Sinclair），与 Ardot 官方无任何隶属或合作关系。Ardot 是其各自权利人的商标。

> 这是一个自包含的 Ardot 设计专家，技能与规则已随包完整内置。
> **可跨 IDE 使用**：任意支持 MCP 的 IDE（WorkBuddy、Cursor、Claude Code、Cline 等）；
> MCP 通道名在运行时探测，不写死。
>
> **没有 MCP 也不会空手而归**：连上 Ardot MCP 就直接改画布；探测不到通道时，先交付一份可执行的
> `DESIGN-SPEC.md` 规格文档，再问你要不要落画布。

## 人设

- **名字**：Ardot 设计专家（花名 Jax）
- **定位**：会写前端的设计总监
- **能力**：网页、海报、幻灯片都出，还能出码、出评审，问题在交付前就挑出来

## 依赖

- **Ardot MCP 服务** —— 必须安装并连接（唯一外部依赖）
- **ardot-design-assistant-local 技能** —— 已完整内置在 `skills/ardot-design-assistant-local/`，其全部规则与指南文件（`references/`）一并随包提供

未连接 Ardot MCP 时，专家会交付 `DESIGN-SPEC.md` 规格文档，并给出「落画布 / 出 HTML 预览 / 改规格」三个选项；
只有用户明确说“只要画布”才会停下来提示连接（设计助手与规则已随专家内置，无需单独安装技能）。

## 安装

以下为**本地开发 / 手动安装**路径；从专家中心直接安装的用户可跳过本节。
本专家需注册到 WorkBuddy 的 `marketplace.json` 后，才会出现在专家中心。仅复制文件夹不会自动生效，请二选一完成注册：

**方式 A：通过专家中心导入（推荐）**

1. 打开 WorkBuddy → 专家中心 → 导入 / 添加本地专家
2. 选择本仓库根目录（`ardot-design-expert/`）
3. 等待导入完成，专家即出现在「我的专家」中

**方式 B：手动放置 + 注册脚本**

1. 将 `ardot-design-expert/` 目录复制到：
   - macOS / Linux：`~/.workbuddy/plugins/marketplaces/my-experts/plugins/ardot-design-expert/`
   - Windows：`C:\Users\<你的用户名>\.workbuddy\plugins\marketplaces\my-experts\plugins\ardot-design-expert\`
2. 运行 WorkBuddy 内置的 `expert-manager` 注册脚本：
   `python register_expert.py <专家目录>`
   （无需传 `--session-id`；`.created-by-session` 只是本地标记，可忽略）
3. 重启 / 刷新专家中心，专家即出现

**使用前**：想直接在画布上改，需要安装并连接 **Ardot MCP**；只想要规格 / 评审 / 转码方案，不连也能用。

## 擅长领域

- UI/UX 设计
- 设计稿转代码
- 像素级走查

## 试试这样问我

- 做一个 SaaS 官网落地页，配色和圆角都绑成设计 token，后面换主题不用重做
- 把这版设计稿转成能直接上线的 React 代码，并核对还原度
- 交付前帮我走查这版设计稿，列出必须修掉的问题

## 目录结构

```
ardot-design-expert/
├── .codebuddy-plugin/plugin.json   # 专家元数据（含展示字段）
├── agents/ardot-design-expert.md   # 人设 / 提示词（Jax）
├── skills/ardot-design-assistant-local/  # 设计助理技能（自包含）
│   ├── SKILL.md                    # 主入口：可移植性说明 / 通道探测 / 五处纠正 / 宿主注入加载门 / 工作流 / 硬规则
│   ├── scripts/                    # 直播海报风格目录拉取脚本（Node ≥ 18，零本地依赖）
│   └── references/                 # 57 份，全部随包提供
│       ├── 【核心规则】
│       ├── spec-mode.md            # 🆕 无 Ardot MCP 时的规格交付（9 节结构 + 收尾三问）
│       ├── design-mode-equivalents.md  # 🆕 无宿主指令块时，三块注入行为的等价判定 + "何时该问"边界
│       ├── design-rules.md         # 唯一事实来源：编辑原则 / 坐标 / flexbox / 组件 / 变量 / 共享样式 / 属性 schema / 排障 / ⛔ Forbidden Patterns
│       ├── style-guide.md          # 视觉风格哲学（反 AI 套路 / 三旋钮 / Bento / 破折号与眉标硬门）
│       ├── style-lexicon.md        # 🆕 风格词典：20 个风格 → 英文检索词 / 硬特征 / 适用 + 4 个 token 兜底
│       ├── style-guide-tags.md     # search_style_guide 英文关键词清单（fetch_style_guide_tags 工具不存在，读本地文件）
│       ├── effects-guide.md        # 🆕 复合效果配方：玻璃拟态 / 霓虹 / 金属 / 渐变描边 / 虹彩 / 新拟态
│       ├── ardot-schema.md         # 🆕 节点属性 schema（Node→Mixin 组合 / 属性默认值）
│       ├── 【专项能力】
│       ├── component-instance.md   # 🆕 组件 / 实例 / 变体（属性定义、实例覆盖、隐藏可选子节点）
│       ├── design-variables.md     # 🆕 变量绑定解绑 / apply_variables / variableModes 切换
│       ├── shared-styles.md        # 🆕 共享样式 textStyleId / fillStyleId
│       ├── batch-edit-tool-usage.md      # 🆕 batch_edit 完整操作手册（18K）
│       ├── apply-variables-tool-usage.md # 🆕 apply_variables 使用手册
│       ├── 【工作流】
│       ├── ardot-workflow.md       # 端到端示例（新建 / 修改 / 换肤 / 变量 / 表单）
│       ├── slides-workflow.md      # 幻灯片标准 5 阶段流程
│       ├── slides-agent-teams-workflow.md  # 幻灯片 Agent Teams 协作（须用户显式点选）
│       ├── design-to-code-workflow.md      # 设计→代码（Phase 0 平台澄清 … Phase 4 双证据终验）
│       ├── extract-style-guide-from-web.md # 从网页提取风格指南
│       ├── design-review-workflow.md       # 设计稿本身质量走查（6 维评分卡 + 硬指标计数）
│       ├── redesign-protocol.md    # 🆕 改版协议：三模式判定 / 审计 / 保留红线 / 7 级杠杆 / 对账验收
│       ├── code-review-workflow.md         # 设计↔代码双向校对（模式 A / 模式 B）
│       ├── 【海报】
│       ├── guidelines-poster.md   # 通用海报 / 封面 / banner / 电商主图（§0 硬约束 + 13 个 Layout Contract + §8 多尺寸）
│       ├── poster-multisize-pipeline.md # 🆕 多尺寸套图可执行产线（母版 + 图生图派生 + 回填 + 跨尺寸审计）
│       ├── guidelines-logo.md     # 🆕 Logo 落地（⚠️ 非官方标准，官方 8 个 topic 无 logo）
│       ├── livestream-poster/      # 🆕 直播海报（3 条风格工作流 + 自适应尺寸 + DSL 合成）
│       ├── 【类型指南】
│       ├── guidelines-{landing-page,web-app,mobile-app,table,slides,code,tailwind}.md
│       └── miora/                  # 🆕 AI 生成媒体（图片 / 视频 / 品牌资产）
│           ├── creative-core.md    # 家族底座：意图识别 / 参数契约 / 费用边界 / 画布交付 / 质量门
│           ├── brand/               # Logo / 吉祥物 / 品牌全案 / IP 物料
│           ├── image/               # 电商详情图 / App 图标 / 插画 / 系列一致性
│           └── video/               # 短视频 / 动效
└── README.md
```

> `tools/`（漂移检测脚本 + 官方规则快照 `official/`）只存在于仓库，**不随包分发**，用法见 `tools/README.md`。
> 接手维护（或换 AI 助手）时，先读根目录的 `AGENTS.md`。
> `references/miora/{brand,image,video}/overview.md` 与 `references/livestream-poster/overview.md` 是各层入口，
> 均为普通文档（无 frontmatter），不会被注册成独立技能。

## 与同类设计技能的关系

本包可以在已经装了其他 Ardot 设计技能的环境里共存：两者**内容有重叠**，冲突时以本包为准
（本包规则更严格，并修正了若干已失效的写法）。

**本包的增量**（那些技能里没有的组合）：

- **无 MCP 仍可交付**：探测不到画布通道时产出 `DESIGN-SPEC.md`，而不是一句“请先连接”
- **绑定前先读 token 的硬门**：写画布之前先 `fetch_variables`，禁止直接写 hex
- **交付前双证据走查**：节点声明值 × 实际渲染像素，缺一不下结论
- **可机械判定的文案硬门**：破折号、眉标预算、中文空话，都给数字不给感觉
- **跨 IDE 可移植**：规则随包走，不依赖宿主注入

**为什么规则随包走**：必须能在任意支持 MCP 的 IDE 里独立运行。代价是上游升级不会自动同步，
因此 `skills/ardot-design-assistant-local/PROVENANCE.md`（维护者文档，说明每一份文件的来源，**不随包分发**）与
`bash tools/sync-check.sh` 用来检测漂移。

> 使用者**无需关心**以上机制 —— 直接安装使用即可。

## 能力与工具要求

除 Ardot MCP 外，部分能力依赖对应宿主环境（缺失时会明确提示，不会静默失败）：

| 能力 | 所需工具 | 缺失时行为 |
|---|---|---|
| 画布设计（UI / 页面 / 幻灯片 / 海报 / 转码） | `ardot_*` MCP | 交付 `DESIGN-SPEC.md` 规格文档，再询问下一步（不再空手终止） |
| 海报多尺寸套图（母版 + 派生） | `ImageGen` + `ardot_*` | 降级为 `G()` 占位 + 给出建议 prompt，版式照常交付 |
| 直播海报 | `ImageGen` | 停止并提示，规格交付与其余能力不受影响 |
| AI 生图 / 生视频 / 品牌资产 | `miora_*` MCP | 停止并提示，画布与规格能力不受影响 |

> 生图按张计费（单张约 5–10 credits）。`SKILL.md` 与 `poster-multisize-pipeline.md` 都要求**生成前先告知用户**，
> 不会静默消耗额度。

> 宿主没有注入指令块时，按 `references/design-mode-equivalents.md` 的默认规则自判——
> **行为一致，且不会每步都反问用户**。
