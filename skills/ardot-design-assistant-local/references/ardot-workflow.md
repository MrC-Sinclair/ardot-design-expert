# Ardot MCP Tool Usage Guide — Complete Reference

端到端流程示例。设计规则、属性约束、排障、完整 **Tiered Validation / 收敛阈值** 见 `design-rules.md`。

> **四件事先记住**：
> 1. **文件开关**：ardot MCP 现已提供 `create_design` / `open_design`（ardot 服务，异步——调用后轮询 `fetch_file_info` 确认就绪）可新建 / 打开文件。若用户已在编辑器中打开文件，先用 `fetch_editor_state()` 探测当前选区；若没打开，可引导用户打开，或由你用 `open_design` / `create_design` 代开。（要在当前文档内加一块全新画布，用 `create_new_page(name: "...")`，拿返回的 `pageId` 作根。）
> 2. **并行读取无依赖的读调用** —— 一步里有多个无相互依赖的调用，一条消息并行发出；不要串行。示例用 `(parallel, single message)` 标注。
> 3. **校验 tier** —— `[T1]`/`[T3]`/`[T4]`/`[T5]` 标注每批 `batch_edit` 适用的校验 tier。不要每批都跑全量 screenshot+layout。每区块最多 2 次修复迭代。
> 4. **capture 必填参数** —— `capture_screenshot` 必须带 `screenShotDir`（绝对目录）+ `nodeIds`；`capture_layout` 必须带 `parentId`。

## End-to-End Workflow Examples

### Example A: 新建落地页

```
Step 0 (message 1):
  确认文件已打开：fetch_editor_state()（若没打开，引导用户先在 Ardot 打开 .ardot 文件）。
  （可选）create_new_page(name: "Landing") → 拿 pageId 作根容器。

Step 1 — 读现有状态（全新页可跳过；打开已有文件则并行）：
  # 打开已有文件：(parallel, single message)
  #   fetch_editor_state(includeSchema: false)
  #   fetch_variables

Step 2: Read guidelines-landing-page.md → 学落地页规则
        Read style-guide-tags.md → 为 Step 4 选英文关键词

Step 3: fetch_guidelines(topic: "landing-page")   (parallel, single message)
        （权威规则源；补充手册已在 Step 2 读）

Steps 4–6 (parallel, single message):
  search_style_guide({ styleKeywords: "...", colorKeywords: "...", typographyKeywords: "...", layoutKeywords: "...", sceneKeywords: "...", compositionKeywords: "..." })  ← 英文关键词
  locate_available_space(width: 1440, height: 3000)
  # `fetch_style_guide_tags`（ardot-design）现已提供，可直接获取官方英文关键词；也可继续用 Step 2 的 style-guide-tags.md

Step 4b: build_style_guide({ style, color, typography, layout, scene, composition })
         → 读返回的 design tokens（background_primary, radius_card …）并套用

Step 7: batch_edit → 页面 frame + hero 脚手架（结构）              [T1]
        → capture_layout({parentId: heroId, problemsOnly: true})   (skip screenshot)
Step 8: batch_edit → hero 内容与样式（视觉）                       [T3]
        → capture_screenshot({nodeIds: [heroId], screenShotDir: "<dir>"})  (skip layout)
Step 9: batch_edit → features 区块脚手架 + 内容 + 样式             [T4, 区块完成]
        → capture_screenshot({nodeIds: [...], screenShotDir: "<dir>"}) + capture_layout({parentId: featuresId, problemsOnly: true})  (once)
Step 10: batch_edit → footer + CTA 区块                            [T4, 区块完成]
        → capture_screenshot + capture_layout(problemsOnly: true) (once)
Step 11: 若累计有真实问题 → 一个 batch_edit 全修 → 只重跑对应 tier（每区块最多 2 次）
Step 12: capture_screenshot({nodeIds: [pageId], screenShotDir: "<dir>"})   [T5, 最终]
```

