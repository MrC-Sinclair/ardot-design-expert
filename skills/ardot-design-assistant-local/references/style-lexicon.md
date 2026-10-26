# 风格词典（Style Lexicon）

> **用途**：把用户口中的风格词，翻译成「英文检索词 + 视觉特征 + 配色取向」，供 Step 4 使用。
> **它不定数值。** 词典只回答"往哪个方向做"，具体 hex / 圆角 / 阴影参数一律来自
> `build_style_guide` 返回值或用户给定的 token（见文末「使用规则」第 4 条）。
>
> **来源**：由本专家维护者本人整理的 21 条 UI 大风格分类（`6种主流UI大风格.md` / `其他15种UI大风格.md`），
> 本文为其**结构化摘要 + 中文检索词补全**。编号沿用原素材便于对照；
> 原文第 20 条与第 3 条重复（Soft 3D / Spatial），**实际独立风格 20 个**。

---

## 0. 先分层：模板只能落在 L2 / L3

这套素材最有价值的不是 21 个名字，而是它开头的四级分类：

| 层 | 是什么 | 例子 | 能不能当"模板" |
|---|---|---|---|
| **L1 交互范式** | 界面如何被生成与交互 | GUI / 触摸 / GenUI | ❌ 不是视觉选择 |
| **L2 大风格** | 全部视觉维度的组合（材质、形态、色彩、层次、动效、字体、图标） | 液态玻璃、Material 3、新粗野主义 | ✅ **主模板只能来自这层** |
| **L3 趋势级风格** | 只管 1–2 个维度，1–3 年生命周期 | 超色彩（只管色彩）、动态排版（只管动效） | ✅ 可作"叠加项" |
| **L4 要素 / 手法** | 单一具体处理 | 内阴影、毛玻璃模糊值、按压微动效 | ❌ 是配方，不是模板 |

**混层是这类库最容易犯的错**：把 "Glassmorphism"（L2）和 "内阴影"（L4）并列成两个模板，
结果一个模板管全局、一个只管一个效果，选谁都别扭。

**硬规则**：一次设计 = **1 个 L2 主风格** + **最多 1 个 L3/L4 叠加项**。
⛔ 不要选两个 L2 混搭（"极简 + 赛博朋克"不是风格，是没决定）。

---

## 1. 主表：20 个独立风格

