#!/usr/bin/env bash
# Report flake output leaves that import a sibling leaf.
# A leaf is any file under flake/<dir>/; it may import its own directory,
# flake/lib.nix, and anything outside flake/. Files directly in flake/ are
# the assembler and are exempt.
set -euo pipefail

for path in "$@"; do
  awk -v path="$path" '
    BEGIN {
      if (!match(path, /(^|\/)flake\//)) exit 0
      root = substr(path, 1, RSTART + RLENGTH - 1)
      rest = substr(path, RSTART + RLENGTH)
      if (index(rest, "/") == 0) exit 0
      leaf = root substr(rest, 1, index(rest, "/") - 1) "/"
      dir = path
      sub(/[^\/]*$/, "", dir)
      absolute = (substr(path, 1, 1) == "/")
    }
    /^[[:space:]]*#/ { next }
    {
      line = $0
      while (match(line, /import[[:space:]]+\(?[[:space:]]*\.\.?\/[^[:space:];)]*/)) {
        ref = substr(line, RSTART, RLENGTH)
        line = substr(line, RSTART + RLENGTH)
        sub(/^import[[:space:]]+\(?[[:space:]]*/, "", ref)
        n = split(dir ref, parts, "/")
        top = 0
        for (i = 1; i <= n; i++) {
          if (parts[i] == "" || parts[i] == ".") continue
          if (parts[i] == ".." && top > 0 && stack[top] != "..") top--
          else stack[++top] = parts[i]
        }
        resolved = absolute ? "/" : ""
        for (i = 1; i <= top; i++) resolved = resolved stack[i] (i < top ? "/" : "")
        base = root
        if (!absolute) sub(/^\.\//, "", base)
        if (index(resolved, base) != 1) continue
        if (index(resolved, leaf) == 1 || resolved == leaf) continue
        if (resolved == base "lib.nix" || index(resolved, base "lib/") == 1) continue
        printf "%s:%d: leaf imports sibling %s; extract shared logic to flake/lib.nix or pass it from the assembler\n", path, NR, ref
        finding = 1
      }
    }
    END { if (finding) exit 1 }
  ' "$path" || status=1
done
exit "${status:-0}"
