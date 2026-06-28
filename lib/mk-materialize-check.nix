# Deterministic consumer-side test for skill materialization. Runs mkSet
# for the requested categories, then asserts the multi-channel output
# layout matches expectations self-derived from categories.nix + meta:
# core categories emit path-less always-on rules (V18/V32), domain
# categories emit conditional rules with correct globs (V17/V19), per-file
# overrides flip individual files (V30), source tree mirrored 1:1
# (V19/V25), excluded files absent (V8). Assertion logic lives in
# ./materialize-check.sh (nix/modularity: no embedded shell).
{ lib }:

let
  cats = import ../set/lib/categories.nix;
  agents = import ../set/lib/agents.nix;
  meta = import ../set/meta.nix { inherit lib; };
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
    CORE = lib.concatStringsSep " " cats.core;
    OVERRIDES = meta.channelOverrides;
    EXCLUDE = lib.concatStringsSep " " exclude;
  }
  ''
    bash ${./materialize-check.sh}
    touch $out
  ''
