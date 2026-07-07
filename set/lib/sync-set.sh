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
