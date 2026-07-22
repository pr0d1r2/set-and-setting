#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-mk-set.sh -- runnable installer for mkSet (C9/V28).
# Writes .mkset.json manifest for smart re-run (I.manifest/T37).
# Supports --agent flag for agent seam passthrough (T39/V21/V23).
# Env in: SKILLS_DIR, CONCEPTS_DIR, PRINCIPLES_DIR, MK_SET_SCRIPT, EMIT_SCRIPT,
#   SYNC_SCRIPT, ALL_CATEGORIES, CORE_CATEGORIES, GLOBS_MAP,
#   AGENT_SEAMS (agent=dir,condField,skillDir,...;...),
#   RESOLVE_AGENT_SCRIPT, MKSET_REV (optional)
set -euo pipefail

read -ra all_cats <<<"$ALL_CATEGORIES"
read -ra core_cats <<<"$CORE_CATEGORIES"

agent_name="claude"

mode="default"
dry_run=0
selected=()
remove_cats=()

while [ $# -gt 0 ]; do
  case "$1" in
    --help)
      echo "Usage: mkSet [OPTIONS] [CATEGORIES...]"
      echo ""
      echo "Materialize set-and-setting skills into the target agent's rules directory."
      echo ""
      echo "Options:"
      echo "  --help          Show this help and exit"
      echo "  --list          List available categories and exit"
      echo "  --dry-run       Show what would be emitted without writing"
      echo "  --all           Install all categories"
      echo "  --all-except    Install all categories except those listed"
      echo "  --auto          Install only skills with repo evidence (smart)"
      echo "  --remove        Remove listed categories from the install"
      echo "  --agent NAME    Target agent (default: claude)"
      echo ""
      echo "Core categories (always included): ${core_cats[*]}"
      echo "All categories: ${all_cats[*]}"
      echo ""
      echo "Examples:"
      echo "  mkSet                          # core only (or refresh manifest)"
      echo "  mkSet nix security             # core + nix + security"
      echo "  mkSet --all                    # all categories"
      echo "  mkSet --all-except nixos       # all except nixos"
      echo "  mkSet --auto                   # only skills the repo needs"
      echo "  mkSet --remove nix             # remove nix from install"
      echo "  mkSet --agent opencode         # emit for opencode agent"
      echo "  mkSet --agent opencode --all   # all categories for opencode"
      echo "  mkSet --agent caveman-code     # emit for caveman-code agent"
      echo "  mkSet --agent cursor           # emit for Cursor agent"
      echo "  mkSet --agent codex            # emit for Codex agent"
      echo "  mkSet --agent gemini-cli       # emit for Gemini CLI agent"
      echo "  mkSet --agent copilot          # emit for GitHub Copilot agent"
      echo "  mkSet --agent amp              # emit for Amp agent"
      exit 0
      ;;
    --list)
      echo "Available categories:"
      for c in "${all_cats[@]}"; do
        is_core=""
        for cc in "${core_cats[@]}"; do
          [ "$c" = "$cc" ] && is_core=" (core)" && break
        done
        echo "  $c$is_core"
      done
      exit 0
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --all)
      mode="all"
      shift
      ;;
    --auto)
      mode="auto"
      shift
      ;;
    --all-except)
      mode="all-except"
      shift
      while [ $# -gt 0 ] && [[ "$1" != --* ]]; do
        selected+=("$1")
        shift
      done
      ;;
    --remove)
      mode="remove"
      shift
      while [ $# -gt 0 ] && [[ "$1" != --* ]]; do
        remove_cats+=("$1")
        shift
      done
      if [ ${#remove_cats[@]} -eq 0 ]; then
        echo "error: --remove requires at least one category"
        echo "Run 'mkSet --help' for usage."
        exit 1
      fi
      ;;
    --agent)
      shift
      if [ $# -eq 0 ]; then
        echo "error: --agent requires a name"
        echo "Run 'mkSet --help' for usage."
        exit 1
      fi
      agent_name="$1"
      shift
      ;;
    -*)
      echo "error: unknown option '$1'"
      echo "Run 'mkSet --help' for usage."
      exit 1
      ;;
    *)
      selected+=("$1")
      shift
      ;;
  esac
done

seam="$(AGENT_NAME="$agent_name" bash "$RESOLVE_AGENT_SCRIPT")"
IFS=',' read -r agent_dir agent_cond_field agent_skill_dir agent_disable_invocation \
  agent_alwayson_import agent_alwayson_file agent_conditional_mechanism <<<"$seam"

MANIFEST="$agent_dir/.mkset.json"

manifest_cats=()
manifest_rev=""
if [ -f "$MANIFEST" ]; then
  manifest_rev="$(grep -o '"rev":"[^"]*"' "$MANIFEST" | head -1 | sed 's/"rev":"//;s/"//')"
  raw="$(grep -o '"categories":\[[^]]*\]' "$MANIFEST" | sed 's/"categories":\[//;s/\]//;s/"//g')"
  IFS=',' read -ra manifest_cats <<<"$raw"
fi

if [ "$mode" = "remove" ]; then
  for rc in "${remove_cats[@]}"; do
    found=0
    for c in "${all_cats[@]}"; do
      [ "$rc" = "$c" ] && found=1 && break
    done
    if [ "$found" -eq 0 ]; then
      echo "error: unknown category '$rc'"
      echo "Available categories: ${all_cats[*]}"
      exit 1
    fi
    is_core=0
    for cc in "${core_cats[@]}"; do
      [ "$rc" = "$cc" ] && is_core=1 && break
    done
    if [ "$is_core" -eq 1 ]; then
      echo "error: cannot remove core category '$rc'"
      exit 1
    fi
  done
  if [ ${#manifest_cats[@]} -eq 0 ] || [ -z "${manifest_cats[0]:-}" ]; then
    echo "error: no manifest found; nothing to remove"
    exit 1
  fi
  final_cats=()
  for mc in "${manifest_cats[@]}"; do
    [ -z "$mc" ] && continue
    skip=0
    for rc in "${remove_cats[@]}"; do
      [ "$mc" = "$rc" ] && skip=1 && break
    done
    [ "$skip" -eq 0 ] && final_cats+=("$mc")
  done
elif [ "$mode" = "all" ] || [ "$mode" = "auto" ]; then
  # auto considers every category, then prunes to applicable files (V34)
  final_cats=("${all_cats[@]}")
elif [ "$mode" = "all-except" ]; then
  for ex in "${selected[@]:-}"; do
    [ -z "$ex" ] && continue
    found=0
    for c in "${all_cats[@]}"; do
      [ "$ex" = "$c" ] && found=1 && break
    done
    if [ "$found" -eq 0 ]; then
      echo "error: unknown category '$ex'"
      echo "Available categories: ${all_cats[*]}"
      exit 1
    fi
  done
  for c in "${all_cats[@]}"; do
    skip=0
    for ex in "${selected[@]:-}"; do
      [ "$c" = "$ex" ] && skip=1 && break
    done
    [ "$skip" -eq 0 ] && final_cats+=("$c")
  done
else
  if [ "$mode" = "default" ] && [ ${#selected[@]} -eq 0 ] && [ ${#manifest_cats[@]} -gt 0 ] && [ -n "${manifest_cats[0]:-}" ]; then
    final_cats=("${manifest_cats[@]}")
    current_rev="${MKSET_REV:-}"
    if [ -n "$current_rev" ] && [ -n "$manifest_rev" ] && [ "$current_rev" != "$manifest_rev" ]; then
      echo "Update detected: $manifest_rev -> $current_rev"
    fi
    echo "Refreshing from manifest: ${final_cats[*]}"
  else
    final_cats=("${core_cats[@]}")
    for s in "${selected[@]:-}"; do
      [ -z "$s" ] && continue
      found=0
      for c in "${all_cats[@]}"; do
        [ "$s" = "$c" ] && found=1 && break
      done
      if [ "$found" -eq 0 ]; then
        echo "error: unknown category '$s'"
        echo "Available categories: ${all_cats[*]}"
        exit 1
      fi
      dupe=0
      for fc in "${final_cats[@]}"; do
        [ "$s" = "$fc" ] && dupe=1 && break
      done
      [ "$dupe" -eq 0 ] && final_cats+=("$s")
    done
  fi
fi

if [ "$mode" = "default" ] && [ ${#selected[@]} -eq 0 ] && [ ${#manifest_cats[@]} -eq 0 ]; then
  selectable=()
  for c in "${all_cats[@]}"; do
    is_core=0
    for cc in "${core_cats[@]}"; do
      [ "$c" = "$cc" ] && is_core=1 && break
    done
    [ "$is_core" -eq 0 ] && selectable+=("$c")
  done
  echo "Installing core categories: ${core_cats[*]}"
  echo ""
  echo "Additional categories available: ${selectable[*]}"
  echo "Use 'mkSet <category> ...' or 'mkSet --all' to install more."
  echo ""
fi

# Smart materialization (V34): derive the applicable file set from repo
# evidence and pass it to the emitter as KEEP. Scan logic is extracted to
# app-auto-keep.sh (sh/modularity).
applicability_evidence=""
if [ "$mode" = "auto" ]; then
  applicability_evidence="$(bash "$AUTO_KEEP_SCRIPT")"
  KEEP="$(printf '%s\n' "$applicability_evidence" | cut -d'|' -f1)"
  export KEEP
fi

if [ "$dry_run" -eq 1 ]; then
  if [ "$mode" = "remove" ]; then
    echo "Would remove: ${remove_cats[*]}"
    echo "Would keep: ${final_cats[*]}"
  elif [ "$mode" = "auto" ]; then
    echo "Would install applicable skills (repo evidence):"
    printf '%s\n' "$applicability_evidence" | sed 's/^/  /'
  else
    echo "Would install categories: ${final_cats[*]}"
  fi
  echo "Agent: $agent_name"
  echo "Target: ./$agent_dir/"
  exit 0
fi

# Save old manifest for rename propagation (T24/C7) before the
# clean-replace destroys it.
old_manifest=""
if [ -f "$MANIFEST" ]; then
  old_manifest="$(mktemp)"
  cp "$MANIFEST" "$old_manifest"
fi

out="$(mktemp -d)"
trap 'rm -rf "$out" ${old_manifest:+"$old_manifest"}' EXIT

export out
export SKILLS_DIR CONCEPTS_DIR
export EMIT="$EMIT_SCRIPT"
export EMIT_RULE="$EMIT_RULE_SCRIPT"
if [ -n "${EMIT_PRINCIPLES_SCRIPT:-}" ]; then
  export PRINCIPLES_DIR="${PRINCIPLES_DIR:-$SKILLS_DIR/principles}"
  export EMIT_PRINCIPLES="$EMIT_PRINCIPLES_SCRIPT"
fi
export SYNC_SRC="$SYNC_SCRIPT"
export DIR="$agent_dir"
export COND_FIELD="$agent_cond_field"
export CATEGORIES="${final_cats[*]}"
export GLOBS_MAP
export CORE="$CORE_CATEGORIES"
export OVERRIDES="${CHANNEL_OVERRIDES:-}"
export EXCLUDE=""
export CONCEPTS="1"
# Multi-channel env vars (V17/V28): only export when the supporting
# scripts are available (the flake wrapper sets them; bats tests may not).
if [ -n "${EMIT_SKILLMD_SCRIPT:-}" ]; then
  export SKILL_DIR="${agent_skill_dir:-}"
  export SKILL_DISABLE_INVOCATION="${agent_disable_invocation:-0}"
  export EMIT_SKILLMD="$EMIT_SKILLMD_SCRIPT"
  export KEYWORDS_MAP="${KEYWORDS_MAP:-}"
fi
if [ -n "${COMPILER_SCRIPT:-}" ]; then
  export ALWAYSON_IMPORT="${agent_alwayson_import:-}"
  export ALWAYSON_FILE="${agent_alwayson_file:-}"
  export CONDITIONAL_MECHANISM="${agent_conditional_mechanism:-}"
  export COMPILER="$COMPILER_SCRIPT"
fi
# Rename propagation (T24/C7): pass the propagation script and rename
# map to mk-set.sh so the derivation ships them for sync-set.
if [ -n "${RENAME_PROPAGATE_SCRIPT:-}" ]; then
  export RENAME_PROPAGATE="$RENAME_PROPAGATE_SCRIPT"
fi
export RENAMES_MAP="${RENAMES_MAP:-}"

bash "$MK_SET_SCRIPT"

# Prior run copied from /nix/store (read-only); restore the write bit so
# rm can clean-replace the tree (V26).
[ -e "./$agent_dir" ] && chmod -R u+w "./$agent_dir"
rm -rf "./$agent_dir"

set_parent="${agent_dir%%/*}"
cp -r "$out/$set_parent" "./" 2>/dev/null || true
# cp -r preserves the store's read-only perms; make writable so the next
# run's rm can clean-replace it.
chmod -R u+w "./$agent_dir"

# Multi-channel root-level artifacts (V17/V28/V39): AGENTS.md,
# opencode.json, and portable SKILL.md dirs when the skill dir is
# outside the set parent tree (e.g. opencode skill.dir = ".").
for f in "$out/AGENTS.md" "$out/opencode.json"; do
  [ -f "$f" ] || continue
  rm -f "./${f##*/}"
  cp "$f" "./"
done
for d in "$out"/set-*/; do
  [ -d "$d" ] || continue
  d_stripped="${d%/}"
  base="${d_stripped##*/}"
  [ -e "$out/$set_parent/$base" ] && continue
  [ -e "./$base" ] && chmod -R u+w "./$base"
  rm -rf "./$base"
  cp -r "$d_stripped" "./"
  chmod -R u+w "./$base"
done

cats_json=""
for c in "${final_cats[@]}"; do
  [ -n "$cats_json" ] && cats_json="$cats_json,"
  cats_json="$cats_json\"$c\""
done
rev="${MKSET_REV:-unknown}"
mkdir -p "$agent_dir"

# Record applicability evidence per kept skill under --auto (V37 audit).
app_json=""
if [ "$mode" = "auto" ]; then
  while IFS='|' read -r rel reason; do
    [ -n "$rel" ] || continue
    [ -n "$app_json" ] && app_json="$app_json,"
    app_json="$app_json\"$rel\":\"$reason\""
  done <<<"$applicability_evidence"
fi

# Rename propagation (T24/C7): detect stale references after install.
renames_json=""
if [ -n "${RENAMES_MAP:-}" ]; then
  renames_out="$(mktemp)"
  RENAMES_MAP="$RENAMES_MAP" \
    OLD_MANIFEST="${old_manifest:-/dev/null}" \
    TARGET_DIR="." \
    AGENT_DIR="$agent_dir" \
    RENAMES_OUT="$renames_out" \
    bash "$RENAME_PROPAGATE_SCRIPT" || true
  renames_json="$(cat "$renames_out" 2>/dev/null || true)"
  rm -f "$renames_out"
fi

# Build the manifest JSON with optional fields (V37 audit).
manifest_body="\"categories\":[$cats_json],\"rev\":\"$rev\",\"agent\":\"$agent_name\""
[ -n "$app_json" ] && manifest_body="$manifest_body,\"applicability\":{$app_json}"
[ -n "$renames_json" ] && manifest_body="$manifest_body,\"renames\":{$renames_json}"
printf '{%s}\n' "$manifest_body" >"$MANIFEST"

if [ "$mode" = "remove" ]; then
  echo "Removed: ${remove_cats[*]}"
  echo "Installed categories: ${final_cats[*]}"
else
  echo "Installed categories: ${final_cats[*]}"
fi
