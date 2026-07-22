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
  }
  ''
    for rel in $REL_PATHS; do
      if [ ! -e "$EXPECTED/$rel" ]; then
        echo "UNKNOWN: pinned canonical path is absent: $rel -- $SYNC_HINT"
        exit 1
      fi
    done
    bash ${./drift-check.sh}
    touch $out
  ''
