# Resolve real @-references against mkSet outputs, without consulting the
# source tree. Both a broad and a narrow selection are checked because a ref
# can be valid only when its target category is emitted.
{ lib }:

let
  cats = import ../set/lib/categories.nix;
  mkSet = import ../set/lib/mk-set.nix { inherit lib; };

  check =
    {
      pkgs,
      name,
      categories,
    }:
    let
      emitted = mkSet {
        inherit pkgs categories;
        concepts = true;
        # The portable channel inlines source bodies into SKILL.md; its
        # source-relative bundle refs are not emitted as files. Keep this
        # check focused on the path/materialized channels that ship files.
        agent = {
          skill = {
            dir = "";
          };
        };
      };
    in
    pkgs.runCommand "${name}-emitted-ref-resolution-check"
      {
        ARTIFACT_ROOT = emitted;
        REF_MATCH = ./ref-match.sh;
      }
      ''
        bash ${./ref-resolution-emitted-check.sh}
        touch $out
      '';
in
{
  pkgs,
}:
{
  all = check {
    inherit pkgs;
    name = "all";
    categories = cats.all;
  };
  language = check {
    inherit pkgs;
    name = "language";
    categories = [ "language" ];
  };
}
