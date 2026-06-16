# SPEC -- set-and-setting

## §G Goal

Deterministic, agent-agnostic **set** (mindset: skills, principles,
concepts) and **setting** (environment: guardrails, standards,
infrastructure) for AI coding agent trips. Psychedelic metaphor:
set + setting → trip. Nix flake composes markdown skills and dotfile
standards into immutable, content-addressed derivations. Consumers
import as flake input, build via nix closure, sync to repo -- skills
update deterministically when upstream improves.

## §C Constraints

- C1: Pure nix -- no runtime deps beyond nixpkgs.
- C2: Agent-agnostic -- no Claude/GPT/etc specifics in set/ or setting/. Any LLM agent can consume.
- C3: Cross-platform -- aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux.
- C4: Skills are markdown only (*.md). No executable code in set/.
- C5: MIT license.
- C6: Consumers use `git+file:` or `github:` flake inputs.
- C7: Deterministic updates -- consumer `nix flake update set-and-setting` + `sync-set`/`sync-setting` + commit = reproducible upgrade path for both skills and standards.
- C8: Packaging profile-driven -- repo defines the concept superset (I.concepts); one builder `mkAgentDir` renders the concepts an `agent` profile supports. Profile is consumer-supplied; no agent format baked here. Agents share not all concepts, but repo supports every concept. Reinforces C2.

## §I Interfaces

