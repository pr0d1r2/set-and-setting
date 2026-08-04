# Active parallel-change check migrations (#281).
# When non-empty, the materializer emits a side-by-side migration overlay
# (lefthook-migration.yml) alongside the main lefthook.yml, implementing the
# expand/migrate/contract pattern:
#
#   EXPAND   -- old check stays in lefthook.yml but disabled (skip:true);
#              new check lands in lefthook-migration.yml, advisory (non-blocking).
#   MIGRATE  -- fleet validates new check over real PRs. Each consumer diff is
#              the overlay only (small, reviewable, reversible).
#   CONTRACT -- new check promoted to lefthook.yml, overlay dropped.
#
# Each entry:
#   name:   migration identifier (informational, for diagnostics)
#   skip:   list of command names to mark skip:true in main config
#   overlay: fragment name whose migration YAML provides the new commands
#
# Empty list = no active migration = identical to pre-#281 behavior.
# Adding a migration here causes ALL consumers to get the overlay on their
# next nix flake update + sync-setting.
[ ]
