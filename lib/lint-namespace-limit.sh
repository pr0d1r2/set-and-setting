#!/usr/bin/env bash
set -euo pipefail

awk '
function record(path, line, name,    parts, i, namespace, quoted, part_count) {
    if (name == "") return
    # A quoted Nix attribute name is a single literal name, even when it
    # contains dots. Only unquoted names use dots as namespace separators.
    quoted = (substr(name, 1, 1) == "\"")
    gsub(/^"|"$/, "", name)
    if (quoted) {
        parts[1] = name
        part_count = 1
    } else {
        part_count = split(name, parts, ".")
    }
    namespace = "<root>"
    if (!(path SUBSEP namespace SUBSEP parts[1] in seen)) {
        counts[path SUBSEP namespace]++
        lines[path SUBSEP namespace] = line
        seen[path SUBSEP namespace SUBSEP parts[1]] = 1
    }
    for (i = 1; i < part_count; i++) {
        namespace = (namespace == "<root>" ? parts[i] : namespace "." parts[i])
        counts[path SUBSEP namespace]++
        lines[path SUBSEP namespace] = line
    }
}

FNR == 1 { in_apps = 0; after_in = 0 }

{
    if ($0 ~ /^[[:space:]]*in[[:space:]]+\{[[:space:]]*$/) in_apps = 1
    if ($0 ~ /^[[:space:]]*in[[:space:]]*$/) after_in = 1
    if (after_in && $0 ~ /^[[:space:]]*\{[[:space:]]*$/) in_apps = 1

    if (in_apps && $0 ~ /^[[:space:]]{2}("[^"]+"|[A-Za-z0-9_.-]+)[[:space:]]*=[[:space:]]*\{/) {
        name = $0
        sub(/^[[:space:]]*/, "", name)
        sub(/[[:space:]]*=.*/, "", name)
        record(FILENAME, FNR, name)
    }

    if (FILENAME ~ /(^|\/)(justfile|[^/]+\.just)$/ &&
        $0 !~ /^[[:space:]]*#/ && $0 ~ /^[^[:space:]\[][^:]*:/) {
        target = $0
        sub(/[[:space:]]*:.*/, "", target)
        sub(/[[:space:]]+\+.*/, "", target)
        split(target, words, /[[:space:]]+/)
        if (words[1] != "") record(FILENAME, FNR, words[1])
    }
}

END {
    failed = 0
    for (key in counts) {
        if (counts[key] > 10) {
            split(key, fields, SUBSEP)
            printf "%s:%s: namespace %s has %d entries; resolve the limit with a split or sub\n", fields[1], lines[key], fields[2], counts[key]
            failed = 1
        }
    }
    exit failed
}' "$@"
