# mkSet -- the skill-set emitter (single source of truth for skills).
# Transforms agnostic set/skills/ markdown into the Agent-Skills
# open-standard layout: one skill folder per category. Domain categories
# get a SKILL.md with the conditional-load field (paths) so the body
# loads when matching files are edited; cross-cutting categories emit to
# the always-on rules dir (no globs, always loaded). The agent format
# lives only here (C2/V17). The `agent` seam is the only agent-specific
# surface. Shell logic lives in the sibling *.sh scripts (nix/modularity).
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
    SKILL_PATH = ag.skillPath;
    RULE_PATH = ag.rulePath;
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
