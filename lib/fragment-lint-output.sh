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
    function clean(value,   quote, close_at, i, character) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      quote = substr(value, 1, 1)
      if (quote == "\"" || quote == "\047") {
        close_at = 0
        for (i = 2; i <= length(value); i++) {
          character = substr(value, i, 1)
          if (character == quote) {
            if (quote == "\047" && substr(value, i + 1, 1) == quote) {
              i++
              continue
            }
            close_at = i - 1
            break
          }
        }
        if (close_at > 0) return substr(value, 2, close_at - 1)
      }
      sub(/[[:space:]]+#.*/, "", value)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      return value
    }
    function inspect(value, line) {
      value = clean(value)
      if (value != "" && value != "failure") report(line, sprintf("%c%s%c", 39, value, 39))
    }
    function scan(value, line,   i, character, escaped, result) {
      close_bracket = 0
      for (i = 1; i <= length(value); i++) {
        character = substr(value, i, 1)
        if (comment) break
        if (quote != "") {
          result = result character
          if (quote == "\"" && character == "\\" && !escaped) {
            escaped = 1
          } else if (character == quote && !escaped) {
            quote = ""
            escaped = 0
          } else {
            escaped = 0
          }
        } else if (character == "\"" || character == "\047") {
          quote = character
          result = result character
        } else if (character == ",") {
          inspect(result, line)
          result = ""
        } else if (character == "#") {
          comment = 1
        } else if (character == "]") {
          inspect(result, line)
          result = ""
          close_bracket = 1
          break
        } else {
          result = result character
        }
      }
      comment = 0
      inspect(result, line)
      return result
    }
    /^[[:space:]]*output:[[:space:]]*\[/ {
      list = $0
      sub(/^[^[]*\[/, "", list)
      quote = ""
      list = scan(list, NR)
      flow_output = !close_bracket
      next
    }
    flow_output {
      list = scan($0, NR)
      if (close_bracket) flow_output = 0
      next
    }
    /^[[:space:]]*output:[[:space:]]*$/ {
      output_indent = match($0, /[^[:space:]]/) - 1
      in_output = 1
      next
    }
    in_output {
      if ($0 ~ /^[[:space:]]*(#.*)?$/) next
      indent = match($0, /[^[:space:]]/) - 1
      if ($0 ~ /^[[:space:]]*-[[:space:]]*/ && indent >= output_indent) {
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
