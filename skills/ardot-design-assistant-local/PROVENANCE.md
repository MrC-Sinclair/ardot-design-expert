# PROVENANCE · 溯源与同步说明

本专家包 `ardot-design-assistant-local` 是 **WorkBuddy 内置 Ardot 技能族的 fork**。
保留 fork 是**有意的产品决策**：本包必须能在**任意支持 MCP 的 IDE**（Cursor / Claude Code /
Cline / WorkBuddy 各模式）中独立运行，不依赖宿主注入任何内置技能。

代价是**上游升级不会自动同步**。本文件 + `sync-check.sh` 就是为此存在的机制。

---

## 一、上游来源

| 项 | 值 |
|---|---|
| 上游包 | `workbuddy-builtin/skills/` |
| 盘符路径（Windows） | `D:/codeSoftware/WorkBuddy/resources/app.asar.unpacked/resources/plugins/workbuddy-builtin/skills/` |
| 上游族| `ardot-design-core` · `ardot-ui-design` · `ardot-slides` · `ardot-poster` · `ardot-design-to-code` · `miora-creative-core` · `miora-brand-design` · `miora-image-generation` · `miora-video-generation` |
| 最近一次同步 | 2026-10-05 |
| 本地版本 | 1.5.1（2026-10-18）：补齐「设计系统门 / Bind Before Build / T2b token 绑定校验」 |
| 同步方式 | `bash sync-check.sh`（见下） |

---

## 二、文件分类（**改之前先看这里**）

### A. `verbatim` — 与上游逐字节一致（上游改动会覆盖回来）

这些文件**不要手改**：改了会在下次同步时被覆盖。发现上游有更新时，正确做法是接受上游版本。

| 本包文件 | 上游来源 |
|---|---|
| `references/ardot-schema.md` | `ardot-design-core/references/ardot-schema.md` |
| `references/effects-guide.md` | `ardot-design-core/rules/effects-guide.md` |
| `references/apply-variables-tool-usage.md` | `ardot-design-core/tool-usage/apply-variables.md` |
| `references/guidelines-code.md` | `ardot-design-to-code/references/guidelines-code.md` |
| `references/guidelines-tailwind.md` | `ardot-design-to-code/references/guidelines-tailwind.md` |
| `references/guidelines-mobile-app.md` | `ardot-ui-design/references/guidelines-mobile-app.md` |
| `references/guidelines-table.md` | `ardot-ui-design/references/guidelines-table.md` |
| `references/guidelines-web-app.md` | `ardot-ui-design/references/guidelines-web-app.md` |
| `references/guidelines-slides.md` | `ardot-slides/references/guidelines-slides.md` |
| `references/guidelines-poster.md` | `ardot-poster/references/guidelines-poster.md` |
| `references/extract-style-guide-from-web.md` | `ardot-design-to-code/workflows/extract-style-guide-from-web.md` |
| `references/miora/**`（15 个文件） | `miora-creative-core` / `miora-brand-design` / `miora-image-generation` / `miora-video-generation` |
| `references/livestream-poster/**`（11 个文件） | `livestream-poster/`（SKILL + references + workflows） |
| `scripts/*.mjs`（2 个） | `livestream-poster/scripts/`（`fetch-operation-styles.mjs` / `fetch-operation-design.mjs`） |

> ⚠️ **例外**：`references/miora/**` 与 `guidelines-poster.md` 虽源自上游，但已做**本地化改造**
> —— 内部路径引用全部重写为本包路径（`Skill(miora-creative-core)` → `Read references/miora/creative-core.md`），
> `creative-core.md` 另加了「环境前置检查」护栏。**再同步时必须重新做这两步改造**，否则会退回成
> 指向不存在 skill 的死链。

### B. `fork` — 本地分叉，本包为权威（上游更新时需人工合并）

