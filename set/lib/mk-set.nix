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
    EMIT = ./emit-skill.sh;
    SYNC_SRC = ./sync-set.sh;
  }
  ''
    bash ${./mk-set.sh}
  ''
