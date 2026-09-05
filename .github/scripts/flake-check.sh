#!/usr/bin/env bash
# Run the pinned flake check with build logs, bounded by FLAKE_CHECK_TIMEOUT.
#
# Extracted from .github/workflows/guardrails.yml, where it appeared once per
# platform job: shell inside `run:` is invisible to shellcheck, shfmt and every
# other guardrail this repository runs on *.sh, and two copies of the same four
# lines drift independently.
set -euo pipefail

# --keep-going: report EVERY failing check in one run. Without it the first
# failure ends the run, so N defects cost N round trips -- and a round trip is
# the tending loop's unit of cost, not a second.
nix flake check \
  --keep-going \
  --print-build-logs \
  --timeout "${FLAKE_CHECK_TIMEOUT:-600}"
