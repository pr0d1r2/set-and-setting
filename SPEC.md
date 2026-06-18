# SPEC -- set-and-setting

## §G Goal

Deterministic, agent-agnostic **set** (mindset: skills, principles,
concepts) and **setting** (environment: guardrails, standards,
infrastructure) for AI coding agent trips. Psychedelic metaphor:
set + setting → trip. Nix flake composes markdown skills and dotfile
standards into immutable, content-addressed derivations. Consumers
import as flake input, build via nix closure, sync to repo -- skills
update deterministically when upstream improves.

North star: two builders are the single sources of truth across every
consumer repo. `mkSet` owns the skill set -- it emits the Agent-Skills
open-standard layout (`.claude/skills/set/`) that autoloads in any
compatible agent, materialized and gitignored in consumers. `mkSetting`
owns unified config -- shareable configs (e.g. `.markdownlint.yml`,
`.yamllint.yml`, agent commands/allowances) are exposed as
`packages.setting`, materialized and gitignored. Repo-specific files (`.gitattributes`, `.editorconfig`,
`config/lefthook/file_size_limits.yml`, `.narrow-language-*.dic`,
`.nix-embedded-shell-allowlist`) are scaffolded once in a seed/init
phase, then tracked and owned by the consumer. This repo is consumer #0
and dogfoods both.

## §C Constraints

- C1: Pure nix -- no runtime deps beyond nixpkgs.
- C2: Agent-agnostic -- no Claude/GPT/etc specifics in set/ or setting/. Any LLM agent can consume.
- C3: Cross-platform -- aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux.
- C4: Skills are markdown only (*.md). No executable code in set/.
- C5: MIT license.
- C6: Consumers use `git+file:` or `github:` flake inputs.
- C7: Deterministic updates -- consumer `nix flake update set-and-setting` + `sync-set`/`sync-setting` + commit = reproducible upgrade path for both skills and standards.
- C8: Composable outputs -- `packages.set` is the Agent-Skills tree emitted from agnostic `set/` by `mkSet` (agent format only there). Consumed per-repo (sync) or home-level. Per-agent surface is one seam `{ dir, condField, alwaysOnFile }`. Reinforces C2.
- C9: Three delivery paths, one emitter. (1) flake input -- pinned/
  vendored, drift-checked. (2) home-manager -- `home.file` into
  `~/.claude/skills/set`. (3) `nix run github:pr0d1r2/set-and-setting#mkSet
  [cats]` -- zero-dependency, ad-hoc, per-CWD; nix is the only dep (repo
  is public). All three share the one emitter; (3) emits at run time.

## §I Interfaces

- I.flake: `flake.nix` -- main entry. Exposes `sets`, `drafts`, `settings`, `lib.mkSet`, `lib.mkSetting`, `lib.mkDriftCheck`, `lib.mkMaterializeCheck`, `packages.set`, `packages.setting`, `checks`.
- I.mkSet: `set/lib/mk-set.nix` -- the skill-set emitter and single
  source of truth for skills. Transforms agnostic `set/skills/` markdown
  into the Agent-Skills open-standard layout: one skill folder per
  category (`<dir>/set/<category>/SKILL.md` + topic/aspect files as body
  or supporting files) with derived `name` + `description`; cross-cutting
  categories emit to the always-on file. Args: `pkgs`, `categories`,
  `concepts`, `exclude`, `agent ? claude` where
  `agent = { dir, condField, alwaysOnFile }`. Outputs: the emitted tree +
  `bin/sync-set` (target-arg). Agent format lives only here (C2/V17).
- I.mkSetting: `setting/lib/mk-setting.nix` -- single source of truth for
  unified config. Two outputs: (1) seed/init -- repo-specific starters
  scaffolded once then tracked & repo-owned: `.gitignore`,
  `.gitattributes`, `.editorconfig`, `config/lefthook/file_size_limits.yml`,
  `.narrow-language-*.dic`, `.nix-embedded-shell-allowlist`; (2)
  materialized -- unified configs always synced & gitignored:
  `.markdownlint.yml`, `.yamllint.yml`, `.claude/` commands/allowances.
  Args: `pkgs` + per-output toggles. `bin/sync-setting` (materialize),
  `bin/sync-setting-init` (scaffold, skips files that already exist).
- I.mkDriftCheck: `lib/mk-drift-check.nix` -- compares synced set files against built derivation. Args: `pkgs`, `skillSet`, `projectRoot`, `setPath`. Fails with exit 1 on drift.
- I.mkSettingDriftCheck: `lib/mk-setting-drift-check.nix` -- compares synced dotfiles against mkSetting output. Args: `pkgs`, `settingSet`, `projectRoot`. Fails with exit 1 on drift.
- I.mkMaterializeCheck: `lib/mk-materialize-check.nix` -- deterministic
  consumer-side test for skill materialization. Runs mkSet for the
  requested categories (core implied), then asserts the output layout
  matches expectations self-derived from `categories.nix`: domain
  categories have `SKILL.md` with the conditional-load field and raw
  facets (V25); always-on categories have a rule file with no
  conditional field; excluded files are absent. Args: `pkgs`,
  `categories`, `exclude ? []`, `agent ? {}`. Shell logic in
  `lib/materialize-check.sh` (nix/modularity). Consumer wiring is one
  line in their `checks` output.