| 本包文件 | 上游来源 | 分叉内容 |
|---|---|---|
| `references/design-rules.md` | `ardot-design-core/rules/design-rules.md` | **本地扩充约 40KB**（组件属性定义 / 变体 / 组件属性绑定等章节为本地独有）；同时已修正上游的 `screenShotDir`、`G() "stock"` 等失效参数。1.5.1 新增 `### Bind Before Build`、`T2b — Token binding` 校验档、Components 段的「复制前审计参考节点」 |
| `references/style-guide.md` | `ardot-design-core/rules/style-guide.md` | 小幅修订（`G()` 类型枚举更正） |
| `references/shared-styles.md` | `ardot-design-core/func-rule/shared-styles/SKILL.md` | 去frontmatter，正文一致 |
| `references/component-instance.md` | `ardot-design-core/func-rule/component-instance/SKILL.md` | 小幅修订 |
| `references/design-variables.md` | `ardot-design-core/func-rule/design-variables/SKILL.md` | 小幅修订；1.5.1 新增「写画布前必做（Bind Before Build）」与 `resolveVariables` 读回口径。**已从 SKILL.md 的「宿主注入跳过清单」移出**——本文件是 fork，旧清单按 verbatim 跳过它，会让本地新增内容在注入模式下永不生效 |
| `references/ardot-workflow.md` | `ardot-design-core/workflows/ardot-workflow.md` | 不存在工具替换为`batch_read` / `batch_edit` |
| `references/batch-edit-tool-usage.md` | `ardot-design-core/tool-usage/batch-edit.md` | 小幅修订；1.5.1 补一条「成功响应 ≠ 已绑定 token」的校验提示 |
| `references/slides-workflow.md` | `ardot-slides/workflows/slides-workflow.md` | 流程细化 |
| `references/design-to-code-workflow.md` | `ardot-design-to-code/workflows/design-to-code-workflow.md` | 流程细化（Phase 0 平台澄清、双证据终验） |
| `references/guidelines-landing-page.md` | `ardot-ui-design/references/guidelines-landing-page.md` | `G()` 类型枚举更正 |
| `SKILL.md` | —（本地原创） | 入口：MCP 探测、三处实测纠正、宿主指令块、分层校验、硬约束表 |

> **合并方向永远是「上游 → 本包」**：先看上游新增了什么，再决定是否并入本包。
> 反向（本包 → 上游）不成立，因为上游不归我们改。

> ⚠️ **`scripts/` 是可移植性的关键**：直播海报的「静默匹配视觉风格」靠这两个脚本拉远程风格目录。
> **不带上它们，直播海报的 style-matching 工作流在任何 IDE 上都跑不起来。**
> 两者只依赖 Node 内置 `fetch`（Node ≥ 18）+ 远程 JSON catalog，零本地依赖，已实测可跑。

### C. `local-only` — 本包独有（上游没有，不要删）

| 文件 | 用途 |
|---|---|
| `references/design-review-workflow.md` | 设计稿**本身**质量走查（6 维评分卡 + P0–P2） |
| `references/code-review-workflow.md` | 设计↔代码**双向**校对（模式 A 还原度 / 模式 B 反向对齐） |
| `references/slides-agent-teams-workflow.md` | 幻灯片 Agent Teams 协作流程（多 agent，质量更高） |
| `references/style-guide-tags.md` | `search_style_guide` 英文关键词灵感库（替代不存在的 `fetch_style_guide_tags`） |

---

## 三、同步流程

```bash
bash sync-check.sh          # 在本 skill 目录下执行
```

输出分两类：

- **`verbatim` / `SAFE-TO-OVERWRITE`** — 上游有更新，本包无改动。直接覆盖是安全的。
- **`FORK — MANUAL MERGE`** — 本包改过，上游也有更新。**必须人工看 diff**，把上游新增内容并进来。

同步后必做回归（本包对上游做了本地化改造，机械覆盖会破坏）：

1. 复扫失效参数：`grep -rn "screenShotDir\|G(.*\"stock\"" references/`
2. 复扫不存在的工具：`grep -rn "scan_all_unique_properties\|substitute_all_matching_properties\|fetch_style_guide_tags" references/`
   （命中处必须是在「⛔ 不存在 / 禁止」的条款句里）
3. 复扫死链：`grep -rn "Skill(miora\|ardot-design-core/" references/` 应为 0 命中
4. 若 `guidelines-poster.md` 或 `references/miora/**` 被覆盖，重做「A类例外」里的本地化改造

---

## 四、双入口共存约定

在 WorkBuddy「设计创意」模式下，宿主会**额外**注入 `ardot-design-core` + 领域技能，
与本包构成双份同源规则。**处置规则见 `SKILL.md` 的「宿主注入时的加载门」**：
verbatim 文件一律跳过不读，只读本包分叉部分。既避免规则冲突，也省100KB+ 上下文。
