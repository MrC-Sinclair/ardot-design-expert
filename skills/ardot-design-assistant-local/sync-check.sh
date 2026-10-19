#!/usr/bin/env bash
# sync-check.sh — 检测本专家包与 WorkBuddy 内置设计技能族的漂移
#
# 用法：在本脚本所在目录执行  bash sync-check.sh
# 覆盖上游路径：
#   ARDOT_UPSTREAM=/path/to/ardot/<ver>/skills bash sync-check.sh
#   MIORA_CACHE=/path/to/plugins/cache/workbuddy-builtin bash sync-check.sh
#
# 输出三类：
#   SAFE-TO-OVERWRITE  上游有更新、本包未改动 → 可安全覆盖
#   FORK-MANUAL-MERGE  本包改过               → 必须人工看 diff
#   LOCAL-ONLY         本包独有，上游没有     → 忽略
#
# 上游结构（5.8.x 起，与 5.7 及更早不同）：
#   <cache>/ardot/<ver>/skills/{ardot-design-core,ardot-ui-design,ardot-slides,
#                               ardot-poster,ardot-design-to-code,livestream-poster,design-router}
#   <cache>/skill-miora-creative-core/<ver>/   （brand / image / video 各自独立一个）
#   旧安装目录 resources/plugins/workbuddy-builtin/skills/ 已不再承载 ardot 族。

set -uo pipefail
cd "$(dirname "$0")"

CACHE="${MIORA_CACHE:-$HOME/.workbuddy/plugins/cache/workbuddy-builtin}"

