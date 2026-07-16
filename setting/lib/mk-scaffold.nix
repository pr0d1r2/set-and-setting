{ pkgs }:

let
  inherit (builtins) readFile;

  assembledLefthook =
    pkgs.runCommand "scaffold-lefthook"
      {
        FRAGMENTS_DIR = ../integrations/lefthook;
      }
      ''
        bash ${./assemble-lefthook.sh}
      '';

  scaffoldBundle = pkgs.symlinkJoin {
    name = "scaffold-repo";
    paths = [
      assembledLefthook
      (pkgs.writeTextDir "flake.nix" (readFile ../scaffold/component-flake.txt))
      (pkgs.writeTextDir ".github/workflows/ci.yml" (readFile ../scaffold/ci.yml))
    ];
  };
in
scaffoldBundle
