{
  pkgs,
  fragments,
  scaffoldDir,
  canonDir,
}:

let
  cfm = import ./check-fragment-map.nix;
  invalidFragments = builtins.filter (
    fragment: !(builtins.elem fragment cfm.validFragments)
  ) fragments;
  unitNames = pkgs.lib.unique (
    builtins.concatLists (map (fragment: cfm.canonUnitsPerFragment.${fragment}) fragments)
  );
  units = {
    canonDocs = import ./canon-docs.nix { inherit pkgs canonDir; };
    canonGovernance = import ./canon-governance.nix { inherit pkgs canonDir; };
    canonDevEnv = import ./canon-dev-env.nix { inherit pkgs canonDir; };
    canonSpec = import ./canon-spec.nix { inherit pkgs canonDir; };
  };
in
assert
  invalidFragments == [ ]
  || builtins.throw "canonFor: unknown fragments: ${builtins.concatStringsSep ", " invalidFragments}. Valid: ${builtins.concatStringsSep ", " cfm.validFragments}";
pkgs.symlinkJoin {
  name = "canon-repo";
  paths = [
    (import ./mk-seed.nix { inherit pkgs scaffoldDir; })
    # SPEC.md is the enrollment floor for every canonical repository. It is
    # independent of whether that repository enables Markdown linting.
    units.canonSpec
  ]
  ++ map (name: units.${name}) unitNames;
}
