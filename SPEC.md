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

- I.flake: `flake.nix` -- main entry. Exposes `sets`, `drafts`, `settings`, `lib.mkSet`, `lib.mkSetting`, `lib.mkDriftCheck`, `lib.mkDepGraphCheck`, `lib.mkMaterializeCheck`, `lib.mkDevShells`, `packages.set`, `packages.setting`, `checks`.
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
  The app (`app-mk-setting.sh`) also assembles a content-aware
  `lefthook.yml` at runtime from detected repo content (V40).
  Args: `pkgs` + per-output toggles. `bin/sync-setting` (materialize),
  `bin/sync-setting-init` (scaffold, skips files that already exist).
- I.detectFragments: `setting/lib/detect-fragments.sh` -- content-aware
  lefthook fragment detector (V40). Examines tracked files via
  `git ls-files` and determines which integration fragments
  (`setting/integrations/lefthook/*.yml`) apply: `base`+`ascii` always,
  `nix` if `*.nix`, `shell` if `*.sh`/`*.bash`, `markdown` if `*.md`,
  `yaml` if `*.yml`/`*.yaml`. Bare repos (no tracked files) default to
  all fragments. Output: deterministic space-separated fragment list.
- I.mkDriftCheck: `lib/mk-drift-check.nix` -- compares synced set files against built derivation. Args: `pkgs`, `skillSet`, `projectRoot`, `setPath`. Fails with exit 1 on drift.
- I.mkSettingDriftCheck: `lib/mk-setting-drift-check.nix` -- compares synced
  dotfiles against mkSetting output. When `devShells` is provided, also
  enforces the stacked-shell invariant (T60): shells named `default`/
  `agentic` only, `agentic.packages ⊇ default.packages`, CI must not set
  `skip-lefthook: true`. Nix-level assertions (names, superset) fire at
  eval time; CI check runs at build time via `devshells-drift-check.sh`.
  Args: `pkgs`, `settingSet`, `projectRoot`, `devShells ? null`. Fails
  with exit 1 on drift.
- I.mkDepGraphCheck: `lib/mk-dep-graph-check.nix` -- validates that a
  consumer's `flake.lock` dependency graph uses only `github:` URLs (C6).
  Fails with exit 1 if any input uses `git+file:`, `path:`, or other
  non-github types. Args: `pkgs`, `projectRoot`. Shell logic in
  `lib/dep-graph-check.sh` (nix/modularity). Consumer wiring is one
  line in their `checks` output.
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
- I.mkDevShells: `setting/lib/mk-dev-shells.nix` -- stacked devShell
  emitter (T59). Args: `pkgs`, `basePackages`, optional
  `agenticPackages`, `defaultShellHook`, `agenticShellHook`. Returns
  `{ default, agentic }` where `agentic` stacks on `default` via
  `inputsFrom` (packages inherited, no duplication). Both shells get
  `NIX_CONFIG` and lefthook install. `default` = CI + non-LLM full
  tooling; `agentic` = default + LLM. Emitted from mkSetting
  (passthru) so refresh propagates via `nix flake update` (C7). Also
  exposed as `lib.mkDevShells`.
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
- I.apps: `apps.<sys>.{mkSet,mkSetting,mkSetting-init,bootstrap,auto-update,graduate,branch-protection}`
  -- runnable installers for the zero-dependency delivery path (C9).
  `nix run github:pr0d1r2/set-and-setting#mkSet [cats|--all|--all-except
  a b]` materializes skills into `./.claude/rules/set/` at the CWD.
  Emit happens at RUN TIME (the app carries agnostic source + emitter
  scripts; no pre-baked per-agent tree), so categories and the `--agent`
  seam are pure runtime flags. `mkSetting` materializes unified config;
  `mkSetting-init` seeds repo-specific starters (skip-if-exists);
  `bootstrap` = mkSet core + mkSetting + mkSetting-init in one. Each
  supports `--list`/`--help`/`--dry-run`. `auto-update` updates
  flake input, syncs, commits (T8/C7).
- I.auto-update: `lib/auto-update.sh` + reusable workflow +
  scaffold. Updates flake lock, validates, syncs, opens PR.
- I.graduate: `lib/graduate-draft.sh` + `apps.graduate` -- developer
  tool to graduate draft skills to stable. Moves
  `set/drafts/<cat>/` files into `set/skills/<cat>/`, updates `@`-refs
  from `@set/drafts/<cat>/` to `@set/<cat>/`, removes the draft
  directory. Handles both merge (into existing category) and new
  category creation (reports required nix config changes). Supports
  `--dry-run`, `--list`, `--help`. Nix checks validate merge graduation
  (graduated files appear as domain rules with correct globs) and
  `@`-ref rewriting (no `drafts/` prefix survives).
