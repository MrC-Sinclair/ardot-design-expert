# 设计稿质量评审工作流（Design Review）

交叉使用 Ardot 节点读取与截图能力，对设计稿**本身**做专业走查。所有结论必须可追溯到
`batch_read` 节点数据、`capture_screenshot` 截图或 `capture_layout` 结构检测三者之一，杜绝「看起来」式主观臆断。

## 0. 前置

- 确认 `.ardot` 已打开（`fetch_editor_state`）。
- 用 `fetch_editor_state` 拿根 / 页面结构，确定评审范围（逐页或指定节点 id）。
- `batch_read` 读取目标节点（`readDepth` 适中，`resolveInstances:true` 解析组件实例的语义 ID）。

## 1. 数据获取与对齐

对每页 / 每区块：

1. `capture_layout({parentId:<pageId>, problemsOnly:true})` → 自动列出结构问题（重叠 / 溢出 / 错位），作为 P0 候选。
2. `batch_read` 遍历关键节点，提取字段（见 SKILL.md 列表）。
3. `capture_screenshot({nodeIds:[...], screenShotDir:"<绝对目录>"})` 截图，与节点数据交叉印证。

## 2. 评审检查清单（逐项打分 + 找问题）

### 一、视觉设计（Visual）

1. **布局与对齐**
   - 模块间距：`itemSpacing` / `padding*` 是否一致、是否遵循规律（如 8 的倍数）。
   - 对齐：兄弟节点 `x`/`y` 是否对齐；边缘 / 拼接处是否有错位（`capture_layout` problemsOnly 已标）。
2. **色彩规范**
   - 调色板一致性：所有 `fills` 是否落在同一套色板（允许中性灰 + 单强调色，饱和度 <80%）。
     出现杂色 / AI 紫蓝（如 `#6D5BFF` 类发光紫）/ 纯黑 `#000000` → 记问题（对照 style-guide §3、§9）。
   - 对比度 WCAG AA：关键文本 vs 背景计算相对亮度比，正文 ≥4.5:1、大字 ≥3:1（算法见 §3）。不达标 → P1。
   - 功能性色：成功绿 / 失败红 / 警告橙使用是否正确一致。
3. **字体与排版**
   - 字体家族统一：`fontName.family` 中英文 / 数字一致；避免把 `Inter` 当首选（style-guide 反 AI 套路），
     优先 Geist / Outfit / Satoshi；缺失则 `get_available_fonts` 核对真实可用字体。
   - 字号层级：`fontSize` 标题 > 正文 > 辅助，分明；`fontWeight` 用数字串（"400"/"700"）。
   - 行高 / 段落：`lineHeight` 舒适；`characters` 结合截图检查是否有孤儿文字（末行 1–2 字）或异常折行。
4. **图标与图片**
   - 图标风格统一（线性 / 面性 / 颜色 / 视觉重量）；SVG 节点需 `layout:"none"`（对照 design-rules SVG 规则）。
   - 图片：`fills` 为 G() `stock`/`ai`/`placeholder`，容器 `width/height` 比例与图片是否失真（截图核对无拉伸 / 裁剪）。
5. **控件与组件一致性**
   - 对照组件库（`batch_read` 设计系统 frame）：按钮 / 输入 / 卡片 / 标签的 `cornerRadius`、`strokes`、`effects`、`fills`、尺寸是否全局统一。
   - 状态机：组件是否为 `COMPONENT_SET` 且覆盖 `hover`/`pressed`/`disabled`/`selected` 变体（见 §4）。缺关键状态 → P1。

### 二、交互与体验（Interaction & UX）

1. **信息架构与导航**：主导航是否清晰；层级主次是否分明（结合截图看视觉权重）。
2. **操作反馈与状态**：是否有 loading（骨架屏）/ empty / error 状态设计（style-guide §7）。缺空 / 错状态 → P2。
3. **点击区域**：可点节点 `width`×`height` 移动端 ≥44×44pt（≈44×44px@1x），否则误触风险 → P2。
4. **响应式**：高 variance 设计在窄视口是否回退单列（style-guide §4）。

