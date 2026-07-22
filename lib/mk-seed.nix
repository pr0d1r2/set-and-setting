# mk-seed.nix (#95): the pinned infrastructure unit for a leaf consumer.
# The reusable guardrails.yml workflow is the single CI source.
{
  pkgs,
  scaffoldDir,
}:

let
  inherit (builtins) readFile;
in
pkgs.symlinkJoin {
  name = "leaf-seed";
  paths = [
    (pkgs.writeTextDir "flake.nix" (readFile "${scaffoldDir}/leaf-flake.txt"))
    (pkgs.writeTextDir ".gitignore" (readFile "${scaffoldDir}/leaf-gitignore.txt"))
    (pkgs.writeTextDir ".github/workflows/ci.yml" (readFile "${scaffoldDir}/leaf-ci.yml"))
  ];
}
