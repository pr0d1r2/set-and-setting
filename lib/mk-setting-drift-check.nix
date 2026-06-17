# Compares synced materialized configs against the built setting. Seed
# files are consumer-owned after scaffolding so they are not checked
# here. Drift logic lives in ./drift-check.sh (nix/modularity).
{
  pkgs,
  settingSet,
  projectRoot,
}:

pkgs.runCommand "setting-drift-check"
  {
    nativeBuildInputs = [ pkgs.diffutils ];
    EXPECTED = settingSet;
    ACTUAL = "${projectRoot}";
    REL_PATHS = ".markdownlint.yml .yamllint.yml";
    SYNC_HINT = "run: sync-setting";
  }
  ''
    bash ${./drift-check.sh}
    touch $out
  ''
