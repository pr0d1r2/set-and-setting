# Resolves every real @-reference in the set/ tree to an existing source
# path (T64/V12/V29). Consumes the T63 matcher (lib/ref-match.sh) so only
# genuine refs are checked, then fails with exit 1 on any truly-missing
# target. Shell logic in ./ref-resolve-check.sh (nix/modularity: no embedded
# shell here). Args: pkgs, setRoot (the set/ source tree).
{
  pkgs,
  setRoot,
}:

pkgs.runCommand "set-ref-resolution-check"
  {
    nativeBuildInputs = [ pkgs.findutils ];
    SET_ROOT = setRoot;
    REF_MATCH = ./ref-match.sh;
  }
  ''
    bash ${./ref-resolve-check.sh}
    touch $out
  ''
