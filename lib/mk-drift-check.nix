# Compares a synced set against the built derivation. Drift logic lives
# in ./drift-check.sh (nix/modularity: no embedded shell here).
{
  pkgs,
  skillSet,
  projectRoot,
  setPath ? "agent/set",
}:

pkgs.runCommand "skill-drift-check"
  {
    nativeBuildInputs = [ pkgs.diffutils ];
    EXPECTED = skillSet;
    ACTUAL = "${projectRoot}/${setPath}";
    REL_PATHS = "skills concepts set.md";
    SYNC_HINT = "run: nix run .#sync-set";
  }
  ''
    bash ${./drift-check.sh}
    touch $out
  ''
