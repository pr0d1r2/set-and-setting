# Validates that a consumer's flake.lock dependency graph uses only
# github: URLs (C6/T9). Fails with exit 1 if any input uses git+file:,
# path:, or other non-github types. Shell logic in ./dep-graph-check.sh
# (nix/modularity: no embedded shell here).
{
  pkgs,
  projectRoot,
}:

pkgs.runCommand "dep-graph-check"
  {
    FLAKE_LOCK = "${projectRoot}/flake.lock";
  }
  ''
    bash ${./dep-graph-check.sh}
    touch $out
  ''
