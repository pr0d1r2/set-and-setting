#!/usr/bin/env bash
# Build the delivery paths and run the flake check, for the cache-push jobs.
#
# The build is what populates the binary cache; the check keeps a pushed closure
# from being one the gate would reject.
set -euo pipefail

nix build .#set .#setting --no-link
nix flake check --print-build-logs
