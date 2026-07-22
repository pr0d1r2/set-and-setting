{ pkgs, canonDir }:

pkgs.writeTextDir "SPEC.md" (builtins.readFile "${canonDir}/SPEC.md.in")