- I.sync-set: CLI script in mkSet output. Copies skills+concepts+set.md to consumer repo target dir.
- I.sync-setting: CLI script in mkSetting output. Copies dotfiles to consumer repo root.
- I.sets: Attrset of raw paths to each skill category dir.
- I.drafts: Attrset of raw paths to draft category dirs. Opt-in via `categories = [ "drafts/skill" "drafts/agent" ... ]` in mkSet.
- I.settings: Attrset of raw paths to each standard dir (editorconfig, gitattributes, gitignore).
- I.self-wire: `CLAUDE.md` -- this repo dogfoods `packages.set`: it emits own `set/` into a gitignored `.claude/skills/set/` + always-on rules, auto-synced on devShell/direnv entry. No `@`-ref duplication of skills.
- I.set-package: `packages.<sys>.set` -- a default `mkSet` build over all stable categories + concepts. Consumed home-level (`home.file.".claude/skills/set".source`) or per-repo (sync, gitignored).
- I.setting-package: `packages.<sys>.setting` -- a default `mkSetting`
  materialize build (unified configs only: `.markdownlint.yml`,
  `.yamllint.yml`, `.claude/` commands/allowances). Consumed per-repo
  (sync, gitignored) or home-level for the `.claude/` parts. Symmetric
  with `packages.set`. Seed/init scaffold is separate
  (`bin/sync-setting-init`), not in this package.
- I.sync-target: `sync-set`/`sync-setting` take a target dir arg; default preserves prior behavior.
- I.apps: `apps.<sys>.{mkSet,mkSetting,mkSetting-init,bootstrap}` --
  runnable installers for the zero-dependency delivery path (C9).
  `nix run github:pr0d1r2/set-and-setting#mkSet [cats|--all|--all-except
  a b]` materializes skills into `./.claude/skills/set/` at the CWD.
  Emit happens at RUN TIME (the app carries agnostic source + emitter
  scripts; no pre-baked per-agent tree), so categories and the `--agent`
  seam are pure runtime flags. `mkSetting` materializes unified config;
  `mkSetting-init` seeds repo-specific starters (skip-if-exists);
  `bootstrap` = mkSet core + mkSetting + mkSetting-init in one. Each
  supports `--list`/`--help`/`--dry-run`.
