# SPEC -- set-and-setting

## §G Goal

Deterministic, agent-agnostic **set** (mindset: skills, principles,
concepts) and **setting** (environment: guardrails, standards,
infrastructure) for AI coding agent trips. Psychedelic metaphor:
set + setting → trip. Nix flake composes markdown skills and dotfile
standards into immutable, content-addressed derivations. Consumers
import as flake input, build via nix closure, sync to repo -- skills
update deterministically when upstream improves.

North star: `mkSetting` is the single source of truth for unified
configuration across every consumer repo. Shareable config (linter
configs, dictionaries, allowlists, agent commands/allowances) is
outsourced to `mkSetting` and materialized; each consumer tracks a
minimal seed plus small local extensions. The `set` package emits the
Agent-Skills open-standard layout so skills autoload in any compatible
agent. This repo is consumer #0 and dogfoods both.

## §C Constraints

- C1: Pure nix -- no runtime deps beyond nixpkgs.
- C2: Agent-agnostic -- no Claude/GPT/etc specifics in set/ or setting/. Any LLM agent can consume.
- C3: Cross-platform -- aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux.
- C4: Skills are markdown only (*.md). No executable code in set/.
- C5: MIT license.
- C6: Consumers use `git+file:` or `github:` flake inputs.
- C7: Deterministic updates -- consumer `nix flake update set-and-setting` + `sync-set`/`sync-setting` + commit = reproducible upgrade path for both skills and standards.
- C8: Composable outputs -- `packages.set` is the Agent-Skills tree emitted from agnostic `set/` by `lib/mkSkills` (agent format only there). Consumed per-repo (sync) or home-level. Per-agent surface is one seam `{ dir, condField, alwaysOnFile }`. Reinforces C2.

## §I Interfaces

- I.flake: `flake.nix` -- main entry. Exposes `sets`, `drafts`, `settings`, `lib.mkSet`, `lib.mkSetting`, `lib.mkDriftCheck`, `checks`.
- I.mkSet: `set/lib/mk-set.nix` -- builds `agent-set` derivation from selected categories. Args: `pkgs`, `categories`, `concepts`, `exclude`, `extra`, `extraPaths`. Outputs: `$out/skills/`, `$out/concepts/`, `$out/set.md`, `$out/bin/sync-set`.
- I.mkSetting: `setting/lib/mk-setting.nix` -- single source of truth for
  unified config. Args: `pkgs`, `editorconfig`, `gitattributes`,
  `gitignore`, `markdownlint`, `yamllint`, `fileSizeLimits`,
  `dictionaries` (base⊕local per language), `embeddedShellAllowlist`
  (base⊕local). Outputs: tracked seed (`.gitignore`) + materialized,
  gitignored configs (`.markdownlint.yml`, `.yamllint.yml`,
  `config/lefthook/file_size_limits.yml`, `.narrow-language-*.dic`,
  `.nix-embedded-shell-allowlist`, `.claude/`) + `bin/sync-setting`.
- I.mkDriftCheck: `lib/mk-drift-check.nix` -- compares synced set files against built derivation. Args: `pkgs`, `skillSet`, `projectRoot`, `setPath`. Fails with exit 1 on drift.
- I.mkSettingDriftCheck: `lib/mk-setting-drift-check.nix` -- compares synced dotfiles against mkSetting output. Args: `pkgs`, `settingSet`, `projectRoot`. Fails with exit 1 on drift.
- I.sync-set: CLI script in mkSet output. Copies skills+concepts+set.md to consumer repo target dir.
- I.sync-setting: CLI script in mkSetting output. Copies dotfiles to consumer repo root.
- I.sets: Attrset of raw paths to each skill category dir.
- I.drafts: Attrset of raw paths to draft category dirs. Opt-in via `categories = [ "drafts/skill" "drafts/agent" ... ]` in mkSet.
- I.settings: Attrset of raw paths to each standard dir (editorconfig, gitattributes, gitignore).
- I.self-wire: `CLAUDE.md` -- this repo dogfoods `packages.set`: it emits own `set/` into a gitignored `.claude/skills/set/` + always-on rules, auto-synced on devShell/direnv entry. No `@`-ref duplication of skills.
- I.mkSkills: `lib/mk-skills.nix` -- the emitter. Transforms agnostic
  `set/skills/` markdown into the Agent-Skills open-standard layout: one
  skill folder per category (`<set-subdir>/<category>/SKILL.md` + topic/
  aspect files as body or supporting files) with derived `name` +
  `description`; cross-cutting categories emit to the always-on file.
  Args: `pkgs`, `agent ? claude` where `agent = { dir, condField,
  alwaysOnFile }`. Outputs: the emitted tree + `bin/sync` (target-arg).
  Agent format lives only here (C2/V17).
- I.set-package: `packages.<sys>.set` -- a default `mkSkills` build over all stable categories + concepts. Consumed home-level (`home.file.".claude/skills/set".source`) or per-repo (sync, gitignored).
- I.sync-target: `sync-set`/`sync-setting`/`mkSkills` `bin/sync` take a target dir arg; default preserves prior behavior.

## §V Invariants

