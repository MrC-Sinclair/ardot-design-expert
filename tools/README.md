# tools/ — 维护脚本（不随包分发）

这个目录只服务于**维护者**，不属于交付物。打包时不要把 `tools/` 打进去。

## sync-check.sh

检测本专家包里的 `references/` 与 WorkBuddy 内置设计技能族的漂移。

**什么时候跑**：升级 WorkBuddy 之后，或者怀疑内置技能更新了、本包规则过期时。

**怎么跑**（在仓库根目录）：

```bash
bash tools/sync-check.sh
```

上游不在默认位置时，用环境变量指定：

```bash
ARDOT_UPSTREAM=/path/to/ardot/<ver>/skills bash tools/sync-check.sh
MIORA_CACHE=/path/to/plugins/cache/workbuddy-builtin bash tools/sync-check.sh
```

**输出三类**：

| 标记 | 含义 | 该怎么做 |
|---|---|---|
| `SAFE-TO-OVERWRITE` | 上游更新了，本包没改过 | 可直接用上游版本覆盖 |
| `FORK-MANUAL-MERGE` | 本包改过（本地分叉） | 必须人工看 diff 再合并 |
| `LOCAL-ONLY` | 本包独有，上游没有 | 忽略 |

**前置条件**：本机装过 WorkBuddy，且 `~/.workbuddy/plugins/cache/workbuddy-builtin/` 下有 `ardot` 与 `skill-miora-*` 插件。找不到上游时脚本会直接退出并提示用环境变量指定，不会写任何文件。

**只读**：脚本不修改任何文件，只打印差异。
