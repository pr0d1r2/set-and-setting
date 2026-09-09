#!/usr/bin/env bash
# Assemble a materialization's `lefthook.yml`, then apply the migration overlay
# when the caller supplied one.
#
# Extracted from `mk-materialization.nix`'s `runCommand` text so that the nix
# file carries NO shell: the repo's own `nix-no-embedded-shell` check refuses
# shell inside `''` blocks, and it had been refusing `flake/apps/default.nix`
# first — which is what kept this one out of sight.
#
# The conditional that used to live in Nix (`if hasMigrations && … then`) is a
# shell test here, over the variables the derivation already exports:
#   FRAGMENTS_DIR · FRAGMENTS · MIGRATION_SKIPS · MIGRATION_HAS_OVERLAY
#   ASSEMBLE_SCRIPT · MIGRATION_OVERLAY_DIR · MIGRATION_OVERLAY_SCRIPT
#
# Same behaviour, one less dialect: an overlay runs when there IS one, exactly
# as before.

set -euo pipefail

bash "$ASSEMBLE_SCRIPT"

if [ -n "${MIGRATION_HAS_OVERLAY:-}" ] &&
  [ -n "${MIGRATION_OVERLAY_DIR:-}" ] &&
  [ -n "${MIGRATION_OVERLAY_SCRIPT:-}" ]; then
  bash "$MIGRATION_OVERLAY_SCRIPT"
fi
