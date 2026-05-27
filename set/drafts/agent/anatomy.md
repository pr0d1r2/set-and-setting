# Agent: anatomy

How skills, hooks, commands, and settings interact in an AI coding
agent.

## Components

- **Skills** (set/): behavioral rules loaded into context. Passive —
  they inform, the agent decides. Markdown only.
- **Hooks** (setting/): shell commands triggered by agent events
  (pre-commit, file-save, session-start). Active — they execute
  automatically.
- **Commands**: user-invoked operations the agent can perform.
  Registered via agent config, not skill files.
- **Settings**: agent configuration (permissions, model, theme).
  Per-agent format, lives in setting/.

## Interaction model

```
User request
  → Agent loads skills (set/) into context
  → Agent plans action informed by skills
  → Agent executes action
  → Hooks (setting/) fire on events
  → Hook output feeds back to agent
```

Skills shape decisions. Hooks enforce guardrails. Commands expose
capabilities. Settings configure the runtime.
