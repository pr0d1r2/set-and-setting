#!/usr/bin/env bash
# Write one source file as a rule (V17/V18/V19/V25/V32). Resolves the
# effective channel for this file: a per-file override (from
# meta.channelOverrides) wins over the category default. Core channel ->
# path-less (no frontmatter -> always-on). Domain channel -> conditional
# frontmatter (COND_FIELD + globs). Body copied verbatim. No functions
# (sh/modularity).
# Env in:
#   SRC         source file
#   REL         relpath under set/skills (override-match key)
#   DEST        destination file
#   CAT_CHANNEL category default channel (core|domain)
#   CAT_GLOBS   space-separated category globs
#   COND_FIELD  frontmatter field name (e.g. "paths")
#   OVERRIDES   "path<TAB>channel<TAB>g1,g2" lines
set -euo pipefail

channel="$CAT_CHANNEL"
globs="$CAT_GLOBS"

while IFS=$'\t' read -r opath ochannel oglobs; do
    [ "$opath" = "$REL" ] || continue
    [ -n "$ochannel" ] && channel="$ochannel"
    [ -n "$oglobs" ] && globs="${oglobs//,/ }"
    break
done <<<"${OVERRIDES:-}"

mkdir -p "$(dirname "$DEST")"

if [ "$channel" = "core" ]; then
    cat "$SRC" >"$DEST"
else
    read -ra garr <<<"$globs"
    {
        printf '%s\n%s:\n' "---" "$COND_FIELD"
        for g in "${garr[@]}"; do printf '  - "%s"\n' "$g"; done
        printf '%s\n\n' "---"
    } >"$DEST"
    cat "$SRC" >>"$DEST"
fi
