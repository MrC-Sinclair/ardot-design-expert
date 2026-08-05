---
name: ardot-design-assistant-local
description: |
  Ardot 画布设计助手：在 .ardot 文件上创建 / 修改 UI 界面、页面、布局、组件，以及把设计稿转成前端代码。
  当用户说 "设计一个页面 / 屏幕"、"画一个落地页"、"做个 dashboard"、"修改这个设计"、"生成风格指南 / 设计系统"、
  "设计稿转代码 / 出码"、"生成幻灯片 / 演示文稿"、"一比一还原 / 复刻设计稿"、"导出为网页"，或英文
  "design a page / screen", "create a landing page", "build a UI", "modify the design",
  "design to code", "generate slides", "pixel-perfect reproduction" 时使用。
  Triggers 覆盖中英文口语化表达。所有画布操作必须经过 ardot MCP 工具。
metadata:
  version: "1.3.1"
  author: Sinclair
  license: MIT
---

# Ardot Design Assistant

在 `.ardot` 文件上完成设计任务的标准工作流。所有画布操作必须走 ardot MCP 工具。

> **MCP 通道映射（务必对照，避免调到死通道）**：Ardot 通过两条 MCP 连接器路由暴露工具，工具名以 `mcp__<route>__` 前缀区分：
> - **`mcp__ardot-design__*`（设计主通道，本环境可用 ✅）**：`fetch_editor_state` / `batch_edit` / `batch_read` / `capture_layout` / `capture_screenshot` / `fetch_variables` / `locate_available_space` / `create_new_page` / `search_style_guide` / `build_style_guide` / `fetch_guidelines` / `get_available_fonts` / `fetch_component_lib` / `fetch_file_info` / `scan_exportable_resources` 等。
> - **`mcp__ardot__*`（文件开关通道，本环境常 `NO_ADAPTER` ⚠️）**：`create_design` / `open_design` / `create_new_page` / `search_style_guide` / `build_style_guide` 等。该通道适配器未连接时调用会返回 `NO_ADAPTER`，**不要依赖它代开 / 代建文件**，改为引导用户在 Ardot 编辑器中手动打开 `.ardot` 文件。

## When to use

- 在 `.ardot` 画布上从零创建 UI 界面 / 页面 / 屏幕 / 布局（落地页、Web App、移动端、dashboard、表格、海报、幻灯片）
- 修改 / 调整已有 Ardot 设计（加按钮、移动元素、改样式、全局换肤 / 变量）
- 把设计稿（图片 / 参考站 / 文字描述）1:1 还原 / 复刻到画布
- 设计稿转前端代码（HTML/CSS/JS、React / Vue + Tailwind、应用工程、响应式）
- 生成 / 提取视觉风格指南、搭建设计系统 / 设计变量
- 生成幻灯片 / 演示文稿
- 审查已有前端代码对设计稿的还原度（像素级走查 / 找出偏差）
- 对已完成的设计稿**本身**做质量走查（视觉 / 交互 / 内容）——触发词：评审 / 走查 / 体检 / design review / critique

## Reference Files

按需加载（在 Workflow 对应 Step 里用 Read 工具**显式**读取）：

| File | When to load |
|------|--------------|
| `references/design-rules.md` | **唯一事实来源** — 编辑原则、坐标、flexbox、文本、组件、颜色、变量、表格、图片、效果、SVG、属性 schema、排障、生成后校验 |
| `references/style-guide.md` | 视觉风格哲学 — 排版 / 配色 / 布局 / 表面处理 / 反 AI 套路 / 创意弹药库（用于给 `search_style_guide` 提供英文关键词方向） |
| `references/style-guide-tags.md` | `search_style_guide` 的英文关键词灵感库（按轴分组），读它来选关键词，而不是凭空编 |
| `references/ardot-workflow.md` | 端到端流程示例（新建 / 修改 / 全局换肤 / 变量 / 表单）与详细操作语法 |
| `references/slides-workflow.md` | 幻灯片 / 演示文稿 — 标准 5 阶段流程 |
| `references/slides-agent-teams-workflow.md` | 幻灯片 — Agent Teams 协作流程（质量更高但更慢、更费 token；作为选项提供给用户） |
| `references/extract-style-guide-from-web.md` | 网站 → 设计指南提取 |
| `references/design-to-code-workflow.md` | 设计 → 前端代码（HTML/CSS/JS、Application、幻灯片转场、响应式） |
| `references/code-review-workflow.md` | 代码 → 设计稿 逆向评审（还原度评分卡 + P0–P2 修复清单 + 可访问性 / 语义化 / 状态机） |
| `references/design-review-workflow.md` | 设计稿**本身**质量走查（视觉 / 交互 / 内容三维度 + WCAG 对比度 + 状态机 + 结构化输出），与 `code-review-workflow.md` 方向相反 |
| `references/guidelines-landing-page.md` 等 | 各类型设计的**补充**手册（**权威规则以 `fetch_guidelines(topic=...)` 为准**） |

