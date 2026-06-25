# agents.nix -- known agent seams for mkSet (V21/V23).
# Each seam maps the two agent-specific surface values:
#   dir        -- where path-scoped rule files go (.claude/rules/set)
#   condField  -- frontmatter field name for conditional-load globs
# Adding a new agent: define its seam here, then it works everywhere
# (nix build, CLI installer, home-manager). Proves C2 agent-agnostic.
{
  claude = {
    dir = ".claude/rules/set";
    condField = "paths";
  };

  opencode = {
    dir = ".opencode/rules/set";
    condField = "globs";
  };
}