- I.manifest: `./.claude/skills/set/.mkset.json` -- records installed categories + upstream rev + agent. Drives smart re-run (bare `mkSet` with a manifest refreshes what's installed), update detection, and `--remove`. Distinguishes mkSet-managed files from hand-added ones.

## §V Invariants

- V1: `nix flake check` passes on all 4 supported systems.
- V2: `mkSet` output `set.md` lists concepts first, then `generic/skill.md`, then all other skills sorted. No file listed twice.
- V3: `mkSet` preserves category prefix in output paths -- files from different categories never collide even if filenames match.
- V4: `mkDriftCheck` exits 0 iff synced `skills/`, `concepts/`, and `set.md` are byte-identical to built derivation.
- V5: `mkSetting` gitignore composes fragments by concatenation in declared order.
- V6: Every skill file is `*.md`. No other extensions in `set/skills/`.
- V7: Skill file structure follows `<topic>.md` + `<topic>/<aspect>.md` convention. Cross-cutting aspects (modularity, security) reuse same naming across topics.
- V8: `exclude` parameter in mkSet filters paths from output -- excluded files must not appear in derivation.
- V9: (retired -- extra/extraPaths injection dropped with the mkSet emitter rewrite)
- V10: Source repo dogfoods `packages.set` -- emits own `set/` into a gitignored `.claude/skills/set/` + always-on rules, auto-synced on devShell/direnv entry. No `@`-ref duplication of skills.
- V11: Draft skills live in `set/drafts/` mirroring `set/skills/` structure. Not loaded by default -- consumer opts in via `drafts/*` categories.
- V12: Bundle files compose atomics via `@` references. Own content limited to heading and purpose statement.
- V13: Every draft file is `*.md`. Same format rules as stable skills (V6, V7).
- V14: Hardware concepts are composable templates under `concepts/hardware/<vendor>/<model>.md`. Templates describe capabilities, not roles.
- V15: Concept files may compose sub-concepts via `@` references, same pattern as skill bundles (V12).
- V16: No secrets, credentials, or PII (beyond public GitHub usernames) in any tracked file or git history.
- V17: The agent output format (`SKILL.md` + frontmatter) lives only in `mkSet`. No agent-specific frontmatter or naming in `set/skills/` sources (preserves C2 agent-agnostic).
- V18: Each emitted `SKILL.md` carries valid frontmatter -- `name` (slug) and `description` (one line, derived from the source skill's heading + purpose) -- followed by the unchanged agnostic markdown body.
- V19: `mkSet` emits the Agent-Skills open-standard layout (`<skill>/SKILL.md` + supporting files), portable across agentskills.io tools. Source is single-source-of-truth; emission adds only frontmatter + placement.
- V20: `mkSet` groups one skill folder per category; domain categories
  carry the conditional-load field (Claude `paths`, Cursor `globs`) from a
  category-globs map; cross-cutting categories (e.g. `generic`) emit to
  the always-on file (`AGENTS.md` / `CLAUDE.md` / `.claude/rules`), no
  globs.
- V21: The only agent-specific surface is the seam `{ dir, condField, alwaysOnFile }` (default Claude). The same agnostic sources build for any agent given its seam values.
- V22: `mkSetting` is the single source of truth for unified config, with
  two output kinds: seed/init (repo-specific starters -- `.gitattributes`,
  `.editorconfig`, `file_size_limits.yml`, `.narrow-language-*.dic`,
  allowlist -- scaffolded once, then tracked & repo-owned) and
  materialized (unified configs -- `.markdownlint.yml`, `.yamllint.yml`,
  `.claude/` commands/allowances -- always synced & gitignored). Only
  truly unified, non-repo-specific config is materialized.
- V23: Agnosticism is proven by 2 agent seams building the same sources -- Claude (default) + opencode. A single seam may hide baked assumptions. Other agents (Cursor, Codex, Gemini CLI, Copilot, Amp, ...) are a future extension list, not required now.
- V24: Coarse granularity -- one catalog entry (`SKILL.md`) per category, NOT per topic. `paths` gates body activation, not catalog presence (all skill names are always indexed, descriptions share a budget); per-topic skills would dilute the listing. Verified against Claude Code skills docs.
- V25: Facets are cloned raw (no frontmatter, not skills, not catalog
  entries) as supporting files under `<cat>/`. The category `SKILL.md`
  body LINKS them with markdown links (`[facet](facet.md)`) + a one-line
  note; the agent reads them on-demand (progressive disclosure). NOT
  `@`-import (that is the always-on CLAUDE.md mechanism) and NOT
  concatenated into the body.
- V26: Clean-replace per category -- installing a `<cat>` does
  `rm -rf .claude/skills/set/<cat>` then writes fresh (removed facets
  vanish; deterministic, exact upstream state). Scoped to the `set`
  namespace; never blanket-removes a shared dir. Unrequested categories
  untouched. Exception: `mkSetting-init` seeds skip-if-exists (repo-owned),
  never replaced.
- V27: Selection -- core (`generic`+`git`) is always pulled; domains and other cross-cutting are opt-in. No args => core only + a notice listing selectable categories. `--all` and `--all-except a b ...` available. Unknown category => error + list (fail with guidance).
- V28: Run-time emit for the `nix run` path -- the installer ships agnostic source + emitter scripts and emits into CWD at run time; one emitter serves all three delivery paths (C9). The same `mk-set.sh`/`emit-skill.sh` produce the flake-input, home-manager, and `nix run` outputs.

## §T Tasks

| id  | s | description                                          | cites     |
|-----|---|------------------------------------------------------|-----------|
| T1  | ~ | CLAUDE.md wires own set/ skills via direct @ refs -- superseded by T30 dogfood (emit to .claude/skills/set) | V10,I.self-wire,T30 |
| T2  | x | add README.md with usage examples for consumers      | I.mkSet,I.mkSetting |
| T3  | x | add lefthook integration in setting/integrations/    | I.flake   |
| T4  | x | add `nix flake check` CI (GitHub Actions)            | V1,C3     |
| T5  | x | expose mkDriftCheck for setting/ (not just set/)     | I.mkDriftCheck |
| T6  | x | add tests for mkSet exclude param                    | V8        |
| T7  | . | switch consumer repos from git+file: to github: URLs | C6        |
| T8  | . | auto-update mechanism -- flake re-eval triggers sync-set + sync-setting + commit in consumer repos | C7,I.sync-set,I.sync-setting |
| T9  | . | consumer dependency graph: upstream repos switch git+file: to github: URLs after push | C6 |
| T10 | x | add `set/drafts/` tree with atomic skill files and bundles | V11,V12,V13 |
| T11 | x | wire drafts categories into mkSet and flake.nix | I.flake,I.drafts |
| T12 | . | add mkSet check: drafts categories build without error | V1,V11 |
| T13 | . | graduate draft to stable: move `drafts/X` → `skills/X` when mature | V11 |
| T14 | . | skill linting CI: enforce format, size budget, `@` ref resolution | V12,V13 |
| T15 | x | CLAUDE.md wire drafts via `@` refs (dogfood) | V10,V11 |
| T16 | x | generalize hardware concepts into composable templates | V14,V15 |
| T17 | x | audit git history for secrets and PII before opensourcing | V16 |
| T18 | . | create public GitHub repo and push | C6 |
| T19 | . | enable main branch protection requiring PRs | C5 |
| T20 | . | set up cachix cache for nix builds | V1 |
| T21 | . | set up GitHub Actions CI (nix flake check, all platforms) | V1,C3 |
| T22 | . | update hallucinogen: git+file: to github: set-and-setting | C6,T7 |
| T23 | . | update CHANGELOG.md for opensourcing | C5 |
| T24 | . | rename propagation: mechanism for consumers to detect upstream skill renames and update synced copies | C7,I.sync-set |
| T25 | x | evolve `mkSet` into the emitter -- group `set/skills/<category>` into one Agent-Skills folder per category; derive name/description; `bin/sync-set` target-arg; fold loose top-level `<topic>.md` (cli.md) into its category | I.mkSet,V19 |
| T26 | x | `packages.<sys>.set` = mkSet build over all stable categories + concepts | I.set-package |
| T27 | x | category-globs map -- domain categories get the conditional-load field, cross-cutting emit to always-on file | V20 |
| T28 | x | mkSetting split: materialize unified configs (markdownlint/yamllint/.claude, gitignored) + seed/init scaffold for repo-specific starters (gitattributes/editorconfig/file_size_limits/dics/allowlist), skip-if-exists | V22 |
| T29 | x | `compose-set` check -- agnostic md (no frontmatter injected), sync layout, gitignore ignores synced set while seed tracked | V1 |
| T30 | . | dogfood -- emit set into gitignored `.claude/skills/set/` + always-on, auto-sync on devShell entry; drop CLAUDE.md `@`-ref block | V10,I.self-wire |
| T31 | . | agnosticism proof -- the opencode seam (`AGENTS.md` always-on; opencode skill dir + conditional field) builds the same sources as Claude | V23 |
| T33 | . | downstream wiring -- consumer repos + `nix-home-manager-claude-code` example + CI sync pre-step (materialized configs synced before hooks run) | C6,C7,V22 |
| T34 | . | future: additional agent seams (Cursor `globs`/`.cursor/rules`, Codex, Gemini CLI, Copilot, Amp, ...) -- extension list, not built now | V23,C2 |
| T32 | x | repo-wide `lefthook --all-files` green: cleared markdownlint, editorconfig, ascii, nixfmt, nix-no-embedded-shell debt + narrow-language baseline-freeze; CI now runs the full lefthook suite via nix-lefthook-ci-action (only commit-gate `changelog-touched` excluded) | C3,V6,B1 |
| T35 | x | refactor mkSet emission to facets-as-linked-files -- `<cat>/SKILL.md` (frontmatter + body that markdown-links raw cloned facets) instead of concatenation; clean-replace per category | I.mkSet,V24,V25,V26 |
| T36 | x | `apps.<sys>.{mkSet,mkSetting,mkSetting-init,bootstrap}` runnable installers -- run-time emit into CWD; selection (core always, domains opt-in, `--all`/`--all-except`, default=core+notice); `--list`/`--help`/`--dry-run`; fail-with-guidance | I.apps,V27,V28,C9 |
| T37 | x | install manifest `.claude/skills/set/.mkset.json` -- smart bare re-run (refresh installed), update detection, `--remove` | I.manifest |
| T38 | x | README headline -- document `nix run github:pr0d1r2/set-and-setting#mkSet` one-command skill materialization as the first-impression WOW (single command, zero deps); cover all three delivery paths (C9) | I.apps,C9 |
| T39 | x | `--agent` seam passthrough in installers (opencode target); ties the agnosticism proof | V21,V28,T31 |
| T40 | x | `lib.mkMaterializeCheck` -- deterministic consumer-side test for skill materialization; self-derives expectations from `categories.nix`; bats coverage + `checks` entries | I.mkMaterializeCheck,V20,V25 |

## §B Bugs

| id | date | cause | fix |
|----|------|-------|-----|
| B1 | 2026-06-16 | upstream nix-lefthook tightened checks; repo never revalidated, so `main` fails `lefthook run pre-commit --all-files` on pre-existing files (prose markdownlint, `*.nix` em-dashes, editorconfig padding, drift-check embedded shell) | fixed: narrow-other glob (#10), drift+embedded-shell extracted (#13), markdownlint/editorconfig/narrow cleared + CI runs lefthook (T32) |
