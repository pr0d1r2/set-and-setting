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
consumer repo. `mkSet` owns the skill set -- from one agnostic source it
emits a **per-agent, multi-channel** load layout (V17): always-on core,
conditional domains, and portable `SKILL.md`. Claude first, opencode
(then others) via a per-agent profile. `@`-import is Claude-only, so
cross-agent always-on is delivered by **compiling** the Claude
`CLAUDE.md` `@`-manifest into an inline, gitignored `AGENTS.md` (V29).
All emitted artifacts are materialized and gitignored in consumers.
`mkSetting`
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
- C6: Consumers use `github:` flake inputs.
- C7: Deterministic updates -- consumer `nix flake update set-and-setting` + `sync-set`/`sync-setting` + commit = reproducible upgrade path for both skills and standards.
- C8: Composable outputs -- `packages.set` is the path-scoped-rules tree emitted from agnostic `set/` by `mkSet` (agent format only there: just `paths:` frontmatter). Consumed per-repo (sync) or home-level. Per-agent surface is one seam `{ dir, condField }`. Reinforces C2.
- C9: Three delivery paths, one emitter. (1) flake input -- pinned/
  vendored, drift-checked. (2) home-manager -- `home.file` into
  `~/.claude/rules/set`. (3) `nix run github:pr0d1r2/set-and-setting#mkSet
  [cats]` -- zero-dependency, ad-hoc, per-CWD; nix is the only dep (repo
  is public). All three share the one emitter; (3) emits at run time.

## §I Interfaces

- I.flake: `flake.nix` -- main entry. Exposes `sets`, `drafts`, `settings`, `lib.mkSet`, `lib.mkSetting`, `lib.mkDriftCheck`, `lib.mkMaterializeCheck`, `packages.set`, `packages.setting`, `checks`.
- I.mkSet: `set/lib/mk-set.nix` -- the skill-set emitter and single
  source of truth for skills. Mirrors agnostic `set/skills/` markdown 1:1
  into `<dir>/set/` as **path-scoped rules**: each source file copied
  verbatim with its category `paths:` prepended (domains narrow, core/
  universal broad). No `SKILL.md`, no derived name/description, no `@`.
  Args: `pkgs`, `categories`, `concepts`, `exclude`, `agent ? claude`
  where `agent = { dir, condField }` (default `.claude/rules/set`,
  `paths`). Outputs: the emitted rules tree + `bin/sync-set` (target-arg).
  Agent format lives only here (C2/V17).
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
  matches expectations self-derived from `categories.nix`: every category
  is a mirrored rule tree under `<dir>/set/<category>/` whose files carry
  the category `paths:` (broad for core/universal, narrow for domains);
  bodies verbatim; excluded files absent. Args: `pkgs`,
  `categories`, `exclude ? []`, `agent ? {}`. Shell logic in
  `lib/materialize-check.sh` (nix/modularity). Consumer wiring is one
  line in their `checks` output.