## Preparation: 确保有 .ardot 文件在编辑器中打开

开始前先确认：
- 调 `fetch_editor_state()` 或 `fetch_file_info()` 探测当前是否已有打开的文件。
- 若已打开 → 进入 Step 1。
- 若未打开 → **引导用户在 Ardot 编辑器中手动打开 / 新建 `.ardot` 文件**，再下达设计指令。
  - 仅在 `mcp__ardot__*`（文件开关通道）确认已连接时，才可代用户调用 `open_design` / `create_design` 代开（异步，调用后轮询 `fetch_file_info` 确认就绪）。本环境该通道常处于 `NO_ADAPTER`，**默认不要依赖**，优先手动开文件。
- （可选）若当前文档已存在、用户想要一块全新画布：调 `create_new_page(name: "...")`（属 `mcp__ardot-design__*` 主通道，可用）在其内加一个空白页，用返回的 `pageId` 作为根容器。

## Standard Workflow

> **步骤 checkpoint 约定（必须遵守）**：每完成一个 Step，立即在对话中记录一条「✅ 已完成 Step N」（N 为步骤编号，如「✅ 已完成 Step 3」）。这样当用户中途取消 / 任务中断 / 进程被回收时，可直接从断点续跑，无需重做已完成部分。各 Step 末尾不再逐条重复提示，但 AI 必须在**每步收尾时**落一条 checkpoint 日志，不可跳过。

### Step 0: 确认文件已就绪

- 调 `fetch_editor_state({includeSchema: false, includeGeneralEditInstructions: false})` 确认有打开的文件与当前选区。
- **硬门**：拿到有效文件前，不要发出任何写操作（I/U/C/M/D/G）。

### Step 1: 读取现有状态（并行）

| 场景 | 调用 |
|---|---|
| 已有文件、要做新设计 | `fetch_editor_state({includeSchema:false})` + `fetch_variables`（一条消息并行） |
| 纯修改（文件已打开、目标已知） | 上面两个 **加** 按需 `batch_read` / `capture_layout` / `capture_screenshot`（均并行） |

> 获取官方英文风格关键词：读本地 `references/style-guide-tags.md`（离线关键词灵感库，权威可用）。注意 `fetch_style_guide_tags` 工具在当前 Ardot 版本中**不存在**，不要调用；直接读本地 `references/style-guide-tags.md` 选关键词，再喂给 `search_style_guide`。

### Step 2: 创意 vs 组合

- 创意（新屏幕 / 页面 / dashboard / 换肤）→ Step 3–4
- 组合（"加个按钮"、"移动这个"）→ 跳到 Step 5，读 `references/design-rules.md`

### Step 3: 加载设计类型指南（权威来源 = fetch_guidelines）

**先用 Read 读取权威规则，再读补充手册**：
1. 调 `fetch_guidelines(topic: <topic>)` 获取该类型的官方设计规则（topic：`table` / `landing-page` / `web-app` / `mobile-app` / `slides` / `posters` / `code` / `tailwind`，共 8 个）。海报类设计现在已有专属规范，直接用 `fetch_guidelines(topic: "posters")` 获取（与其他类型一致）；视觉风格方向仍可用 `search_style_guide` + `build_style_guide` 物化 token。
2. 用 Read 读取对应的**补充**手册（first-match）：

| 优先级 | 触发 | 补充手册 |
|---|---|---|
| 1 | slides, 幻灯片, 演示文稿 | `references/guidelines-slides.md` |
| 2 | mobile, app, 移动端 | `references/guidelines-mobile-app.md` |
| 3 | landing, 营销, 落地页 | `references/guidelines-landing-page.md` |
| 4 | table, 表格 | `references/guidelines-table.md` |
| 5 | 转代码, 出码, 生成应用 | `references/guidelines-code.md`（+ `references/guidelines-tailwind.md` 若用 Tailwind） |
| 6 | web app（默认） | `references/guidelines-web-app.md` |
| 7 | posters, 海报 | 暂无专属补充手册，套用 `references/design-rules.md` 通用规则（`fetch_guidelines(topic:"posters")` 已提供海报规范） |

> `fetch_guidelines` 是权威且由 Ardot 维护的规则源；本地 `guidelines-*.md` 仅作补充细节，若二者冲突以 `fetch_guidelines` 为准。

### Step 4: 获取视觉风格（search_style_guide + build_style_guide）

