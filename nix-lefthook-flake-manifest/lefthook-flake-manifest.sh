#!/usr/bin/env bash
# Enforce that flake.nix remains a thin manifest.
set -euo pipefail

flake="${1:-flake.nix}"
strictness="${FLAKE_MANIFEST_STRICTNESS:-strict}"

if [ ! -f "$flake" ]; then
  echo "flake-manifest: no flake.nix, nothing to check"
  exit 0
fi

case "$strictness" in
  off)
    echo "flake-manifest: disabled"
    exit 0
    ;;
  let-only | strict) ;;
  *)
    echo "flake-manifest: invalid FLAKE_MANIFEST_STRICTNESS '$strictness' (expected strict, let-only, or off)" >&2
    exit 2
    ;;
esac

awk -v strictness="$strictness" '
function fail(message) {
    print "flake-manifest: " message > "/dev/stderr"
    failed = 1
}

# Remove comments and strings while retaining delimiters needed to track Nix
# attrsets. This intentionally remains a structural check, not a Nix parser.
function sanitize(line,    out, i, c, nextc) {
    out = ""
    for (i = 1; i <= length(line); i++) {
        c = substr(line, i, 1)
        nextc = substr(line, i + 1, 1)
        if (block_comment) {
            if (c == "*" && nextc == "/") {
                block_comment = 0
                i++
            }
            continue
        }
        if (string) {
            if (escaped) {
                escaped = 0
            } else if (c == "\\") {
                escaped = 1
            } else if (c == "\"") {
                string = 0
                out = out "\"\""
            }
            continue
        }
        if (c == "/" && nextc == "*") {
            block_comment = 1
            i++
        } else if (c == "#") {
            break
        } else if (c == "\"") {
            string = 1
        } else {
            out = out c
        }
    }
    return out
}

function brace_delta(text,    i, c, delta) {
    delta = 0
    for (i = 1; i <= length(text); i++) {
        c = substr(text, i, 1)
        if (c == "{") delta++
        else if (c == "}") delta--
    }
    return delta
}

{
    clean = sanitize($0)
    sub(/^[[:space:]]+/, "", clean)

    if (!outer_seen && clean ~ /^let([[:space:]]|$)/)
        fail("top-level let block is not allowed")

    if (!outer_seen && clean ~ /{/) outer_seen = 1

  if (outer_seen && depth == 1 && match(clean, /^([A-Za-z][A-Za-z0-9_-]*)[[:space:]]*=/, key_match)) {
        key = key_match[1]
        seen[key]++
        if (key != "description" && key != "nixConfig" && key != "inputs" && key != "outputs")
      fail("top-level attribute " key " is not allowed")
  }

  if (outer_seen && depth == 1 && clean ~ /^[A-Za-z][A-Za-z0-9_.-]*[[:space:]]*=/ &&
      clean !~ /^([A-Za-z][A-Za-z0-9_-]*)[[:space:]]*=/)
    fail("top-level attributes must use literal manifest attrsets")

  if (outer_seen && depth == 1 && clean ~ /^outputs[[:space:]]*=/) collecting_outputs = 1
  if (collecting_outputs) outputs = outputs " " clean
  if (outer_seen && depth == 1 && clean ~ /^inputs[[:space:]]*=/) collecting_inputs = 1
  if (collecting_inputs) inputs = inputs " " clean

  depth += brace_delta(clean)
  if (collecting_outputs && depth == 0) collecting_outputs = 0
  if (collecting_inputs && depth == 1) collecting_inputs = 0
}

END {
    if (!outer_seen) fail("flake.nix does not contain a top-level attrset")
  if (!seen["outputs"]) fail("outputs delegation is required")
  if (seen["outputs"] > 1) fail("outputs must be declared exactly once")
  if (seen["inputs"]) {
    inputs_body = inputs
    sub(/^.*inputs[[:space:]]*=[[:space:]]*/, "", inputs_body)
    if (inputs_body !~ /^\{/) fail("inputs must be a literal attrset")
  }

    if (outputs ~ /=[[:space:]]*[^:;]+:[[:space:]]*let([[:space:]]|$)/ ||
        outputs ~ /:[[:space:]]*let([[:space:]]|$)/) {
        fail("outputs body must not be a let expression")
    }

    if (strictness == "strict") {
        body = outputs
        sub(/^.*outputs[[:space:]]*=[[:space:]]*/, "", body)

        # Consume either `inputs:` or an attrset argument `{ ... }:`. The
        # remaining first token is the delegated expression body.
        if (body ~ /^[A-Za-z_][A-Za-z0-9_-]*[[:space:]]*:/) {
            sub(/^[A-Za-z_][A-Za-z0-9_-]*[[:space:]]*:[[:space:]]*/, "", body)
        } else if (substr(body, 1, 1) == "{") {
            level = 0
            colon = 0
            for (i = 1; i <= length(body); i++) {
                c = substr(body, i, 1)
                if (c == "{") level++
                else if (c == "}") level--
                else if (c == ":" && level == 0) {
                    colon = i
                    break
                }
            }
            if (!colon) fail("outputs must be a function delegation")
            else body = substr(body, colon + 1)
            sub(/^[[:space:]]+/, "", body)
        } else {
            fail("outputs must be a function delegation")
        }

        if (body ~ /^\{/) fail("outputs body must delegate, not construct an attrset")
        if (body ~ /^let([[:space:]]|$)/) fail("outputs body must not be a let expression")
        if (body ~ /^$/) fail("outputs delegation body is empty")
    }

    exit failed
}
' "$flake"

echo "flake-manifest: PASS ($flake)"