- I.sync-set: CLI script in mkSet output. Copies skills+concepts+set.md to consumer repo target dir.
- I.sync-setting: CLI script in mkSetting output. Copies dotfiles to consumer repo root.
- I.sets: Attrset of raw paths to each skill category dir.
- I.drafts: Attrset of raw paths to draft category dirs. Opt-in via `categories = [ "drafts/skill" "drafts/agent" ... ]` in mkSet.
- I.settings: Attrset of raw paths to each standard dir (editorconfig, gitattributes, gitignore).
- I.self-wire: `CLAUDE.md` -- this repo dogfoods `packages.set`: it emits own `set/` into a gitignored `.claude/rules/set/` (path-scoped rules), auto-synced on devShell/direnv entry. No `@`-ref duplication of skills.
- I.set-package: `packages.<sys>.set` -- a default `mkSet` build over all stable categories + concepts. Consumed home-level (`home.file.".claude/rules/set".source`) or per-repo (sync, gitignored).
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
  a b]` materializes skills into `./.claude/rules/set/` at the CWD.
  Emit happens at RUN TIME (the app carries agnostic source + emitter
  scripts; no pre-baked per-agent tree), so categories and the `--agent`
  seam are pure runtime flags. `mkSetting` materializes unified config;
  `mkSetting-init` seeds repo-specific starters (skip-if-exists);
  `bootstrap` = mkSet core + mkSetting + mkSetting-init in one. Each
  supports `--list`/`--help`/`--dry-run`.
- I.manifest: `./.claude/rules/set/.mkset.json` -- records installed categories + upstream rev + agent. Drives smart re-run (bare `mkSet` with a manifest refreshes what's installed), update detection, and `--remove`. Distinguishes mkSet-managed files from hand-added ones.
- I.agentProfile: per-agent profile (default Claude). Carries each agent's
  channel mechanisms: always-on file + import syntax, conditional
  mechanism, skill format/location. Claude: `{ alwaysOn = CLAUDE.md(@);
  conditional = .claude/rules(paths); skill = .claude/skills/<n>/SKILL.md
  }`. opencode: `{ alwaysOn = AGENTS.md(inline); conditional =
  opencode.json instructions globs; skill = SKILL.md }`. The only place an
  agent format appears (C2/V17).
- I.meta: `set/meta.nix` -- sidecar channel map (V30), keyed by source
  path/subtree, `{ channel, paths, keywords, always? }`, subtree-inherit +
  per-file override. Single source for channel assignment; feeds all
  channels. Keeps `set/` markdown agnostic.
- I.compiler: `lib/agents-md-compile.nix` (+ `.sh`) -- the `@`->`AGENTS.md`
  resolver (V29). Args: the Claude `CLAUDE.md` (or `@`-manifest). Output:
  inline `AGENTS.md`. Mirrors Claude `@`-parse rules.
- I.mechanism-tests: `tests/mechanism/` -- headless-agent probe suite
  (V31) verifying loading semantics. Each probe: marker fixture + run
  `claude -p`/opencode + assert marker behavior. Skip-if-no-binary.

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
- V10: Source repo dogfoods `packages.set` -- emits own `set/` into a gitignored `.claude/rules/set/` (path-scoped rules), auto-synced on devShell/direnv entry. No `@`-ref duplication of skills.
- V11: Draft skills live in `set/drafts/` mirroring `set/skills/` structure. Not loaded by default -- consumer opts in via `drafts/*` categories.
- V12: Bundle files compose atomics via `@` references. Own content limited to heading and purpose statement.
- V13: Every draft file is `*.md`. Same format rules as stable skills (V6, V7).
- V14: Hardware concepts are composable templates under `concepts/hardware/<vendor>/<model>.md`. Templates describe capabilities, not roles.
- V15: Concept files may compose sub-concepts via `@` references, same pattern as skill bundles (V12).
- V16: No secrets, credentials, or PII (beyond public GitHub usernames) in any tracked file or git history.
- V17: mkSet emits a **multi-channel** layout per agent (B2 -- `SKILL.md`
  under `.claude/skills/` is model-invoked, not reliably always-on; only
  `.claude/rules/` / always-on files load reliably). Channels: (a)
  always-on core, (b) conditional domains, (c) portable `SKILL.md`. The
  sidecar meta map (I.meta), not the source markdown, declares each
  file's channel. Sources stay agnostic (C2).
- V18: Always-on core (channel a) -- the few categories that must apply
  every turn (`generic`, `git`) load unconditionally. Authored as the
  Claude `CLAUDE.md` `@`-manifest, compiled to an inline gitignored
  `AGENTS.md` (V29) for opencode/others. Keep it small (initial context
  is the enemy).
- V19: Conditional domains (channel b) load only when relevant, via each
  agent's mechanism: Claude path-scoped `.claude/rules/` (`paths`);
  opencode `opencode.json` `instructions` globs. Deterministic on the
  Claude side (verified: path-rules load on matching-file read).
- V20: Portable skills (channel c) -- `SKILL.md` (agentskills.io) for
  `/`-invocability and cross-agent reach. On Claude, deduped from the
  rule channel via `disable-model-invocation: true` so the same content
  never double-loads (rule is the loader; SKILL.md is `/`-invoke +
  cross-agent only).
- V21: The agent-specific surface is a per-agent **profile** (I.agentProfile),
  not one path/field: it carries each agent's channel mechanisms (Claude:
  `CLAUDE.md`+`@`, `.claude/rules`+`paths`, `SKILL.md`; opencode:
  `AGENTS.md`, `opencode.json` instructions, `SKILL.md`). Default Claude.
- V22: `mkSetting` is the single source of truth for unified config, with
  two output kinds: seed/init (repo-specific starters -- `.gitattributes`,
  `.editorconfig`, `file_size_limits.yml`, `.narrow-language-*.dic`,
  allowlist -- scaffolded once, then tracked & repo-owned) and
  materialized (unified configs -- `.markdownlint.yml`, `.yamllint.yml`,
  `.claude/` commands/allowances -- always synced & gitignored). Only
  truly unified, non-repo-specific config is materialized.
- V23: Agnosticism is proven by 2 agent seams building the same sources -- Claude (default) + opencode. A single seam may hide baked assumptions. Other agents (Cursor, Codex, Gemini CLI, Copilot, Amp, ...) are a future extension list, not required now.
- V24: Loading is via path-specific rules (deterministic on matching-file
  read), not the model-invoked SKILL.md catalog. No skill-listing budget
  to dilute, so granularity is free: mirror the source `<topic>.md` +
  `<topic>/<aspect>.md` tree 1:1 as rule files. Verified vs docs.
- V25: Each source file becomes one rule file in the mirror, body copied
  verbatim + its category `paths` prepended. No concatenation, no
  `SKILL.md`, no supporting-file linking, no `@`. Topics/aspects with the
  same category share the same globs and load together when matched.
- V26: Clean-replace per category -- installing a `<cat>` does
  `rm -rf .claude/rules/set/<cat>` (and its sibling `<cat>.md`) then
  writes fresh (removed files vanish; deterministic, exact upstream
  state). Scoped to the `set/` namespace under `.claude/rules/`; never
  blanket-removes a shared dir. Unrequested categories untouched.
  Exception: `mkSetting-init` seeds skip-if-exists (repo-owned).
- V27: Selection -- core (`generic`+`git`) is always pulled; domains and other cross-cutting are opt-in. No args => core only + a notice listing selectable categories. `--all` and `--all-except a b ...` available. Unknown category => error + list (fail with guidance).
- V28: Run-time emit for the `nix run` path -- the installer ships agnostic source + emitter scripts and emits into CWD at run time; one emitter serves all three delivery paths (C9). The same `mk-set.sh`/`emit-skill.sh` produce the flake-input, home-manager, and `nix run` outputs.
- V29: The `@`->`AGENTS.md` compiler recursively resolves the Claude
  `CLAUDE.md` `@`-manifest and inlines it into a gitignored `AGENTS.md`,
  mirroring Claude's `@`-rules for fidelity (skip `@` in code spans/fences,
  strip block-level HTML comments, max 4 hops). Compiled `AGENTS.md` ==
  what Claude loads. `@` stays a Claude-internal authoring convenience;
  cross-agent always-on is delivered inline.
- V30: The sidecar meta map `set/meta.nix` (data, not in-source
  frontmatter -- C2/V17 hold) is keyed by source path/subtree and carries
  `{ channel, paths, keywords, always? }` with subtree-inheritance + per-
  file override + category fallback. It is the single source for channel
  assignment and feeds all channels (paths -> rule globs + SKILL.md
  `paths`; keywords -> SKILL.md `description`/`when_to_use`).
- V31: Loading semantics are TESTED, not assumed (I.mechanism-tests): a
  probe suite drives headless `claude -p` (and opencode) on marker
  fixtures to confirm autoload, write-trigger, `@`-recursion, `@`-in-rules,
  symlink load, and `disable-model-invocation`. Every channel decision
  cites a passing probe. Integration suite (needs agent binary + auth);
  skip-if-absent, not hermetic CI.
- V32: T50 probes empirically confirm Claude loading semantics
  (2026-06-26, query-style marker + majority vote over nondeterministic
  runs): (a) `.claude/skills/` `SKILL.md` model-invokes on a matching
  prompt -- NOT always-on (narrows B2: description-gated, not broken);
  (b) path-less `.claude/rules` load always; (c) `@`-import recurses
  through `CLAUDE.md` (V29 compiler viable); (d) `@` expands inside a
  rule file (DRY rule-refs viable -- T48/T49); (e) symlinked rule loads;
  (f) `disable-model-invocation: true` blocks autoload (dedup V20 works).
  Open (G2): path-scoped rule read-vs-write trigger -- verdict flips even
  voted, not reliably probe-observable (mechanism is real; path-scoped
  rules load live in this repo's dogfood). Design defensively --
  write-critical rules -> broad/always-on globs.

## §T Tasks

| id  | s | description                                          | cites     |
|-----|---|------------------------------------------------------|-----------|
| T1  | ~ | CLAUDE.md wires own set/ skills via direct @ refs -- superseded by T30 dogfood (emit to .claude/rules/set) | V10,I.self-wire,T30 |
| T2  | x | add README.md with usage examples for consumers      | I.mkSet,I.mkSetting |
| T3  | x | add lefthook integration in setting/integrations/    | I.flake   |
| T4  | x | add `nix flake check` CI (GitHub Actions)            | V1,C3     |
| T5  | x | expose mkDriftCheck for setting/ (not just set/)     | I.mkDriftCheck |
| T6  | x | add tests for mkSet exclude param                    | V8        |
| T7  | x | switch consumer repos from git+file: to github: URLs | C6        |
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
| T30 | x | dogfood -- emit set into gitignored `.claude/rules/set/` + always-on, auto-sync on devShell entry; drop CLAUDE.md `@`-ref block | V10,I.self-wire |
| T31 | . | agnosticism proof -- the opencode seam (`AGENTS.md` always-on; opencode skill dir + conditional field) builds the same sources as Claude | V23 |
| T33 | . | downstream wiring -- consumer repos + `nix-home-manager-claude-code` example + CI sync pre-step (materialized configs synced before hooks run) | C6,C7,V22 |
| T34 | . | future: additional agent seams (Cursor `globs`/`.cursor/rules`, Codex, Gemini CLI, Copilot, Amp, ...) -- extension list, not built now | V23,C2 |
| T32 | x | repo-wide `lefthook --all-files` green: cleared markdownlint, editorconfig, ascii, nixfmt, nix-no-embedded-shell debt + narrow-language baseline-freeze; CI now runs the full lefthook suite via nix-lefthook-ci-action (only commit-gate `changelog-touched` excluded) | C3,V6,B1 |
| T35 | x | refactor mkSet emission to facets-as-linked-files -- `<cat>/SKILL.md` (frontmatter + body that markdown-links raw cloned facets) instead of concatenation; clean-replace per category | I.mkSet,V24,V25,V26 |
| T36 | x | `apps.<sys>.{mkSet,mkSetting,mkSetting-init,bootstrap}` runnable installers -- run-time emit into CWD; selection (core always, domains opt-in, `--all`/`--all-except`, default=core+notice); `--list`/`--help`/`--dry-run`; fail-with-guidance | I.apps,V27,V28,C9 |
| T37 | x | install manifest `.claude/rules/set/.mkset.json` -- smart bare re-run (refresh installed), update detection, `--remove` | I.manifest |
| T38 | x | README headline -- document `nix run github:pr0d1r2/set-and-setting#mkSet` one-command skill materialization as the first-impression WOW (single command, zero deps); cover all three delivery paths (C9) | I.apps,C9 |
| T39 | x | `--agent` seam passthrough in installers (opencode target); ties the agnosticism proof | V21,V28,T31 |
| T40 | . | rework mkSet emission to a path-scoped rules mirror -- drop SKILL.md/frontmatter/facets-links; copy each source file verbatim with its category `paths:` prepended; emit to `<dir>/set/`. Supersedes T25/T35 | I.mkSet,V17,V18,V19,B2 |
| T41 | . | complete category-globs map -- every category has `paths` (domains narrow e.g. `**/*.nix`; core/universal broad e.g. `generic`->`**/*`); nothing path-less | V20 |
| T42 | . | retarget apps + `mkMaterializeCheck` + sync to `.claude/rules/set`; assert rules layout (paths + verbatim body), not SKILL.md | I.apps,I.mkMaterializeCheck,V24,V25 |
| T43 | . | README: update WOW + delivery docs -- skills materialize into `.claude/rules/set/` (not `.claude/skills/`) | I.apps,C9 |
| T44 | . | re-dogfood -- emit own set into gitignored `.claude/rules/set/`; update `.gitignore`/`.envrc` | V10,I.self-wire |
| T40 | x | `lib.mkMaterializeCheck` -- deterministic consumer-side test for skill materialization; self-derives expectations from `categories.nix`; bats coverage + `checks` entries | I.mkMaterializeCheck,V20,V25 |
| T50 | x | **GATE** mechanism test suite (`tests/mechanism/`) -- headless `claude -p`/opencode probes confirming autoload, write-trigger, `@`-recursion, `@`-in-rules, symlink load, `disable-model-invocation`; skip-if-no-binary. Run BEFORE committing content to a channel | I.mechanism-tests,V31,B3 |
| T45 | x | sidecar meta map `set/meta.nix` -- `{ channel, paths, keywords, always? }` keyed by path, subtree-inherit + per-file override + category fallback | I.meta,V30 |
| T46 | x | per-agent profile (`I.agentProfile`) -- Claude + opencode channel mechanisms (always-on file/import, conditional mechanism, skill format) | I.agentProfile,V21 |
| T47 | ~ | multi-channel emitter -- mkSet emits 3 channels per profile from the meta map: always-on core, conditional domains, portable `SKILL.md`. Supersedes the rules-only T40-T44 emit | I.mkSet,V17,V18,V19,V20 |
| T48 | . | `@`->`AGENTS.md` compiler (`lib/agents-md-compile`) -- recursive inline, Claude `@`-parse fidelity | I.compiler,V29 |
| T49 | . | dedup -- emit `SKILL.md` with `disable-model-invocation: true` on Claude so the rule is the sole loader (no double-load) | V20 |
| T51 | . | opencode profile + agnosticism proof -- build the same sources for opencode (AGENTS.md + opencode.json); ties T31 | V21,V23,T31 |
| T52 | . | README -- document the multi-channel model + three delivery paths; keep the one-command WOW | I.apps,C9 |

## §B Bugs

| id | date | cause | fix |
|----|------|-------|-----|
| B1 | 2026-06-16 | upstream nix-lefthook tightened checks; repo never revalidated, so `main` fails `lefthook run pre-commit --all-files` on pre-existing files (prose markdownlint, `*.nix` em-dashes, editorconfig padding, drift-check embedded shell) | fixed: narrow-other glob (#10), drift+embedded-shell extracted (#13), markdownlint/editorconfig/narrow cleared + CI runs lefthook (T32) |
| B2 | 2026-06-18 | emitted `SKILL.md` under `.claude/skills/` is not always-on -- skills are model-invoked (description-indexed, body on-demand), loading only when a prompt matches their description; only `.claude/rules/` loads unconditionally (path-less at launch; path-scoped on matching-file read). The shipped always-on SKILL.md model (T25/T35-T39) thus never autoloaded -- description-gated, NOT broken (T50 probes confirm, V32). | redesign rules-only: drop SKILL.md, mirror source as `.claude/rules/set/` with `paths` everywhere (T40-T44). Verified vs Claude Code memory/skills docs; since superseded by B3 multi-channel. |
| B3 | 2026-06-26 | rules-only (B2 fix) over-corrected: `.claude/rules` is Claude-proprietary (reduces agnosticism, C2/V23), and `@`-import is Claude-only (opencode/Codex/AGENTS.md spec have no `@` -- opencode uses `opencode.json` instructions globs or Read-on-demand). So a single mechanism can't be both reliable-on-Claude and portable. | best-of-both multi-channel (V17-V21): per-agent profile + sidecar meta + `SKILL.md` (portable) + Claude rules (reliable) + `@`->`AGENTS.md` compiler (portable always-on) + dedup; gated by the mechanism test suite (T50). Verified vs opencode/Codex docs. |
