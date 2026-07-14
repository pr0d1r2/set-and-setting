#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-bootstrap.sh -- combined installer: mkSet core + mkSetting +
# mkSetting-init + mkScaffold (C9). Equivalent to running all four
# in sequence. Passes --agent and --dry-run through to mkSet (T39).
# Env in: MKSET_APP, MKSETTING_APP, MKSETTING_INIT_APP, MKSCAFFOLD_APP
set -euo pipefail

if [ "${1:-}" = "--help" ]; then
  echo "Usage: bootstrap [--help] [--dry-run] [--agent NAME]"
  echo ""
  echo "Combined installer: mkSet (core) + mkSetting + mkSetting-init"
  echo "+ mkScaffold. Equivalent to running all four in sequence."
  echo ""
  echo "Options:"
  echo "  --agent NAME  Target agent for mkSet (default: claude)"
  exit 0
fi

mkset_args=()
other_args=()
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)
      mkset_args+=("--dry-run")
      other_args+=("--dry-run")
      shift
      ;;
    --agent)
      shift
      if [ $# -eq 0 ]; then
        echo "error: --agent requires a name"
        exit 1
      fi
      mkset_args+=("--agent" "$1")
      shift
      ;;
    *)
      shift
      ;;
  esac
done

"$MKSET_APP" "${mkset_args[@]+"${mkset_args[@]}"}"
"$MKSETTING_APP" "${other_args[@]+"${other_args[@]}"}"
"$MKSETTING_INIT_APP" "${other_args[@]+"${other_args[@]}"}"
"$MKSCAFFOLD_APP" "${other_args[@]+"${other_args[@]}"}"
