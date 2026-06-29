# Compares a synced set against the built derivation. Drift logic lives
# in ./drift-check.sh (nix/modularity: no embedded shell here).
{
  pkgs,
  skillSet,
  projectRoot,
  setPath ? ".claude/rules/set",
}:

pkgs.runCommand "skill-drift-check"
  {
    nativeBuildInputs = [ pkgs.diffutils ];
    EXPECTED = "${skillSet}/${setPath}";
    ACTUAL = "${projectRoot}/${setPath}";
    REL_PATHS = ".";
    SYNC_HINT = "run: nix run .#sync-set";
  }
  ''
    bash ${./drift-check.sh}
    touch $out
  ''
