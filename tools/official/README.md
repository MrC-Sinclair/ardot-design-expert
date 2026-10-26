# tools/official/ — 官方规则快照（不随包分发）

`fetch_guidelines` 是 Ardot 官方维护的规则源。本目录存放**官方原文快照**，用途只有一个：
和上游做 diff，判断本地工作副本是否漂移。

> **本目录在 `tools/` 下，因此不会被打进交付 zip。**
> 打包只收 `.codebuddy-plugin/` `agents/` `avatars/` `skills/`（见根目录 `AGENTS.md`），
> `tools/` 整体排除。所以这里可以放"只给维护者看、运行时不读"的东西。

## 当前快照

| 文件 | topic | 拉取日期 | 状态 |
|---|---|---|---|
| `posters.md` | `posters` | 2026-10-26 | ✅ 官方原文逐字快照（§0–§8 完整） |

**只有一张快照，是有意为之，不是漏做。** 理由见下节。

## 为什么不给 8 个 topic 都做逐字快照

`fetch_guidelines` 共 8 个 topic：`table` / `landing-page` / `web-app` / `mobile-app` /
`slides` / `posters` / `code` / `tailwind`。其中 7 个在
`skills/ardot-design-assistant-local/references/` 下**已有本地工作副本**（`guidelines-*.md`），
且本身就是从上游同步来的（见 `PROVENANCE.md` A 类）。

对它们再做逐字快照会带来两个**实质问题**，不是省事：

1. **会重新引入已判定失效的写法。** 2026-10-26 实测 `landing-page` 官方原文里仍有
   `G(hero, "ai", "modern team collaboration workspace")` 和「用 G 搜 Unsplash 图库」。
   这两条在本通道都不可执行（`G()` 的 `type` 只接受 `"placeholder"`，见 MCP schema）。
   逐字快照 = 把失效示例搬进仓库，直接违反本仓库的回归规则
   （`PROVENANCE.md` §四 第 2 条：`grep 'G(.*"ai"' references/` 应为 0 命中）。
   **逐字快照与"不得声称 G() 支持 ai"是互斥的**，只能二选一。这里选后者。
2. **重复 ~100KB 同源文本。** 两份一模一样的规则同时存在，只会让"读哪份"变成新的歧义源。

因此策略是：**官方原文里存在失效指令的 topic，不做逐字快照，以本地工作副本为准**
（工作副本已把失效段替换为可执行链路，并在 `PROVENANCE.md` 登记为 `fork`）。

`posters` 是唯一例外，也是唯一真缺口：官方 §8「多尺寸一致性」在本地旧稿里**整段缺失**
（本地只到 §7），所以必须把原文拿回来。

## 优先级（冲突时按此裁决）

```
用户显式指令
  > 官方原文基线（本目录）
  > skills/ardot-design-assistant-local/references/guidelines-<topic>.md（工作副本，含本地化改写）
  > 类型指南推断
```

⚠️ 但快照是**基线，不是执行稿**：里面的失效指令（如 `G(...,"ai")`）照抄会失败。
执行时读工作副本；只有怀疑工作副本漂移时，才回来 diff 快照。

## 如何刷新快照

1. 调 `fetch_guidelines({topic: "<topic>"})`。
2. 把返回正文**原样**写入 `tools/official/<topic>.md`，文件头加：

```
<!--
官方规则快照（OFFICIAL SNAPSHOT）· 请勿改写正文
source : fetch_guidelines(topic: "<topic>")
captured: <YYYY-MM-DD>
status : 官方原文，逐字未删改。本地注解只能追加在末尾「本地注解区」。
-->
```

3. 与工作副本 diff（`skills/ardot-design-assistant-local/references/guidelines-<topic>.md`），
   把**新增且可执行**的内容并入；不可执行的部分（不存在的工具、失效参数）在并入时替换为等价链路，
   并在 `PROVENANCE.md` 记一笔。
4. 若某 topic 的官方原文新增了失效指令，**不要把该 topic 加入本目录**——按上节理由处理。

## 硬约束

- ⛔ 不得改写快照正文措辞。本地说明只能放文件末尾「本地注解区」。
- ⛔ 不得把快照正文整段复制进 `SKILL.md`。`SKILL.md` 只做索引，且**不应引用本目录**
  （本目录不随包分发，写进 SKILL.md 就是给用户一个打不开的路径）。
- ⛔ 不得引用不存在的章节：官方 §8.3 提到的 `ardot-poster` SKILL「Step 5 → Multi-size shared master visual」
  **在任何环境都不存在**——本包没有这个 skill；上游 `skill-ardot-poster` 插件虽有同名 `SKILL.md`，
  但里面没有 Step 5，也没有 `text_to_image` / `edit_image`。
