#!/usr/bin/env bash

set -euo pipefail

status=0
for path in "$@"; do
  [ -f "$path" ] || continue
  awk -v path="$path" '
    function report(line, script) {
      printf "%s:%d: invoke shell scripts with an interpreter prefix: bash %s\n", path, line, script
      found = 1
    }
    /^[[:space:]]*#!/ { next }
    /^[[:space:]]*#/ { next }
    {
      text = $0
      quoted = 0
      quote = ""
      visible = ""
      for (i = 1; i <= length(text); i++) {
        ch = substr(text, i, 1)
        if (quoted) {
          if (ch == quote && (i == 1 || substr(text, i - 1, 1) != "\\")) quoted = 0
          visible = visible " "
        } else if (ch == "\"" || ch == "\047") {
          quoted = 1
          quote = ch
          visible = visible " "
        } else visible = visible ch
      }
      rest = visible
      while (match(rest, "(^|[[:space:](;|&])(([.]?[.]?/|[[:alnum:]_.-]+/)[^[:space:];|&()\\\047\"]+[.]sh)([[:space:]]|$)")) {
        prefix = substr(rest, 1, RSTART - 1)
        sub(/^.*[[:space:](;|&]/, "", prefix)
        script = substr(rest, RSTART, RLENGTH)
        sub(/^[[:space:](;|&]*/, "", script)
        sub(/[[:space:]]*$/, "", script)
        if (prefix !~ /^(bash|sh|dash|zsh|ksh|fish|env)([[:space:]]+|$)/) report(NR, script)
        rest = substr(rest, RSTART + RLENGTH)
      }
    }
    END { exit found ? 1 : 0 }
  ' "$path" || status=1
done
exit "$status"
