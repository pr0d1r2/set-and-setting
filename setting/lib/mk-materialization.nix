{
  pkgs,
  fragments,
  wrappersForFragment,
  fragmentsDir,
  assembleScript,
  corePackages,
  migrations ? [ ],
  migrationOverlayDir ? null,
  migrationOverlayScript ? null,
}:

let
  cfm = import ../../lib/check-fragment-map.nix;
  inherit (cfm) validFragments;

  invalidFragments = builtins.filter (f: !(builtins.elem f validFragments)) fragments;

  fragmentPackages = builtins.concatMap (f: wrappersForFragment.${f}) fragments;

  hasMigrations = migrations != [ ];

  migrationSkips = builtins.concatStringsSep " " (builtins.concatMap (m: m.skip) migrations);

  assembledLefthook =
    pkgs.runCommand "materialization-lefthook"
      {
        FRAGMENTS_DIR = fragmentsDir;
        FRAGMENTS = builtins.concatStringsSep " " fragments;
        MIGRATION_SKIPS = if hasMigrations then migrationSkips else "";
        MIGRATION_HAS_OVERLAY = if hasMigrations then "1" else "";
        ASSEMBLE_SCRIPT = assembleScript;
        MIGRATION_OVERLAY_DIR = if migrationOverlayDir != null then migrationOverlayDir else "";
        MIGRATION_OVERLAY_SCRIPT = if migrationOverlayScript != null then migrationOverlayScript else "";
      }
      ''
        bash ${./materialize-lefthook.sh}
      '';
in
assert
  invalidFragments == [ ]
  || builtins.throw "materializationFor: unknown fragments: ${builtins.concatStringsSep ", " invalidFragments}. Valid: ${builtins.concatStringsSep ", " validFragments}";
{
  files = assembledLefthook;
  packages = corePackages ++ fragmentPackages;
}
