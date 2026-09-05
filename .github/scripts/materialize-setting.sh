#!/usr/bin/env bash
# Materialize this repository's own setting into the checkout.
#
# The darwin job has no dev shell entry before its checks, so the configs the
# gate reads are built and synced explicitly.
set -euo pipefail

setting_pkg="$(nix build .#setting --print-out-paths --no-link)"
"$setting_pkg/bin/sync-setting" .
