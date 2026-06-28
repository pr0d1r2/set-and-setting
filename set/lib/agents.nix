# agents.nix -- per-agent profiles for mkSet (V21/V23, I.agentProfile).
# A profile carries every agent-specific channel mechanism -- the only
# place an agent format appears (C2/V17):
#   alwaysOn    -- always-on file + import syntax (channel a, V18)
#                  { file; import; }  import = "@" | "inline"
#   conditional -- conditional-load mechanism (channel b, V19)
#                  { dir; field; mechanism; }
#   skill       -- portable SKILL.md format/location (channel c, V20)
#                  { dir; file; }
# Back-compat seam: top-level `dir`/`condField` are derived from
# `conditional` (single source within each entry) so existing consumers
# (mk-set.nix, resolve-agent.sh, flake.nix) keep working unchanged.
# Adding a new agent: define its profile here, then it works everywhere
# (nix build, CLI installer, home-manager). Proves C2 agent-agnostic.
{
  claude = rec {
    alwaysOn = {
      file = "CLAUDE.md";
      import = "@";
    };
    conditional = {
      dir = ".claude/rules/set";
      field = "paths";
      mechanism = "path-rules";
    };
    skill = {
      dir = ".claude/skills";
      file = "SKILL.md";
    };

    # back-compat seam
    inherit (conditional) dir;
    condField = conditional.field;
  };

  opencode = rec {
    alwaysOn = {
      file = "AGENTS.md";
      import = "inline";
    };
    conditional = {
      dir = ".opencode/rules/set";
      field = "globs";
      mechanism = "opencode.json-instructions";
    };
    skill = {
      dir = ".";
      file = "SKILL.md";
    };

    # back-compat seam
    inherit (conditional) dir;
    condField = conditional.field;
  };
}
