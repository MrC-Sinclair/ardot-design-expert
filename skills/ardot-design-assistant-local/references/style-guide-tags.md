# search_style_guide 关键词灵感库（英文）

> `search_style_guide` 的关键词**必须全英文**（目录是英文的，非 ASCII 会被拒绝）。
> 本文件按轴分组，给你选词灵感——挑 1–2 个/轴，组合成各 `*Keywords` 参数。
> 用法：
> 1. 用 Read 读本文件，按用户意图挑英文关键词。
> 2. 结合 `style-guide.md` 的创意方向（反 AI 套路、禁紫调等）定调。
> 3. 调 `search_style_guide({ styleKeywords, colorKeywords, typographyKeywords, layoutKeywords, sceneKeywords, compositionKeywords })`。
> 4. 对返回候选按 `summary`+`bestFor` 选（不唯 `score`），再调 `build_style_guide` 物化 tokens。

## Platform / Scene（→ sceneKeywords）
- web app, SaaS dashboard, mobile app iOS, mobile app Android, marketing landing, e-commerce, fintech, devtools, admin console, portfolio, blog, docs site

## Mood / Tone（→ styleKeywords 或 colorKeywords）
- minimal, clean, modern, premium, elegant, luxury, playful, friendly, corporate, enterprise, editorial, brutalist, swiss, scandinavian, japanese, zen, dark mode, light mode, monochrome

## Color direction（→ colorKeywords）
- warm earthy, muted sage, cool slate, high contrast, vibrant, pastel, neon cyberpunk, navy gold, emerald accent, off-black zinc, cream ivory, terracotta

## Typography（→ typographyKeywords）
- elegant serif editorial, geometric sans, grotesk, monospace dev, bold display, condensed, humanist, technical

## Layout / Composition（→ layoutKeywords / compositionKeywords）
- bento dashboard, sidebar nav, hero floating screenshot, split screen, asymmetric white space, masonry, zig-zag cards, sticky scroll, glassmorphism, dark sidebar, icon rail, magazine grid, data dense

## 反套路提醒（来自 style-guide.md，定调时遵守）
- 禁 "AI 紫/蓝" 渐变发光；用中性底 + 单一高对比强调色。
- 不用纯黑 #000000，用 Zinc-950 / 炭灰。
- 降饱和度，强调色与中性色融合。
- 非编辑/创意场景不用衬线；避免满屏 Inter（优先 Geist / Satoshi / Cabinet Grotesk 等，缺失时 `get_available_fonts` 兜底）。
- 不用 3 等宽卡片排排坐；用 zig-zag / 非对称网格 / 横滑。