- V1: `nix flake check` passes on all 4 supported systems.
- V2: `mkSet` output `set.md` lists concepts first, then `generic/skill.md`, then all other skills sorted. No file listed twice.
- V3: `mkSet` preserves category prefix in output paths -- files from different categories never collide even if filenames match.
- V4: `mkDriftCheck` exits 0 iff synced `skills/`, `concepts/`, and `set.md` are byte-identical to built derivation.
- V5: `mkSetting` gitignore composes fragments by concatenation in declared order.
- V6: Every skill file is `*.md`. No other extensions in `set/skills/`.
- V7: Skill file structure follows `<topic>.md` + `<topic>/<aspect>.md` convention. Cross-cutting aspects (modularity, security) reuse same naming across topics.
- V8: `exclude` parameter in mkSet filters paths from output -- excluded files must not appear in derivation.
- V9: `extra` and `extraPaths` in mkSet inject content into `$out/skills/` without requiring source files in this repo.
- V10: Source repo dogfoods `packages.set` -- emits own `set/` into a gitignored `.claude/skills/set/` + always-on rules, auto-synced on devShell/direnv entry. No `@`-ref duplication of skills.
- V11: Draft skills live in `set/drafts/` mirroring `set/skills/` structure. Not loaded by default -- consumer opts in via `drafts/*` categories.
- V12: Bundle files compose atomics via `@` references. Own content limited to heading and purpose statement.
- V13: Every draft file is `*.md`. Same format rules as stable skills (V6, V7).
- V14: Hardware concepts are composable templates under `concepts/hardware/<vendor>/<model>.md`. Templates describe capabilities, not roles.
- V15: Concept files may compose sub-concepts via `@` references, same pattern as skill bundles (V12).
- V16: No secrets, credentials, or PII (beyond public GitHub usernames) in any tracked file or git history.
- V17: The agent output format (`SKILL.md` + frontmatter) lives only in `lib`/`mkSkills`. No agent-specific frontmatter or naming in `set/skills/` sources (preserves C2 agent-agnostic).
- V18: Each emitted `SKILL.md` carries valid frontmatter -- `name` (slug) and `description` (one line, derived from the source skill's heading + purpose) -- followed by the unchanged agnostic markdown body.
- V19: `mkSkills` emits the Agent-Skills open-standard layout (`<skill>/SKILL.md` + supporting files), portable across agentskills.io tools. Source is single-source-of-truth; emission adds only frontmatter + placement.
- V20: `mkSkills` groups one skill folder per category; domain categories
  carry the conditional-load field (Claude `paths`, Cursor `globs`) from a
  category-globs map; cross-cutting categories (e.g. `generic`) emit to
  the always-on file (`AGENTS.md` / `CLAUDE.md` / `.claude/rules`), no
  globs.
- V21: The only agent-specific surface is the seam `{ dir, condField, alwaysOnFile }` (default Claude). The same agnostic sources build for any agent given its seam values.
- V22: `mkSetting` is the single source of truth for unified config.
  Consumer tracks a seed (`.gitignore`, `lefthook.yml`, `.envrc`, flake,
  local extensions); the rest (linter configs, dictionaries, allowlist,
  `.claude/` commands/allowances) is materialized and gitignored.
  Editable configs compose `base ⊕ local` by concatenation (V5 pattern).
- V23: Agnosticism is proven by ≥2 agent seams building the same sources (e.g. Claude + Cursor/opencode). A single seam may hide baked assumptions.

## §T Tasks

| id  | s | description                                          | cites     |
|-----|---|------------------------------------------------------|-----------|
| T1  | ~ | CLAUDE.md wires own set/ skills via direct @ refs -- superseded by T30 dogfood (emit to .claude/skills/set) | V10,I.self-wire,T30 |
| T2  | x | add README.md with usage examples for consumers      | I.mkSet,I.mkSetting |
| T3  | x | add lefthook integration in setting/integrations/    | I.flake   |
| T4  | x | add `nix flake check` CI (GitHub Actions)            | V1,C3     |
| T5  | x | expose mkDriftCheck for setting/ (not just set/)     | I.mkDriftCheck |
| T6  | x | add tests for mkSet exclude/extra/extraPaths params  | V8,V9     |
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
| T25 | . | `lib.mkSkills` emitter -- group `set/skills/<category>` into one Agent-Skills folder per category; derive name/description; `bin/sync` target-arg; fold loose top-level `<topic>.md` (cli.md) into its category | I.mkSkills,V19 |
| T26 | . | `packages.<sys>.set` = mkSkills build over all stable categories + concepts | I.set-package |
| T27 | . | category-globs map -- domain categories get the conditional-load field, cross-cutting emit to always-on file | V20 |
| T28 | . | mkSetting materializes check-configs (markdownlint/yamllint/file_size_limits/dicts/allowlist/.claude) with base⊕local composition; gitignore ignores materialized paths | V22,V5 |
| T29 | . | `compose-set` check -- agnostic md (no frontmatter injected), sync layout, gitignore ignores synced set while seed tracked | V1 |
| T30 | . | dogfood -- emit set into gitignored `.claude/skills/set/` + always-on, auto-sync on devShell entry; drop CLAUDE.md `@`-ref block | V10,I.self-wire |
| T31 | . | agnosticism proof -- a second agent seam (Cursor `globs`/`.cursor/rules` or opencode) builds the same sources | V23 |
| T33 | . | downstream wiring -- consumer repos + `nix-home-manager-claude-code` example + CI sync pre-step (materialized configs synced before hooks run) | C6,C7,V22 |
| T32 | . | repo-wide `lefthook --all-files` green: clear pre-existing markdownlint (MD040/031/032/038), editorconfig left-padding, ascii em-dash in `*.nix`, nixfmt, and nix-no-embedded-shell debt surfaced by stricter upstream nix-lefthook | C3,V6,B1 |

## §B Bugs

| id | date | cause | fix |
|----|------|-------|-----|
| B1 | 2026-06-16 | upstream nix-lefthook tightened checks; repo never revalidated, so `main` fails `lefthook run pre-commit --all-files` on pre-existing files (prose markdownlint, `*.nix` em-dashes, editorconfig padding, drift-check embedded shell) | narrow-other scoped via local glob this branch; remainder tracked as T32 |