# 取某个插件目录下最新的版本目录（按版本号排序）
latest() {
  ls -d "$1"/*/ 2>/dev/null | sort -V | tail -1 | sed 's:/*$::'
}

# ---- 上游根目录解析 -------------------------------------------------------
if [ -z "${ARDOT_UPSTREAM:-}" ]; then
  ARDOT_UPSTREAM="$(latest "$CACHE/ardot")"
  [ -n "${ARDOT_UPSTREAM:-}" ] && ARDOT_UPSTREAM="$ARDOT_UPSTREAM/skills"
fi
# 兜底：旧安装目录 / macOS 应用包
if [ ! -d "${ARDOT_UPSTREAM:-/nonexistent}" ]; then
  for cand in \
    "$HOME/.workbuddy/resources/workbuddy-builtin/skills" \
    "/Applications/WorkBuddy.app/Contents/Resources/app.asar.unpacked/resources/plugins/workbuddy-builtin/skills" \
    "/d/codeSoftware/WorkBuddy/resources/app.asar.unpacked/resources/plugins/workbuddy-builtin/skills"
  do
    if [ -d "$cand/ardot-design-core" ]; then ARDOT_UPSTREAM="$cand"; break; fi
  done
fi

M_CORE="$(latest "$CACHE/skill-miora-creative-core")"
M_BRAND="$(latest "$CACHE/skill-miora-brand-design")"
M_IMAGE="$(latest "$CACHE/skill-miora-image-generation")"
M_VIDEO="$(latest "$CACHE/skill-miora-video-generation")"

if [ ! -d "${ARDOT_UPSTREAM:-/nonexistent}" ]; then
  echo "❌ 上游 ardot 技能族路径不存在：${ARDOT_UPSTREAM:-<未解析>}"
  echo "   自动探测失败。用环境变量指定："
  echo "     ARDOT_UPSTREAM=/path/to/ardot/<ver>/skills bash sync-check.sh"
  echo "   本脚本只用于维护本 fork（可选）；普通使用者无需运行。"
  exit 1
fi
UPSTREAM="$ARDOT_UPSTREAM"

# ---- 本包文件 → 上游来源 --------------------------------------------------
MAP=(
  "references/ardot-schema.md|ardot-design-core/references/ardot-schema.md|VERBATIM"
  "references/effects-guide.md|ardot-design-core/rules/effects-guide.md|VERBATIM"
  "references/apply-variables-tool-usage.md|ardot-design-core/tool-usage/apply-variables.md|VERBATIM"
  "references/guidelines-code.md|ardot-design-to-code/references/guidelines-code.md|VERBATIM"
  "references/guidelines-tailwind.md|ardot-design-to-code/references/guidelines-tailwind.md|VERBATIM"
  "references/guidelines-mobile-app.md|ardot-ui-design/references/guidelines-mobile-app.md|VERBATIM"
  "references/guidelines-table.md|ardot-ui-design/references/guidelines-table.md|VERBATIM"
  "references/guidelines-web-app.md|ardot-ui-design/references/guidelines-web-app.md|VERBATIM"
  "references/guidelines-slides.md|ardot-slides/references/guidelines-slides.md|VERBATIM"
  "references/guidelines-poster.md|ardot-poster/references/guidelines-poster.md|VERBATIM-LOCALIZED"
  "references/extract-style-guide-from-web.md|ardot-design-to-code/workflows/extract-style-guide-from-web.md|VERBATIM"
  "references/design-rules.md|ardot-design-core/rules/design-rules.md|FORK"
  "references/style-guide.md|ardot-design-core/rules/style-guide.md|FORK"
  "references/shared-styles.md|ardot-design-core/func-rule/shared-styles/SKILL.md|FORK"
  "references/component-instance.md|ardot-design-core/func-rule/component-instance/SKILL.md|FORK"
  "references/design-variables.md|ardot-design-core/func-rule/design-variables/SKILL.md|FORK"
  "references/ardot-workflow.md|ardot-design-core/workflows/ardot-workflow.md|FORK"
  "references/batch-edit-tool-usage.md|ardot-design-core/tool-usage/batch-edit.md|FORK"
  "references/slides-workflow.md|ardot-slides/workflows/slides-workflow.md|FORK"
  "references/design-to-code-workflow.md|ardot-design-to-code/workflows/design-to-code-workflow.md|FORK"
  "references/guidelines-landing-page.md|ardot-ui-design/references/guidelines-landing-page.md|FORK"
)

# Miora（各自独立插件）→ 本包 references/miora/
MIORA_PAIRS=(
  "references/miora/creative-core.md|$M_CORE/SKILL.md"
  "references/miora/input-contract.md|$M_CORE/references/input-contract.md"
  "references/miora/output-contract.md|$M_CORE/references/output-contract.md"
  "references/miora/quality-gates.md|$M_CORE/references/quality-gates.md"
  "references/miora/canvas-delivery.md|$M_CORE/references/canvas-delivery.md"
  "references/miora/brand/SKILL.md|$M_BRAND/SKILL.md"
  "references/miora/brand/brand-logo.md|$M_BRAND/references/brand-logo.md"
  "references/miora/brand/brand-mascot.md|$M_BRAND/references/brand-mascot.md"
  "references/miora/brand/brand-full-package.md|$M_BRAND/references/brand-full-package.md"
  "references/miora/brand/ip-materials.md|$M_BRAND/references/ip-materials.md"
  "references/miora/image/SKILL.md|$M_IMAGE/SKILL.md"
  "references/miora/image/ecommerce-detail.md|$M_IMAGE/references/ecommerce-detail.md"
  "references/miora/image/series-consistency.md|$M_IMAGE/references/series-consistency.md"
  "references/miora/video/SKILL.md|$M_VIDEO/SKILL.md"
  "references/miora/video/short-video.md|$M_VIDEO/references/short-video.md"
  "references/livestream-poster/SKILL.md|$UPSTREAM/livestream-poster/SKILL.md"
  "references/livestream-poster/adaptive-sizing.md|$UPSTREAM/livestream-poster/references/adaptive-sizing.md"
  "references/livestream-poster/dsl-md-format.md|$UPSTREAM/livestream-poster/references/dsl-md-format.md"
  "references/livestream-poster/fallback-prompt-rules.md|$UPSTREAM/livestream-poster/references/fallback-prompt-rules.md"
  "references/livestream-poster/person-size-control.md|$UPSTREAM/livestream-poster/references/person-size-control.md"
  "references/livestream-poster/prompt-examples.md|$UPSTREAM/livestream-poster/references/prompt-examples.md"
  "references/livestream-poster/render-and-compose.md|$UPSTREAM/livestream-poster/references/render-and-compose.md"
  "references/livestream-poster/style-guide-semantics.md|$UPSTREAM/livestream-poster/references/style-guide-semantics.md"
  "references/livestream-poster/workflows/style-matching.md|$UPSTREAM/livestream-poster/workflows/style-matching.md"
  "references/livestream-poster/workflows/style-reference.md|$UPSTREAM/livestream-poster/workflows/style-reference.md"
  "references/livestream-poster/workflows/style-selection.md|$UPSTREAM/livestream-poster/workflows/style-selection.md"
)

strip() { sed 's/\r$//' "$1"; }
nlines() { diff <(strip "$1") <(strip "$2") 2>/dev/null | grep -c '^[<>]'; }

safe=0; fork=0; miss=0

echo "═══════════════════════════════════════════════════════════"
echo " Expert package ↔ built-in design skills drift check"
echo " ardot : $UPSTREAM"
echo " miora : ${M_CORE:-<未解析>}"
echo "═══════════════════════════════════════════════════════════"
echo

echo "── 上游技能族清单（结构变了就要改本脚本映射） ────────────"
for d in ardot-design-core ardot-ui-design ardot-slides ardot-poster ardot-design-to-code livestream-poster design-router; do
  [ -f "$UPSTREAM/$d/SKILL.md" ] && printf "  ▸ %-24s SKILL.md %s bytes\n" "$d" "$(wc -c < "$UPSTREAM/$d/SKILL.md")"
done
echo

echo "── FORK files（本包已改，需人工判断） ──────────────────────"
for entry in "${MAP[@]}"; do
  IFS='|' read -r local up kind <<< "$entry"
  [ "$kind" = "VERBATIM" ] && continue
  if [ ! -f "$local" ] || [ ! -f "$UPSTREAM/$up" ]; then
    printf "  ⚠ %-46s 缺文件(本地:%s 上游:%s)\n" "$local" "$([ -f "$local" ] && echo Y || echo N)" "$([ -f "$UPSTREAM/$up" ] && echo Y || echo N)"
    miss=$((miss+1)); continue
  fi
  d=$(nlines "$local" "$UPSTREAM/$up")
  if [ "$d" -gt 0 ]; then
    printf "  ● %-46s %4s 行差异  ← 人工合并\n" "$local" "$d"
    fork=$((fork+1))
  else
    printf "  ○ %-46s   0 行（与上游一致）\n" "$local"
  fi
done

echo
echo "── VERBATIM files（上游变了才能覆盖） ──────────────────────"
for entry in "${MAP[@]}"; do
  IFS='|' read -r local up kind <<< "$entry"
  [ "$kind" = "VERBATIM" ] || continue
  if [ ! -f "$local" ] || [ ! -f "$UPSTREAM/$up" ]; then
    printf "  ⚠ %-46s 缺文件\n" "$local"; miss=$((miss+1)); continue
  fi
  d=$(nlines "$local" "$UPSTREAM/$up")
  if [ "$d" -eq 0 ]; then
    printf "  ✓ %-46s   0 行\n" "$local"
  else
    printf "  ↑ %-46s %4s 行差异  ← 上游有更新，本包未改\n" "$local" "$d"
    safe=$((safe+1))
  fi
done

echo
echo "── Miora + 直播海报 files（已本地化，覆盖后须重做改造） ───"
for entry in "${MIORA_PAIRS[@]}"; do
  IFS='|' read -r local up <<< "$entry"
  if [ ! -f "$local" ] || [ ! -f "${up:- /nonexistent}" ]; then
    printf "  ⚠ %-46s 缺文件(上游:%s)\n" "$local" "$up"
    miss=$((miss+1)); continue
  fi
  d=$(nlines "$local" "$up")
  if [ "$d" -eq 0 ]; then
    printf "  ✓ %-46s   0 行\n" "$local"
  else
    printf "  ● %-46s %4s 行差异  ← 多为本地化路径改写，属正常\n" "$local" "$d"
  fi
done

echo
echo "── LOCAL-ONLY files（上游没有，勿删） ─────────────────────"
for f in references/design-review-workflow.md references/code-review-workflow.md \
         references/slides-agent-teams-workflow.md references/style-guide-tags.md; do
  [ -f "$f" ] && printf "  ★ %-46s\n" "$f" || printf "  ✗ %-46s 缺失！\n" "$f"
done

echo
echo "═══════════════════════════════════════════════════════════"
printf " 上游有更新可覆盖: %s   需人工合并: %s   异常: %s\n" "$safe" "$fork" "$miss"
echo "═══════════════════════════════════════════════════════════"

if [ "$safe" -gt 0 ] || [ "$fork" -gt 0 ]; then
  cat <<'EOF'

下一步（详见 PROVENANCE.md「同步流程」）：
  1. 合并方向永远是「上游 → 本包」，反向不成立。
  2. VERBATIM 更新可直接覆盖；FORK 必须先看 diff。
  3. 若覆盖了 guidelines-poster.md、references/miora/** 或 references/livestream-poster/**，
     务必重做本地化改造（路径改写 + creative-core.md 的环境前置检查）。
  4. 回归自检：
       grep -rn 'screenShotDir' references/
       grep -rn 'scan_all_unique_properties\|substitute_all_matching_properties' references/
       grep -rn 'Skill(miora\|ardot-design-core/' references/
       grep -rn 'G(.*"ai"' references/          # 5.8.x 起 G() 只有 placeholder
EOF
fi
