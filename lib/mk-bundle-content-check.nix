# V12 bundle own-content enforcement (T65). A bundle composes atomics via
# `@` references; its own content is limited to a single heading + a purpose
# statement + the refs. This check consumes the T63 matcher (lib/ref-match.sh)
# to detect bundles, then flags any structural markdown (fenced code, lists,
# tables, blockquotes, extra headings) as content that belongs in a composed
# file. Ships standalone -- independent of the T64 ref-resolution check.
# Shell logic in ./bundle-content-check.sh (nix/modularity: no embedded shell
# here). Args: pkgs, setRoot (the set/ source tree).
{
  pkgs,
  setRoot,
}:

pkgs.runCommand "set-bundle-content-check"
  {
    nativeBuildInputs = [ pkgs.findutils ];
    SET_ROOT = setRoot;
    REF_MATCH = ./ref-match.sh;
  }
  ''
    bash ${./bundle-content-check.sh}
    touch $out
  ''
