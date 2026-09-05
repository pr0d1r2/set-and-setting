#!/usr/bin/env bash
# Run the pinned flake check with build logs, bounded by FLAKE_CHECK_TIMEOUT.
#
# Extracted from .github/workflows/guardrails.yml, where it appeared once per
# platform job: shell inside `run:` is invisible to shellcheck, shfmt and every
# other guardrail this repository runs on *.sh, and two copies of the same four
# lines drift independently.
set -euo pipefail

nix flake check \
  --print-build-logs \
  --timeout "${FLAKE_CHECK_TIMEOUT:-600}"
