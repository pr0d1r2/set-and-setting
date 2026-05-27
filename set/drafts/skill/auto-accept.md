# Skill: auto-accept

Skills that introduce CLI commands should declare which commands are
safe for automatic execution without user confirmation.

## Rules

- A skill may include an `## Auto-accept` section listing shell
  command patterns that are read-only or idempotent.
- Patterns use glob syntax: `nix flake check*`, `bats *`.
- Destructive commands (rm, git push, drop) never appear in
  auto-accept.
- Consumer tooling extracts these patterns to generate
  `.claude/settings.local.json` allowlists or equivalent per-agent
  config.
