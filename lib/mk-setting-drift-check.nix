# Compares synced materialized configs against the built setting. Seed
# files are consumer-owned after scaffolding so they are not checked
# here. Drift logic lives in ./drift-check.sh (nix/modularity).
# When devShells is provided, also enforces the stacked-shell invariant
# (T60): shells named default/agentic only, agentic >= default, no
# CI skip-lefthook.
{
  pkgs,
  settingSet,
  projectRoot,
  devShells ? null,
}:

let
  devShellsOk =
    if devShells == null then
      true
    else
      assert
        builtins.attrNames devShells == [
          "agentic"
          "default"
        ]
        || builtins.throw "devShells: expected exactly 'default' and 'agentic', got: ${builtins.concatStringsSep " " (builtins.attrNames devShells)}";
      assert
        builtins.all (
          p: builtins.elem p devShells.agentic.nativeBuildInputs
        ) devShells.default.nativeBuildInputs
        || builtins.throw "agentic.packages must be a superset of default.packages";
      true;
in
pkgs.runCommand "setting-drift-check"
  {
    nativeBuildInputs = [
      pkgs.diffutils
      pkgs.gnugrep
    ];
    EXPECTED = settingSet;
    ACTUAL = "${projectRoot}";
    REL_PATHS = ".markdownlint.yml .yamllint.yml";
    SYNC_HINT = "run: sync-setting";
    CHECK_CI_SKIP_LEFTHOOK = if devShells != null then "1" else "";
    inherit devShellsOk;
  }
  ''
    bash ${./drift-check.sh}
    bash ${./devshells-drift-check.sh}
    touch $out
  ''
