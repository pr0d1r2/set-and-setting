# Deterministic consumer-side test for skill materialization. Runs mkSet
# for the requested categories, then asserts the output layout matches
# expectations self-derived from categories.nix: domain categories have
# SKILL.md with the conditional-load field and raw facets (V25); always-on
# categories have a rule file with no conditional field; excluded files
# are absent. Assertion logic lives in ./materialize-check.sh
# (nix/modularity: no embedded shell).
{ lib }:

let
  cats = import ../set/lib/categories.nix;
  agents = import ../set/lib/agents.nix;
  mkSet = import ../set/lib/mk-set.nix { inherit lib; };
in

{
  pkgs,
  categories ? [ ],
  exclude ? [ ],
  agent ? { },
}:

let
  ag = agents.claude // agent;

  allCats = cats.core ++ categories;
  uniqueCats = lib.unique allCats;

  materializedSet = mkSet {
    inherit pkgs exclude;
    categories = uniqueCats;
    concepts = false;
    agent = ag;
  };

  categoryGlobs = cats.globs;
  globsMap = lib.concatStringsSep ";" (
    lib.mapAttrsToList (c: globs: "${c}=${lib.concatStringsSep "," globs}") categoryGlobs
  );
in
pkgs.runCommand "materialize-check"
  {
    MATERIALIZED = materializedSet;
    SKILL_PATH = ag.skillPath;
    RULE_PATH = ag.rulePath;
    COND_FIELD = ag.condField;
    CATEGORIES = lib.concatStringsSep " " uniqueCats;
    GLOBS_MAP = globsMap;
    EXCLUDE = lib.concatStringsSep " " exclude;
  }
  ''
    bash ${./materialize-check.sh}
    touch $out
  ''
