# mk-seed.nix (#95): emits the committed minimum for a leaf consumer repo.
# A leaf commits only: thin flake.nix + flake.lock + CI stub + .gitignore +
# fragments declaration. Everything else is materialized (gitignored).
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
    (pkgs.writeTextDir ".github/workflows/auto-update.yml" (readFile "${scaffoldDir}/auto-update.yml"))
  ];
}