| # | 风格 | 英文检索词（喂给 `search_style_guide`） | 三条硬特征 | 配色取向 | 典型适用 |
|---|---|---|---|---|---|
| 1 | 液态玻璃 Liquid Glass | `liquid glass, frosted, translucent, backdrop blur, refraction` | 半透明面 + 背景模糊、边缘高光、多层浮动 | 浅底 + 高明度彩透 | AI / 高端消费 / 音乐 |
| 2 | 新粗野主义 Neo-Brutalism | `neo brutalism, thick border, hard shadow, oversized type` | 粗黑描边、硬投影（无模糊）、巨大字重 | 黑白高对比 + 撞色 | 创意工具 / 独立品牌 |
| 3 | 柔和空间立体 Soft 3D | `soft 3d, spatial, floating card, soft shadow, depth` | 3D 图标、漂浮卡片、大而柔的投影 | 浅紫浅蓝渐变 | 教育 / 家庭 / AI |
| 4 | 极简 Minimalism | `minimal, whitespace, restrained, low saturation` | 大留白、低饱和、极轻阴影 | 单色 + 中性灰 | SaaS / 效率工具 |
| 5 | 赛博朋克 Cyberpunk | `cyberpunk, neon glow, hud, dark ui, scanline` | 深底、霓虹描边发光、数据线 | 近黑 + 青 / 品红 | 游戏 / Web3 |
| 6 | 杂志排版 Editorial | `editorial, magazine layout, big type, multi column` | 超大标题、多栏网格、图文互嵌 | 米白 + 墨黑 + 一点强调 | 媒体 / 时尚 / 作品集 |
| 7 | 千禧 Y2K | `y2k, chrome, metallic, glossy, bubble` | 金属铬材质、气泡装饰、彩虹渐变 | 银紫 + 强高光 | 年轻品牌 / 音乐 |
| 8 | Web 2.0 光泽 | `web 2.0, glossy button, bevel, drop shadow` | 光泽按钮、倒角、明显投影 | 饱和蓝 + 白高光 | 复古营销页 |
| 9 | 像素 8-bit | `pixel art, 8 bit, sprite, pixel font` | 硬边缘、有限色板、像素字 | 16 色以内 | 游戏 / 趣味产品 |
| 10 | 终端 CLI | `terminal, monospace, command line, ascii` | 等宽字、黑底、命令提示符 | 黑 + 绿 / 琥珀 | 开发者工具 |
| 11 | 数据仪表盘 | `dashboard, kpi card, data dense, chart` | KPI 卡 + 图表 + 表格三件套 | 中性底 + 单一强调 | 后台 / B 端 |
| 12 | 瑞士国际主义 Swiss | `swiss, international typographic, strict grid` | 严格网格、无衬线、非对称 | 黑白 + 一强调色 | 品牌官网 / 出版 |
| 13 | 复古电脑 Retro | `retro computer, crt, windows 95, dos` | 灰窗口、像素图标、扫描线 | 灰 + 系统蓝 | 怀旧 / 实验 |
| 14 | 科幻 HUD | `sci fi hud, radar, telemetry, scanning line` | 雷达刻度环、扫描线、遥测数字 | 深蓝 + 青 | 游戏 / 展陈 |
| 15 | 黏土拟态 Claymorphism | `claymorphism, clay, pastel, soft shadow` | 超大圆角、厚卡片、软阴影 | 粉彩 Pastel | 儿童 / 消费 |
| 16 | 新拟态 Neumorphism | `neumorphism, soft ui, extruded, inset` | 同色背景、双向阴影、几乎无边框 | 单一浅灰 | 硬件控制面板 |
| 17 | 玻璃拟态 Glassmorphism | `glassmorphism, frosted glass, blur, translucent border` | 半透明卡 + 模糊 + 白描边 | 彩色底透出 | 通用现代 |
| 18 | 拟物 Skeuomorphism | `skeuomorphism, realistic texture, leather, paper` | 真实材质纹理、物理光影 | 棕 / 木 / 金属 | 笔记 / 复古工具 |
| 19 | Metro / Modern UI | `metro, tile, flat tile, typography` | 大色块 Tile、强字阶 | 纯色块 | 资讯 / 效率 |
| 21 | 扁平化 Flat | `flat design, solid color, no shadow, geometric` | 纯色、无阴影、简几何 | 明亮纯色 | 通用 / 工具 |

> 编号 20 空缺——原文第 20 条与第 3 条重复，已合并。

---

## 2. 反查：从产品类型倒推风格

用户说"做个 XX 产品"但没给风格时，从这里起手，**给出 2 个候选让用户选一句**，不要自己拍。

| 产品类型 | 首选 | 次选 | 慎用 |
|---|---|---|---|
| SaaS / 后台 / B 端 | 极简、数据仪表盘 | 瑞士、扁平 | 拟物、Y2K |
| 落地页 / 品牌官网 | 杂志排版、瑞士 | 液态玻璃、新粗野 | 像素、终端 |
| 海报 / 活动 | 新粗野、编辑排版 | 赛博朋克、Y2K | 极简（缺冲击） |
| 儿童 / 家庭 / 教育 | 黏土拟态、柔和 3D | 扁平 | 终端、赛博 |
| 游戏 / Web3 / 加密 | 赛博朋克、科幻 HUD | 像素 | 极简、瑞士 |
| 开发者工具 | 终端、数据仪表盘 | 扁平 | 黏土、Y2K |
| 高端消费 / AI | 液态玻璃、柔和 3D | 极简 | 像素、复古 |

---

## 3. 使用规则（**优先于上面两张表**）

1. **先归一，再检索**：把用户的话（"要高级一点""像苹果那种"）映射到表里**最近的一条**，
   取出它的英文检索词。不要拿中文原话去调 `search_style_guide`——它只吃英文。
2. **有工具就让工具出参数**：`search_style_guide({...英文词})` → 选 `summary`/`bestFor` 匹配的 →
   `build_style_guide(...)` 物化 tokens。**直接读返回值套用**，不要凭记忆编。
