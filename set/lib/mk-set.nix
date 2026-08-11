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
  renames = import ../renames.nix { inherit lib; };
in

{
  pkgs,
  # A named set is a self-contained skill directory materialized verbatim.
  # Omit this to use the multi-channel category emitter below.
  name ? null,
  categories ? cats.all,
  concepts ? true,
  # Skill filenames to omit from the emitted output (e.g. "rtk.md").
  exclude ? [ ],
  # Per-agent seam. Default: Claude (from agents.nix).
  agent ? { },
  # Source tree root. Default: set/skills/. Override to include drafts
  # (e.g. a merged tree with set/drafts/ as a drafts/ subdirectory).
  skillsDir ? ../skills,
  # Active principle registry; null derives it from skillsDir.
  principlesDir ? null,
}:

let
  ag = agents.claude // agent;

  namedSource = skillsDir + "/${name}";

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
if name != null then
  pkgs.runCommand "${name}-set" { } ''
    cp -R ${namedSource} $out
  ''
else
  pkgs.runCommand "agent-set"
    {
      SKILLS_DIR = skillsDir;
      PRINCIPLES_DIR = if principlesDir == null then "${skillsDir}/principles" else principlesDir;
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
      SKILL_DISABLE_INVOCATION = if ag.skill.disableModelInvocation or false then "1" else "0";
      KEYWORDS_MAP = keywordsMap;
      # Always-on channel (V18/V29/V39): "inline" import => compile set.md to
      # an inline AGENTS.md (universal core only). "opencode.json-instructions"
      # => also emit an opencode.json listing only the always-on file.
      ALWAYSON_IMPORT = ag.alwaysOn.import;
      ALWAYSON_FILE = ag.alwaysOn.file;
      CONDITIONAL_MECHANISM = ag.conditional.mechanism;
      RENAMES_MAP = renames.serialized;
      COMPILER = ../../lib/agents-md-compile.sh;
      EMIT = ./emit-skill.sh;
      EMIT_RULE = ./emit-rule.sh;
      EMIT_SKILLMD = ./emit-skillmd.sh;
      EMIT_PRINCIPLES = ./emit-principles.sh;
      RENAME_PROPAGATE = ./rename-propagate.sh;
      SYNC_SRC = ./sync-set.sh;
      REF_MATCH = ../../lib/ref-match.sh;
      REWRITE_REFS = ./rewrite-refs.sh;
      SET_ROOT = "${builtins.dirOf (toString skillsDir)}";
    }
    ''
      bash ${./mk-set.sh}
    ''