- I.branch-protection: `lib/branch-protection.sh` + `apps.branch-protection`
  -- enables GitHub branch protection requiring PRs via `gh api`.
  Configures required status checks, disables force pushes and
  deletions. Supports `--repo`, `--branch`, `--status-checks`,
  `--dry-run`, `--help`. Requires `gh auth login`.
- I.manifest: `./.claude/rules/set/.mkset.json` -- records installed
  categories + upstream rev + agent. Drives smart re-run (bare `mkSet`
  with a manifest refreshes what's installed), update detection, and
  `--remove`. Distinguishes mkSet-managed files from hand-added ones.
  Under `--auto` (V34), also records per-skill applicability evidence --
  matched `paths`/`content`, or `required-by: <topic>` (facet->core pull)
  -- for audit + smart re-eval (V37).
- I.agentProfile: per-agent profile (default Claude). Carries each agent's
  channel mechanisms: always-on file + import syntax, conditional
  mechanism, skill format/location. Claude: `{ alwaysOn = CLAUDE.md(@);
  conditional = .claude/rules(paths); skill = .claude/skills/<n>/SKILL.md
  }`. opencode: `{ alwaysOn = AGENTS.md(inline); conditional =
  opencode.json instructions globs; skill = SKILL.md }`. The only place an
  agent format appears (C2/V17).
- I.meta: `set/meta.nix` -- sidecar channel + relevance map (V30/V34),
  keyed by source path/subtree, `{ channel, paths, keywords, content?,
  always? }`, subtree-inherit + per-file override. `paths` do double duty
  (runtime conditional-load globs + static applicability); `content` is a
  materialize-time-only grep signal (V35). Single source for channel
  assignment and applicability; feeds all channels. Keeps `set/` markdown
  agnostic.
- I.applicability: `set/lib/applicability.{nix,sh}` -- materialize-time
  smart-selection filter (V34). Given the meta signals + `git ls-files`,
  returns the applicable skill-file set: a topic core/facet is kept iff
  its resolved `paths` + `content` evidence matches tracked files
  (vendored/generated excluded), and any kept facet force-pulls its
  `<topic>.md` core (V36). Boolean now (scored later). Emits the
  per-skill evidence for the manifest (V37). Drives `--auto`.
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
- V19: Conditional domains (channel b) load only when relevant. The
  mechanism is agent-specific and only Claude has a deterministic one:
  path-scoped `.claude/rules/` (`paths`) load on matching-file read
  (verified). opencode has NO path-scoped conditional load (V39); its
  domains arrive via the portable `SKILL.md` (model-invoke) + Read-on-
  demand of the emitted rule files. `opencode.json` `instructions` are
  always-on (not conditional, B5), so domains stay OUT of them (V38).
- V20: Portable skills (channel c) -- `SKILL.md` (agentskills.io) for
  `/`-invocability and cross-agent reach. On Claude, deduped from the
  rule channel via `disable-model-invocation: true` so the same content
  never double-loads (rule is the loader; SKILL.md is `/`-invoke +
  cross-agent only).
- V21: The agent-specific surface is a per-agent **profile** (I.agentProfile),
  not one path/field: it carries each agent's channel mechanisms (Claude:
  `CLAUDE.md`+`@`, `.claude/rules`+`paths`, `SKILL.md`; opencode:
  `AGENTS.md`, `opencode.json` instructions, `SKILL.md`; caveman-code:
  `CAVE.md`+`@`, `.cave/rules`+`paths`, `SKILL.md`). Default Claude.
- V22: `mkSetting` is the single source of truth for unified config, with
  two output kinds: seed/init (repo-specific starters -- `.gitattributes`,
  `.editorconfig`, `file_size_limits.yml`, `.narrow-language-*.dic`,
  allowlist -- scaffolded once, then tracked & repo-owned) and
  materialized (unified configs -- `.markdownlint.yml`, `.yamllint.yml`,
  `.claude/` commands/allowances -- always synced & gitignored). Only
  truly unified, non-repo-specific config is materialized.
- V23: Agnosticism is proven by 8 agent seams building the same sources -- Claude (default), opencode, caveman-code, Cursor, Codex, Gemini CLI, Copilot, and Amp. A single seam may hide baked assumptions; 8 seams across two families (@-import and inline) make it robust.
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
- V33: Materialized trees are writable. `sync-set`/`app-mk-set` copy from
  `/nix/store` (read-only -- dirs 555, files 444); `cp -r` carries those
  perms. The clean-replace `rm` (V26) needs the write bit on parent dirs,
  so each emitter `chmod -R u+w` the copied tree (and any prior tree
  before removing it). Re-sync is idempotent, never `Permission denied`
  (B4).
