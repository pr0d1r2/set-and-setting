#!/usr/bin/env bash
# Require architecture and development architecture evidence in README.md.
# An explicit marker such as <!-- no architecture diagram: not applicable -->
# is an accepted escape when the repository has no shape to draw.
set -euo pipefail

for path in "$@"; do
  awk -v path="$path" '
    function heading_level(line,    hashes) {
      hashes = line
      sub(/[[:space:]].*$/, "", hashes)
      return length(hashes)
    }

    BEGIN {
      architecture = 0
      development = 0
      architecture_found = 0
      development_found = 0
      architecture_level = 0
      development_level = 0
    }

    {
      if ($0 ~ /<!--[[:space:]]*no[[:space:]]+architecture[[:space:]]+diagram([[:space:]]|:)/) architecture_found = 1
      if ($0 ~ /<!--[[:space:]]*no[[:space:]]+development[[:space:]]+architecture[[:space:]]+diagram([[:space:]]|:)/) development_found = 1

      if ($0 ~ /^#{1,6}[[:space:]]+/) {
        level = heading_level($0)
        title = $0
        sub(/^#{1,6}[[:space:]]+/, "", title)
        sub(/[[:space:]]+#*[[:space:]]*$/, "", title)
        if (tolower(title) == "architecture") {
          architecture = 1
          architecture_level = level
          development = 0
        } else if (tolower(title) == "development architecture") {
          development = 1
          development_level = level
          architecture = 0
        } else {
          if (architecture == 1 && level <= architecture_level) architecture = 0
          if (development == 1 && level <= development_level) development = 0
        }
      }

      if ($0 ~ /^```[[:space:]]*(mermaid|diagram)([[:space:]]|$)/) {
        if (architecture == 1) architecture_found = 1
        if (development == 1) development_found = 1
      }
      if ($0 ~ /!\[[^]]*\]\([^)]*\)/ || $0 ~ /<[[:space:]]*img([[:space:]>])/ ) {
        if (architecture == 1) architecture_found = 1
        if (development == 1) development_found = 1
      }
    }

    END {
      finding = 0
      if (!architecture_found) {
        printf "%s:1: missing architecture diagram (add a diagram or an explicit no architecture diagram marker)\n", path
        finding = 1
      }
      if (!development_found) {
        printf "%s:1: missing development architecture diagram (add a diagram or an explicit no development architecture diagram marker)\n", path
        finding = 1
      }
      if (finding) exit 1
    }
  ' "$path"
done
