# Compare the effective checks selected by a consumer with the emitted hook
# artifact.  Pinned checks come from checksFor; hook-only checks come from the
# materialized lefthook.yml.  Extra names are allowed as repo-local checks.
{
  pkgs,
  fragments,
  checks,
  consumerChecks ? { },
  materialization,
  expectedMaterialization,
}:

let
  cfm = import ./check-fragment-map.nix;
  fragmentText = builtins.concatStringsSep " " fragments;
  pinned = builtins.concatStringsSep "\n" (builtins.attrNames checks);
  claimed = builtins.concatLists (map (f: cfm.checksPerFragment.${f}) fragments);
  covered = builtins.concatLists (builtins.attrValues cfm.coveragePerFileClass);
  uncovered = builtins.filter (name: !(builtins.elem name covered)) claimed;
in
assert
  uncovered == [ ]
  || builtins.throw "coverage-drift: checks claim file classes without coverage: ${builtins.concatStringsSep ", " uncovered}";
pkgs.runCommand "coverage-drift-check"
  {
    nativeBuildInputs = [
      pkgs.gawk
      pkgs.coreutils
    ];
    EXPECTED_HOOK = "${expectedMaterialization.files}/lefthook.yml";
    ACTUAL_HOOK = "${materialization.files}/lefthook.yml";
    EXPECTED_PINNED = pinned;
    CONSUMER_CHECKS = builtins.concatStringsSep "\n" (builtins.attrNames consumerChecks);
    FRAGMENTS = fragmentText;
  }
  ''
    bash ${./coverage-drift-check.sh}
    touch "$out"
  ''
