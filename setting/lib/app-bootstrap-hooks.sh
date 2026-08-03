#!/usr/bin/env bash
# app-bootstrap-hooks.sh -- install lefthook hooks without entering a shell.
set -euo pipefail

if [ "${1:-}" = "--help" ]; then
  echo "Usage: bootstrap-hooks [--help]"
  echo ""
  echo "Install this repository's lefthook git hooks."
  exit 0
fi

if [ "$#" -gt 0 ]; then
  echo "bootstrap-hooks: unknown argument: $1" >&2
  exit 2
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "bootstrap-hooks: deferred (not a git repository)"
  exit 0
fi

lefthook install
