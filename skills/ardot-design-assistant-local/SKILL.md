---
name: ardot-design-assistant-local
description: |
  Ardot 画布设计助手（自包含）：在 .ardot 文件上创建 / 修改 UI 界面、页面、布局、组件，
  以及设计稿转前端代码、设计↔代码双向校对、设计稿质量走查、网站风格提取、幻灯片生成。
  当用户说 "设计一个页面 / 屏幕"、"画一个落地页"、"做个 dashboard"、"修改这个设计"、"生成风格指南 / 设计系统"、
  "设计稿转代码 / 出码"、"生成幻灯片 / 演示文稿"、"一比一还原 / 复刻设计稿"、"导出为网页"、
  "对齐真实代码 / 校对设计稿 / 和代码对比一下"、"评审设计稿 / 走查"，或英文
  "design a page / screen", "create a landing page", "build a UI", "modify the design",
  "design to code", "generate slides", "pixel-perfect reproduction", "align design to code",
  "design review", "critique" 时使用。
  Triggers 覆盖中英文口语化表达。所有画布操作必须经过 ardot MCP 工具。
  本 skill 自带全部规则与工作流，不依赖任何外部 skill，可在任意支持 MCP 的 IDE 中独立运行。
metadata:
  version: "1.4.0"
  author: Sinclair
  license: MIT
  portability: "自包含。已在 WorkBuddy（含设计创意模式）与其他支持 MCP 的 IDE 中验证；MCP 通道名以运行时探测为准，不写死。"
---

# Ardot Design Assistant

在 `.ardot` 文件上完成设计任务的标准工作流。所有画布操作必须走 ardot MCP 工具。

## 可移植性说明（先读）

本 skill **自包含**：全部规则、schema、工作流、类型指南都在 `references/` 里，不依赖任何外部技能。

| 运行环境 | 差异 | 本 skill 的行为 |
|---|---|---|
| **其他 IDE**（Cursor / Claude Code / Cline 等） | 无 WorkBuddy 内置技能、无指令块 | 完全正常，走本文件全部流程即可 |
| **WorkBuddy · 日常办公 / 代码开发模式** | Ardot MCP 可能未注入 | 按下面「MCP 通道探测」判定；拿不到画布工具就终止 |
| **WorkBuddy · 设计创意模式** | 会**额外**注入 `ardot-design-core` + 领域技能 | 二者内容同源（本包为合并后的超集）。**以本包为准**；本包未覆盖处可参考注入技能 |

> 设计创意模式下宿主会预置一些结论（指令块），见「宿主注入指令块」——**出现就服从，没出现也不影响本流程**。

---

## MCP 通道探测（第一步，必做）

**不要假设通道名。** 不同环境 / 版本下 Ardot 会以不同命名空间暴露工具（历史出现过
`mcp__ardot__*`、`mcp__ardot-design__*`、`mcp__ardot-remote__*`），且**文件开关类工具
（`create_design` / `open_design`）与画布操作类工具可能不在同一命名空间**。

1. 找出当前会话所有 `mcp__ardot*` 前缀的命名空间。
2. 探测画布通道：`fetch_editor_state({ fileUrl })` 或 `fetch_file_info()`。
   - 正常返回 → 该命名空间即**画布通道**，固定使用，不再更换。
   - `NO_ADAPTER` / 工具不存在 → 换下一个命名空间重试。
3. **文件开关通道单独判定**：`create_design` / `open_design` 未必在画布通道下。
   - 有 → 可代用户建 / 开文件（异步，调用后等待就绪，用 `fetch_file_info` 确认）。
   - 都没有 → **不要**尝试代开代建，引导用户在 Ardot 编辑器中手动打开 / 新建 `.ardot` 文件。
4. 全部命名空间不可用 → 按文末「环境不可用」话术终止。

> 历史坑（勿复现）：早期版本写死过"`mcp__ardot-design__*` 是主通道、`mcp__ardot__*` 常 `NO_ADAPTER`"。
> 在部分环境里**恰好相反**（`ardot-design` 指向已禁用的 `127.0.0.1:50501` 本地路由，而 `ardot` 才是活通道）。
> 故此处一律以探测为准。

---

