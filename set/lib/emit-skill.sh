#!/usr/bin/env bash
# Emit one category's rule files across the always-on / conditional
# channels (V17/V18/V19/V32). The channel is decided by the meta map
# (V30): a category in CORE emits path-less rules (no frontmatter ->
# always-on); any other category emits conditional rules carrying the
# agent's conditional-load field + globs. A per-file override (from
# meta.channelOverrides) can flip an individual file's channel/globs
# (e.g. generic/rtk.md -> domain). Body copied verbatim (V25). No
# SKILL.md here -- that is a separate channel. Extracted per
# nix/modularity + sh/modularity: no embedded shell, no functions.
# Env in:
#   CAT        category name
#   DEST_DIR   output base directory (e.g. $out/.claude/rules/set)
#   GLOBS      space-separated category conditional-load globs
#   COND_FIELD frontmatter field name for the globs (e.g. "paths")
#   SKILLS_DIR root of the agnostic set/skills tree
#   EXCLUDE    space-separated filenames to omit (e.g. "rtk.md")
#   CORE       space-separated core (always-on) category names (V18)
#   OVERRIDES  per-file channel overrides: "path|channel|g1,g2"
#              lines (relpaths under SKILLS_DIR, "|" delimiter)
#   EMIT_RULE  path to emit-rule.sh (per-file rule writer)
#   KEEP       optional newline-separated relpaths to emit (smart
#              materialization, V34); unset/empty = emit all (no filter)
set -euo pipefail

# KEEP filter: when non-empty, only the listed relpaths are emitted.
keep_active=0
if [ -n "${KEEP:-}" ]; then
  keep_active=1
fi

catdir="$SKILLS_DIR/$CAT"
core="$SKILLS_DIR/$CAT.md"

read -ra excludes <<<"${EXCLUDE:-}"
findargs=()
for e in "${excludes[@]:-}"; do
  [ -n "$e" ] || continue
  findargs+=(! -name "$e")
  [ "$e" = "$CAT.md" ] && core=""
done

# Category channel: core (always-on) if listed in CORE, else domain.
cat_channel="domain"
for c in ${CORE:-}; do
  [ "$c" = "$CAT" ] && cat_channel="core" && break
done

mkdir -p "$DEST_DIR"

# Core file (loose <cat>.md), emitted as "<cat>.md" at the set root.
if [ -n "$core" ] && [ -f "$core" ]; then
  if [ "$keep_active" -eq 0 ] || printf '%s\n' "$KEEP" | grep -qxF "$CAT.md"; then
    SRC="$core" REL="$CAT.md" DEST="$DEST_DIR/$CAT.md" \
      CAT_CHANNEL="$cat_channel" CAT_GLOBS="$GLOBS" \
      COND_FIELD="$COND_FIELD" OVERRIDES="${OVERRIDES:-}" REF_MAP="${REF_MAP:-}" REF_MATCH="${REF_MATCH:-}" SET_ROOT="${SET_ROOT:-}" REWRITE_REFS="${REWRITE_REFS:-}" bash "$EMIT_RULE"
  fi
fi

if [ -d "$catdir" ]; then
  find "$catdir" -name '*.md' ${findargs[@]+"${findargs[@]}"} | sort | while read -r f; do
    sub="${f#"$catdir"/}"
    rel="$CAT/$sub"
    if [ "$keep_active" -eq 1 ] && ! printf '%s\n' "$KEEP" | grep -qxF "$rel"; then
      continue
    fi
    SRC="$f" REL="$rel" DEST="$DEST_DIR/$CAT/$sub" \
      CAT_CHANNEL="$cat_channel" CAT_GLOBS="$GLOBS" \
      COND_FIELD="$COND_FIELD" OVERRIDES="${OVERRIDES:-}" REF_MAP="${REF_MAP:-}" REF_MATCH="${REF_MATCH:-}" SET_ROOT="${SET_ROOT:-}" REWRITE_REFS="${REWRITE_REFS:-}" bash "$EMIT_RULE"
  done
fi
