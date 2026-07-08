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
      # Claude dedup (V20): the rule channel is the loader, so the SKILL.md
      # is not model-invoked -- it stays /-invoke + cross-agent only.
      disableModelInvocation = true;
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
      # opencode has no disable-model-invocation; SKILL.md stays
      # model-invocable (cross-agent content carrier).
      disableModelInvocation = false;
    };

    # back-compat seam
    inherit (conditional) dir;
    condField = conditional.field;
  };

  caveman-code = rec {
    alwaysOn = {
      file = "CAVE.md";
      import = "@";
    };
    conditional = {
      dir = ".cave/rules/set";
      field = "paths";
      mechanism = "path-rules";
    };
    skill = {
      dir = ".cave/skills";
      file = "SKILL.md";
      # caveman-code is a Claude Code superset; same dedup (V20).
      disableModelInvocation = true;
    };

    # back-compat seam
    inherit (conditional) dir;
    condField = conditional.field;
  };

  # T34 extension agents -- additional seams proving C2 agent-agnostic.
  # All use inline import (compiled AGENTS.md); none have @-import.

  cursor = rec {
    alwaysOn = {
      file = "AGENTS.md";
      import = "inline";
    };
    conditional = {
      dir = ".cursor/rules/set";
      field = "globs";
      mechanism = "cursor-rules";
    };
    skill = {
      dir = ".";
      file = "SKILL.md";
      disableModelInvocation = false;
    };

    inherit (conditional) dir;
    condField = conditional.field;
  };

  codex = rec {
    alwaysOn = {
      file = "AGENTS.md";
      import = "inline";
    };
    conditional = {
      dir = ".codex/rules/set";
      field = "globs";
      mechanism = "none";
    };
    skill = {
      dir = ".";
      file = "SKILL.md";
      disableModelInvocation = false;
    };

    inherit (conditional) dir;
    condField = conditional.field;
  };

  gemini-cli = rec {
    alwaysOn = {
      file = "AGENTS.md";
      import = "inline";
    };
    conditional = {
      dir = ".gemini/rules/set";
      field = "globs";
      mechanism = "none";
    };
    skill = {
      dir = ".";
      file = "SKILL.md";
      disableModelInvocation = false;
    };

    inherit (conditional) dir;
    condField = conditional.field;
  };

  copilot = rec {
    alwaysOn = {
      file = "AGENTS.md";
      import = "inline";
    };
    conditional = {
      dir = ".copilot/rules/set";
      field = "globs";
      mechanism = "none";
    };
    skill = {
      dir = ".";
      file = "SKILL.md";
      disableModelInvocation = false;
    };

    inherit (conditional) dir;
    condField = conditional.field;
  };

  amp = rec {
    alwaysOn = {
      file = "AGENTS.md";
      import = "inline";
    };
    conditional = {
      dir = ".amp/rules/set";
      field = "globs";
      mechanism = "none";
    };
    skill = {
      dir = ".";
      file = "SKILL.md";
      disableModelInvocation = false;
    };

    inherit (conditional) dir;
    condField = conditional.field;
  };
}
