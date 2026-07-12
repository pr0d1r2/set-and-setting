{
  pkgs,
  fragments,
  wrappersForFragment,
  fragmentsDir,
  assembleScript,
  corePackages,
}:

let
  validFragments = [
    "base"
    "nix"
    "shell"
    "ascii"
    "markdown"
    "yaml"
    "set"
  ];

  invalidFragments = builtins.filter (f: !(builtins.elem f validFragments)) fragments;

  fragmentPackages = builtins.concatMap (f: wrappersForFragment.${f}) fragments;

  assembledLefthook =
    pkgs.runCommand "materialization-lefthook"
      {
        FRAGMENTS_DIR = fragmentsDir;
        FRAGMENTS = builtins.concatStringsSep " " fragments;
      }
      ''
        bash ${assembleScript}
      '';
in
assert
  invalidFragments == [ ]
  || builtins.throw "materializationFor: unknown fragments: ${builtins.concatStringsSep ", " invalidFragments}. Valid: ${builtins.concatStringsSep ", " validFragments}";
{
  files = assembledLefthook;
  packages = corePackages ++ fragmentPackages;
}
