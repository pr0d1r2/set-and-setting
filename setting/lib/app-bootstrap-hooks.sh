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

if [ ! -d .git ]; then
  echo "bootstrap-hooks: not a git repository" >&2
  exit 1
fi

lefthook install
