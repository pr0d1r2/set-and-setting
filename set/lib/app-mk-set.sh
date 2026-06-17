#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-mk-set.sh -- runnable installer for mkSet (C9 zero-dependency path).
# Materializes skills into ./.claude/skills/set/ at the CWD at run time
# (V28). Selection: core (generic+git) always; domains opt-in (V27).
# Env in: SKILLS_DIR, CONCEPTS_DIR, MK_SET_SCRIPT, EMIT_SCRIPT,
#   SYNC_SCRIPT, ALL_CATEGORIES, CORE_CATEGORIES, GLOBS_MAP
set -euo pipefail

read -ra all_cats <<<"$ALL_CATEGORIES"
read -ra core_cats <<<"$CORE_CATEGORIES"

mode="default"
dry_run=0
selected=()

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
            echo ""
            echo "Core categories (always included): ${core_cats[*]}"
            echo "All categories: ${all_cats[*]}"
            echo ""
            echo "Examples:"
            echo "  mkSet                      # core only (generic git)"
            echo "  mkSet nix security         # core + nix + security"
            echo "  mkSet --all                # all categories"
            echo "  mkSet --all-except nixos   # all except nixos"
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

final_cats=()

if [ "$mode" = "all" ]; then
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

if [ "$mode" = "default" ] && [ ${#selected[@]} -eq 0 ]; then
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
    echo "Would install categories: ${final_cats[*]}"
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
cp -r "$out/.claude" "./" 2>/dev/null || true

echo "Installed categories: ${final_cats[*]}"