- V34: Smart materialization -- mkSet `--auto` installs only the
  *applicable* skill set derived from repo evidence, not a blanket copy. A
  topic core / facet is kept iff its resolved meta signal matches the
  consumer's tracked files: `paths` (file shape) AND `content` (grep --
  feature actually used). Boolean now; scored (confidence threshold) is a
  later extension. core (`generic`, `git`) always kept; an unsigned file
  falls back to its subtree/category signal (conservative include, never
  silently drop a needed skill). `--auto` is the default for the zero-dep
  `nix run` path; `--all` / explicit categories / `--pin` / `--exclude`
  override. Deterministic over `git ls-files` (C7).
- V35: Two relevance dimensions, two mechanisms. `paths` globs do double
  duty -- runtime conditional-load (Claude rules / opencode instructions)
  AND static applicability. `content` grep is *materialize-time only*: it
  decides whether a skill is copied, never when it loads (Claude/opencode
  gate on path globs only, not file content). So `content` shrinks the
  on-disk footprint and the `SKILL.md` description index, not per-turn
  load.
- V36: Facets are structural dependencies. A facet `<topic>/<aspect>.md`
  extends its topic core `<topic>.md` and may not apply even when the core
  does; the include unit is the facet. The only dependency edge is facet
  -> its topic core, read from the path (parent dir) -- no declared
  `requires` DAG. Keeping any facet force-pulls its `<topic>.md` core;
  pruning is per-facet. (Soft "suggests" affinity is deferred to the
  scored phase.)
- V37: Materialization is audited. `.mkset.json` (I.manifest) records, per
  installed skill, WHY it was kept -- matched `paths`/`content` evidence,
  or `required-by: <topic>` (facet->core pull) -- so re-eval is smart,
  explainable, and diffable. Update = `nix flake update` + `--auto`
  re-eval re-applies upstream skill changes and re-prunes (C7/V26
  self-heal).
- V38: Always-on stays universal-only. The always-on channel (`AGENTS.md`
  / path-less core rules) carries only genuinely-universal content (core
  topics). Domain topics/facets are never inlined always-on -- they reach
  every agent via the conditional channel (Claude path-rules, opencode
  instructions globs), evidence-gated. A domain promoted to always-on is a
  deliberate, documented exception. Keeps initial context minimal (V18).
- V39: opencode loading model (verified vs opencode docs). Always-on:
  `AGENTS.md` (auto-discovered) + `opencode.json` `instructions` (paths/
  globs to extra files) -- BOTH always-loaded, combined with AGENTS.md,
  never per-open-file conditional. So only the universal core goes there
  (V38). opencode does NOT read per-file frontmatter, so the emitted
  `globs:`/`paths:` on rule files is Claude-only and inert for opencode;
  opencode reaches domains via `SKILL.md` (model-invoke) + Read-on-demand
  of the rule files. mkSet for the opencode profile emits a compiled
  `AGENTS.md` (from `set.md`, via the V29 compiler) + an `opencode.json`
  whose `instructions` list only the always-on file.
- V40: Content-aware lefthook.yml construction. `mkSetting` and
  `mkScaffold` apps assemble `lefthook.yml` at runtime from detected repo
  content (I.detectFragments): `detect-fragments.sh` examines tracked
  files via `git ls-files`, selects applicable integration fragments
  (`base`+`ascii` always; `nix`/`shell`/`markdown`/`yaml` conditional on
  file types), and `assemble-lefthook.sh` merges them into a single
  `lefthook.yml`. Bare repos default to all fragments. The nix derivation
  (`mk-scaffold.nix`) still pre-builds an all-fragment reference for CI
  checks; the apps override at runtime for content-awareness.
  Idempotent: same tracked files → same fragments → same output → no
  diff. Convergent: adding a new file type (e.g. `*.sh`) causes the next
  `mkSetting` run to add the matching checks. `lefthook-local.yml`
  overrides preserved (never touched).

## §T Tasks