## 三处实测纠正（与部分文档 / 旧描述不一致，以本文件为准）

| # | 错误写法 | ✅ 正确 |
|---|---|---|
| 1 | `G(node, "stock", ...)` | `G()` 只接受 **`"ai"`** / **`"placeholder"`**，没有 `stock`。`ai` = 真实生成图（prompt 写完整描述）；`placeholder` = 灰底占位块（prompt 写 **≤20 字符短标签**，用用户语言） |
| 2 | `capture_screenshot({ screenShotDir: "..." })` | 当前 MCP **没有** `screenShotDir` 参数，只有 `fileUrl` + `nodeIds`。截图由工具返回可下载 URL，**下载并 Read 图片**才叫视觉验证；不要把截图写到磁盘任何目录 |
| 3 | 一次 `batch_edit` 塞满整页 | 每批 ≤ 25 ops，按逻辑区块拆 |

**ardot MCP 中不存在、禁止调用的工具**：`fetch_style_guide`、`fetch_style_guide_tags`、
`scan_all_unique_properties`、`substitute_all_matching_properties`。
（需要风格关键词灵感时，读本地 `references/style-guide-tags.md`，不要用不存在的工具。）

---

## 宿主注入指令块（仅 WorkBuddy 设计创意模式；出现即服从）

| 指令块 | 行为 |
|---|---|
| `<ardot_file_directive action="create">` | 首个画布动作**只发一次** `create_design`，然后继续。严禁二次调用"确认是否建成功" |
| `<ardot_file_directive action="open">` | **只发一次** `open_design(fileUrl/ID)`，然后继续 |
| `<ardot_file_directive action="ambiguous">` | 用户用了"创建 / 做一个"但**没有设计意图**（如"建个 CNB issue"）。**不要**建文件，先问用户确认 |
| `<ardot_image_gen mode="ai">` | 本任务所有 `G()` 用 `"ai"` 生成真实图（成品 / 交付稿） |
| `<ardot_image_gen mode="placeholder">` | 本任务所有 `G()` 用 `"placeholder"`（草稿 / 线框，不消耗生图预算） |
| `<ardot_design_style>` 风格模板 | 按注入说明拉取模板 md 作为视觉基底，**跳过** Step 4（`search_style_guide` / `build_style_guide`）；用户另有明确风格约束时，用用户约束覆盖冲突维度 |

> ⛔ **同一个任务最多一次 `create_design` 或 `open_design`。** 调用即视为已创建 / 已打开。
> 文件异步加载：调用后**等待**就绪再发其他 MCP 调用，不要与读操作并发。
> 确认文件 / 取 fileId 用 `fetch_file_info`，不是再调一次 create / open。
> 新建的空文件根 PageID 为 `0:1`，此时跳过 `fetch_editor_state`（无内容可读）。

---

## Reference Files

按需加载（在 Workflow 对应 Step 里用 Read **显式**读取）：

### 核心规则

| File | When to load |
|------|--------------|
| `references/design-rules.md` | **唯一事实来源** — 编辑原则、坐标、flexbox、文本、组件、颜色、变量、共享样式、表格、图片、效果、SVG、属性 schema、排障、生成后校验、⛔ Forbidden Patterns |
| `references/style-guide.md` | 视觉风格哲学 — 排版 / 配色 / 布局 / 表面处理 / 方差等级 / 反 AI 套路 / Bento 网格 / 创意弹药库 |
| `references/style-guide-tags.md` | `search_style_guide` 的**英文关键词灵感库**（按轴分组）。选词前读它，别凭空编 |
| `references/effects-guide.md` | 复合视觉效果配方：玻璃拟态 / 霓虹发光 / 金属 / 渐变描边 / 虹彩 / 新拟态。**动手画之前必读**（参数格式与常规预期不同） |
| `references/ardot-schema.md` | 节点属性 schema（Node Types / Property Mixins / Node→Mixin 组合 / 属性默认值省略优化） |

### 专项能力

