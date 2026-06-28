# meta.nix -- sidecar channel map (V30/I.meta). Single source for channel
# assignment, keyed by source path/subtree. Keeps set/ markdown agnostic
# (C2/V17): channel metadata lives here as data, never as in-source
# frontmatter.
#
# `resolve <path>` returns { channel, paths, keywords, always } for a
# source file path relative to set/skills/ (e.g. "nix/flake.md",
# "generic/skill/interchange.md"). Three levels merge, most specific
# wins:
#   category fallback  <-  subtree entry  <-  exact-file override
#
# Fields:
#   channel  -- "core" (always-on, V18) | "domain" (conditional, V19)
#   paths    -- conditional-load globs (-> rule globs + SKILL.md paths)
#   keywords -- terms for SKILL.md description / when_to_use
#   always   -- bool; force always-on regardless of channel
#
# This map feeds every channel: paths drive both the Claude rule globs
# and the portable SKILL.md `paths`; keywords drive the SKILL.md
# description / when_to_use (V30).
{ lib }:

let
  cats = import ./lib/categories.nix;

  # Per-path / per-subtree overrides. Keys are paths relative to
  # set/skills/: a category ("language"), a topic ("language/narrow.md"),
  # or any prefix. A more specific key overrides a less specific one, and
  # both override the category fallback. Each value is a partial set;
  # unspecified fields fall back.
  overrides = {
    # subtree: every language/* file inherits these keywords unless it
    # overrides them per-file.
    "language" = {
      keywords = [
        "prose"
        "writing"
        "documentation"
        "style"
      ];
    };

    # per-file override: narrow.md is specifically about dictionaries, so
    # it replaces the inherited subtree keywords.
    "language/narrow.md" = {
      keywords = [
        "narrow-language"
        "dictionary"
        "spelling"
        "vocabulary"
      ];
    };

    # rtk is a host-specific proxy, not a universal rule -- keep it a
    # narrow domain even though it sits under the always-on generic core.
    "generic/rtk.md" = {
      channel = "domain";
      always = false;
      keywords = [
        "rtk"
        "token"
        "proxy"
      ];
    };
  };

  resolve =
    path:
    let
      parts = lib.splitString "/" path;
      category = lib.head parts;
      isCore = lib.elem category cats.core;

      fallback = {
        channel = if isCore then "core" else "domain";
        paths = cats.globs.${category} or [ "**/*" ];
        keywords = [ category ];
        always = isCore;
      };

      # Cumulative path prefixes, least specific first:
      #   "nix/infinity/gap.md" -> [ "nix" "nix/infinity" "nix/infinity/gap.md" ]
      prefixes = lib.genList (i: lib.concatStringsSep "/" (lib.sublist 0 (i + 1) parts)) (
        lib.length parts
      );

      matched = lib.filter (p: overrides ? ${p}) prefixes;
    in
    lib.foldl' (acc: p: acc // overrides.${p}) fallback matched;

  # Serialized channel-affecting overrides for the bash emitter, one per
  # line: "path<TAB>channel<TAB>g1,g2". Only entries that actually set
  # `channel` or `paths` (keyword-only overrides do not affect the rule
  # channel). Keeps meta.nix the single source of channel data (V30) while
  # the emitter stays plain bash that works for both the nix and the
  # run-time app paths (C9/V28). Empty channel/globs fields fall back to
  # the file's category in the emitter.
  channelOverrides = lib.concatStringsSep "\n" (
    lib.filter (s: s != "") (
      lib.mapAttrsToList (
        p: o:
        lib.optionalString (o ? channel || o ? paths)
          "${p}\t${o.channel or ""}\t${lib.concatStringsSep "," (o.paths or [ ])}"
      ) overrides
    )
  );
in
{
  inherit overrides resolve channelOverrides;
}
