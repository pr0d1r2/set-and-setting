# checksFor (#93): fragment-driven check selection -- the CI-gate counterpart
# to materializationFor. Given a consumer's declared fragments, returns ONLY
# the pinned checks relevant to those fragments. A consumer declares fragments
# once and gets both local convenience (materializationFor -> lefthook.yml +
# packages) and CI gate (checksFor -> flake checks).
#
# Usage:
#   checks = forAllSystems (pkgs:
#     (set-and-setting.lib.checksFor { inherit pkgs; src = ./.; fragments = ["base" "nix"]; })
#     // { dep-graph = ...; default = ...; }
#   );
#
# Only tools with pinned-check equivalents (mk*Check helpers) are included.
# Hooks that need git context (commit-msg-lint, narrow-language), test runners
# (bats), or tools that ARE `nix flake check` (nix-flake-check) are excluded --
# those remain lefthook-local-only.
#
# Check names and fragment membership are defined in check-fragment-map.nix
# (the single source of truth). Adding a new pinned check = add it there +
# add the mk*Check arg + wire it in checksForFragment below.
{
  pkgs,
  src,
  fragments,
  mkNixfmtCheck,
  mkShfmtCheck,
  mkTrailingWhitespaceCheck,
  mkMissingFinalNewlineCheck,
  mkEditorconfigCheckerCheck,
  mkShellcheckCheck,
  mkNoShellFunctionsCheck,
  mkAsciiOnlyCheck,
  mkTyposCheck,
  mkStatixCheck,
  mkDeadnixCheck,
  mkNixNoEmbeddedShellCheck,
  mkGitleaksCheck,
  mkGitConflictMarkersCheck,
  mkGitNoLocalPathsCheck,
  mkExecutePermissionsCheck,
  mkFileSizeCheckCheck,
}:

let
  cfm = import ./check-fragment-map.nix;

  invalidFragments = builtins.filter (f: !(builtins.elem f cfm.validFragments)) fragments;

  checksForFragment = {
    base = {
      gitleaks = mkGitleaksCheck { inherit pkgs src; };
      git-conflict-markers = mkGitConflictMarkersCheck { inherit pkgs src; };
      git-no-local-paths = mkGitNoLocalPathsCheck { inherit pkgs src; };
      execute-permissions = mkExecutePermissionsCheck { inherit pkgs src; };
      file-size-check = mkFileSizeCheckCheck { inherit pkgs src; };
      trailing-whitespace = mkTrailingWhitespaceCheck { inherit pkgs src; };
      missing-final-newline = mkMissingFinalNewlineCheck { inherit pkgs src; };
      editorconfig-checker = mkEditorconfigCheckerCheck { inherit pkgs src; };
      typos = mkTyposCheck { inherit pkgs src; };
    };
    nix = {
      nixfmt = mkNixfmtCheck { inherit pkgs src; };
      statix = mkStatixCheck { inherit pkgs src; };
      deadnix = mkDeadnixCheck { inherit pkgs src; };
      nix-no-embedded-shell = mkNixNoEmbeddedShellCheck { inherit pkgs src; };
    };
    shell = {
      shellcheck = mkShellcheckCheck { inherit pkgs src; };
      shfmt = mkShfmtCheck { inherit pkgs src; };
      no-shell-functions = mkNoShellFunctionsCheck { inherit pkgs src; };
    };
    ascii = {
      ascii-only = mkAsciiOnlyCheck { inherit pkgs src; };
    };
    markdown = { };
    yaml = { };
    set = { };
  };

  merged = builtins.foldl' (acc: f: acc // checksForFragment.${f}) { } fragments;
in
assert
  invalidFragments == [ ]
  || builtins.throw "checksFor: unknown fragments: ${builtins.concatStringsSep ", " invalidFragments}. Valid: ${builtins.concatStringsSep ", " cfm.validFragments}";
merged
