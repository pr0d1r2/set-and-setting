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

## Adding a skill

Writing the markdown file is one step of five. The other four decide
whether the skill ever loads, and skipping them fails silently -- the
file looks correct and does nothing.

1. Choose stable or draft. Unproven content goes to
  `set/drafts/<category>/` and reaches only consumers who opt in.
  Promote it later with `nix run .#graduate`, which moves the files
  and rewrites `@`-refs; do not move them by hand.
2. Choose the shape. A core rule is `<topic>.md`; a narrower facet is
  `<topic>/<aspect>.md`. A facet extends its core, so keeping a facet
  pulls its `<topic>.md` in with it.
3. Add an exact `set/meta.nix` entry. It decides `channel` (always-on or
  conditional), `paths` (which files trigger a conditional load), and
  `keywords` (what makes the portable skill discoverable). Category
  inheritance is a fallback for established trees, not an approval to
  add a new skill: validation rejects a direct `generic/*.md` file that
  has no exact decision.
4. For a new category only, add it to `set/lib/categories.nix`.
  Without that the category is not emitted.
5. Verify with `nix flake check`, then confirm the file appears in the
  channel you intended under `.claude/rules/set/`. Do not assume it
  did.

Always-on carries universal content only. A rule tied to one language,
tool, or repo layout belongs on the conditional channel however useful
it is -- always-on costs context on every turn in every consumer.

Do not hand-edit any manifest to wire the skill in. The always-on
manifest and the rule tree are emitted from `set/` and gitignored, so
an edit there is overwritten by the next sync.

When a skill file is added or changed, apply its rules to the entire
repo immediately. Scan all existing files for violations of the new or
updated skill. Fix each violation in a separate commit -- do not batch
unrelated changes together. This keeps diffs reviewable and bisectable.
