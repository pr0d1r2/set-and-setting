# Enforce V6/V13: only *.md files in set/skills/ and set/drafts/ (T56).
# Pure find + exit-on-non-md. No content parsing. Shell logic in
# ./skill-extension-check.sh (nix/modularity). Args: pkgs, setRoot.
{
  pkgs,
  setRoot,
}:

pkgs.runCommand "set-skill-extension-check"
  {
    nativeBuildInputs = [ pkgs.findutils ];
    SET_ROOT = setRoot;
  }
  ''
    bash ${./skill-extension-check.sh}
    touch $out
  ''
