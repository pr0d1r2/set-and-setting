# agents.nix -- known agent seams for mkSet (V21/V23).
# Each seam maps the three agent-specific surface values:
#   skillPath  -- where domain category folders go
#   rulePath   -- where always-on cross-cutting rules go
#   condField  -- frontmatter field name for conditional-load globs
# Adding a new agent: define its seam here, then it works everywhere
# (nix build, CLI installer, home-manager). Proves C2 agent-agnostic.
{
  claude = {
    skillPath = ".claude/skills/set";
    rulePath = ".claude/rules";
    condField = "paths";
  };

  opencode = {
    skillPath = ".opencode/skills/set";
    rulePath = ".opencode/rules";
    condField = "globs";
  };
}