| File | When to load |
|------|--------------|
| `references/component-instance.md` | 组件 / 实例 / 变体：属性定义、绑定到节点、实例上改属性、嵌套实例覆盖文本、隐藏可选子节点。**改任何 INSTANCE / COMPONENT / COMPONENT_SET 之前必读** |
| `references/design-variables.md` | 变量绑定与解绑、`apply_variables`、节点 `variableModes`（主题 / 密度）切换 |
| `references/shared-styles.md` | 共享样式绑定 `textStyleId` / `fillStyleId` |
| `references/batch-edit-tool-usage.md` | **`batch_edit` 完整操作手册**（I/U/C/M/D/G 语法、常见错误属性、字号字重对齐枚举）。**每次用 `batch_edit` 都要读** |
| `references/apply-variables-tool-usage.md` | `apply_variables` 使用手册。每次用 `apply_variables` 都要读 |

### 工作流

| File | When to load |
|------|--------------|
| `references/ardot-workflow.md` | 端到端流程示例（新建 / 修改 / 全局换肤 / 建变量 / 表单）与详细操作语法 |
| `references/slides-workflow.md` | 幻灯片 / 演示文稿 — 标准 5 阶段流程 |
| `references/slides-agent-teams-workflow.md` | 幻灯片 — Agent Teams 协作流程（质量更高但更慢、更费 token；作为选项提供给用户） |
| `references/design-to-code-workflow.md` | 设计 → 前端代码（含 Phase 0 平台澄清、导出、映射、本地预览、双证据终验） |
| `references/extract-style-guide-from-web.md` | 网站 → 设计指南提取 |
| `references/code-review-workflow.md` | 设计↔代码**双向**校对：**模式 A** 代码→设计稿 还原度评审 + **模式 B** 设计稿→代码 反向对齐（双证据硬门） |
| `references/design-review-workflow.md` | 设计稿**本身**质量走查（视觉 / 交互 / 内容 + WCAG 对比度 + 状态机） |

### 类型指南

| File | 触发 |
|---|---|
| `references/guidelines-landing-page.md` | 落地页 / 营销页 |
| `references/guidelines-web-app.md` | Web App（默认） |
| `references/guidelines-mobile-app.md` | 移动端 / App |
| `references/guidelines-table.md` | 表格 / 数据密集 |
| `references/guidelines-slides.md` | 幻灯片 |
| `references/guidelines-code.md` | 转代码（+ `references/guidelines-tailwind.md` 若用 Tailwind） |

> `fetch_guidelines(topic: ...)`（topic：`table` / `landing-page` / `web-app` / `mobile-app` / `slides` /
> `posters` / `code` / `tailwind`）是 Ardot 官方维护的规则源。**若该工具可用，它与本地 `guidelines-*.md`
> 冲突时以 `fetch_guidelines` 为准**；工具不可用时直接用本地文件。

---

## Standard Workflow

> **checkpoint 约定**：每完成一个 Step，立即在对话里记一条「✅ 已完成 Step N」。
> 中途取消 / 中断时可直接从断点续跑，无需重做。

### Step 0: 确认文件已就绪

- 调 `fetch_editor_state({includeSchema: false, includeGeneralEditInstructions: false})` 确认有打开的文件与当前选区。
- **硬门**：拿到有效文件前，不要发出任何写操作（I/U/C/M/D/G）。
- 没有打开的文件 → 按「MCP 通道探测」第 3 条处理（能代开就代开，不能就引导用户手动开）。

### Step 1: 读取现有状态（并行）

| 场景 | 调用 |
|---|---|
| 已有文件、要做新设计 | `fetch_editor_state({includeSchema:false})` + `fetch_variables`（一条消息并行） |
| 纯修改（文件已打开、目标已知） | 上面两个 **加** 按需 `batch_read` / `capture_layout` / `capture_screenshot`（均并行） |

### Step 2: 创意 vs 组合

- 创意（新屏幕 / 页面 / dashboard / 换肤）→ Step 3–4
- 组合（"加个按钮"、"移动这个"）→ 跳到 Step 5，读 `references/design-rules.md`

### Step 3: 加载设计类型指南

1. 若 `fetch_guidelines` 可用 → `fetch_guidelines(topic: <topic>)` 取官方规则。
2. 用 Read 读对应的本地补充手册（first-match）：

