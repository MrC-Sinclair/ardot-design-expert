# Ardot 设计专家

> ⚠️ **非官方声明**：本专家由社区个人维护（作者 Sinclair），与 Ardot 官方无任何隶属或合作关系。Ardot 是其各自权利人的商标。

> 这是一个自包含的 Ardot 设计专家，技能与规则已随包完整内置，唯一外部依赖是 Ardot MCP 服务需保持连接。
> **可跨 IDE 使用**：WorkBuddy（含设计创意模式）以及 Cursor / Claude Code / Cline 等任意支持 MCP 的 IDE。
> MCP 通道名在运行时探测，不写死。

## 人设

- **名字**：Ardot 设计专家（花名 Jax）
- **定位**：设计出码与像素级走查专家
- **能力**：交付的不是效果图 —— 在 Ardot 画布上产出**可编辑、绑 token 的设计稿**，转成**可运行的前端代码**，再用**双证据像素走查**（节点声明值 × 实际渲染）给你一份能验收的结论

## 依赖

- **Ardot MCP 服务** —— 必须安装并连接（唯一外部依赖）
- **ardot-design-assistant-local 技能** —— 已完整内置在 `skills/ardot-design-assistant-local/`，其全部规则与指南文件（`references/`）一并随包提供

若 Ardot MCP 未连接，专家会按规范提示用户先安装并连接 Ardot MCP 服务（设计助手与规则已随专家内置，无需单独安装技能）。

## 安装

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

**使用前**：必须安装并连接 **Ardot MCP** 服务，否则专家会提示你先连接 MCP。

## 擅长领域

- UI/UX 设计
- 设计稿转代码
- 像素级走查

## 试试这样问我

- 设计一个带亮/暗双主题的 SaaS dashboard，颜色全绑成设计 token
- 把这份设计稿转成 React + Tailwind，并校验像素级还原度
- 走查这份设计稿：给我 6 维评分和 P0–P2 问题清单

## 目录结构

```
ardot-design-expert/
├── .codebuddy-plugin/plugin.json   # 专家元数据（含展示字段）
├── agents/ardot-design-expert.md   # 人设 / 提示词（Jax）
├── skills/ardot-design-assistant-local/  # 设计助理技能（自包含）
│   ├── SKILL.md                    # 主入口：可移植性说明 / 通道探测 / 三处纠正 / 宿主注入加载门 / 工作流 / 硬规则
│   ├── PROVENANCE.md               # 溯源：哪些文件与上游同源、哪些是本地分叉/独有、同步流程
│   ├── sync-check.sh               # 维护用：检测与WorkBuddy 内置技能的漂移（普通使用者无需运行）
│   ├── scripts/                    # 直播海报风格目录拉取脚本（Node ≥ 18，零本地依赖）
│   └── references/                 # 51 份，全部随包提供
│       ├── 【核心规则】
│       ├── design-rules.md         # 唯一事实来源：编辑原则 / 坐标 / flexbox / 组件 / 变量 / 共享样式 / 属性 schema / 排障 / ⛔ Forbidden Patterns
│       ├── style-guide.md          # 视觉风格哲学（反 AI 套路 / 方差等级 / Bento 网格 / 创意弹药库）
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
│       ├── design-review-workflow.md       # 设计稿本身质量走查（视觉 / 交互 / 内容）
│       ├── code-review-workflow.md         # 设计↔代码双向校对（模式 A / 模式 B）
│       ├── 【海报】
│       ├── guidelines-poster.md# 通用海报 / 封面 / banner / 电商主图
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

## 上游关系

本专家包是 WorkBuddy 内置 Ardot 技能族（`ardot-design-core` / `ardot-ui-design` / `ardot-slides` /
`ardot-poster` / `livestream-poster` / `ardot-design-to-code` 与 Miora 四件套）的**自包含 fork**。

保留 fork 是有意的产品决策：**必须能在任意支持 MCP 的 IDE 中独立运行，不依赖宿主注入任何内置技能**。
代价是上游升级不会自动同步，因此：

- `PROVENANCE.md` 标注了每个文件的来源（`verbatim` 与上游逐字节一致 / `fork` 本地分叉 / `local-only` 独有）
- 维护者可运行 `bash sync-check.sh` 机械检测漂移

在 WorkBuddy 设计创意模式下，宿主会额外注入同源技能。`SKILL.md` 的「宿主注入加载门」会
**跳过与上游逐字节相同的文件、只加载本地分叉部分**，避免双份规则冲突并节省上下文。

> 使用者**无需关心**以上机制 —— 直接安装使用即可。`PROVENANCE.md` 与 `sync-check.sh` 只服务于维护本 fork。

## 依赖

除 Ardot MCP 外，部分能力依赖对应宿主环境（缺失时会明确提示，不会静默失败）：

| 能力 | 所需工具 | 缺失时行为 |
|---|---|---|
| 画布设计（UI / 页面 / 幻灯片 / 海报 / 转码） | `ardot_*` MCP | 停止并提示连接 Ardot MCP |
| 直播海报 | `ImageGen` | 停止并提示，Ardot 画布部分不受影响 |
| AI 生图 / 生视频 / 品牌资产 | `miora_*` MCP | 停止并提示，画布能力不受影响 |

```