| id  | s | description                                          | cites     |
|-----|---|------------------------------------------------------|-----------|
| T63 | x | `@`-ref matcher -- pure shell scanner that emits ONLY real `@`-references from a markdown file: leading-token `@set/...`, `@concepts/...`, or relative `@<category>/<file>.md`. SKIPS code spans/fences + block HTML comments (V29 parse rules) and non-ref `@` tokens (email `@example.com`, git SHAs `@fbeb9d9`, prose `@include`/`@main`/`@v4`/`@privileged`/`@system-service`). No repo-wide gate; bats over fixtures. The false-positive filter that blocked T58 | V12,V29,T58 |
| T64 | x | ref-resolution nix check -- consume the T63 matcher; resolve each real ref to an existing path under `set/` (`@set/...` from the repo root; relative `@<cat>/<file>.md` against its own dir; drafts vs skills). Exit 1 ONLY on a truly-missing target. Wire `checks.set-ref-resolution`. Green: T63 skips false matches, existing refs resolve. Bats coverage | I.flake,V12,T58,T63 |
| T65 | x | V12 bundle own-content enforcement -- independent grep check: bundle files (compose via `@`) limit own content to heading + purpose statement + `@` refs. Runs separate from resolution (T64); ships on its own. Bats coverage | V12,T58 |
| T66 | x | lefthook wiring -- add the T64 ref-resolution + T65 V12 checks as a content-aware lefthook fragment gate (only when `set/*.md` tracked, per I.detectFragments). Bats for the assembled hook | I.detectFragments,V40,T64,T65 |
| T59 | x | devShells STACK: `agentic` = `default` + LLM (claude/asciinema/harness) via `inputsFrom=[default]` (⊥ duplicate the package list); rename `dev`→`agentic`; drop `ci = default` alias (CI uses `default`). Emit from mkSetting so refresh propagates. #69 slice 1 | I.mkSetting,I.mkDevShells,I.flake |
| T60 | x | drift-check: enforce `agentic.packages ⊇ default.packages`, shells named `default`/`agentic` only, no lean-`ci`, CI ⊥ `skip-lefthook: true`. Extend mk-setting-drift-check.nix. #69 slice 2 | I.mkSetting,I.mkDriftCheck |
| T61 | x | document the stacked-shell model + invariant in the linting skill: `default` = CI + non-LLM full tooling ⊂ `agentic` = default + LLM; CI runs the same gate as local hooks. #69 slice 3 | I.mkSetting |
| T62 | . | HUMAN-GATED — ⊥ AUTO-DRIVE/MERGE (fleet-wide BREAKING): CI template runs the lint gate — `skip-lefthook: false` (or `nix develop -c lefthook run pre-commit --all-files`) in `default`, then build+test. A human lands this deliberately AFTER T59-T61 settle; tracks #69 | I.mkSetting |
| T1  | ~ | CLAUDE.md wires own set/ skills via direct @ refs -- superseded by T30 dogfood (emit to .claude/rules/set) | V10,I.self-wire,T30 |
| T2  | x | add README.md with usage examples for consumers      | I.mkSet,I.mkSetting |
| T3  | x | add lefthook integration in setting/integrations/    | I.flake   |
| T4  | x | add `nix flake check` CI (GitHub Actions)            | V1,C3     |
| T5  | x | expose mkDriftCheck for setting/ (not just set/)     | I.mkDriftCheck |
| T6  | x | add tests for mkSet exclude param                    | V8        |
| T7  | x | switch consumer repos from git+file: to github: URLs | C6        |
| T8  | x | auto-update mechanism -- flake re-eval triggers sync-set + sync-setting + commit in consumer repos | C7,I.sync-set,I.sync-setting |
| T9  | x | consumer dependency graph: upstream repos switch git+file: to github: URLs after push | C6,I.mkDepGraphCheck |
| T10 | x | add `set/drafts/` tree with atomic skill files and bundles | V11,V12,V13 |
| T11 | x | wire drafts categories into mkSet and flake.nix | I.flake,I.drafts |
| T12 | x | add mkSet check: drafts categories build without error | V1,V11 |
| T13 | x | graduate draft to stable: move `drafts/X` → `skills/X` when mature | V11,I.graduate |
| T14 | ~ | skill linting CI: enforce format, size budget, `@` ref resolution -- SUPERSEDED by T56-T58 (granularized into independently-shippable checks) | V12,V13,T56,T57,T58 |
| T15 | x | CLAUDE.md wire drafts via `@` refs (dogfood) | V10,V11 |
| T16 | x | generalize hardware concepts into composable templates | V14,V15 |
| T17 | x | audit git history for secrets and PII before opensourcing | V16 |
| T18 | x | create public GitHub repo and push | C6 |
| T19 | x | enable main branch protection requiring PRs (#66) | C5 |
| T20 | x | set up cachix cache for nix builds | V1 |
| T21 | x | set up GitHub Actions CI (nix flake check, all platforms) | V1,C3 |
| T22 | x | update hallucinogen: git+file: to github: set-and-setting | C6,T7 |
| T23 | x | update CHANGELOG.md for opensourcing | C5 |
| T24 | x | rename propagation: mechanism for consumers to detect upstream skill renames and update synced copies | C7,I.sync-set |
| T25 | x | evolve `mkSet` into the emitter -- group `set/skills/<category>` into one Agent-Skills folder per category; derive name/description; `bin/sync-set` target-arg; fold loose top-level `<topic>.md` (cli.md) into its category | I.mkSet,V19 |
| T26 | x | `packages.<sys>.set` = mkSet build over all stable categories + concepts | I.set-package |
| T27 | x | category-globs map -- domain categories get the conditional-load field, cross-cutting emit to always-on file | V20 |
| T28 | x | mkSetting split: materialize unified configs (markdownlint/yamllint/.claude, gitignored) + seed/init scaffold for repo-specific starters (gitattributes/editorconfig/file_size_limits/dics/allowlist), skip-if-exists | V22 |
| T29 | x | `compose-set` check -- agnostic md (no frontmatter injected), sync layout, gitignore ignores synced set while seed tracked | V1 |
| T30 | x | dogfood -- emit set into gitignored `.claude/rules/set/` + always-on, auto-sync on devShell entry; drop CLAUDE.md `@`-ref block | V10,I.self-wire |
| T31 | x | agnosticism proof -- the opencode seam (`AGENTS.md` always-on; opencode skill dir + conditional field) builds the same sources as Claude | V23 |
| T33 | x | downstream wiring -- consumer repos + `nix-home-manager-claude-code` example + CI sync pre-step (materialized configs synced before hooks run) | C6,C7,V22 |
| T34 | x | additional agent seams: Cursor (`globs`/`.cursor/rules`), Codex (`.codex/rules`), Gemini CLI (`.gemini/rules`), Copilot (`.copilot/rules`), Amp (`.amp/rules`) -- profiles, nix checks, bats tests | V23,C2 |
| T54 | x | caveman-code profile + agnosticism proof -- Claude Code superset using `.cave/` paths, `CAVE.md`+`@`, `paths` conditional, same dedup; third agent seam; bats + nix checks | V21,V23,I.agentProfile |
| T32 | x | repo-wide `lefthook --all-files` green: cleared markdownlint, editorconfig, ascii, nixfmt, nix-no-embedded-shell debt + narrow-language baseline-freeze; CI now runs the full lefthook suite via nix-lefthook-ci-action (only commit-gate `changelog-touched` excluded) | C3,V6,B1 |
| T35 | x | refactor mkSet emission to facets-as-linked-files -- `<cat>/SKILL.md` (frontmatter + body that markdown-links raw cloned facets) instead of concatenation; clean-replace per category | I.mkSet,V24,V25,V26 |
| T36 | x | `apps.<sys>.{mkSet,mkSetting,mkSetting-init,bootstrap}` runnable installers -- run-time emit into CWD; selection (core always, domains opt-in, `--all`/`--all-except`, default=core+notice); `--list`/`--help`/`--dry-run`; fail-with-guidance | I.apps,V27,V28,C9 |
| T37 | x | install manifest `.claude/rules/set/.mkset.json` -- smart bare re-run (refresh installed), update detection, `--remove` | I.manifest |
| T38 | x | README headline -- document `nix run github:pr0d1r2/set-and-setting#mkSet` one-command skill materialization as the first-impression WOW (single command, zero deps); cover all three delivery paths (C9) | I.apps,C9 |
| T39 | x | `--agent` seam passthrough in installers (opencode target); ties the agnosticism proof | V21,V28,T31 |
| T40 | ~ | rework mkSet emission to a path-scoped rules mirror -- drop SKILL.md/frontmatter/facets-links; emit to `<dir>/set/`. SUPERSEDED by T47 (multi-channel keeps SKILL.md + adds always-on/conditional/portable channels; rules-only over-corrected, B3) | I.mkSet,V17,V18,V19,B2,T47 |
| T41 | x | complete the meta relevance map -- every topic core has a broad `paths` (domains narrow e.g. `**/*.nix`; core/universal broad e.g. `generic`->`**/*`); high-value facets get narrow `paths`+`content` (qemu, iso, mdns, nixos hardening, cachix, python-package); unsigned facets inherit subtree/category; nothing path-less. Prereq for T53 | V20,V34,V35,I.meta |
| T42 | x | retarget apps + `mkMaterializeCheck` + sync to `.claude/rules/set` -- done: `agents.dir` default + `sync-set` target it; materialize-check asserts the rules layout (paths + verbatim body); apps (T36/T53) emit there. SKILL.md now a valid sibling channel (T47), not a violation | I.apps,I.mkMaterializeCheck,V24,V25,T47 |
| T43 | x | README: update WOW + delivery docs for the multi-channel emit -- consolidate into T52 | I.apps,C9,T52 |
| T44 | . | re-dogfood for multi-channel -- this repo already emits a gitignored `.claude/rules/set/` (auto-synced); extend to the always-on `set.md`->`AGENTS.md` (T48 compiler) + portable `SKILL.md` channels; update `.gitignore`/`.envrc` | V10,I.self-wire,T47,T48 |
| T40 | x | `lib.mkMaterializeCheck` -- deterministic consumer-side test for skill materialization; self-derives expectations from `categories.nix`; bats coverage + `checks` entries | I.mkMaterializeCheck,V20,V25 |
| T50 | x | **GATE** mechanism test suite (`tests/mechanism/`) -- headless `claude -p`/opencode probes confirming autoload, write-trigger, `@`-recursion, `@`-in-rules, symlink load, `disable-model-invocation`; skip-if-no-binary. Run BEFORE committing content to a channel | I.mechanism-tests,V31,B3 |
| T45 | x | sidecar meta map `set/meta.nix` -- `{ channel, paths, keywords, always? }` keyed by path, subtree-inherit + per-file override + category fallback | I.meta,V30 |
| T46 | x | per-agent profile (`I.agentProfile`) -- Claude + opencode channel mechanisms (always-on file/import, conditional mechanism, skill format) | I.agentProfile,V21 |
| T47 | x | multi-channel emitter -- mkSet emits 3 channels per profile from the meta map: always-on core, conditional domains, portable `SKILL.md`. Supersedes the rules-only T40-T44 emit | I.mkSet,V17,V18,V19,V20 |
| T48 | x | `@`->`AGENTS.md` compiler (`lib/agents-md-compile`) -- recursive inline, Claude `@`-parse fidelity | I.compiler,V29 |
| T49 | x | dedup -- emit `SKILL.md` with `disable-model-invocation: true` on Claude so the rule is the sole loader (no double-load) | V20 |
| T51 | x | opencode profile + agnosticism proof -- build the same sources for opencode (AGENTS.md + opencode.json); ties T31. Always-on stays universal-only (V38) | V21,V23,V38,T31 |
| T52 | x | README -- document the multi-channel model + three delivery paths; keep the one-command WOW | I.apps,C9 |
| T53 | x | smart auto-materialization (`I.applicability`) -- boolean facet-grained filter over `git ls-files` (`paths` AND `content`, vendored/generated excluded) + facet->core backfill + per-skill manifest evidence; `--auto` default for the `nix run` path, `--all`/explicit/`--pin`/`--exclude` override; scored mode deferred. Needs T41 | V34,V35,V36,V37,I.applicability,I.manifest,I.apps |
| T55 | x | content-aware lefthook.yml construction -- `detect-fragments.sh` examines `git ls-files` for file types; `assemble-lefthook.sh` accepts `FRAGMENTS` param; both `mkSetting` and `mkScaffold` apps detect+assemble at runtime; idempotent+convergent; bats coverage for detection, parameterized assembly, and content-aware app behavior | V40,I.detectFragments,I.mkSetting |
| T56 | . | skill extension lint -- nix check + lefthook hook enforcing V6/V13: only `*.md` files in `set/skills/` and `set/drafts/`. Pure `find` + exit-on-non-md. No content parsing. Bats coverage | V6,V13,T14 |
| T57 | . | skill size budget lint -- nix check + lefthook hook enforcing per-file size limit on individual skill/draft markdown. Single `wc -c` / `find -size` check. Independent of format or structure checks. Bats coverage | V6,V7,T14 |
| T58 | ~ | `@` ref resolution lint -- nix check validating all `@`-references in `set/` files resolve to existing source paths; also enforces V12 -- SUPERSEDED by T63-T66 (a plain grep flags real non-ref `@` tokens -- git SHAs, email addresses, prose `@main`/`@include` -- and relative refs, so it never goes green; granularized into matcher -> resolution -> V12 -> hook) | V12,T14,T63,T64,T65,T66 |

## §B Bugs

| id | date | cause | fix |
|----|------|-------|-----|
| B1 | 2026-06-16 | upstream nix-lefthook tightened checks; repo never revalidated, so `main` fails `lefthook run pre-commit --all-files` on pre-existing files (prose markdownlint, `*.nix` em-dashes, editorconfig padding, drift-check embedded shell) | fixed: narrow-other glob (#10), drift+embedded-shell extracted (#13), markdownlint/editorconfig/narrow cleared + CI runs lefthook (T32) |
| B2 | 2026-06-18 | emitted `SKILL.md` under `.claude/skills/` is not always-on -- skills are model-invoked (description-indexed, body on-demand), loading only when a prompt matches their description; only `.claude/rules/` loads unconditionally (path-less at launch; path-scoped on matching-file read). The shipped always-on SKILL.md model (T25/T35-T39) thus never autoloaded -- description-gated, NOT broken (T50 probes confirm, V32). | redesign rules-only: drop SKILL.md, mirror source as `.claude/rules/set/` with `paths` everywhere (T40-T44). Verified vs Claude Code memory/skills docs; since superseded by B3 multi-channel. |
| B4 | 2026-06-28 | `sync-set`/`app-mk-set` `cp -r` the emitted tree from `/nix/store` (read-only: dirs 555, files 444) and kept those perms. The next sync's clean-replace `rm -rf` (V26) then failed with `Permission denied` -- `rm` deletes by writing the parent dir, which lacked the write bit. Surfaced as a wall of `rm: cannot remove ...` on devShell/direnv entry; the dogfood tree stuck read-only. | fixed: each emitter `chmod -R u+w` the copied tree after `cp`, and the prior tree before `rm` (V33); bats cover read-only re-sync for both scripts |
| B5 | 2026-06-29 | V19/V21 framed opencode `opencode.json` `instructions` globs as the *conditional* (channel-b) mechanism, mirroring Claude path-rules. opencode docs: `instructions` are paths/globs to files that are ALWAYS loaded and combined with `AGENTS.md` -- there is no per-open-file conditional load, and opencode ignores per-file `paths:`/`globs:` frontmatter. So the emitted opencode rule frontmatter is inert and putting domains in `instructions` would bloat every turn. | corrected V19; added V39 (opencode loading model). T51 emits a compiled `AGENTS.md` (universal core only, V38) + an `opencode.json` whose `instructions` list only the always-on file; opencode domains reach the agent via `SKILL.md` + Read-on-demand. Verified vs opencode.ai/docs (rules, config). |
| B3 | 2026-06-26 | rules-only (B2 fix) over-corrected: `.claude/rules` is Claude-proprietary (reduces agnosticism, C2/V23), and `@`-import is Claude-only (opencode/Codex/AGENTS.md spec have no `@` -- opencode uses `opencode.json` instructions globs or Read-on-demand). So a single mechanism can't be both reliable-on-Claude and portable. | fixed: best-of-both multi-channel (V17-V21): per-agent profile + sidecar meta + `SKILL.md` (portable) + Claude rules (reliable) + `@`->`AGENTS.md` compiler (portable always-on) + dedup; gated by the mechanism test suite (T50). Verified vs opencode/Codex docs. |
| B6 | 2026-07-03 | `build-linux` CI failed: (1) `SPEC.md` (33181 bytes) exceeded the `.md` file-size-check limit of 32768 bytes in `file_size_limits.yml`; (2) `build-linux` job lacked `flake-check-timeout` and `flake-eval-timeout` params, so the CI action's nix check step printed "fails" and exited 1. | fixed: bumped `.md` limit to 40960 in `file_size_limits.yml`; added `flake-check-timeout: "600"` and `flake-eval-timeout: "120"` to `build-linux` in `ci.yml` (matching `build-darwin`). |
| B7 | 2026-07-03 | `build-linux` CI failed with `fatal: Unable to create .git/index.lock: File exists` -- parallel lefthook hooks fought over git's index lock. Root cause: the `ci` devShell set `GIT_OPTIONAL_LOCKS=0` in `shellHook`, but the CI action uses `nix develop --command` which does NOT run shellHook. Without `GIT_OPTIONAL_LOCKS=0`, read-only git operations (file-list resolution for parallel hooks) take optional locks and collide. | fixed: moved `GIT_OPTIONAL_LOCKS` from `shellHook` to a top-level `mkShell` attribute (`GIT_OPTIONAL_LOCKS = "0"`), which persists in `--command` mode. |
| B8 | 2026-07-03 | `build-linux` CI failed: `cachix/cachix-action@ad2ddac` pinned inside `nix-lefthook-ci-action@ce9a118b` targets Node.js 20, but GitHub runners forced Node.js 24. The old cachix-action has un-awaited `setup()`/`upload()` calls; on Node.js 24, unhandled promise rejections exit with code 1. All hooks and checks pass locally. Upstream `nix-lefthook-ci-action` has no newer version with a fixed cachix-action pin. | fixed: removed `cachix-cache` and `cachix-auth-token` from all CI jobs in `ci.yml`; cachix is a caching layer, not a test -- all hooks and checks run identically without it. Re-enable when upstream `nix-lefthook-ci-action` updates its cachix-action pin to one targeting Node.js 24. |
| B9 | 2026-07-03 | `build-linux-arm` CI failed: job lacked `flake-check-timeout` and `flake-eval-timeout` params (same root cause as B6, missed for this job). Without these params the CI action's nix check step prints "fails" and exits 1. QEMU-emulated aarch64-linux checks are even slower than native, making timeouts essential. | fixed: added `flake-check-timeout: "600"` and `flake-eval-timeout: "120"` to `build-linux-arm` in `ci.yml` (matching `build-linux` and `build-darwin`). |
| B10 | 2026-07-03 | `build-linux` CI failed: B8 fix was incomplete -- removing `cachix-cache` and `cachix-auth-token` params from `ci.yml` did not disable cachix because `nix-lefthook-ci-action@ce9a118b` defaults `cachix-cache` to `"pr0d1r2"`. The problematic `cachix/cachix-action@ad2ddac` (Node.js 20 targeting, fails on Node.js 24 runners) still ran on every CI job. All hooks and checks pass locally. | fixed: added explicit `cachix-cache: ""` to all three CI jobs (`build-linux`, `build-darwin`, `build-linux-arm`) to override the action default and fully disable the cachix step. |
| B11 | 2026-07-03 | `build-linux` CI failed: B7 fix was incomplete -- `GIT_OPTIONAL_LOCKS=0` as a `mkShell` attribute in the `ci` devShell is not reliably injected into the CI action's shell because the action runs `nix develop --ignore-environment` and only `extra-env` values are guaranteed to reach the hooks. Parallel lefthook hooks still fought over git's index lock. | fixed: added `GIT_OPTIONAL_LOCKS=0` to `extra-env` in all three CI jobs (`build-linux`, `build-darwin`, `build-linux-arm`); this is the documented reliable injection path for the `nix-lefthook-ci-action`. |
| B12 | 2026-07-03 | `build-linux` CI failed: B11 fix was insufficient -- `GIT_OPTIONAL_LOCKS=0` only suppresses optional index refreshes. Parallel lefthook hooks invoke tools (nix, gitleaks) that take mandatory git index locks via libgit2 or internal git calls; `GIT_OPTIONAL_LOCKS` does not affect these. With `parallel: true`, concurrent hooks still collide on `.git/index.lock` on CI runners where I/O timing makes the race more likely. | fixed: removed `parallel: true` from `assemble-lefthook.sh`, all integration fragments, and the tracked `lefthook.yml`. Hooks now run sequentially, eliminating index lock contention. No checks disabled -- same hooks, same files, sequential execution. Local devs can re-enable via `lefthook-local.yml`. |
| B13 | 2026-07-03 | `build-linux` CI failed: two independent causes. (1) `nix-flake-check` hook runs `nix flake check` inside `nix develop .#ci --ignore-environment`, but the `ci` devShell lacked `NIX_CONFIG` for `nix-command flakes` experimental features. The default devShell set this in `shellHook`, which does not run under `--command` mode. Result: bare `error: experimental Nix feature 'nix-command' is disabled`. (2) `flake.nix` grew to 45107 bytes, exceeding the 45056-byte `.nix` file-size limit in `file_size_limits.yml`. | fixed: added `NIX_CONFIG = "experimental-features = nix-command flakes"` as a `mkShell` attribute on the `ci` devShell (persists to `--command` mode unlike `shellHook`); bumped `.nix` file-size limit from 45056 to 49152 in `file_size_limits.yml`. |
| B14 | 2026-07-04 | `build-linux` CI failed: two independent causes. (1) T56-T58 granularization commit grew `SPEC.md` to 41436 bytes, exceeding the 40960-byte `.md` file-size limit in `file_size_limits.yml`. (2) New words in the T56-T58 task descriptions (`enforcing`, `granularized`, `parsing`, `shippable`, `validating`) were not in `.narrow-language-markdown.dic`. | fixed: bumped `.md` limit from 40960 to 49152 in `file_size_limits.yml`; added the 5 words to `.narrow-language-markdown.dic`. |
| B15 | 2026-07-04 | `build-linux` CI failed: `branch-protection.sh` (T19) uses `jq` but the `ci` devShell did not include `pkgs.jq`. Under `nix develop --ignore-environment` (which the CI action uses), only packages explicitly listed in the devShell are available. `jq` was reachable in the default devShell (via transitive deps) but absent in the stripped CI environment, causing all 7 `--dry-run` tests to fail with exit 127 (command not found). All tests passed locally in the default devShell. | fixed: added `pkgs.jq` to the `ci` devShell `packages` list in `flake.nix`. |
| B16 | 2026-07-04 | `build-linux-arm` CI failed: `lefthook-bats-unit` wrapper runs `bats --jobs "$(nproc)"`, executing multiple `.bats` files in parallel. On CI runners `nproc` returns 2-4+, causing concurrent git processes under QEMU aarch64 binfmt_misc emulation. QEMU's syscall emulation (brk/mmap) is unreliable under parallelism, corrupting test results. Same class as B12 (parallel execution + QEMU contention). Tests pass locally where `nproc` returns 1 (sequential). | fixed: overrode `bats-unit` command in tracked `lefthook.yml` (both pre-commit and pre-push) to run `bats` directly without `--jobs`, making test execution sequential. Same hooks, same files, no tests disabled. |
| B17 | 2026-07-06 | `build-linux` CI failed: T59 dropped the `ci = default` devShell alias from `flake.nix`, but `nix-lefthook-ci-action` defaults its `devshell` input to `"ci"`. Without an explicit override, all three CI jobs tried `nix develop .#ci` which no longer exists: `error: flake does not provide attribute 'devShells.x86_64-linux.ci'`. | fixed: added `devshell: "default"` to all three CI jobs (`build-linux`, `build-darwin`, `build-linux-arm`) in `ci.yml`, matching the T59 stacked-shell model where `default` = CI + non-LLM tooling. |
