# Security

Default-deny at every layer. When running autonomous AI agents, the
security model assumes the agent's output is untrusted and the network
is hostile.

## Principles

- Never relax a constraint without documenting why in HARDENING.md
- Secrets at activation time, never at nix eval time
- Credentials never in git or build artifacts
- Operator access via SSH allowlist only
- Agent killed first under memory pressure (earlyoom + OOMScoreAdjust)

See `security/hardening.md` for systemd patterns,
`security/auth-hygiene.md` for auth flows,
`security/personal.md` for PII rules.
