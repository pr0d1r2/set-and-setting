# Deterministic consumer-side test for skill materialization. Runs mkSet
# for the requested categories, then asserts the output layout matches
# expectations self-derived from categories.nix: every rule file has the
# conditional-load field with correct globs (V17/V18/V20), source tree is
# mirrored 1:1 (V19/V25), no SKILL.md anywhere (V17), excluded files are
# absent. Assertion logic lives in ./materialize-check.sh
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
    DIR = ag.dir;
    COND_FIELD = ag.condField;
    CATEGORIES = lib.concatStringsSep " " uniqueCats;
    GLOBS_MAP = globsMap;
    EXCLUDE = lib.concatStringsSep " " exclude;
  }
  ''
    bash ${./materialize-check.sh}
    touch $out
  ''
