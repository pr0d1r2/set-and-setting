{ nixpkgs }:
let
  supported = [
    "aarch64-darwin"
    "x86_64-darwin"
    "x86_64-linux"
    "aarch64-linux"
  ];
in
{
  inherit supported;
  forAll = f: nixpkgs.lib.genAttrs supported (system: f nixpkgs.legacyPackages.${system});
}