- I.flake: `flake.nix` -- main entry. Exposes `sets`, `drafts`, `settings`, `lib.mkSet`, `lib.mkSetting`, `lib.mkDriftCheck`, `checks`.
- I.mkSet: `set/lib/mk-set.nix` -- builds `agent-set` derivation from selected categories. Args: `pkgs`, `categories`, `concepts`, `exclude`, `extra`, `extraPaths`. Outputs: `$out/skills/`, `$out/concepts/`, `$out/set.md`, `$out/bin/sync-set`.
- I.mkSetting: `setting/lib/mk-setting.nix` -- builds `agent-setting` derivation from selected standards. Args: `pkgs`, `editorconfig`, `gitattributes`, `gitignore`. Outputs: `$out/.editorconfig`, `$out/.gitattributes`, `$out/.gitignore`, `$out/bin/sync-setting`.
- I.mkDriftCheck: `lib/mk-drift-check.nix` -- compares synced set files against built derivation. Args: `pkgs`, `skillSet`, `projectRoot`, `setPath`. Fails with exit 1 on drift.
- I.mkSettingDriftCheck: `lib/mk-setting-drift-check.nix` -- compares synced dotfiles against mkSetting output. Args: `pkgs`, `settingSet`, `projectRoot`. Fails with exit 1 on drift.
- I.sync-set: CLI script in mkSet output. Copies skills+concepts+set.md to consumer repo target dir.
- I.sync-setting: CLI script in mkSetting output. Copies dotfiles to consumer repo root.
- I.sets: Attrset of raw paths to each of 15 skill category dirs.
- I.drafts: Attrset of raw paths to draft category dirs. Opt-in via `categories = [ "drafts/skill" "drafts/agent" ... ]` in mkSet.
- I.settings: Attrset of raw paths to each standard dir (editorconfig, gitattributes, gitignore).
- I.self-wire: `CLAUDE.md` -- this repo consumes own `set/` via direct `@` references. No build/sync indirection. Dogfood pattern for source repo.
- I.concepts: the concept superset -- this repo defines every agent concept first-class: `skills`, `commands`, `agents`, `memory`, `hooks`, `settings`, `mcp`. Agents support a subset; a concept the source carries is never lost, only un-rendered for agents that lack it.
- I.agentProfile: per-agent adapter profile, supplied by the consumer (e.g. `nix-home-manager-claude-code`), never baked here. Fields: `dir`, `supports` (subset of I.concepts), `version`, and per-concept render `{ path, filename, template | render }`. Only place an agent format appears.
- I.mkAgentDir: one builder -- `mkAgentDir { pkgs, agent, units }`. For each concept in `agent.supports` it renders the matching `units` (by `kind`) per the profile into `$out/<agent.dir>/`, plus `$out/bin/sync` and drift, both targeting `agent.dir`. Supersedes the `mkSkills`/`mkX` family.

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
- V10: Source repo wires own skills via direct `@` file refs -- no mkSet build, no sync, no duplication.
- V11: Draft skills live in `set/drafts/` mirroring `set/skills/` structure. Not loaded by default -- consumer opts in via `drafts/*` categories.
- V12: Bundle files compose atomics via `@` references. Own content limited to heading and purpose statement.
- V13: Every draft file is `*.md`. Same format rules as stable skills (V6, V7).
- V14: Hardware concepts are composable templates under `concepts/hardware/<vendor>/<model>.md`. Templates describe capabilities, not roles.
- V15: Concept files may compose sub-concepts via `@` references, same pattern as skill bundles (V12).
- V16: No secrets, credentials, or PII (beyond public GitHub usernames) in any tracked file or git history.
- V17: Invocable skill bundles are an output transform -- the per-agent `SKILL.md` format lives only in `lib`/`mkSkills`. No agent-specific frontmatter or naming in `set/skills/` sources (preserves C2 agent-agnostic).
- V18: Each emitted `SKILL.md` carries valid frontmatter -- `name` (slug) and `description` (one line, derived from the source skill's heading + purpose) -- followed by the unchanged agnostic markdown body.
- V19: `mkSkills` makes an explicit, curated subset invocable (workflow/command skills); the rest stay `@`-context via `mkSet`. The same source file may feed both -- single source of truth, two packagings.
- V20: Builders are profile-driven -- no concrete agent format in this repo. The consumer's per-agent module supplies the `agent` profile (I.agentProfile); the same agnostic source builds for any agent given its profile (C8).
- V21: This repo defines the concept superset (I.concepts); a profile renders only the concepts it `supports`, and an unsupported concept is a no-op -- the source still carries it, nothing lost or garbage.
- V22: Skill/command/agent KIND is agnostic content metadata (`kind: context | command | subagent`); the profile maps kind → artifact placement. A unit is not emitted as both always-on `@`-context and an invocable command -- mutually exclusive by kind, so nothing is double-loaded.
- V23: Agnosticism is proven by ≥2 profiles building the same source (e.g. claude + a second). A single profile may hide baked assumptions, so the test matrix keeps two.

## §T Tasks

| id  | s | description                                          | cites     |
|-----|---|------------------------------------------------------|-----------|
| T1  | x | CLAUDE.md wires own set/ skills via direct @ refs    | V10,I.self-wire |
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
| T25 | . | `I.concepts` -- define the concept superset (skills, commands, agents, memory, hooks, settings, mcp) first-class in this repo | C8,I.concepts |
| T26 | . | unit metadata convention (`kind`, `name`, `description`) in source -- agnostic; `kind` maps a unit to one concept, drives placement and frontmatter | V18,V22 |
| T27 | . | `I.agentProfile` schema -- `dir`, `supports` subset of concepts, `version`, per-concept `template` or `render` | C8,I.agentProfile |
| T28 | . | `lib.mkAgentDir { agent, units }` -- render supported concepts into `agent.dir` plus `bin/sync` and drift; supersedes baked mkSkills | I.mkAgentDir |
| T29 | . | Claude profile plus a second (OpenCode stub) as the agnosticism test matrix; audit schema for baked Claude assumptions | V23 |
| T30 | . | partition source units by `kind` -- invocable concepts versus `@`-context (`mkSet`), mutually exclusive, no double-load | V22 |
| T31 | . | per-agent `sync` and drift target dir from `agent.dir`; namespacing policy for flat concept dirs | I.mkDriftCheck,V20 |
| T32 | . | repo-wide `lefthook --all-files` green: clear pre-existing markdownlint (MD040/031/032/038), editorconfig left-padding, ascii em-dash in `*.nix`, nixfmt, and nix-no-embedded-shell debt surfaced by stricter upstream nix-lefthook | C3,V6,B1 |

## §B Bugs

| id | date | cause | fix |
|----|------|-------|-----|
| B1 | 2026-06-16 | upstream nix-lefthook tightened checks; repo never revalidated, so `main` fails `lefthook run pre-commit --all-files` on pre-existing files (prose markdownlint, `*.nix` em-dashes, editorconfig padding, drift-check embedded shell) | narrow-other scoped via local glob this branch; remainder tracked as T32 |
