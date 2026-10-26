# Logo 落地指南（本包自建标准）

> ## ⚠️ 非官方来源
>
> **本文不是官方规范。** 官方 `fetch_guidelines` 的 8 个 topic 里**没有 `logo`**
> （table / landing-page / web-app / mobile-app / slides / posters / code / tailwind）。
> 本文的尺寸、留白、审计条目均为**本包自建标准**，用于在没有官方口径时给出可执行的一致做法，
> 不是平台约束，也不能引用为"官方要求"。
>
> 上游若新增 `logo` topic，**以官方为准**，本文降级为补充；重新拉取方式见仓库
> `tools/official/README.md`（快照不随包分发）。

---

## 0. 能力边界（先读，避免承诺做不到的事）

Ardot 画布**不是矢量图形编辑器**。做 logo 之前必须知道下面几条，否则会中途卡死或产出劣质结果。

| 能力 | 有无 | 影响 |
|---|---|---|
| 布尔运算（union / subtract / intersect / exclude） | ❌ **没有** | 做不了"形状相减"型 logo（负空间、镂空字母、几何切割） |
| **SVG 矢量导入** | ✅ **有** | `type:"frame"` + `svg` 属性 → 解析成 FrameNode + 矢量子节点。**logo 首选路径**，缩放不糊、可进组件 |
| 路径编辑（拖锚点、调贝塞尔手柄） | ❌ 没有 | 导入后的矢量只能整体缩放 / 逐子节点改色，**改不了曲线形状**；要改形状回源文件改再重新导入 |
| 描边转轮廓（outline stroke） | ❌ 没有 | 不能把细描边字变成实心形状 |
| 形状 + 文本 + 效果（阴影/模糊/渐变） | ✅ 有 | 几何型 logo、字标型 logo 可做 |
| 图片填充（PNG/JPEG/WEBP） | ✅ 有 | 栅格 logo 可上传绑定 |
| 组件 / 实例 / 变体 | ✅ 有 | logo 做成组件后可全局复用、换色 |

> 表中标「❌」的项，判断依据是**当前 MCP 工具集与属性 schema 里没有对应操作**（不是"很难做"）。
> 若后续版本新增了相关工具，以实测为准，并回来更新本表。

### 硬规则

1. ⛔ **禁止凭记忆手写 SVG `path` 几何。** 人写不出准确的贝塞尔坐标，出来的曲线一定是歪的。
   矢量只能**导入权威源**（品牌方 SVG、Simple Icons、Lucide、设计工具导出），不做手写。
2. ⛔ **不要声称做了布尔运算。** 没有这个能力。需要镂空效果时，改用「图片填充 + 透明 PNG」或
   把负空间做成同色底层遮盖（仅纯色背景可行）。
3. ⛔ **不要用 emoji / Unicode 符号当 logo**。

---

## 1. 三条路线（按保真度排序）

### 路线 A：已有 logo 素材 → **SVG 矢量导入**（首选）

用户给了 SVG 时，**不要转 PNG**。`batch_edit` 支持把 SVG 解析成真正的矢量节点：

```javascript
logo=I(parentId, {
  type: "frame",
  name: "Logo / Primary",
  svg: "<svg viewBox=\"0 0 120 32\" xmlns=\"http://www.w3.org/2000/svg\">…完整的 SVG 源码…</svg>",
  width: 120, height: 32
})
```

解析结果是 **FrameNode + 矢量子节点**，不是位图——缩放不糊、能进组件、能改单个子节点颜色。
比"转 PNG 再上传"好一个档，且不消耗生图额度。

执行要求：

1. **整段 SVG 源码原样传入**，包括 `<svg>` 根标签、`viewBox`、命名空间。不要裁剪、不要改属性。
2. 传 `width` / `height` 按目标显示尺寸给，比例跟 `viewBox` 保持一致，别拉变形。
3. **必须截图验证**：`capture_screenshot({fileUrl, nodeIds:[logoId]})` 后 Read 图片。
   SVG 解析不是无损的——以下情况会失真或丢元素：滤镜（`feGaussianBlur` 等）、复杂渐变、
   蒙版 / `clipPath`、内嵌位图、外部字体依赖的 `<text>`。看到异常就降级到路线 A2。
4. 导入后可整体缩放；**改色要逐个子节点 `U()`**，不保证一次改全——这不是 bug，矢量子节点各自持有 fill。

### 路线 A2：位图素材 → 上传绑定（SVG 解析失败、或源本来就是 PNG/JPEG 时）

走标准真图管线：
`register_assets({fileUrl, contentType})` → `curl -X PUT '<uploadUrl>'` → `upload_images({items:[{nodeId, filePath: downloadUrl}]})`。

- 透明底优先。白底图贴在深色页面上会出现白框——这不算"logo 有边框"，是素材问题。
- 位图 logo 不可无损放大，交付说明里要写清"这是位图，放大到 N 倍会糊"。

> ⛔ 不要重绘用户的 logo。哪怕看起来很简单。
> ⛔ 不要因为"PNG 更省事"就跳过 SVG 导入——矢量是这个文件唯一能给的、位图给不了的东西。

