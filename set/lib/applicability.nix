# applicability.nix -- builds the meta-applicability check (V34/I.applicability).
# The filter engine is the sibling applicability.sh; this wires the meta
# `signals` into a fixture check (nix/modularity: no embedded shell beyond
# the runner). The real run happens in the consumer repo via the app
# `--auto` path, against `git ls-files`.
{ lib }:

{ pkgs }:

pkgs.runCommand "meta-applicability-check"
  {
    SIGNALS = (import ../meta.nix { inherit lib; }).signals;
    FILTER = ./applicability.sh;
  }
  ''
    bash ${./applicability-check.sh}
    touch $out
  ''
