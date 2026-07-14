#!/usr/bin/env bash
# Sync the emitted set into a target dir (default: cwd). Clean-replaces
# the set namespace (V26) then copies the agent artifact tree the package
# carries. Discovers the agent dir from the build output (V21/V23
# agent-agnostic): looks for .*/rules/set/ in the derivation.
set -euo pipefail

target="${1:-.}"
src="$(dirname "$(dirname "$(readlink -f "$0")")")"
mkdir -p "$target"

set_parent=""
for d in "$src"/.*; do
    base="${d##*/}"
    [ "$base" = "." ] || [ "$base" = ".." ] && continue
    [ -d "$d/rules/set" ] || continue
    set_parent="$base"
    break
done

if [ -n "$set_parent" ]; then
    # Save old manifest for rename propagation (T24/C7) before the
    # clean-replace destroys it.
    old_manifest=""
    manifest_path="$target/$set_parent/rules/set/.mkset.json"
    if [ -f "$manifest_path" ]; then
        old_manifest="$(mktemp)"
        cp "$manifest_path" "$old_manifest"
    fi

    # Prior sync copied from /nix/store (read-only); restore the write bit
    # so the clean-replace rm can delete the tree (V26).
    [ -e "$target/$set_parent/rules/set" ] &&
        chmod -R u+w "$target/$set_parent/rules/set"
    rm -rf "$target/$set_parent/rules/set"
    mkdir -p "$target/$set_parent/rules"
    cp -r "$src/$set_parent/rules/set" "$target/$set_parent/rules/"
    # cp -r preserves the store's read-only perms; make writable so the
    # next sync's rm can clean-replace it.
    chmod -R u+w "$target/$set_parent/rules/set"
    # always-on @-manifest (sibling of the set dir), if present
    rm -f "$target/$set_parent/rules/set.md"
    [ -f "$src/$set_parent/rules/set.md" ] &&
        cp "$src/$set_parent/rules/set.md" "$target/$set_parent/rules/set.md"

    # Portable SKILL.md channel (V20/T44): discover and sync set-* skill
    # dirs from the derivation. The skill dir varies by agent profile;
    # discover it from the build output.
    skill_src=""
    while IFS= read -r skillmd; do
        catdir="$(dirname "$skillmd")"
        skill_src="$(dirname "$catdir")"
        break
    done < <(find "$src" -name 'SKILL.md' -path '*/set-*/SKILL.md' 2>/dev/null | sort | head -1)

    if [ -n "$skill_src" ]; then
        skill_rel="${skill_src#"$src"}"
        skill_rel="${skill_rel#/}"
        [ -z "$skill_rel" ] && skill_rel="."
        skill_dest="$target/$skill_rel"

        # Clean-replace set-* skill dirs (V26-analogous)
        if [ -d "$skill_dest" ]; then
            for d in "$skill_dest"/set-*; do
                [ -d "$d" ] || continue
                chmod -R u+w "$d" 2>/dev/null || true
                rm -rf "$d"
            done
        fi

        mkdir -p "$skill_dest"
        for d in "$skill_src"/set-*; do
            [ -d "$d" ] || continue
            cp -r "$d" "$skill_dest/"
            chmod -R u+w "$skill_dest/${d##*/}"
        done
    fi

    # Always-on AGENTS.md compilation (T44/V29): compile set.md into an
    # inline AGENTS.md so non-Claude agents (opencode, cursor, etc.)
    # auto-discover it at the repo root.
    compiler="$src/bin/agents-md-compile"
    manifest_file="$target/$set_parent/rules/set.md"
    if [ -f "$compiler" ] && [ -f "$manifest_file" ]; then
        INPUT="$manifest_file" \
            BASE="$(dirname "$manifest_file")" \
            SELF="$compiler" \
            bash "$compiler" >"$target/AGENTS.md"
    fi

    # Rename propagation (T24/C7): detect stale references after sync.
    renames_file="$target/$set_parent/rules/set/.mkset-renames"
    propagate_script="$src/bin/rename-propagate"
    if [ -f "$renames_file" ] && [ -f "$propagate_script" ]; then
        RENAMES_MAP="$(cat "$renames_file")" \
        OLD_MANIFEST="${old_manifest:-/dev/null}" \
        TARGET_DIR="$target" \
        AGENT_DIR="$set_parent/rules/set" \
        RENAMES_OUT=/dev/null \
            bash "$propagate_script" || true
    fi
    [ -n "$old_manifest" ] && rm -f "$old_manifest"
fi
echo "synced set -> $target"