**不要用** `fetch_style_guide`（该工具不存在——正确名称为 `search_style_guide`）。改为两步：
1. **先用 Read 读取 `references/style-guide.md`**，套用其「反 AI 套路」定调规则（禁 AI 紫/蓝渐变发光、不用纯黑 `#000000`、降饱和度、避免满屏 Inter 等）；再用 Read 读 `references/style-guide-tags.md` 拿英文关键词灵感，结合两者调：
   `search_style_guide({ styleKeywords: "...", colorKeywords: "...", typographyKeywords: "...", layoutKeywords: "...", sceneKeywords: "...", compositionKeywords: "..." })`（建议 `topK: 3`，减少 token 且不降低单选质量）
   （所有关键词**必须英文**；按 `summary`+`bestFor` 选，不唯 `score`）。
2. 用第 1 步选中的 name/index 调 `build_style_guide({ style, color, typography, layout, scene, composition })` 物化出具体 design tokens（如 `background_primary`、`radius_card`）。**直接读返回 JSON 里的 token 值并套用**，不要凭记忆编。

### Steps 5–6: 风格 + 空间 + 检视（并行）

一条消息并行发起（仅当无相互依赖）：
- **新顶层屏幕**：调 `locate_available_space({width, height})`（必须，避免重叠）；纯修改跳过。
- 检视调用（仅修改且 Step 1 未覆盖时）：`batch_read`（按 pattern/ID，`readDepth:3` 看组件结构）、`capture_layout({parentId, problemsOnly:true})`、`capture_screenshot({nodeIds:[...], screenShotDir:"<绝对目录>"})`。
- 跳过不适用的子调用。

### Step 7: 执行设计

`batch_edit` 每批 ≤ 25 ops。构建顺序：结构 → 内容 → 样式 → 校验。操作：I() 插入 / U() 更新 / C() 复制 / M() 移动 / D() 删除 / G() 图片。详细语法读 `references/ardot-workflow.md`。

### Step 8: 校验

遵循 `references/design-rules.md` 的 **Post-Generation Validation Pattern**，使用分层校验（T1 结构 → `capture_layout`；T3 视觉 → `capture_screenshot`；T4 区块完成 → 两者各一次；T5 整页 → 一次 `capture_screenshot`）。

**关键参数约束（ardot MCP 实测）**：
- 每个 `capture_screenshot` **必须**带 `screenShotDir`（绝对可写目录，如工作区临时目录）+ `nodeIds`（数组，单次 ≤ 10）。
- 每个 `capture_layout` **必须**带 `parentId`（必填）。

不要每批都做全量双校验。收敛阈值：每区块最多 2 次修复迭代，忽略 ≤4px 间距噪声，风格匹配后不再主观返工。

## Specialized Workflows

> ⚠️ **硬门（照 Step 0 范式）**：进入任一专用流程前，**必须已 Read 其对应 reference**；未 Read 不得产出任何结论、不得动手。输出须符合对应 workflow 格式——`code-review` 必须含 **5 维还原度评分卡 + P0–P2 清单**，`design-review` 必须含 **6 维质量评分卡 + P0–P2 清单**——否则视为未完成。

匹配下列任务时，读取对应 reference 并严格执行：
- 幻灯片 / 演示文稿 → 问用户用哪种：Agent Teams 协作（`references/slides-agent-teams-workflow.md`，质量高但慢 / 费 token）或标准流程（`references/slides-workflow.md`，快）。强制设计规则在 `references/guidelines-slides.md`。
- 网站 → 风格指南提取 → `references/extract-style-guide-from-web.md`
- 设计 → 前端代码 → `references/design-to-code-workflow.md`
- 代码 → 设计稿 还原度评审 → `references/code-review-workflow.md`
- 设计稿质量评审（与「代码 → 设计稿」方向相反：审**设计稿本身**）→ `references/design-review-workflow.md`

## When NOT to use

（触发边界——出现下列情况**不要**调用本 skill，改走其他能力或先引导用户）

- 用户在非 Ardot 画布的设计工具里工作（Figma / Sketch / Photoshop 等）——本 skill 只操作 `.ardot` 文件。
- 纯前端编码任务，没有任何设计稿、也没有画布意图——直接用普通编码能力，不要绕到画布。
- 用户尚未在 Ardot 编辑器中打开任何 `.ardot` 文件，且拒绝先打开——先引导其打开，不要凭空生成。

## Out of scope

（本 skill 明确不做的具体动作）

- 新建或打开 `.ardot` 文件——默认引导用户在 Ardot 编辑器中手动打开 / 新建。仅在 `mcp__ardot__*`（文件开关通道）已连接时，才可用 `create_design` / `open_design` 代开（异步，需轮询 `fetch_file_info` 就绪）；本环境该通道常处于 `NO_ADAPTER`，不要依赖。
- 与画布无关的纯前端工程（脚手架、构建配置、后端逻辑）——除非是「设计稿转码」的直接产出。
- 图标 / 图片素材的外部图库搜索（如 Unsplash）——图片一律用 `G()` 的 `stock`（首选）/ `ai` / `placeholder` 类型生成，禁止粘贴外部 URL。

