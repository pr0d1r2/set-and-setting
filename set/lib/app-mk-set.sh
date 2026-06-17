#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-mk-set.sh -- runnable installer for mkSet (C9/V28).
# Writes .mkset.json manifest for smart re-run (I.manifest/T37).
# Env in: SKILLS_DIR, CONCEPTS_DIR, MK_SET_SCRIPT, EMIT_SCRIPT,
#   SYNC_SCRIPT, ALL_CATEGORIES, CORE_CATEGORIES, GLOBS_MAP,
#   MKSET_REV (optional)
set -euo pipefail

read -ra all_cats <<<"$ALL_CATEGORIES"
read -ra core_cats <<<"$CORE_CATEGORIES"

MANIFEST=".claude/skills/set/.mkset.json"

mode="default"
dry_run=0
selected=()
remove_cats=()

while [ $# -gt 0 ]; do
    case "$1" in
        --help)
            echo "Usage: mkSet [OPTIONS] [CATEGORIES...]"
            echo ""
            echo "Materialize set-and-setting skills into ./.claude/skills/set/"
            echo ""
            echo "Options:"
            echo "  --help          Show this help and exit"
            echo "  --list          List available categories and exit"
            echo "  --dry-run       Show what would be emitted without writing"
            echo "  --all           Install all categories"
            echo "  --all-except    Install all categories except those listed"
            echo "  --remove        Remove listed categories from the install"
            echo ""
            echo "Core categories (always included): ${core_cats[*]}"
            echo "All categories: ${all_cats[*]}"
            echo ""
            echo "Examples:"
            echo "  mkSet                      # core only (or refresh manifest)"
            echo "  mkSet nix security         # core + nix + security"
            echo "  mkSet --all                # all categories"
            echo "  mkSet --all-except nixos   # all except nixos"
            echo "  mkSet --remove nix         # remove nix from install"
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
elif [ "$mode" = "all" ]; then
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

if [ "$dry_run" -eq 1 ]; then
    if [ "$mode" = "remove" ]; then
        echo "Would remove: ${remove_cats[*]}"
        echo "Would keep: ${final_cats[*]}"
    else
        echo "Would install categories: ${final_cats[*]}"
    fi
    echo "Target: ./.claude/skills/set/"
    exit 0
fi

out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT

export out
export SKILLS_DIR CONCEPTS_DIR
export EMIT="$EMIT_SCRIPT"
export SYNC_SRC="$SYNC_SCRIPT"
export SKILL_PATH=".claude/skills/set"
export RULE_PATH=".claude/rules"
export COND_FIELD="paths"
export CATEGORIES="${final_cats[*]}"
export GLOBS_MAP
export EXCLUDE=""
export CONCEPTS="1"

bash "$MK_SET_SCRIPT"

rm -rf "./.claude/skills/set"

# Clean up stale always-on rule files for dropped categories
if [ ${#manifest_cats[@]} -gt 0 ] && [ -n "${manifest_cats[0]:-}" ]; then
    for mc in "${manifest_cats[@]}"; do
        [ -z "$mc" ] && continue
        keep=0
        for fc in "${final_cats[@]}"; do
            [ "$mc" = "$fc" ] && keep=1 && break
        done
        [ "$keep" -eq 0 ] && rm -f "./.claude/rules/$mc.md"
    done
fi

cp -r "$out/.claude" "./" 2>/dev/null || true

cats_json=""
for c in "${final_cats[@]}"; do
    [ -n "$cats_json" ] && cats_json="$cats_json,"
    cats_json="$cats_json\"$c\""
done
rev="${MKSET_REV:-unknown}"
agent="claude"
mkdir -p ".claude/skills/set"
printf '{"categories":[%s],"rev":"%s","agent":"%s"}\n' "$cats_json" "$rev" "$agent" >"$MANIFEST"

if [ "$mode" = "remove" ]; then
    echo "Removed: ${remove_cats[*]}"
    echo "Installed categories: ${final_cats[*]}"
else
    echo "Installed categories: ${final_cats[*]}"
fi
