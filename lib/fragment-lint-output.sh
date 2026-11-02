#!/usr/bin/env bash

set -euo pipefail

status=0
for path in "$@"; do
  [ -f "$path" ] || continue
  awk -v path="$path" '
    function report(line, value) {
      printf "%s:%d: output list contains %s; only failure is allowed because other output produces noise that hides real errors\n", path, line, value
      found = 1
    }
    function clean(value) {
      sub(/[[:space:]]+#.*/, "", value)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      if ((substr(value, 1, 1) == "\"" || substr(value, 1, 1) == "\047") &&
          substr(value, length(value), 1) == substr(value, 1, 1)) {
        value = substr(value, 2, length(value) - 2)
      }
      return value
    }
    function inspect(value, line) {
      value = clean(value)
      if (value != "" && value != "failure") report(line, sprintf("%c%s%c", 39, value, 39))
    }
    /^[[:space:]]*output:[[:space:]]*\[/ {
      list = $0
      sub(/^[^[]*\[/, "", list)
      if (list !~ /\]/) {
        flow_output = 1
      } else {
        sub(/\].*$/, "", list)
      }
      count = split(list, values, ",")
      for (i = 1; i <= count; i++) inspect(values[i], NR)
      next
    }
    flow_output {
      list = $0
      if (list ~ /\]/) {
        sub(/\].*$/, "", list)
        flow_output = 0
      }
      count = split(list, values, ",")
      for (i = 1; i <= count; i++) inspect(values[i], NR)
      next
    }
    /^[[:space:]]*output:[[:space:]]*$/ {
      output_indent = match($0, /[^[:space:]]/) - 1
      in_output = 1
      next
    }
    in_output {
      indent = match($0, /[^[:space:]]/) - 1
      if ($0 ~ /^[[:space:]]*-[[:space:]]*/ && indent > output_indent) {
        value = $0
        sub(/^[[:space:]]*-[[:space:]]*/, "", value)
        inspect(value, NR)
        next
      }
      in_output = 0
    }
    END { exit found ? 1 : 0 }
  ' "$path" || status=1
done
exit "$status"