### 三、内容与文案（Content）

1. **拼写 / 语法**：`characters` 文本检查错别字、病句、标点。
2. **术语统一**：同一功能名称全篇一致（如「购物车」）。
3. **长度 / 截断**：`textTruncation`/`maxLines` 是否导致按钮 / 标签文字截断或换行错乱（结合截图与最短宽度推断）。

### 四、开发交付（Dev Handoff，弱化）

Ardot 是画布，**无 Figma 式标注导出 / @1x@2x@3x 切图**。本维度弱化：

- 提示用 `capture_screenshot` 导出视觉给开发；`devStatus` 字段可标开发状态。
- 若用户需要「代码还原度」评审，转 `code-review-workflow`，不要在此硬评切图。

## 3. WCAG 对比度计算

从节点 `fills` 取色（SOLID：`r,g,b` ∈[0,1]，转 0–255）：

```javascript
function lum(c){ c/=255; return c<=0.03928 ? c/12.92 : Math.pow((c+0.055)/1.055, 2.4); }
function relL(r,g,b){ return 0.2126*lum(r)+0.7152*lum(g)+0.0722*lum(b); }
function contrast(fg,bg){
  const L1=relL(fg[0],fg[1],fg[2]), L2=relL(bg[0],bg[1],bg[2]);
  const hi=Math.max(L1,L2), lo=Math.min(L1,L2);
  return (hi+0.05)/(lo+0.05);
}
```

- 正文文本 vs 背景 ≥ 4.5:1；大号文本（≥24px 或 ≥18.66px 且 bold）≥ 3:1。
- 取文本 `fill` 与最近背景节点 `fills` 计算；半透明叠底按 `opacity`/`a` 合成背景后再算。

## 4. 交互状态机读取

- 控件若为 `COMPONENT_SET`：`batch_read` 取其 `componentPropertyDefinitions` 中 `VARIANT` 类型属性的 `variantOptions`（如 `["default","hover","pressed","disabled"]`）。
- 核对是否覆盖默认 / 悬停 / 点击 / 禁用 / 选中；缺失即在报告中列出缺失状态与建议补的变体。
- 实例通过 `componentProperties` 切换变体（`U(instance,{componentProperties:{"State":"hover"}}`）——评审只读取，不改写。

## 5. 输出格式（强制结构化）

### 评审概览
一句话：整体质量 + 最大亮点 + 最大隐患。

### 质量评分卡
| 维度 | 得分(/10) | 核心问题 |
| :--- | :--- | :--- |
| 布局与对齐 | X | ... |
| 色彩与对比度 | X | ... |
| 字体与排版 | X | ... |
| 控件与一致性 | X | ... |
| 交互状态 | X | ... |
| 内容与文案 | X | ... |

### 问题清单（P0–P2，带位置与修复建议）
- **P0（致命）**：严重违背规范 / 结构错位 / 对比度严重不足 / 缺核心状态导致不可用。
  - `[页面/区域/元素]`：问题描述。**→ 修复建议**：具体属性（例：将 `fill` 从 `#000000` 改为 `#18181C`；`itemSpacing` 统一为 16）。
- **P1（重要）**：体验 / 视觉统一性受损（缺 hover/disabled、对比度临界、字体家族混用）。
- **P2（一般）**：细节微调（孤儿文字、点击区 <44px、缺空状态设计）。

### 具体问题位置
逐条指明「页面 / 区域 / 元素」，如「- 登录页：登录按钮缺 `pressed` 变体，点击后无反馈。」

### 总结建议
给设计师 / 开发的整体改进方向，点到最该先改的一块，也肯定出色之处。

## 6. 收敛阈值

- 每区块评审建议最多 2 轮；读不到的字段标「未知」不臆测。
- 间距噪声 ≤4px、亚像素错位忽略；不为主观审美反复返工。
- 仅报告工具 / 数据实际反映的问题。
