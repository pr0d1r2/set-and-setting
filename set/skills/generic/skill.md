# Skill

The `set/skills/` tree holds this project's behavioral rules,
one concept per file. It is structured, not flat: a top-level
`<topic>.md` captures the core rule for a topic, and
`<topic>/<aspect>.md` captures a specific facet of it (e.g. `sh.md` +
`sh/modularity.md`, `lefthook.md` + `lefthook/{nix,sh,xml}.md`). The
structure itself is informative -- `find set/skills/ -type f`
lists every rule the project cares about.

Some aspects are cross-cutting and recur under multiple topics -- for
example `modularity` appears as `sh/modularity.md`,
`nix/modularity.md`, `just/modularity.md`, `nixos/users/modularity.md`,
and `update/modularity.md`; `security` appears as `test/security.md`,
`nixos/security/wrappers.md`, and `update/security.md`. When working
on a cross-cutting concern, list every occurrence first so you apply
the aspect consistently across all topics, not just the one in front
of you. When introducing a new facet of a recurring aspect, follow the
existing `<topic>/<aspect>.md` convention so it stays discoverable the
same way.

When adding a new skill:

- Put a single-topic rule at `set/skills/<topic>.md`.
- Put a narrower facet of an existing topic at
  `set/skills/<topic>/<aspect>.md`.
- Do not hand-edit any manifest to wire the skill in. The always-on
  manifest and the rule tree are emitted from `set/` and gitignored;
  an edit there is overwritten by the next sync.
- Always run `markdownlint` on the new or changed skill file before
  considering the change complete.

When a skill file is added or changed, apply its rules to the entire
repo immediately. Scan all existing files for violations of the new or
updated skill. Fix each violation in a separate commit -- do not batch
unrelated changes together. This keeps diffs reviewable and bisectable.
