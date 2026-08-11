# Framework (#97, part of #93): wrap a PINNED lefthook-* wrapper derivation
# into a hermetic flake `check`. Runs the wrapper in --check mode over the
# repo's matching files, resolving the lint logic via a pinned flake input
# (the wrapper is built from `nix-lefthook-<tool>-src`), NOT a runtime
# `remotes:` git_url. This is the strangler-fig seam: each tier replaces one
# `remotes:` entry with `checks.<name> = mkLefthookCheck { ... }`; because the
# wrapper closure is fully pinned, the check is offline-runnable on a warm
# cache and `nix flake check` runs it hermetically.
#
# Repeat mechanically per tier:
#   checks.<tool> = import ./lib/mk-lefthook-check.nix {
#     inherit pkgs;
#     wrapper  = <the lefthook-<tool> writeShellApplication>;
#     src      = ./.;                # repo root (filtered to `suffices`)
#     name     = "<tool>";
#     suffices = [ ".<ext>" ... ];   # file types the wrapper lints
#   };
#
# Args:
#   pkgs      -- nixpkgs instance for the target system.
#   wrapper   -- a writeShellApplication whose main program lints files passed
#                as args and exits non-zero on a violation (the pinned
#                lefthook-<tool> wrapper). Its main program is resolved via
#                `lib.getExe` (writeShellApplication sets meta.mainProgram).
#   src       -- source tree to lint (usually the repo root, `./.`).
#   name      -- check/derivation name (e.g. "nixfmt").
#   suffices  -- file extensions to select from `src` (e.g. [ ".nix" ]). Pass
#                `null` (the default) for whole-tree tools that lint EVERY file
#                regardless of extension (trailing-whitespace, missing-final-
#                newline, editorconfig-checker) -- the untouched `src` is used,
#                mirroring their glob-less lefthook `remotes:` entry.
#   checkFlag -- flag passed before the file list to put the wrapper in check
#                (non-mutating) mode. Defaults to "--check" (shfmt/nixfmt).
#                Pass "" for wrappers that only ever check and take no such flag
#                (trailing-whitespace, missing-final-newline, editorconfig-
#                checker) -- their sole mode is already read-only.
{
  pkgs,
  wrapper,
  src,
  name,
  suffices ? null,
  pathPrefix ? null,
  checkFlag ? "--check",
}:
let
  inherit (pkgs) lib;
  # Filter the tree to only the linted file types -- keeps the derivation
  # input minimal and cache-stable (unrelated edits don't rebuild the check).
  # A `null` suffices means "lint every file" (glob-less whole-tree tools).
  files =
    let
      selected = if suffices == null then src else lib.sources.sourceFilesBySuffices src suffices;
    in
    if pathPrefix == null then selected else lib.sources.sourceByRegex selected "^${pathPrefix}/.*";
in
pkgs.runCommand "${name}-check"
  {
    nativeBuildInputs = [ pkgs.findutils ];
  }
  ''
    cd ${files}
    mapfile -t matches < <(find . -type f | sort)
    if [ ''${#matches[@]} -eq 0 ]; then
      echo "${name}: no matching files, nothing to check"
      touch $out
      exit 0
    fi
    ${lib.getExe wrapper} ${checkFlag} "''${matches[@]}"
    echo "${name}: PASS (''${#matches[@]} files)"
    touch $out
  ''
