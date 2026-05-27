# Skill: sets

Skills group into sets — curated bundles loaded together for a
specific task or domain. A set is a list of skill paths, not a
copy of their content.

## Rules

- A set is a `.md` file whose body is primarily `@` references to
  atomic skills.
- Sets can nest: a set may `@`-reference another set.
- Sets have a purpose statement in their heading or first paragraph.
- Consumer selects sets via mkSet categories or explicit include
  lists.
- Overlapping skills across sets are deduplicated at load time —
  including a skill twice has no effect.

## Examples

- `security-set`: loads `security.md`, `security/credentials.md`,
  `security/hardening.md`, `security/personal.md`.
- `nix-set`: loads `nix/flake.md`, `nix/develop.md`,
  `nix/modularity.md`, `nix/composability.md`.
