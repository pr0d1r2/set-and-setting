{
  pkgs,
  canon,
  projectRoot,
}:

let
  cfm = import ./check-fragment-map.nix;
in
pkgs.runCommand "canon-drift-check"
  {
    nativeBuildInputs = [ pkgs.diffutils ];
    EXPECTED = canon;
    ACTUAL = projectRoot;
    REL_PATHS = builtins.concatStringsSep " " cfm.pinnedCanonPaths;
    SYNC_HINT = "restore pinned files with mkCanon or migrate";
    DRIFT_CHECK_SCRIPT = ./drift-check.sh;
  }
  ''
    bash ${./canon-drift-check.sh}
  ''
