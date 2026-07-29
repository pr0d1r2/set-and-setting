#!/usr/bin/env bash
set -euo pipefail

# flake-manifest-check.sh -- assert flake.nix is a thin manifest (#200)
#
# A manifest flake.nix delegates its outputs body to an import or function
# call -- optionally after a `let` block that binds helpers before delegating.
# A monolith instead resolves the outputs body to an INLINE ATTRSET of outputs,
# either directly or as the body of a `let ... in { ... }`. This check rejects
# the monolith shapes; delegation passes with or without a leading `let`.
#
# Pass: outputs = inputs: import ./flake inputs;
# Pass: outputs = { ... }: set-and-setting.lib.mkConsumerFlake { ... };
# Pass: outputs = inputs: let lib = ...; in lib.mkConsumerFlake { ... };
# Fail: outputs = { ... }: let ... in { checks = ...; };
# Fail: outputs = { ... }: { checks = ...; packages = ...; };
#
# Takes file paths as arguments; only examines files named flake.nix.
# Exit 0 if all examined files pass (or none are flake.nix), exit 1 on fail.

rc=0

for file in "$@"; do
  if [ "$(basename "$file")" != "flake.nix" ]; then
    continue
  fi

  if [ ! -f "$file" ]; then
    continue
  fi

  stripped="$(sed 's/#.*$//' "$file" | tr '\n' ' ' | sed 's/  */ /g')"

  # inline attrset: outputs = <args> : { ...  -- output logic inlined (monolith)
  if grep -qE 'outputs[[:space:]]*=[[:space:]]*(\{[^}]*\}|[a-zA-Z_][a-zA-Z0-9_-]*)[[:space:]]*:[[:space:]]*\{' <<<"$stripped"; then
    echo "FAIL: $file: outputs body is an inline attrset (monolith)"
    echo "  flake.nix should delegate: outputs = inputs: import ./flake inputs;"
    rc=1
    continue
  fi

  # let-body: outputs = <args> : let ...  -- only a monolith when the let
  # resolves to an inline attrset (in { ... }). A let that ultimately
  # delegates (in <import>/<call>) is a thin manifest and passes.
  if grep -qE 'outputs[[:space:]]*=[[:space:]]*(\{[^}]*\}|[a-zA-Z_][a-zA-Z0-9_-]*)[[:space:]]*:[[:space:]]*let[[:space:]]' <<<"$stripped"; then
    if grep -qE '[^[:alnum:]_]in[[:space:]]*\{' <<<"$stripped"; then
      echo "FAIL: $file: outputs body is a let-block resolving to an inline attrset (monolith)"
      echo "  flake.nix should delegate: outputs = inputs: import ./flake inputs;"
      rc=1
      continue
    fi
  fi

  echo "PASS: $file"
done

exit "$rc"