Notes:
- 全新页整体流程在首个 batch_edit 前是 2 次读往返（Step 2 本地读 + Steps 4–6 并行批）。
- 不要在两个 T3 批次间截图；推迟到区块边界。
- 若 T4 检查干净，可跳过 Step 11。

### Example B: 修改已有设计

```
Step 0: 确认文件已打开 → 没打开则引导用户先打开
Step 1: fetch_editor_state(includeSchema: false) → 看当前状态与选区
Step 2: batch_read(patterns: [{name: "Header"}]) → 找目标元素
Step 3: capture_layout({parentId: "headerId", maxDepth: 2}) → 检视当前布局
Step 4: capture_screenshot({nodeIds: ["headerId"], screenShotDir: "<dir>"}) → 视觉确认当前状态
Step 5: batch_edit → 应用修改（≤25 ops）
Step 6: capture_screenshot({nodeIds: [...], screenShotDir: "<dir>"}) → 验证改动（一次调用批量验证所有目标节点）
```

### Example C: 全局换肤（真实可行做法）

ardot MCP **没有** `scan_all_unique_properties` / `substitute_all_matching_properties`。全局换肤改用以下任一方式：

**方式一：变量驱动（推荐，若样式由变量绑定）**
```
Step 1: fetch_editor_state(includeSchema: false)
Step 2: fetch_variables → 看现有变量集
Step 3: apply_variables({ "Design Tokens": { modes: ["Light","Dark"], variables: { "bgColor": {type:"COLOR", valuesByMode:{...}}, ... } } })
        → 更新变量；所有绑定该变量的节点自动跟随变化            [T3，无需 capture_layout]
Step 4: capture_screenshot({nodeIds: [pageId], screenShotDir: "<dir>"}) 验证
```

**方式二：批量重读 + 重写（无变量绑定时）**
```
Step 1: fetch_editor_state(includeSchema: false)
Step 2: batch_read(patterns: [{type: "FRAME"}], readDepth: 3, properties:["fills","strokes","effects"]) → 收集需改的节点
Step 3: batch_edit → 对收集到的节点批量 U() 改 fills/strokes/radius（≤25 ops/批，按区块拆分）
Step 4: capture_screenshot + capture_layout({parentId: pageId, problemsOnly: true}) 验证
```

### Example D: 建立设计变量

```
Step 0: 确认文件已打开
Step 1: fetch_editor_state(includeSchema: false)
Step 2: fetch_variables → 看现有变量
Step 3: apply_variables → 建 / 更新变量集（Light/Dark 模式）
Step 4: batch_read(patterns: [{reusable: true}]) → 找要绑定变量的组件
Step 5: batch_edit → 把变量引用绑到组件属性                     [T2]
        （仅绑定变量不改变视觉/结构 → 跳过校验；若后续有视觉批次，在那里校验）
```

### Example E: 建注册表单

```
Step 0: 确认文件已打开 → 没打开则引导用户先打开（全新画布可 create_new_page）
Step 1: fetch_editor_state(includeSchema: false) → 拿可用组件
Step 2: batch_edit → 容器 frame + 标题 + 输入框 一次性完成（小表单 ≤25 ops 时一次建，再校验一次）
  container=I(document, {type: "frame", name: "Registration", layout: "vertical", width: 400, height: "hug_contents(600)"})
  title=I("containerId", {type: "text", name: "Title", content: "Create Account", fontSize: 28, fill: "#18191C"})
  input1=I("containerId", {type: "ref", ref: "InputComponentId"})
  U(input1+"/label", {content: "First Name"})
  ... （其余字段、提交按钮，同批）
Step 3: capture_screenshot({nodeIds: [containerId], screenShotDir: "<dir>"}) + capture_layout({parentId: containerId, problemsOnly: true})  (once)
Step 4: 若有问题 → 一个 batch_edit 全修 → 只重跑对应 tier（最多 2 次）
```

Notes:
- 表单这类自包含小 UI，≤25 ops 时一次建完再校验一次，而不是分脚手架/内容/样式多轮。
