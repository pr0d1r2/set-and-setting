{ pkgs, canonDir }:

pkgs.writeTextDir ".envrc" (builtins.readFile "${canonDir}/envrc.in")
