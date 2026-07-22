{
  pkgs,
  canon,
  projectRoot,
}:

pkgs.runCommand "canon-drift-check"
  {
    nativeBuildInputs = [ pkgs.diffutils ];
    EXPECTED = canon;
    ACTUAL = projectRoot;
    REL_PATHS = builtins.concatStringsSep " " [
      "flake.nix"
      ".gitignore"
      ".github/workflows/ci.yml"
    ];
  }
  ''
    bash ${./drift-check.sh}
  ''
