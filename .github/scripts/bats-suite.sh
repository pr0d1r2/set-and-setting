#!/usr/bin/env bash
# Parse then run every tracked Bats file, SEQUENTIALLY, and the TDD-order gate.
#
# Sequential is deliberate (B16/B18/B70): the wrapper enables parallel jobs, CI
# runners expose multiple cores, and the Bats files share git and test state, so
# a parallel run is flaky rather than fast.
set -euo pipefail

mapfile -d '' bats_files < <(git ls-files -z -- '*.bats')

if [ "${#bats_files[@]}" -gt 0 ]; then
  nix develop --command lefthook-bats-parse "${bats_files[@]}"
  nix develop --command bats "${bats_files[@]}"
fi

nix develop --command lefthook-tdd-order-bats
