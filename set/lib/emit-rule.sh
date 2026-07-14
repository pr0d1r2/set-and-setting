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
#   OVERRIDES   "path|channel|g1,g2" lines ("|" delim, not tab -- tab is
#               IFS-whitespace and would collapse an empty channel field)
set -euo pipefail

channel="$CAT_CHANNEL"
globs="$CAT_GLOBS"

# Match overrides: exact wins over prefix; longest prefix wins (V30
# subtree-inherit). Mirrors meta.nix resolve's cascading behaviour.
exact_ch="" exact_gl="" pfx_ch="" pfx_gl="" pfx_len=0
while IFS='|' read -r opath ochannel oglobs; do
    [ -n "$opath" ] || continue
    if [ "$opath" = "$REL" ]; then
        exact_ch="$ochannel"
        exact_gl="$oglobs"
    elif [[ "$REL" == "$opath/"* ]] && [ ${#opath} -gt "$pfx_len" ]; then
        pfx_len=${#opath}
        pfx_ch="$ochannel"
        pfx_gl="$oglobs"
    fi
done <<<"${OVERRIDES:-}"

if [ -n "$exact_ch" ] || [ -n "$exact_gl" ]; then
    [ -n "$exact_ch" ] && channel="$exact_ch"
    [ -n "$exact_gl" ] && globs="${exact_gl//,/ }"
elif [ "$pfx_len" -gt 0 ]; then
    [ -n "$pfx_ch" ] && channel="$pfx_ch"
    [ -n "$pfx_gl" ] && globs="${pfx_gl//,/ }"
fi

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