| 优先级 | 触发 | 手册 |
|---|---|---|
| 1 | slides, 幻灯片, 演示文稿 | `guidelines-slides.md` |
| 2 | mobile, app, 移动端 | `guidelines-mobile-app.md` |
| 3 | landing, 营销, 落地页 | `guidelines-landing-page.md` |
| 4 | table, 表格 | `guidelines-table.md` |
| 5 | 转代码, 出码, 生成应用 | `references/guidelines-code.md`（+ `references/guidelines-tailwind.md`） |
| 6 | web app（默认） | `guidelines-web-app.md` |

> ⛔ **用户指引优先**：用户给出的风格约束（自由文本、`DESIGN.md`、design tokens）与任何指南、
> 产品类型先验、或选中的风格模板冲突时，**一律听用户的**。模板和内置指南只填补未指定的空白。

### Step 4: 获取视觉风格

**若用户已给出明确风格约束、或有 `<ardot_design_style>` 指令块 → 跳过本步。**

1. Read `references/style-guide.md` 套用「反 AI 套路」定调；再 Read `references/style-guide-tags.md` 取英文关键词。
2. `search_style_guide({ styleKeywords, colorKeywords, typographyKeywords, layoutKeywords, sceneKeywords, compositionKeywords })`（建议 `topK: 3`）。所有关键词**必须英文**；按 `summary` + `bestFor` 选，不唯 `score`。
3. `build_style_guide({ style, color, typography, layout, scene, composition })` 物化 tokens，**直接读返回值套用**，不要凭记忆编。

### Step 5–6: 空间 + 检视（并行）

一条消息并行发起（仅当无相互依赖）：
- **新顶层屏幕**：必须调 `locate_available_space({width, height})` 避免重叠；纯修改跳过。
- 检视调用（仅修改且 Step 1 未覆盖时）：`batch_read`（`readDepth: 3` 看组件结构）、
  `capture_layout({parentId, problemsOnly: true})`、`capture_screenshot({nodeIds: [...]})`。
- 跳过不适用的子调用。

### Step 7: 执行设计

**动手前必读 `references/effects-guide.md`**（含 DROP_SHADOW / BACKGROUND_BLUR / 渐变 / 新拟态的正确参数格式）。

- `batch_edit` 每批 ≤ 25 ops；构建顺序：结构 → 内容 → 样式 → 校验。
- 操作：I() 插入 / U() 更新 / C() 复制 / M() 移动 / D() 删除 / G() 图片。
- 每次用 `batch_edit` 都要读 `references/batch-edit-tool-usage.md`；用 `apply_variables` 读 `references/apply-variables-tool-usage.md`。
- 改实例 / 组件 / 变体前必读 `references/component-instance.md`。

**图片模式**：有 `<ardot_image_gen>` 指令块就按它走；没有则按 `references/design-rules.md` 的 Images 规则自选。

> ⛔ **一个图像节点只允许一次 `G()`，绝不重试。** 截图显示"还在生成"、结果不满意、想"重新生成修一下"
> —— 都不行。等它跑完，或用 `U()` 等非 G 操作修版式 / 样式。重复 `G()` 既烧预算又会和上一个任务抢跑。

### Step 8: 校验

> **双证据硬门（全局纪律）**：任何「已对齐 / 已还原 / 无偏差」结论，必须同时基于
> ① **节点声明值**（`batch_read`，务必开 `resolveVariables` 取变量解析后的计算值）+ ② **实际渲染像素**。
> **无视觉能力时，像素一律用 `capture_screenshot` 导出 + Pillow 程序化取色兜底。**
> 禁止仅凭节点数据下结论——变量未生效、字体回退、父级 `clipsContent` / 透明度叠加，都会导致
> 「声明正常、渲染错误」。只采到单源须显式标注「低置信度、视觉未验证」。

分层校验（按本批改动挑最轻的一档，**不要每批都做全量双校验**）：

| 档 | 本批改了什么 | 校验方式 |
|---|---|---|
| T1 结构骨架 | 新 frame、布局模式、padding、层级 | 只 `capture_layout(problemsOnly: true)` |
| T2 内容填充 | 文本内容、token 绑定、实例属性 | **跳过**，并入下一批一起验 |
| T3 视觉 / 样式 | `fill`、排版、效果、圆角、描边 | 只 `capture_screenshot` |
| T4 区块完成 | 一整个逻辑区块（hero / features / footer）做完 | `capture_screenshot` + `capture_layout` **各一次** |
| T5 整页 | 所有区块合并 | 最后一次全页 `capture_screenshot` |

