# Open-source: documentation

Public documentation lives at the repo root. Each file has a specific
audience and purpose.

## Required files

| File | Audience | Purpose |
| ---- | -------- | ------- |
| `README.md` | Everyone | First impression -- what it is, how to start, badges |
| `LICENSE` | Legal | License text |
| `CONTRIBUTING.md` | Contributors | Setup, testing, style, commits |
| `HARDENING.md` | Security reviewers | Active measures, deferred items |
| `SPEC.md` | Maintainers | Full project specification |
| `ATTRIBUTION.md` | Everyone | External software, services, sources |
| `CHANGELOG.md` | Users + contributors | What changed, grouped by release |

## README badges

Badges appear on a single line after the heading, in this order:

1. CI status (when hosted CI exists)
2. License
3. NixOS version

## What stays internal

- Implementation plans -- OK to publish (shows project thinking)
- Agent skills -- OK to publish (educational)
- Config templates -- OK to publish (no real data)
- Operator workflows -- documented in justfile help, not separate docs

## When to update

- `README.md`: when user-facing commands change
- `HARDENING.md`: when security posture changes
- `SPEC.md`: when constraints, interfaces, or invariants change
- `CHANGELOG.md`: with every code change
- `CONTRIBUTING.md`: when dev setup or conventions change