3. **没工具 / 检索为空** → 按该风格的「三条硬特征」手写实现，但**必须在交付说明里标注"参数为估算、非官方 token 库"**。
4. ⛔ **词典不提供任何 hex / 圆角 / 阴影数值**，本文也故意不写。看到"配色取向 = 浅紫浅蓝"就去编
   `#7C3AED` 是错的——那是猜的，不是设计。要么 `build_style_guide` 给，要么用户给。
5. **叠加项最多一个**：L2 主风格 + 一个 L4 手法（例：极简 + 玻璃卡片；编辑排版 + 硬投影），
   叠两个以上会互相抵消，看起来就是"没风格"。
6. **与 `style-guide-tags.md` 的分工**：本文是"成套映射"（风格 → 一组词），
   `style-guide-tags.md` 是"原子词库"（按色彩/排版/布局/场景/构图分轴）。
   **先查本文定方向，再用 tags 补该方向的细分词。**

> 用户给的风格约束（自由文本 / `DESIGN.md` / design tokens）永远压过本文任何建议。
> 本文只用于"用户没说清"的时候把方向收敛到一个具体候选。

---

## 4. token 兜底（4 个高频风格）

> **只在 `build_style_guide` 不可用、或返回空 / 明显不匹配时启用。**
> 这不是"官方 token 库"，是参数估算值。用了它，**交付说明必须写一句**：
> 「本次风格参数为估算值，非官方 token 库返回」。

### 4.0 使用前四条（不看会踩坑）

1. **优先级**：用户给定的 token / `DESIGN.md` > `build_style_guide` 返回 > 本文。
   本文**永远排最后**，不许拿它覆盖前两者。
2. **有 COLOR 变量集的文件，必须绑变量**：本文的 hex 只用来判断"该绑哪个语义角色"
   （bg / surface / text / accent），**不允许**因为"现值正好是这个蓝"就直接写 `#2563EB`。
   文件没有对应 token 时才可以写字面量，并在交付说明里列出"哪几处没有 token"。
3. **字体族名是意图举例，不是保证**：动手前先 `get_available_fonts` 查实际可用族与 style；
   查不到就用 `Inter` 兜底，靠**字重 + 字号 + 字距**拉层级，不要硬编不存在的字体（会静默回退）。
4. **字号档位是 UI 档（桌面 / 移动）**：海报、封面、小画布一律另按
   `guidelines-poster.md` §2.4 的字号表算（含 **28px 绝对下限**），本文档位对那里无效。

### 4.1 极简 Minimalism

| 维度 | 值 |
|---|---|
| 背景 / 表面 | `#FFFFFF` / `#F7F7F8` |
| 描边 | `#E5E7EB`，1px |
| 主文字 / 次文字 | `#111827` / `#6B7280` |
| 强调色 | `#2563EB`（全页只用在 1 个动作上） |
| 圆角 | 输入/按钮 6、卡片 8、大容器 12 |
| 阴影 | 极轻：`y1 blur2 spread0 a0.06`；能不画就不画，用 1px 描边代替 |
| 字号 | hero 56 / 区块标题 32 / 正文 16 / meta 13；字重 600 与 400 两档，别用第三档 |
| 栅格 | 8pt（8/16/24/32/48/64）；内容宽 1200，12 栏、gutter 24 |

**别做**：灰底卡片叠灰底卡片（层次会糊）、三种以上字重、把强调色用在装饰上。

### 4.2 杂志排版 Editorial

| 维度 | 值 |
|---|---|
| 纸底 / 墨色 | `#F7F4EF` / `#14110F` |
| 次级文字 | `#6B625A` |
| 强调色 | `#B23A2E`（oxblood，克制使用） |
| 分隔线 | `#14110F` @ 15% 透明度，1px hairline |
| 圆角 | 0–2（几乎不圆） |
| 阴影 | **不用**。层次靠 hairline + 留白 + 字号落差 |
| 字体 | 标题用衬线（意图：高对比 serif，如 Source Serif / Noto Serif SC）；正文与注释用无衬线（Inter / Noto Sans SC）。**全页最多 2 族** |
| 字号 | 大标题 72–96、导语 24、正文 17（行高 1.7）、图注 12（大写 + 8% 字距） |
| 栅格 | 12 栏**非对称**：正文占 7 栏、侧栏 3 栏，允许图片出血到页边 |

