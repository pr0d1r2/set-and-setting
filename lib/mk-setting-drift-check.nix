# Compares synced dotfiles against the built setting. Drift logic lives
# in ./drift-check.sh (nix/modularity: no embedded shell here).
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
    REL_PATHS = ".editorconfig .gitattributes .gitignore";
    SYNC_HINT = "run: nix run .#sync-setting";
  }
  ''
    bash ${./drift-check.sh}
    touch $out
  ''
