{ pkgs, canonDir }:

pkgs.symlinkJoin {
  name = "canon-governance";
  paths = map (name: pkgs.writeTextDir name (builtins.readFile "${canonDir}/${name}.in")) [
    "CHANGELOG.md"
    "CONTRIBUTING.md"
    "ATTRIBUTION.md"
    "HARDENING.md"
  ];
}
