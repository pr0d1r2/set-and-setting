# Agent: portability

Skills and settings must not assume a specific AI agent. Claude Code,
opencode, aider, or future agents should all consume the same skill
tree without agent-specific adaptation.

## Rules

- No agent-specific syntax in skill files. `@` file references are
  the only composition mechanism — they work across agents that
  support file inclusion.
- Agent-specific configuration (settings.json, .claude/, .aider*)
  belongs in setting/, not set/.
- When an agent lacks a feature a skill assumes (e.g. auto-accept),
  the skill still applies — the missing feature is a gap in the
  agent, not a reason to weaken the rule.
- Test skills with at least two agents before considering them
  portable. Current targets: Claude Code, opencode.