- 每个 `capture_screenshot` 都要 Read 返回的图片，**只拿到路径不算视觉验证**。
- 节点 > 2000px 高时分块截图，不要截整条。
- 连续两批都是 T2 / T3 → 只在末尾验一次。
- 收敛阈值：每区块**最多 2 次修复迭代**；忽略 ≤4px 间距噪声；区块符合规范后不再主观返工。

---

## Hard Rules（违反即返工）

- ⛔ **NO SUB-AGENTS（默认）**：不得 spawn / delegate 任何子智能体、Task、team member、后台 agent。
  **唯一例外**：用户在幻灯片任务中**明确点选**了「Agent Teams 协作流程」。
- 🔤 **输出语言**：未指定时，画布上所有文案默认使用用户提问的语言（嵌入的英文 / 外文原样保留，不翻译）。
  **确定语言后、发出第一个内容类 `batch_edit` 之前，必须向用户发一行公告**
  （如 `本次设计稿内容将使用中文生成` / `Generating the design content in English`）。每个设计任务都要发。
- 🎯 **目标节点优先**：用户指名 / 选中了具体节点，就只改那个节点；没指定才自行推断。
- 📐 **`fetch_editor_state` 必须传 `includeSchema: false`**，避免巨型响应。
- ✍️ **三段式回复**：Opening · Progress · Closing，用 `---` 分隔。不要对用户说"阶段 1/2/3"这类内部措辞。
- 🖼 **截图是内部验证产物**：下载并 Read，不向用户暴露路径，不写入 `/tmp`、家目录、项目根目录。
- 🔧 所有画布操作走 ardot MCP。

---

## Essential Constraints（硬约束）

完整规则、属性 schema 与排障以 **`references/design-rules.md`** 为准。

| 维度 | ✅ 必须 | ❌ 禁止 |
|---|---|---|
| 文本可见性 | 文本节点始终设 `fill` | 不设 `fill` 导致文本不可见 |
| 颜色属性 | `fill` / `fills` / `strokes` | `textColor` / `backgroundColor` / `color` / `fillColor` |
| 圆角 | `cornerRadius` | `borderRadius` |
| 字重 | 数字字符串 `"400"` / `"700"` | `"bold"` / `"semibold"` 等词 |
| 对齐枚举 | 大写 `counterAxisAlignItems` / `primaryAxisAlignItems` | `alignItems` / `justifyContent` |
| 布局尺寸 | 设 `layout` 后显式给 `width`/`height`；动态用 `fill_container` / `hug_contents` | 假设 auto layout 自动给尺寸 |
| flex 子节点定位 | 需绝对定位时 `layoutPositioning: "ABSOLUTE"` | 在 flex 子节点上直接设 `x`/`y`（会被忽略） |
| 图片 | 无 image 节点类型；先插 frame 再用 `G()` | 粘贴外部 URL / 用 image 节点 |
| 图标 | frame 设 `layout:"none"` + 做成组件 + `I(type:"ref")` 插入；生成后截图验证 | 用 icon font / 不设 `layout:none` |
| 图标（代码内联） | 改 `<path d>` 时遵循 `design-rules.md` 的「Raw-code SVG」小节：复制权威源（tdesign-icons / lucide / feather）或渲染验证 | 凭记忆手写 path 几何 / 未渲染就交付 |
| emoji | 文本节点只放纯文本；图标单独做 SVG frame | 用 emoji / Unicode 符号当图标 |
| 变量绑定 | `$:<SetName>:<VariableName>`（如 `$:Semantic:bg-color`） | `$primary-color` 这类写法 |
| 节点命名 | 每个新建 / 复制节点都有有意义的 `name` | 无名节点 |
| 批量提交 | 每批 `batch_edit` ≤ 25 ops，按逻辑区块拆 | 单批塞满整页 |
| 复制后代 | 用 C() 的 `descendants` 改复制出的后代 | 对复制出的后代直接 U()（ID 已变） |
| 校验参数 | `capture_screenshot` 传 `fileUrl` + `nodeIds`（单次 ≤ 10）；`capture_layout` 必带 `parentId` | 用不存在的 `screenShotDir` |
| 浮点颜色 | 保留 2 位小数 | 长浮点 |