## Essential Constraints（硬约束）

下面这些是**违反即导致功能完全错误**的强制规则——无论你之前见过什么"画 Ardot"的常规写法，都必须照此执行。完整规则、属性 schema 与排障一律以 **`references/design-rules.md`** 为准（执行前或遇到不确定时请用 Read 读取）。

| 维度 | ✅ 必须 | ❌ 禁止 |
|---|---|---|
| 文本可见性 | 文本节点始终设 `fill` | 不设 `fill` 导致文本不可见 |
| 颜色属性 | 用 `fill` / `fills` / `strokes` | `textColor` / `backgroundColor` / `color` / `fillColor` |
| 圆角 | `cornerRadius` | `borderRadius` |
| 字重 | 数字字符串 `"400"` / `"700"` | `"bold"` / `"semibold"` 等词 |
| 对齐枚举 | 大写 `counterAxisAlignItems` / `primaryAxisAlignItems` | `alignItems` / `justifyContent`（小写） |
| 布局尺寸 | 设 `layout` 后显式给 `width`/`height`；动态尺寸用 `fill_container`/`hug_contents` | 假设 auto layout 自动给尺寸 |
| flexbox 子节点定位 | 需绝对定位时设 `layoutPositioning: "ABSOLUTE"` | 在 flex 子节点上直接设 `x`/`y`（会被忽略） |
| 图片 | 无 image 节点类型；用 G() 生成 frame 上的 fill（`stock`/`ai`/`placeholder`） | 粘贴外部 URL / 用 image 节点 |
| 图标 | frame 设 `layout:"none"` + 做成组件 + `I(type:"ref")` 插入；生成后 `capture_screenshot` 验证 | 用 icon font / 不设 `layout:none` |
| 变量绑定 | `$:<SetName>:<VariableName>`（如 `$:Semantic:bg-color`） | `$primary-color` 这类写法 |
| 节点命名 | 每个新建/复制节点都有有意义的 `name`；`document` 仅用于根 | 无名节点 |
| 批量提交 | 每批 `batch_edit` ≤ 25 ops，按逻辑区块拆 | 单批塞满整页 |
| 复制后代 | 用 C() 的 `descendants` 改复制出的后代 | 对复制出的后代直接 U()（ID 已变） |
| 校验参数 | `capture_screenshot` 必带 `screenShotDir`+`nodeIds`；`capture_layout` 必带 `parentId` | 缺必填参数 |
| 浮点颜色 | 保留 2 位小数 | 长浮点 |

**ardot MCP 中不存在、禁止调用的工具**：`fetch_style_guide`、`scan_all_unique_properties`、`substitute_all_matching_properties`、`fetch_style_guide_tags`（当前版本该工具不存在，不要调用——直接用本地 `references/style-guide-tags.md`）。

> 注：`create_design` / `open_design` 仅在 `mcp__ardot__*`（文件开关通道）提供；该通道未连接时不可用，详见 Preparation。其余设计工具均在 `mcp__ardot-design__*`（设计主通道）提供且本环境可用。

## Safety

涉及破坏性 / 不可逆的画布操作时，执行前必须先用 **AskUserQuestion** 向用户确认，明确列出将影响的节点与范围：

- **删除节点（D()）**、**批量覆盖整段子树（U() 大范围）**、**清空 `fills` / `strokes`**、**删除 / 重命名组件** —— 先确认
- 删除 / 覆盖前可先用 `batch_read` 记录待操作节点 id，便于向用户说明影响范围
- 已成功提交到画布的节点，除非用户明确要求，不要自动清理
- 单次影响节点数 > 200 的删除 / 覆盖，先提示用户范围再执行

## Error Recovery / 用户取消处理

- **任意 Step 收到 rejection / 用户取消信号**：立即停止后续步骤；用 **Bash** 清理本步产生的临时文件（如 `/tmp/*.json`）；画布上已成功提交的节点保留不动；依据对话中已记录的 checkpoint 日志，向用户报告「已完成哪些 Step、哪一步被取消、重新发起可从哪一步继续」
- **某 Step 失败（如 `batch_edit` 报错）**：不要静默跳过，用 `capture_layout` / `batch_read` 定位问题，单批修复后重验；同一 section 修复迭代不超过 2 次（见 `references/design-rules.md` 收敛阈值），仍失败则记录为已知限制并继续
- **ardot MCP 异常或连接中断**：立即停止写操作，提示用户检查 Ardot MCP 连接（参见 agent 的闭环提示），不要重试无意义的写调用
