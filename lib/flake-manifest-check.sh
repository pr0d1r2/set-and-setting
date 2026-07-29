#!/usr/bin/env bash
set -euo pipefail

# flake-manifest-check.sh -- assert flake.nix is a thin manifest (#200)
#
# A manifest flake.nix delegates its outputs body to an import or function
# call. A monolith inlines the output logic via a let-block or direct
# attrset. This check rejects both monolith patterns.
#
# Pass: outputs = inputs: import ./flake inputs;
# Pass: outputs = { ... }: set-and-setting.lib.mkConsumerFlake { ... };
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

  # let-body: outputs = <args> : let ...
  if grep -qE 'outputs[[:space:]]*=[[:space:]]*(\{[^}]*\}|[a-zA-Z_][a-zA-Z0-9_-]*)[[:space:]]*:[[:space:]]*let[[:space:]]' <<<"$stripped"; then
    echo "FAIL: $file: outputs body contains a let-block (monolith)"
    echo "  flake.nix should delegate: outputs = inputs: import ./flake inputs;"
    rc=1
    continue
  fi

  # inline attrset: outputs = <args> : { ...
  if grep -qE 'outputs[[:space:]]*=[[:space:]]*(\{[^}]*\}|[a-zA-Z_][a-zA-Z0-9_-]*)[[:space:]]*:[[:space:]]*\{' <<<"$stripped"; then
    echo "FAIL: $file: outputs body is an inline attrset (monolith)"
    echo "  flake.nix should delegate: outputs = inputs: import ./flake inputs;"
    rc=1
    continue
  fi

  echo "PASS: $file"
done

exit "$rc"