---

## Specialized Workflows

> ⚠️ **硬门**：进入任一专用流程前**必须先 Read 对应 reference**，未读不得产出结论、不得动手。
> 输出须符合对应格式——`code-review` 必须含 **5 维还原度评分卡 + P0–P2 清单**，
> `design-review` 必须含 **6 维质量评分卡 + P0–P2 清单**——否则视为未完成。

| 任务 | 流程 |
|---|---|
| 幻灯片 / 演示文稿 | 默认 `references/slides-workflow.md`；用户追求更高质量时，先问一句是否走 `references/slides-agent-teams-workflow.md`（更慢更费 token）。强制规则在 `references/guidelines-slides.md` |
| 网站 → 风格指南提取 | `references/extract-style-guide-from-web.md` |
| 设计 → 前端代码 | `references/design-to-code-workflow.md` |
| 代码还原设计稿的还原度评审 | `references/code-review-workflow.md` 模式 A |
| 设计稿对齐真实代码（改设计贴代码） | `references/code-review-workflow.md` 模式 B |
| 设计稿质量评审（审**设计稿本身**） | `references/design-review-workflow.md` |

---

## When NOT to use

- 用户在非 Ardot 画布的设计工具里工作（Figma / Sketch / Photoshop）——本 skill 只操作 `.ardot`。
- 纯前端编码任务，没有设计稿也没有画布意图——直接用普通编码能力，不要绕到画布。
- 用户尚未打开任何 `.ardot` 文件且拒绝先打开——先引导，不要凭空生成。
- 需要 **PowerPoint `.pptx` 文件**作为交付物——走 pptx 能力，不是画布设计。

## Out of scope

- 与画布无关的纯前端工程（脚手架、构建配置、后端逻辑）——除非是「设计稿转码」的直接产出。
- 图标 / 图片素材的外部图库搜索（如 Unsplash）——图片一律用 `G()` 的 `ai` / `placeholder`，禁止粘贴外部 URL。

---

## Safety

破坏性 / 不可逆的画布操作执行前，必须先用 **AskUserQuestion** 向用户确认，明确列出受影响的节点与范围：

- **删除节点（`D()`）**、**批量覆盖整段子树（`U()` 大范围）**、**清空 `fills` / `strokes`**、**删除 / 重命名组件** —— 先确认
- 删除 / 覆盖前可先用 `batch_read` 记录待操作节点 id，便于说明影响范围
- 已成功提交到画布的节点，除非用户明确要求，不要自动清理
- 单次影响节点数 > 200 的删除 / 覆盖，先提示范围再执行

---

## Error Recovery / 用户取消处理

- **任意 Step 收到 rejection / 取消信号**：立即停止后续步骤；清理本步临时文件；画布上已成功提交的节点保留不动；
  依据对话里的 checkpoint 日志报告「已完成哪些 Step、哪一步被取消、可从哪一步继续」。
- **某 Step 失败（如 `batch_edit` 报错）**：不要静默跳过。用 `capture_layout` / `batch_read` 定位，
  单批修复后重验；同一 section 修复迭代不超过 2 次，仍失败则记为已知限制并继续。
- **ardot MCP 异常或连接中断**：立即停止写操作，提示用户检查 Ardot MCP 连接，不要无意义重试写调用。

---

## 环境不可用

画布通道探测全部失败时，停止设计操作并**原样输出**：

> 🎨 要使用 Ardot 设计功能，请确认 **Ardot MCP** 服务已安装并连接。
>
> （设计助手及其规则已随本专家一同打包，无需单独安装 skill。）

> WorkBuddy 用户补充提示：Ardot 连接器是「系统上下文连接器」，只在**设计创意**模式下按会话自动注入，
> 不会出现在连接器面板里。切到日常办公 / 代码开发模式会拿不到画布工具。