### 路线 B：需要新做 → `ImageGen` 出栅格 logo

适合概念稿、活动标识、占位品牌。注意**位图 logo 不可无损放大**，交付时要说明。

```
ImageGen({
  prompt: "minimal vector-style logo mark, <主体隐喻>, flat single-color #0A0E1A on transparent background, centered, generous clear space, no text, no gradients, no 3D",
  size: "1024x1024",
  background: "transparent",
  quality: "high"
})
```

- `background: "transparent"` 出透明底，避免白框。
- prompt 里写 `no text`：模型生成文字极易拼错，字标另做（见路线 C）。
- 生成后必须**放大到 200% 检查**：边缘有没有脏点、笔画粗细是否均匀、左右是否对称。
- ⛔ 成本：约 5–10 credits/张，生成前告知用户。⛔ 一个 logo 只生成 + 绑定一次，不重试。

### 路线 C：字标（wordmark）→ 文本节点，不要生图

纯文字 logo 用**文本节点**做，不用图：

- 字体选 1 个，字重用 600–800，字距收紧（display 字距 −1% ~ −3%）。
- 需要"设计感"时靠**字体选择 + 字距 + 单色 + 留白**，不靠描边/阴影/渐变（那是 2010 年的做法）。
- 文本节点必须显式设 `fill`，否则不可见。
- 交付时把字体名写进说明——用户换环境时会掉字体（字体回退见 `style-guide.md`）。

---

## 2. 尺寸与留白（本包默认值）

| 项 | 默认值 | 说明 |
|---|---|---|
| 页面顶部导航 logo 高度 | 28–40 px | 与导航文字视觉重心对齐，不是与容器等高 |
| 页脚 logo 高度 | 24–32 px | 可比导航略小 |
| 海报 / 封面 logo 高度 | ≥ 短边的 3%，且 ≥ 32 px | 海报有 28px 文本下限，logo 同理不能小到看不清 |
| 最小可用高度 | **24 px** | 低于此值笔画糊成一团，宁可不放 |
| 安全留白（clear space） | 四周 ≥ logo 高度的 **0.5×**，理想 1× | 留白内不许出现任何其他元素 |
| 单色版本 | 必须有 | 深底用白版，浅底用深版，不要给彩色 logo 加白底块 |

**深浅底适配**：一个 logo 至少准备两版（深色版 / 浅色版）。只有一版时，用「同色系底板 + 反白」
而不是直接贴上去赌对比度。

---

## 3. 画布实现步骤

```
1. I(parent, {type:"frame", name:"Logo / Brand", layout:"none", width:W, height:H})
2. 绑定图片 fill（路线 A/B）或插入文本节点（路线 C）
3. 选中 frame → 做成组件（component）→ 命名 "Logo/Primary"
4. 其他位置用 I(parent, {type:"ref", ref:"<componentId>"}) 复用
```

要点：

- logo 容器必须 `layout: "none"`。用 auto layout 会让它随内容伸缩，破坏比例。
- 组件化之后**只改主组件**，所有实例跟着变；不要逐个实例改（那等于散落多份 logo）。
- 一个文件里 logo 组件不超过 3 个变体（Primary / Mono-dark / Mono-light）。再多说明在乱来。

---

## 4. 交付前审计（逐条核对）

| # | 检查 | 判定 |
|---|---|---|
| 1 | logo 比例未被拉伸 | 宽高比与原素材一致（对比原图，不靠目测） |
| 2 | 最小尺寸达标 | 实际渲染高度 ≥ 24 px |
| 3 | 安全留白成立 | 四周 ≥ 0.5× logo 高度内无其他元素 |
| 4 | 对比度达标 | 与背景 ≥ 3:1（logo 属图形，非正文；正文仍按 4.5:1） |
| 5 | 深浅底各有版本 | 深底不出现"深色 logo 贴深底" |
| 6 | 未重绘 / 未改字距以外的东西 | 用户素材原样使用 |
| 7 | 截图验证 | `capture_screenshot` 后 Read 图片，确认没糊、没错位 |

> 审计靠 `capture_screenshot` 的实际像素，不靠节点声明值——图片填充的裁切问题只在像素上看得见。

---

## 5. 与其它文档的关系

| 需要什么 | 去哪 |
|---|---|
| 图片填充 / 上传绑定 / `G()` 限制 | `design-rules.md` § Images |
| 矢量节点怎么安全导入 | `design-rules.md` §「SVG Icons」（`svg` 属性写法与截图验证） |
| 代码内联 SVG 怎么改 | `design-rules.md` §「Raw-code SVG」（改 `<path d>` 的验证纪律） |
| 组件、实例、变体 | `component-instance.md` |
| 品牌 VI 全案、吉祥物、IP 延展（**生成类交付**） | `miora/brand/overview.md`（需 `miora_*` 工具） |
| 海报里的 logo 摆放 | `guidelines-poster.md`（logo 属 footer 组，受 28px 下限约束） |

> **分诊提醒**：要「可编辑的 logo 设计稿」走本文（Ardot 画布）；要「成品 logo 图 / 整套品牌视觉」
> 走 Miora 品牌家族。两者不混用。
