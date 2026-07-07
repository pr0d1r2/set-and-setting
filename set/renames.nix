# renames.nix -- historical skill file rename map (T24/C7). Single source
# of truth for upstream renames; consumed by sync-set and app-mk-set to
# detect stale references in consumer repos. Paths relative to set/skills/.
{ lib }:

let
  entries = [
    # Add entries when skill files are renamed upstream.
    # { old = "nix/flake.md"; new = "nix/nix-flake.md"; }
  ];

  serialized = lib.concatStringsSep "\n" (map (r: "${r.old}|${r.new}") entries);
in
{
  inherit entries serialized;
}