**别做**：圆角卡片、投影、居中正文超过 3 行、把正文也换成衬线（读不动）。

### 4.3 液态玻璃 Liquid Glass

| 维度 | 值 |
|---|---|
| 底层 | 深色渐变 `#0B1020` → `#2A1B4A`（浅色版：`#EEF2FF` → `#FDE7F9`） |
| 玻璃面 | 白色 **12%** 不透明度填充 |
| 玻璃描边 | 白色 **30%**，1px，`strokeAlign: "INSIDE"` |
| 背景模糊 | `BACKGROUND_BLUR` radius **28** |
| 投影 | `y8 blur32 a0.35` 黑，制造悬浮 |
| 文字 | `#FFFFFF`；次级用白色 70%，**不要用灰字**（会脏） |
| 强调色 | `#7DD3FC`（浅色版用 `#6D28D9`） |
| 圆角 | 卡片 24、导航/标签 pill（高度的一半） |

**别做**：玻璃层超过 3 层（糊成一团）、把不透明白卡混进玻璃面、玻璃上放低对比小字。

```javascript
// 玻璃卡片：SEMI-SOLID 用 opacity，不要写进 color.a
card=I("parentId", {type:"frame", name:"Glass Card", cornerRadius:24, padding:24})
U(card, {
  fills:[{type:"SOLID", color:{r:1,g:1,b:1}, opacity:0.12, visible:true, blendMode:"NORMAL"}],
  strokes:[{type:"SOLID", color:{r:1,g:1,b:1}, opacity:0.30, visible:true, blendMode:"NORMAL"}],
  strokeWeight:1, strokeAlign:"INSIDE",
  effects:[
    {type:"BACKGROUND_BLUR", radius:28, visible:true, boundVariables:{}},
    {type:"DROP_SHADOW", color:{r:0,g:0,b:0,a:0.35}, offset:{x:0,y:8}, radius:32, spread:0, visible:true, blendMode:"NORMAL", showShadowBehindNode:true, boundVariables:{}}
  ]
})
```

### 4.4 新粗野主义 Neo-Brutalism

| 维度 | 值 |
|---|---|
| 纸底 | `#FFFDF5`（米白，比纯白耐看） |
| 墨色 | `#0A0A0A`（边框 / 文字 / 硬投影同色） |
| 强调色 | `#FF5C00` 主、`#2F6BFF` 次（色块不用渐变） |
| 圆角 | **0**（要圆角就不是这个风格） |
| 描边 | **3px** 实线墨色，`strokeAlign: "INSIDE"` |
| 阴影 | **硬投影**：`x6 y6 blur0 spread0 a1`；模糊值必须是 0 |
| 字体 | 900 字重（Inter Black / Archivo Black / Noto Sans SC 900），大标题字距 **−2%** |
| 字号 | hero 64–96、区块 32–40、正文 16–18（字重 500，别用 300） |

**别做**：模糊阴影、渐变、1px 细边框、半透明面板——这四样任一出现就不是粗野主义。
**注意**：硬投影会溢出到相邻元素，卡片之间留 **6–8px** 以上间距，或父级设 `clipsContent: false`。

```javascript
// 硬投影：radius 必须 0，alpha 必须 1
card=I("parentId", {type:"frame", name:"Brutal Card", cornerRadius:0, padding:24})
U(card, {
  fills:[{type:"SOLID", color:{r:1,g:0.99,b:0.96}, opacity:1, visible:true, blendMode:"NORMAL"}],
  strokes:[{type:"SOLID", color:{r:0.04,g:0.04,b:0.04}, opacity:1, visible:true, blendMode:"NORMAL"}],
  strokeWeight:3, strokeAlign:"INSIDE",
  effects:[{type:"DROP_SHADOW", color:{r:0.04,g:0.04,b:0.04,a:1}, offset:{x:6,y:6}, radius:0, spread:0, visible:true, blendMode:"NORMAL", showShadowBehindNode:true, boundVariables:{}}]
})
```

---

### 4.5 没命中这 4 个怎么办

按 §3 规则 3 处理：用主表里该风格的「三条硬特征」手写，并按 §4.0 第 4 条标注参数为估算。
**不要**把两个风格的 token 拼起来充数（"极简的留白 + 赛博的霓虹" 不是折中，是没决定）。
