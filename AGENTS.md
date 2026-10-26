# AGENTS.md — 接手这个仓库先读这里

给任何 AI 助手 / 维护者的上下文说明。人类维护者同样适用。

## 这是什么

WorkBuddy 专家包 `ardot-design-expert`（当前 1.7.1）。人设是「会写前端的设计总监 Jax」，
通过 Ardot MCP 操作设计画布，也能把设计稿转成前端代码、做设计↔代码双向走查。
核心能力全部在 `skills/ardot-design-assistant-local/`，包里不带任何外部 skill 依赖。

## 目录与交付边界

**会进交付包**（zip 顶层目录 `ardot-design-expert/`）：

```
.codebuddy-plugin/plugin.json   agents/   avatars/   skills/   README.md   LICENSE
```

**不进包**（仓库内务，打包时排除）：

```
tools/  AGENTS.md  CLAUDE.md  .git/  .workbuddy/
skills/ardot-design-assistant-local/PROVENANCE.md   # 溯源文档：留在仓库，不进包
```

打包（在仓库上一级目录执行）：

```python
import zipfile, pathlib
src = pathlib.Path('ardot-design-expert'); out = pathlib.Path('ardot-design-expert-<ver>.zip')
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for f in ['README.md', 'LICENSE']:
        z.write(src/f, f'ardot-design-expert/{f}')
    for d in ['.codebuddy-plugin', 'agents', 'avatars', 'skills']:
        for p in sorted((src/d).rglob('*')):
            if p.is_file() and p.name != 'PROVENANCE.md':   # 溯源文档不随包
                z.write(p, f'ardot-design-expert/{p.relative_to(src).as_posix()}')
```

## 三条不变量（改任何东西之前先确认）

1. **plugin.json**：`tags` 与 `quickPrompts` 各 3 条；`defaultInitPrompt` 必须等于 `quickPrompts[0]`；
   `displayDescription.zh` 40–50 字符（按 `len()` 算）；`name` / `agentName` / `agents/` 下的文件名**不可改**。
2. **版本号三处同步**：`.codebuddy-plugin/plugin.json` 的 `version`、`SKILL.md` 的 `metadata.version`、
   `PROVENANCE.md` 的「本地版本」。只改一处会留下不一致。
3. **`references/` 下不得出现嵌套 `SKILL.md`**：会被技能加载器当成独立技能注册，导致名字冲突。
   参考资料一律用普通 `.md`（如 `overview.md`）。引用路径统一相对 skill 根写 `references/xxx.md`。

## 修改前必读

- `skills/ardot-design-assistant-local/PROVENANCE.md`：逐文件标注 `verbatim`（与上游逐字节一致，改了会被覆盖）
  / `fork`（本地分叉，需人工合并）/ `local-only`。**动 reference 之前先查这张表。**
- `references/design-rules.md`：画布操作的唯一事实来源，其他文档与它冲突时以它为准。
- `tools/official/`：官方 `fetch_guidelines` 原文快照（**不随包分发**）。改海报 / 多尺寸规则前，
  用它和 `guidelines-poster.md` 做 diff；官方原文里仍有失效写法，**不要整段照抄进 references**。

## 无 MCP 时的行为（这是本包的关键差异，不要改回去）

探测不到 `mcp__ardot*` 时，**不允许**用一句"请先连接 Ardot MCP"结束对话。必须按
`references/spec-mode.md` 走 **Spec Mode**：先交付 `DESIGN-SPEC.md`（固定 9 节），再用
`AskUserQuestion` 给出「落画布 / 出 HTML 预览 / 改规格」三个选项。只有用户明确说"只要画布"才终止。

## 不要做

- ❌ 不要为了"看起来不像复制"而删改 `PROVENANCE.md` / README 里的同源标注——审核做的是文件 diff，抹措辞无效，
  且会把"重复"升级成"隐瞒来源"。
- ❌ 不要在 `agents/*.md` 的 frontmatter 加 `tools` 字段（平台统一分配权限）。
- ❌ 不要把维护脚本、本机绝对路径（`D:/...`、`/Users/...`）、`.git`、`.workbuddy` 带进包。
- ❌ 不要在主流程里静默失败；依赖缺失要么降级交付，要么明确告知。

## 校验

```bash
python <expert-manager>/scripts/validate_expert.py <专家目录>
```

脚本会强制要求专家位于 `~/.workbuddy/plugins/marketplaces/my-experts/plugins/` 下；
就地校验需临时去掉这段位置检查。通过标准：`✅ Expert package is valid!`
