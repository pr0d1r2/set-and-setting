# agents-md-compile -- the @->AGENTS.md compiler (V29/I.compiler). Resolves
# a Claude @-manifest (e.g. the set.md emitted by mkSet) into an inline,
# self-contained AGENTS.md so non-Claude agents get the same always-on
# content Claude loads via @-import. Shell logic lives in the sibling
# agents-md-compile.sh (nix/modularity: no embedded shell).
{
  pkgs,
  # Directory the manifest's @<path> refs resolve against (e.g. the
  # emitted .claude/rules dir, which holds set.md + set/).
  src,
  # Manifest file relative to src (default: the mkSet always-on manifest).
  entry ? "set.md",
  name ? "AGENTS.md",
}:

pkgs.runCommand "agents-md"
  {
    SRC = src;
    ENTRY = entry;
    OUTNAME = name;
    SCRIPT = ./agents-md-compile.sh;
  }
  ''
    mkdir -p "$out"
    INPUT="$SRC/$ENTRY" BASE="$SRC" SELF="$SCRIPT" bash "$SCRIPT" >"$out/$OUTNAME"
  ''
