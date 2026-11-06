#!/usr/bin/env bash

set -euo pipefail

status=0
for path in "$@"; do
  [ -f "$path" ] || continue
  awk -v path="$path" '
    function finish(   covered) {
      if (command == "" || !has_run) return
      covered = has_timeout || run_text ~ /(^|[[:space:];|&()])timeout([[:space:]]|$)/
      if (!covered && !default_timeout) {
        printf "%s:%d: command %s has no bounding timeout (add a timeout key or wrap its invocation with timeout)\n", path, command_line, command
        found = 1
      }
    }
    /^[[:space:]]*default_timeout:[[:space:]]*/ { default_timeout = 1 }
    /^[[:space:]]{2}commands:[[:space:]]*$/ {
      commands_indent = match($0, /[^[:space:]]/) - 1
      in_commands = 1
      next
    }
    in_commands {
      indent = match($0, /[^[:space:]]/) - 1
      if (indent <= commands_indent && $0 !~ /^[[:space:]]*$/) {
        finish()
        command = ""
        in_commands = 0
      } else if (indent == commands_indent + 2 && $0 ~ /^[[:space:]]*[A-Za-z0-9_-]+:[[:space:]]*($|#)/) {
        finish()
        command = $0
        sub(/^[[:space:]]*/, "", command)
        sub(/:.*/, "", command)
        command_line = NR
        has_run = 0
        has_timeout = 0
        run_text = ""
      } else if (command != "" && indent == commands_indent + 4 && $0 ~ /^[[:space:]]+timeout:[[:space:]]*/) {
        timeout_value = $0
        sub(/^[^:]*:[[:space:]]*/, "", timeout_value)
        sub(/[[:space:]]+#.*/, "", timeout_value)
        if (timeout_value ~ /[^[:space:]]/ && timeout_value != "\"\"" && timeout_value != "''") has_timeout = 1
      } else if (command != "" && $0 ~ /^[[:space:]]+run:[[:space:]]*/) {
        has_run = 1
        run_text = $0
        sub(/^[^:]*:[[:space:]]*/, "", run_text)
        sub(/[[:space:]]+#.*/, "", run_text)
      } else if (command != "" && has_run && indent > commands_indent + 2) {
        run_text = run_text " " $0
      }
    }
    END {
      finish()
      exit found && !default_timeout ? 1 : 0
    }
  ' "$path" || status=1
done
exit "$status"
