{ pkgs, canonDir }:

pkgs.symlinkJoin {
  name = "canon-docs";
  paths = [
    (pkgs.writeTextDir "README.md" (builtins.readFile "${canonDir}/README.md.in"))
    (pkgs.writeTextDir "LICENSE" (builtins.readFile "${canonDir}/LICENSE.in"))
  ];
}
