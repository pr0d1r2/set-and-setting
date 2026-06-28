# mkSet -- the skill-set emitter (single source of truth for skills).
# Mirrors agnostic set/skills/ markdown 1:1 into <dir>/ as path-scoped
# rules: each source file copied verbatim with its category conditional-
# load field prepended (V17/V18/V19/V25). Everything is path-scoped
# (V20): domains narrow, core/universal broad. The agent format lives
# only here (C2/V17). The `agent` seam ({ dir, condField }) is the only
# agent-specific surface (V21). Shell logic lives in the sibling *.sh
# scripts (nix/modularity).
{ lib }:

let
  cats = import ./categories.nix;
  agents = import ./agents.nix;
  meta = import ../meta.nix { inherit lib; };
in

{
  pkgs,
  categories ? cats.all,
  concepts ? true,
  # Skill filenames to omit from the emitted output (e.g. "rtk.md").
  exclude ? [ ],
  # Per-agent seam. Default: Claude (from agents.nix).
  agent ? { },
}:

let
  ag = agents.claude // agent;

  categoryGlobs = cats.globs;

  globsMap = lib.concatStringsSep ";" (
    lib.mapAttrsToList (c: globs: "${c}=${lib.concatStringsSep "," globs}") categoryGlobs
  );

  # Per-category keywords for the portable SKILL.md description (V20/V30),
  # resolved from the meta map.
  keywordsMap = lib.concatStringsSep ";" (
    map (c: "${c}=${lib.concatStringsSep "," (meta.resolve c).keywords}") categories
  );
in
pkgs.runCommand "agent-set"
  {
    SKILLS_DIR = ../skills;
    CONCEPTS_DIR = ../concepts;
    CONCEPTS = if concepts then "1" else "0";
    DIR = ag.dir;
    COND_FIELD = ag.condField;
    CATEGORIES = lib.concatStringsSep " " categories;
    GLOBS_MAP = globsMap;
    EXCLUDE = lib.concatStringsSep " " exclude;
    CORE = lib.concatStringsSep " " cats.core;
    OVERRIDES = meta.channelOverrides;
    SKILL_DIR = ag.skill.dir;
    KEYWORDS_MAP = keywordsMap;
    EMIT = ./emit-skill.sh;
    EMIT_RULE = ./emit-rule.sh;
    EMIT_SKILLMD = ./emit-skillmd.sh;
    SYNC_SRC = ./sync-set.sh;
  }
  ''
    bash ${./mk-set.sh}
  ''
