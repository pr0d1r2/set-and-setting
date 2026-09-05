# Changelog

## Unreleased

- Cancel superseded guardrail runs on a pull request, and report every failing
  check in one run rather than the first. The tending loop force-pushes on each
  fix round, so a superseded run held a runner while the run that mattered
  queued; and an all-or-nothing check makes five defects cost five round trips,
  which is the loop's real unit of cost. Cancellation is scoped to pull requests
  so a merge's cache push is never killed. (#489)

- Give the pinned actionlint its shellcheck, so the shell inside every workflow
  `run:` block is linted at last, and move the six embedded blocks into tracked
  `.github/scripts/*.sh` where the repository's own shell guardrails and a Bats
  suite reach them. The flake check was four identical lines in each platform
  job and is now one script; the sequential Bats invocation keeps its reason
  beside it. Adding the module to the embedded-shell allowlist, which the
  monolith split left behind, so the file can be staged at all. (#485)

- Cut CI wall clock and restore binary-cache use. The macos job no longer
  waits for the ubuntu job, both platforms now build the checks in parallel
  rather than one at a time, and the cache declaration moves to installer
  configuration so CI stops ignoring it as untrusted flake config. The
  cache-push jobs now push every check on both platforms, not two packages on
  one.

- Add fleet-linking guidance to the git skill: cross-repo links in
  `README.md`, `SPEC.md` and dependency notes, naming the direction of each
  edge, keeping links in both directions, and the public boundary that keeps
  private repository names, local paths and agent session URLs out of public
  artifacts. A companion leaf covers the same for pull request bodies --
  `OWNER/REPO#N` cross-references, naming which half of a spanning change this
  is, sending a bug to the repo that owns the rule and reading it there, and
  pull request numbers rather than branch shas that a squash merge deletes.

- Fix the consumer coverage-drift check, which interpolated the whole
  materialization attribute set into its expected-hook path and so aborted
  `nix flake check` in every consumer, and force each consumer check's
  derivation in the consumer-flake output check so a check that cannot evaluate
  fails there instead of fleet-wide. The comparator moves to
  `lib/coverage-drift-check.sh` with unit coverage. (#437)

- Retire the Nix fragment's pre-push flake-evaluation command, which required an
  attribute the standard never set and so failed every push from every Nix
  repository. The full flake check in the same hook already evaluates and builds
  every check.

- Retire the base lefthook fragment's narrow-language command, which asked for a
  repository-wide dictionary that the standard never seeds and so failed every
  commit in every tended repository. The wrapper remains available in the
  development shell.

- Correct five superseded task rows that were marked work-in-progress, which
  held the `standard-current` tag back: the tending loop treats any `.` or `~`
  row as pending and so never published a settled standard to the fleet.

- Publish the evaluated `set` and `setting` delivery paths to Cachix after
  successful main-branch checks, restoring cache-backed standard delivery for
  fleet consumers. (#284)

- Fetch the standard through Git instead of GitHub's API tarball endpoint in
  generated consumer flakes, and apply bounded connection and download retries
  before CI evaluates any flake. (#284)

- Add a consumer lock-graph check that rejects check inputs carrying a second
  `nixpkgs` node, keeping materialized check pins deduplicated through
  `follows` and preventing unrelated check bumps from expanding consumer lock
  churn. (#283)

- Add a not-believing testing skill that requires observing a test fail for the
  intended reason before trusting it as evidence, including safe regression
  verification and green-commit guidance. (#276)

- Add a Stroop Effect psychology skill for recognizing interference between
  conflicting cues, selecting the task-relevant dimension, and verifying it
  independently before acting. (#274)

- Add the `sutton` principle: begin diagnosis with the most likely explanation
  and the cheapest reliable discriminating test, while preserving unlikely
  alternatives whose consequences justify early investigation. (#273)

- Add the `wiio` principle: design consequential human and agent communication
  for receiver context, damaging ambiguity, closed-loop confirmation, durable
  handoffs, and pressure-tested completeness. (#272)

- Add a Zipf's Law language skill that standardizes recurring concepts around
  familiar terms, preserves rare words that carry precision, and validates
  changes with the intended audience instead of optimizing word counts. (#271)

- Add the `heaps` principle: shrink context by removing repetition while
  preserving rare, decision-relevant facts and retrieval handles, then verify
  information coverage instead of relying on token count alone. (#269)

- Add the `hofstadter` principle: treat estimates for complex work as uncertain
  forecasts grounded in decomposition, comparable evidence, explicit
  contingency, and re-estimation as unknowns are resolved. (#265)

- Add a Hindsight Bias skill that preserves contemporaneous evidence,
  reconstructs pre-outcome alternatives, and separates decision quality from
  outcome quality in reviews and retrospectives. (#264)

- Add the `finagle` principle: account for credible failures occurring at the
  worst possible moment by identifying critical timing, preserving recovery
  margin, and testing combined stress at consequential boundaries. (#261)

- Add an experimental Infinite Monkey skill to the opt-in
  `drafts/philosophy` category. It uses the theorem as a stress test for search
  strategies while requiring finite budgets, reachable targets, and reliable
  validation. (#260)

- Add an opt-in `drafts/philosophy` category with a Solipsism skill that uses
  methodological doubt to separate private experience from externally tested
  claims. (#259)

- Add `lib.confirmAppFor` as the shared fleet-facing constructor for
  confirmation apps, backed by `mkConfirmApp`, and use the shared constructor in
  both `mkConsumerFlake` and this repository's own app. (#245)

- Add an optional tracked `lefthook-overrides.yml` channel that generated
  Lefthook configuration extends locally and in CI, allowing consumers to
  temporarily skip or repair broken upstream commands with an audit trail.

- Install lefthook hooks from scaffolded dev shells and the combined
  `bootstrap` flow, and expose `nix run .#bootstrap-hooks` for unattended
  materialization and autonomous commit loops. (#228)

- Add a first-class Ruby `mkScaffold` archetype with a `base ruby rubocop
  rspec` consumer flake, Gemfile/gemspec, RuboCop and RSpec configuration,
  library skeleton, explicit `--archetype ruby` selection, Gemfile/gemspec
  auto-detection, and a standard-materialization fidelity gate. (#227)

- Extend Ruby guardrails with Reek, Brakeman, and bundle-audit lefthook
  fragments, detected from `.reek.yml`, `config/brakeman.yml`, and
  `Gemfile.lock`, respectively. (#226)

- Add an RSpec lefthook fragment backed by the Ruby devShell, detected from
  tracked `spec/` files or `.rspec`. (#225)

- Ratchet the fleet-wide Nix file-size cap from 16 KiB to 8 KiB after the
  manifest migration gate. New standard settings inherit the lower ceiling;
  future Nix growth must extract modules rather than raise the cap. (#204)

- Add the reusable `nix-lefthook-flake-manifest` structural guard and enable
  its pinned `flake-manifest` check for the Nix fragment. It accepts import and
  `mkConsumerFlake` delegations, rejects top-level/outputs `let` logic and
  inline output attrsets independent of file size, skips missing flakes, and
  supports strictness configuration. The standard and component scaffold now
  seed a strict config and a thin consumer manifest. (#200)

- Add the `surgical` and `assumptions` principles. `surgical` keeps a change
  scoped to the reported problem and pushes refactors, reformatting, and
  unrequested extras into commits of their own. `assumptions` requires the
  undetermined parts of a request to be named and the chosen reading stated,
  while preferring a flagged assumption over a blocking question. Their
  anti-patterns stay in each file's `Signals of violation` section rather than
  a parallel tree, so there is one source per rule.

- Add the self-contained five-lens `accord` merge-gate set and expose it as
  `packages.accord-set` through named-set materialization. (#190)

- Add `canonFor` and `mkCanon`: fragment-selected canon units now compose the
  thin seed, docs, governance, development environment, and CAVEKIT SPEC into
  one deterministic referenced-repository tree. Migration backfills the same
  tree, pinned seed drift is checkable, and missing comparator inputs fail
  loudly instead of reading as convergence. (#246)

- Make `SPEC.md` the unconditional canon enrollment floor and compose canon
  into `mkSetting-init`, while preserving its setting-specific starters.
  Keep `seed` explicitly limited to pinned repair infrastructure. (#249)

- Seed skip-existing `README.md` and `LICENSE` files from `mkSetting-init`.
  The README carries the canonical CI/license/NixOS badge block and repository
  placeholders; MIT is the explicit default and can be disabled with
  `license = null`. (#235)

- Extend the leaf `seed` app to substitute README owner/repo and MIT
  holder/year placeholders from trip inputs or an existing GitHub `origin`.
  Repositories without coordinates keep a one-line fill-in note. Advance the
  growing SPEC and Nix source size budgets by 8 KiB, and keep the migration
  dropped-check proof independent of README-triggered markdown detection.
  (#235)

- Auto-project every active principle into the always-on agent prompt as a
  `[[slug]]` registry entry with its name and opening rule, and add a generated
  believability-weighted `principles` accord lens for pre-merge review. (#187)

- Add the `meritocracy` principle: let the best-supported idea win regardless
  of who holds it by combining truth, transparency, believability weighting,
  and openness across every agent decision. (#185)

- Add the `process` principle: follow the iterative five-step sequence from
  goals through problems, root-cause diagnosis, design, and execution without
  skipping steps. (#183)

- Add the `ownership` principle: own outcomes end-to-end, drive pull
  requests through green checks, accord, and merge, and finish work or mark
  its evidence-backed blocker explicitly. (#182)

- Remove the obsolete per-repository auto-update workflow and app. Scaffold
  and leaf-seed outputs now contain only `ci.yml` under workflows; their Nix
  checks assert that `auto-update.yml` is absent. Fleet updates are handled by
  the hallucinogen tend loop. (#145)

- T75 (#96): `apps.migrate` -- mechanical, deterministic, idempotent,
  non-LLM, confirmator-gated vendored->referenced transform, safe at
  thousands of repos (one mechanical PR per repo). `lib/migrate.sh`
  (core) + `lib/app-migrate.sh` (CLI) + `apps.migrate`. Per repo:
  (1) detect state (vendored / referenced / bare / partial;
  already-referenced ⇒ no-op); (2) strip vendored artifacts (heavy
  `flake.nix`, tracked `lefthook.yml`, inline `ci.yml`) so they become
  derived + gitignored; (3) plant the leaf seed (#95) skip-if-exists +
  merge materialized-artifact ignores into `.gitignore`;
  (4) confirm-equivalence (the safety net) -- assert the referenced
  effective check-set (pinned `checksFor` names UNION all fragment
  lefthook commands) covers every check the vendored `lefthook.yml`
  enforced; a dropped check ⇒ refuse (exit 1), leave vendored, report --
  then dry-run the confirmator (#94). The FULL confirmator +
  `nix flake check` gate the PR in CI once `nix flake update` has
  produced `flake.lock`. Flags: `--detect`, `--dry-run`, `--help`.
  Added `checks.<sys>.{migrate-vendored,migrate-already-referenced,
  migrate-bare,migrate-partial,migrate-rejects-dropped-check}` and bats
  (`tests/migrate.bats`, `tests/app-migrate.bats`). Bumped the `.nix`
  file-size limit to 143360 and `.md` to 73728. HOLD (V189): the tool
  lands; the fleet-wide run stays human-gated. (V43, I.migrate)

- T71 (#101, part of #93): checks->pinned git/security tier -- FINAL.
  Convert gitleaks, git-conflict-markers, git-no-local-paths,
  execute-permissions, and file-size-check from runtime lefthook
  `remotes:` git_urls to PINNED flake `checks.<sys>.<tool>`. Added
  convenience helpers `lib.mkGitleaksCheck`, `lib.mkGitConflictMarkersCheck`,
  `lib.mkGitNoLocalPathsCheck` (custom derivation excluding flake.nix/
  flake.lock), `lib.mkExecutePermissionsCheck`, and
  `lib.mkFileSizeCheckCheck`, each closing over its own pinned
  `nix-lefthook-<tool>-src`. Added `checks.<sys>.{gitleaks,
  git-conflict-markers,git-no-local-paths,execute-permissions,
  file-size-check}` plus a `<tool>-catches-violation` proof for each.
  Dropped the five `remotes:` entries from the `base` fragment and the
  tracked `lefthook.yml`. The scaffold (`component-flake.txt`) now wires
  the same pinned checks. Updated bats tests and compose-scaffold check
  to assert all 18 migrated tools are pinned checks, not remotes. This
  completes the #93 strangler-fig migration: all lefthook lint tools are
  now hermetic pinned flake checks (V41).

- T70 (#100, part of #93): checks->pinned shell/content tier. Convert
  shellcheck, no-shell-functions, ascii-only, and typos from runtime
  lefthook `remotes:` git_urls to PINNED flake `checks.<sys>.<tool>`.
  Added convenience helpers `lib.mkShellcheckCheck` (`*.sh`),
  `lib.mkNoShellFunctionsCheck` (`*.sh`),
  `lib.mkAsciiOnlyCheck` (`*.{nix,yml,json}`), and `lib.mkTyposCheck`
  (whole-tree), each closing over its own pinned `nix-lefthook-<tool>-src`.
  Added `checks.<sys>.{shellcheck,no-shell-functions,ascii-only,typos}`
  plus a `<tool>-catches-violation` proof for each. Dropped the four
  `remotes:` entries (shellcheck and no-shell-functions from the `shell`
  fragment; ascii-only from `ascii`; typos from `base`) and from the
  tracked `lefthook.yml`; removed ascii-only commands (pinned check runs
  on all matching files). The scaffold (`component-flake.txt`) now wires
  the same pinned checks. Updated bats tests to assert the four tools are
  pinned checks, not remotes. CI green at every step (V41).

- B21: fix bats tests still asserting `nix-lefthook-statix` presence after
  T69 removed all nix linter remotes from the nix fragment. Bumped `.nix`
  file-size limit 81920 -> 90112 (`flake.nix` grew past the old limit).

- T68 (#98, part of #93): checks->pinned formatters tier. Convert shfmt,
  trailing-whitespace, missing-final-newline, and editorconfig-checker
  from runtime lefthook `remotes:` git_urls to PINNED flake
  `checks.<sys>.<tool>`. Extended `lib/mk-lefthook-check.nix` with
  `suffices ? null` (whole-tree tools that lint every file, matching a
  glob-less `remotes:` entry) and `checkFlag ? "--check"` (`""` for
  check-only wrappers with no such flag). Added convenience helpers
  `lib.mkShfmtCheck` (`*.sh`, `--check`), `lib.mkTrailingWhitespaceCheck`,
  `lib.mkMissingFinalNewlineCheck`, and `lib.mkEditorconfigCheckerCheck`,
  each closing over its own pinned `nix-lefthook-<tool>-src`. Added
  `checks.<sys>.{shfmt,trailing-whitespace,missing-final-newline,
  editorconfig-checker}` plus a `<tool>-catches-violation` proof for
  each. Dropped the four `remotes:` entries (shfmt from the `shell`
  fragment; the trio from `base`) and from the tracked `lefthook.yml`;
  the scaffold (`component-flake.txt`) now wires the same pinned checks
  so consumers stay whole. Bumped `.nix` file-size limit 73728 -> 81920
  and `.txt` 10240 -> 12288 (scaffold `component-flake.txt` grew with the
  new pinned checks). Updated `compose-scaffold` + assemble/scaffold bats
  to assert the four
  tools are pinned checks, not remotes. CI green at every step (V41).

- T67 (#97, part of #93): checks->pinned framework + nixfmt proof.
  New `lib/mk-lefthook-check.nix` (exposed as `lib.mkLefthookCheck`)
  wraps a PINNED lefthook-* wrapper derivation into a hermetic flake
  `check` -- runs the wrapper `--check` over the repo's
  `suffices`-filtered files, resolving lint logic via a pinned flake
  input instead of a runtime lefthook `remotes:` git_url. `lib.mkNixfmtCheck`
  is the nixfmt convenience, closing over the pinned
  `nix-lefthook-nixfmt-src`. Added `checks.<sys>.nixfmt` (pinned,
  offline-runnable) and `checks.<sys>.nixfmt-catches-violation` (proves
  a malformed file fails). Removed the `nix-lefthook-nixfmt` entry from
  the `nix` lefthook fragment and the tracked `lefthook.yml`; the
  scaffold (`component-flake.txt`) now exposes the same pinned `nixfmt`
  check so consumers stay whole. Bumped `.nix` file-size limit
  69632 -> 73728. Establishes the strangler-fig pattern (V41) for the
  remaining #93 tiers. Updated `compose-scaffold` +
  assemble/scaffold/setting bats to assert nixfmt is a pinned check,
  not a remote.

- B20: bump `.md` file-size limit from 49152 to 57344 in
  `file_size_limits.yml` -- `SPEC.md` grew past the prior limit.

- B19: make cachix push best-effort -- `continue-on-error: true` on the
  `cachix/cachix-action@v15` step in `cache-push` CI job so auth
  failures (403 Forbidden) don't fail CI after all checks pass.

- T57: skill size budget lint -- `lib/skill-size-check.sh` plus
  `lib/mk-skill-size-check.nix`, enforcing per-file size limit (4096
  bytes) on individual skill/draft markdown. Single `wc -c` check.
  Wired as `checks.set-skill-size` in `flake.nix` and as
  `set-skill-size` hook in `setting/integrations/lefthook/set.yml`
  (pre-commit + pre-push, glob `set/{skills,drafts}/**/*.md`).
  Configurable via `SKILL_SIZE_LIMIT` env var. 16 bats tests.

- T56: skill extension lint -- `lib/skill-extension-check.sh` plus
  `lib/mk-skill-extension-check.nix`, enforcing V6/V13: only `*.md`
  files in `set/skills/` and `set/drafts/`. Pure `find` +
  exit-on-non-md. Wired as `checks.set-skill-extension` in `flake.nix`
  and as `set-skill-extension` hook in `setting/integrations/lefthook/set.yml`
  (pre-commit + pre-push, glob `set/{skills,drafts}/**`). 16 bats tests.

- T44: re-dogfood for multi-channel -- `sync-set.sh` now handles all
  three channels (V17): discovers and syncs portable SKILL.md files
  (channel c, V20) with clean-replace semantics, and compiles `set.md`
  into an inline `AGENTS.md` at the target root (channel a, V29) so
  non-Claude agents auto-discover it. `mk-set.sh` ships the compiler as
  `bin/agents-md-compile` in the derivation. `.gitignore` adds
  `AGENTS.md`; `.envrc` watches the new emitter files. 7 new bats tests.

- B18: fix build-linux-arm CI -- remove `nix-lefthook-bats-unit` remote
  from `lefthook.yml`. The remote's `lefthook-bats-unit` wrapper (which
  runs `bats --jobs "$(nproc)"`) overrode the local sequential `bats`
  command due to lefthook giving remote configs priority over local
  overrides for same-named commands. On QEMU aarch64, parallel bats
  execution causes race conditions in emulated git operations. Documented
  as B18 in SPEC.md.

- T66: lefthook wiring -- new `setting/integrations/lefthook/set.yml`
  fragment gates the T64 ref-resolution and T65 V12 bundle-content checks
  on `set/*.md` tracked files (content-aware, per I.detectFragments/V40).
  `detect-fragments.sh` detects `set/*.md` via `git ls-files`;
  `assemble-lefthook.sh` default includes `set`. Both checks run as
  pre-commit and pre-push commands with `glob: "set/**/*.md"`. 9 new bats
  tests across detect-fragments and assemble-lefthook suites.

- T65: V12 bundle own-content enforcement -- `lib/bundle-content-check.sh`
  plus `lib/mk-bundle-content-check.nix`, an independent grep check that
  consumes the T63 matcher to detect bundle files (those composing via
  `@`) and enforces that each limits its OWN content to a single heading,
  a purpose statement, and the `@` refs. Structural markdown (fenced code,
  bullet/ordered lists, tables, blockquotes) and a second heading fail
  with exit 1; inline code spans and multi-line prose are fine. Ships
  standalone -- runs separate from ref resolution (T64), so a
  truly-missing ref target never fails it. Wired as
  `checks.set-bundle-content`. 18 new bats tests over fixtures.

- T64: ref-resolution nix check -- `lib/ref-resolve-check.sh` +
  `lib/mk-ref-resolution-check.nix` consume the T63 matcher and resolve
  every real `@`-reference in the `set/` tree to an existing source path
  (`@set/...` from the repo root; relative `@<cat>/<file>.md` against its
  own dir/parent, plus the `set/`, `skills/`, and `drafts/` bases). Exits
  1 ONLY on a truly-missing target. Wired as `checks.set-ref-resolution`.
  Because the matcher already filters non-ref `@` tokens and code-span/
  comment refs (T63), the check goes green where a naive grep never could
  (the blocker on T58). 12 new bats tests over fixtures.

- T63: `@`-ref matcher -- `lib/ref-match.sh`, a pure-shell scanner that
  emits ONLY real `@`-references from a markdown file (leading-token
  `@set/...` / `@concepts/...` or relative `@<category>/<file>.md`). Skips
  code spans/fences and block HTML comments (V29 parse rules) plus non-ref
  `@` tokens (email `@example.com`, git SHAs `@fbeb9d9`, prose
  `@include`/`@main`/`@v4`/`@privileged`/`@system-service`). The
  false-positive filter that unblocked T58; consumed by the T64
  ref-resolution check. 26 new bats tests over fixtures.

- T34: additional agent seams -- add Cursor, Codex, Gemini CLI, Copilot,
  and Amp profiles to `agents.nix`, extending the agnosticism proof from
  3 to 8 seams (V23). All extension agents use inline import (compiled
  `AGENTS.md`) and `globs`-based conditional rules. Nix `agent-seam-
  extensions` check proves body-identical emission across all agents. 27
  new bats tests.

- T33: downstream wiring -- consumer scaffold (`component-flake.txt`)
  wires `set-and-setting` flake input with `mkDevShells`, `packages.set`/
  `packages.setting`, sync hooks, and `mkDepGraphCheck`. CI template
  (`ci.yml`) adds a sync pre-step that builds `packages.setting` and
  runs `sync-setting` before hooks (V22 gitignored configs). Add
  `examples/home-manager.nix` home-manager module for global skill
  installation via `home.file` + activation script. Nix checks validate
  scaffold wiring and home-manager syntax.

- T31: agnosticism proof -- add `materialize-check-opencode` nix check
  proving the consumer-facing `mkMaterializeCheck` API works with the
  opencode agent (`globs` field, `.opencode/rules/set` dir). Add bats
  tests across emit-rule, mk-set, and materialize-check proving the
  shell infrastructure is field-agnostic (V23).

- T24: rename propagation -- upstream rename map (`set/renames.nix`),
  detection script (`rename-propagate.sh`), wired into both `sync-set`
  and `app-mk-set` paths. Consumers get advisory warnings when upstream
  renames affect their installed skills or `@`-references. Manifest
  records applied renames for audit (C7/I.sync-set).

## 1.0.0 -- 2026-07-07

Public open-source release under MIT license (C5). Repo live at
`github:pr0d1r2/set-and-setting`.

### Changed

- T22: mark hallucinogen consumer updated from `git+file:` to `github:`
  for its set-and-setting flake input (C6/T7).

- T61: document the stacked-shell model in the linting skill -- add
  stacked devShells section (`default` = CI + non-LLM full tooling,
  `agentic` = default + LLM via stacking), CI same-gate invariant,
  and update linter addition steps for the stacked model.

- T60: devShells drift-check -- extend `mkSettingDriftCheck` with
  optional `devShells` parameter enforcing stacked-shell invariants:
  shells named `default`/`agentic` only, `agentic.packages` superset
  of `default.packages`, CI must not set `skip-lefthook: true`. Nix
  assertions fire at eval time; CI check via `devshells-drift-check.sh`
  at build time. Dogfood check in `flake.nix`. Bats coverage (8 tests).

- T59: devShells STACK -- restructure to `default` (CI + non-LLM
  tooling) + `agentic` (default + LLM via `inputsFrom`). Drop `ci`
  devShell; CI uses `default`. Add `setting/lib/mk-dev-shells.nix`
  emitter exposed as `lib.mkDevShells` and `mkSetting` passthru for
  refresh propagation. Update scaffold template, `.envrc`, SPEC.

- T18: mark public GitHub repo creation complete -- repo live at
  `github:pr0d1r2/set-and-setting` (public, MIT, C6 satisfied).

- CI: bump `.md` file-size limit from 40960 to 49152 (B14); add missing
  dictionary words for T56-T58 task descriptions.
- Add the `@`->AGENTS.md compiler (T48/V29, `lib/agents-md-compile`):
  resolves a Claude `@`-manifest (the mkSet `set.md`) recursively into an
  inline, self-contained AGENTS.md so non-Claude agents get the same
  always-on content Claude loads. Mirrors Claude `@`-parse rules -- skip
  `@` in fenced code blocks and code spans, strip block-level HTML
  comments, cap at 4 hops, leave unresolvable refs literal.
- CI: increase lefthook hook timeouts from 120s to 300s for parallel
  `--all-files` runs. Multiple checks (narrow-language-markdown,
  bats-parse, nix-flake-check, file-size-check, gitleaks, unicode-lint)
  exceeded 120s under concurrent load on CI runners. Both CI env-var
  timeouts (`ci.yml`) and lefthook-native timeouts (`lefthook-local.yml`)
  raised to 300s.
- T7: switch consumer repos from `git+file:` to `github:` flake inputs
  (C6). All flake inputs and the scaffold template already use `github:`
  URLs; constraint C6 updated to drop `git+file:` as an option.
  `compose-scaffold` nix check now rejects `git+file:` URLs in the
  scaffolded `flake.nix`.
- T30: dogfood -- emit set into gitignored `.claude/rules/set/` +
  auto-sync on devShell entry; drop CLAUDE.md `@`-ref block. Reworked
  mkSet emission from SKILL.md-based `.claude/skills/set/` to
  path-scoped rules mirror in `.claude/rules/set/` (V17-V20, V25).
  Each source file is copied verbatim with its category `paths:`
  prepended. Agent seam simplified from 3-field to 2-field
  `{ dir, condField }` (V21). All categories now path-scoped with
  globs -- domains narrow, core/universal broad `**/*` (V20).
  DevShell shellHook auto-syncs `packages.set` on entry.
  CLAUDE.md stripped of `@`-ref blocks for skills/concepts/drafts.

- T8: auto-update mechanism for consumer repos (C7). Adds
  `lib/auto-update.sh` (updates flake input, syncs set + setting,
  commits flake.lock), `apps.<sys>.auto-update` (runnable via
  `nix run github:pr0d1r2/set-and-setting#auto-update`), a reusable
  GitHub Actions workflow (`.github/workflows/auto-update.yml`) that
  consumers call via `uses:`, and a scaffold consumer workflow
  (`setting/scaffold/auto-update.yml`) emitted by `mkScaffold`.

### Added

- T19: branch protection script (`lib/branch-protection.sh`) and nix app
  (`apps.branch-protection`) to enable GitHub main branch protection
  requiring PRs via `gh api`. Supports `--repo`, `--branch`,
  `--status-checks`, `--dry-run`. Bats test coverage.
- T13: graduate-draft mechanism (`apps.graduate`, `lib/graduate-draft.sh`).
  Moves draft skill categories from `set/drafts/<cat>/` to
  `set/skills/<cat>/`, updating `@`-refs from `@set/drafts/<cat>/` to
  `@set/<cat>/`. Handles both merge (into existing category) and new
  category creation (reports required nix config changes). Nix checks
  validate merge graduation and `@`-ref rewriting.
- T54: caveman-code agent profile -- third agent seam proving
  agnosticism (V23). Caveman-code is a Claude Code superset using
  `.cave/` paths, `CAVE.md`+`@` always-on, `paths` conditional,
  same dedup. Profile in `agents.nix`, nix check
  `agent-seam-caveman-code`, bats coverage in `app-mk-set-agent`
  and `sync-set`. `mkSet --agent caveman-code` emits to
  `.cave/rules/set/`.
- `apps.<sys>.mkScaffold` + bootstrap integration (#30): emit the three
  files a bare repo needs to reach green CI -- `flake.nix` (nix-lefthook
  component shape with `devShells.ci` + `default` built from
  `lefthookWrappersFor`), `lefthook.yml` (assembled from the composable
  `setting/integrations/lefthook/*.yml` fragments), and
  `.github/workflows/ci.yml` (`nix-lefthook-ci-action` matrix with
  `skip-build: true`). All three are skip-if-exists (repo-owned after
  scaffolding). `bootstrap` now runs mkSet + mkSetting + mkSetting-init +
  mkScaffold in sequence. Add `compose-scaffold` nix check verifying the
  scaffold output. Note: green CI also requires a `CACHIX_AUTH_TOKEN`
  repo secret (operator-set, out of scope).

- `lefthook-narrow-language-add` wrapper (#29): wire upstream
  `narrow-language-add` script that auto-appends unknown words to
  the correct dictionary (sorted, deduped, `git add`ed). Same
  `runtimeInputs` as `compact`. Update `nix-lefthook-narrow-language`
  input to include the new script. Update `language/narrow.md` skill
  to reference the command.
- `lib.mkMaterializeCheck` (T40/#23): deterministic consumer-side test
  for skill materialization. Consumers wire one line in their `checks`
  output and get automatic verification that mkSet produces the correct
  layout for their selected categories -- every rule file (domain and
  core/universal) carries `paths:` frontmatter with the category globs
  (V18/V20), no `SKILL.md` exists anywhere (V17), bodies are verbatim
  (V25), and excluded files are absent. Expectations self-derive from
  `categories.nix` so consumers never restate the globs map. Shell
  logic in `lib/materialize-check.sh`, bats coverage in
  `tests/materialize-check.bats` (15 test cases). Wired as
  `checks.materialize-check` and `checks.materialize-check-exclude`
  in `flake.nix`.

- Enrich `language/narrow.md` with deterministic narrow-language
  recovery procedure (#28): glob-to-dict table, safe-append recipe,
  compact/freeze/MD024 gotchas, verify step. Add
  `**/.narrow-language-*.dic` to the `language` category globs so
  the rule auto-loads on dictionary edits.

### Documentation

- Rewrite README.md with `nix run` one-command hero (T38): lead with
  the zero-dependency `nix run github:pr0d1r2/set-and-setting#mkSet`
  command as first-impression WOW. Document all three delivery paths
  (C9): `nix run` (zero-dep, per-CWD), flake input (pinned,
  drift-checked), and home-manager (user-level). Update API section
  to reflect the mkSet emitter rewrite (Agent-Skills layout, facets,
  two mkSetting output kinds) and drop retired `extra`/`extraPaths`.
  Fix architecture diagram to show 16 categories and current output
  names.

### Fixed

- B16: override `bats-unit` in `lefthook.yml` to run sequentially,
  fixing QEMU aarch64 CI failures from parallel bats execution.
- B15: add `pkgs.jq` to the `ci` devShell -- `branch-protection.sh`
  uses `jq` but it was absent under `--ignore-environment`, causing 7
  `--dry-run` test failures on CI.
- B10: explicitly disable cachix in all CI jobs (`cachix-cache: ""`);
  B8 fix was incomplete because the action defaults `cachix-cache` to
  `"pr0d1r2"`, so the problematic cachix-action still ran.
- B8: disable cachix in CI -- `cachix-action@ad2ddac` pinned in
  `nix-lefthook-ci-action` targets Node.js 20 but GitHub runners now
  force Node.js 24; un-awaited async calls cause exit code 1. Removed
  `cachix-cache` and `cachix-auth-token` from all CI jobs. Re-enable
  when upstream updates its cachix-action pin.
- B7: fix CI git index.lock contention -- move `GIT_OPTIONAL_LOCKS=0`
  from ci devShell `shellHook` to a top-level `mkShell` attribute so
  it persists when `nix develop --command` skips shellHook.
- B6: bump `.md` file-size-check limit from 32768 to 40960 so SPEC.md
  passes; add `flake-check-timeout` and `flake-eval-timeout` to
  `build-linux` job.
- B4: `sync-set` and `app-mk-set` no longer fail with `Permission denied`
  on re-sync. Both `cp -r` the emitted tree from `/nix/store` (read-only),
  which carried 555/444 perms to the target; the next clean-replace `rm`
  then could not delete it. Each emitter now `chmod -R u+w` the copied
  tree (and any prior tree before removing it). Re-sync is idempotent
  (V33). Surfaced as a wall of `rm: cannot remove` on devShell entry.
- CI: gate cachix push to main-branch pushes only so PRs do not fail
  when the auth token is unavailable.
- Fix `shfmt` and `shellcheck` violations in `lib/materialize-check.sh`.
- CI: move LEFTHOOK_*_TIMEOUT env vars from workflow `env:` block to
  `extra-env` input. The CI action runs `nix develop --ignore-environment`
  which strips all parent env vars; hooks fell back to 30-second defaults
  and timed out under parallel load.
- shellcheck SC2086: quote `$pfx_len` in `set/lib/emit-rule.sh`.
- CI: increase lefthook hook timeouts for parallel `--all-files` runs.
  Workflow-level env block in `ci.yml` sets bash-timeout hooks to 120s
  (300s for `bats-unit`). `lefthook-local.yml` overrides narrow-language
  remote timeouts from 30s to 120s (lefthook-local has higher merge
  priority than remotes).
- Narrow-language dictionaries for integration category (#36): add
  "integration" to nix.dic, 30 new words to markdown.dic from the new
  skill files, compact stale entry from other.dic.
- `file_size_limits.yml`: add `txt: 10240` limit for scaffold templates
  (`component-flake.txt` exceeded the 8192-byte default).
- Fix `assemble-lefthook.bats` teardown deleting real integration
  fragment files and editorconfig/shellcheck violations (#30).
- Add "home" and "keep" to `.narrow-language-other.dic` for the
  `keep-home` CI setting.
- CI devShell shellHook sets `HOME` fallback when unset, preventing
  `fatal: $HOME not set` from git inside `nix develop
  --ignore-environment`.
- `sync-set.sh` discovers the agent dir from the build output instead
  of hardcoding `.claude`. The nix build path with `agent = opencode`
  now produces a working `bin/sync-set` (V21/V23).
- `--remove` of always-on (cross-cutting) categories now cleans stale
  `.claude/rules/<cat>.md` files. Previously only domain categories
  under `.claude/skills/set/` were cleaned by the `rm -rf` step.
- CI: add missing words to `.narrow-language-shell.dic` (scoped,
  verbatim, mirror, broad, etc. from `lib/*.sh`, `set/lib/*.sh`,
  `tests/*.bats`) and `.narrow-language-markdown.dic` (reworked,
  simplified, stripped from `CHANGELOG.md`).
- narrow-language (#29): move `anywhere` to
  `.narrow-language-markdown.dic` -- `CHANGELOG.md` is markdown, so its
  words must live in the markdown dictionary, not
  `.narrow-language-other.dic`.

### Apps

- `mkSet --auto` smart materialization (T53, V34/V37): scans the consumer
  repo (`git ls-files`, vendored/generated excluded) and installs only
  skills with evidence -- core always, a domain/facet kept iff a tracked
  file matches its `paths` AND a path-matched file contains a `content`
  pattern, with facet->topic-core backfill. Records per-skill evidence in
  `.mkset.json` (`applicability`). `--dry-run` previews the applicable
  set; a non-git/empty tree falls back to core. `--all`/explicit/`--auto`
  are distinct modes.

- Add `--agent` seam passthrough to installers (T39/V21/V23): `mkSet
  --agent opencode` emits skills to `.opencode/skills/set/` with
  `globs` conditional-load field instead of Claude's `.claude/skills/set/`
  with `paths`. Same agnostic source, different agent surface. Known
  agent seams defined in `set/lib/agents.nix` -- adding a new agent is
  one attrset entry. `bootstrap --agent NAME` passes through to mkSet.
  Manifest records the target agent. `--dry-run` shows agent and target
  path. Ties the agnosticism proof: nix `agent-seam-opencode` check
  verifies both seams produce identical skill body content and facets.
- Add install manifest `.claude/skills/set/.mkset.json` (T37/I.manifest):
  records installed categories, upstream rev, and agent. Enables smart
  bare re-run (bare `mkSet` with a manifest refreshes previously installed
  categories instead of defaulting to core-only), update detection (prints
  notice when upstream rev differs from manifest), and `--remove` (remove
  categories from the install and update the manifest). Distinguishes
  mkSet-managed files from hand-added ones.
- Add `apps.<sys>.{mkSet,mkSetting,mkSetting-init,bootstrap}` runnable
  installers (T36/C9): `nix run github:pr0d1r2/set-and-setting#mkSet`
  materializes skills into `./.claude/skills/set/` from one command with
  zero deps beyond nix. Run-time emit (V28) -- the same `mk-set.sh` /
  `emit-skill.sh` emitter scripts serve all three delivery paths (flake
  input, home-manager, `nix run`). Selection (V27): core (`generic` +
  `git`) always pulled, domains opt-in via positional args, `--all`,
  or `--all-except`; no args shows a notice listing selectable
  categories. `--list`, `--help`, `--dry-run` on all four apps.
  Unknown category fails with guidance. `bootstrap` = mkSet core +
  mkSetting + mkSetting-init in one command. Extract category metadata
  (`all`, `core`, `globs`) into shared `set/lib/categories.nix`; expose
  `configFiles` and `seed` passthru on `mkSetting` for the apps.

### Tests

- Add `lib.mkDepGraphCheck` (T9/C6): reusable consumer-side nix check
  that validates a `flake.lock` dependency graph uses only `github:` URLs.
  Fails with exit 1 and guidance if any input uses `git+file:`, `path:`,
  or other non-github types. Shell logic in `lib/dep-graph-check.sh`,
  bats coverage in `tests/dep-graph-check.bats` (7 test cases). Wired as
  `checks.dep-graph` in `flake.nix` (dogfood). Consumers wire one line
  in their `checks` output.
- Add `agents-md-compile` + `agents-md` checks (T48/V29): fixture-based
  fidelity check (recursion, fence/code-span skipping, HTML-comment
  stripping, hop limit) plus an end-to-end build that compiles the real
  mkSet `set.md` manifest and asserts the always-on core inlines.
- Add `agent-profiles` check (T46/V21): asserts each agent profile in
  `agents.nix` carries all channel mechanisms (always-on file+import,
  conditional, skill) and the back-compat `dir`/`condField` seam derives
  from `conditional`.
- Add `meta-resolve` check (T45/V30): asserts `set/meta.nix` resolves a
  source path to `{ channel, paths, keywords, always }` via category
  fallback <- subtree entry <- exact-file override.
- Harden the mechanism probes: query-style markers (report a loaded
  passphrase, not follow a directive) + majority voting (`VOTES`) over
  nondeterministic runs. Confirms `@`-recursion, `@`-in-rules, symlink,
  and path-less rule all load, and `disable-model-invocation` blocks;
  skips the path-scoped read-vs-write trigger probes (verdict flips even
  voted -- G2 stays open, design defensively).
- Add T50 mechanism probe suite (`tests/mechanism/`): headless `claude -p`
  probes that empirically confirm Claude loading semantics the
  multi-channel design rests on (skill autoload, path-scoped rule
  read/write trigger, `@`-recursion, `@`-in-rules, symlink load,
  `disable-model-invocation`). Gated behind `MECHANISM_PROBES=1` + a
  `claude` binary so normal hooks/CI skip it (no token burn).
- Update emit-skill, mk-set, and sync-set tests for facets-as-linked-files
  format (9 emit-skill tests, 6 mk-set tests, 5 sync-set tests)
- Add unit tests for `mk-set.sh` (6 cases) and `sync-set.sh` (4 cases)
  to complete coverage for all three extracted mkSet shell scripts

### Set (skills)

- Emit the opencode always-on channel (T51, V39/V38/V23): for the
  opencode profile mkSet compiles `set.md` into an inline `AGENTS.md`
  (universal core only -- no domain) via the V29 compiler, and writes an
  `opencode.json` whose `instructions` list only the always-on file
  (opencode instructions are always-loaded, so domains stay out and reach
  the agent via SKILL.md + Read-on-demand). The Claude profile emits
  neither (native `@` + path-rules). Proves the same agnostic sources
  build for a second agent (C2/V23). Profile-driven off `alwaysOn.import`
  / `conditional.mechanism`.
- Wire the KEEP filter into the emitter (T53, V34): mkSet honours an
  optional `KEEP` set of relpaths -- the rule channel skips non-kept
  files and the SKILL.md channel inlines only kept files (skipping a
  skill folder entirely when nothing is kept). Empty/unset `KEEP` is a
  no-op, so `packages.set` and explicit installs stay full.
- Add the applicability filter engine (T53, V34/V35/V36): `meta.signals`
  serializes each skill file's `paths`+`content`; `applicability.sh` keeps
  a file iff core, or a tracked file matches its `paths` AND a
  path-matched file contains a `content` pattern, then backfills a kept
  facet's `<topic>.md` core. Deterministic over a tracked-file list; the
  bash glob matcher honours gitignore leading-`**/` (matches top-level).
  Engine only -- emitter wiring + app `--auto` follow.
- Fill the meta relevance map (T41, V34/V35): high-value facets get
  narrow `paths` + `content` grep signals -- qemu (`tests/integration/**`,
  `**/*.exp` / `qemu`, `enable-kvm`), iso, qemu/mdns, nixos hardening,
  cachix, python-package. `resolve` now surfaces `content`. The narrow
  `paths` also tighten the emitted rule globs (qemu no longer fires on
  every `.bats`); `content` is materialize-only, consumed by T53.
- Fix a tab-IFS bug in the channel-override emitter: a paths-only
  override (empty channel field) was misparsed because tab is an
  IFS-whitespace char that collapses empty fields, so the narrow globs
  silently fell back to the category. Switch the serialization delimiter
  to `|`. Latent since T47; surfaced by T41's paths-only overrides.
  Regression test added.
- Dedup the SKILL.md channel on Claude (T49, V20): the Claude profile
  emits `disable-model-invocation: true` in each `SKILL.md` so the rule
  channel is the sole loader and the same content never double-loads.
  SKILL.md stays `/`-invoke + cross-agent only. opencode keeps SKILL.md
  model-invocable (no such field). The flag lives in the agent profile
  (`agents.nix` `skill.disableModelInvocation`).
- Fix mkSet with no categories/concepts (T47): the `set.md` manifest
  step now creates the set dir before scanning it, so an empty selection
  no longer errors. Drop the obsolete "no SKILL.md in rules output"
  materialize-check assertion -- SKILL.md is now a valid channel.
- Emit a portable per-category `SKILL.md` channel (T47, V20): each
  category gets an agentskills.io folder `set-<cat>/SKILL.md` with
  frontmatter (name + description from meta keywords + conditional-load
  globs) and the category's source files inlined verbatim. Inlining
  (not separate supporting files) keeps it self-contained for agents
  without a rules channel and avoids a case-insensitive-filesystem
  collision between a `skill.md` source and the `SKILL.md` entry (macOS
  APFS). No `disable-model-invocation` yet (Claude dedup is T49).
- Emit an always-on `@`-manifest `set.md` (T47, V18): a sibling of the
  set dir listing `@`-refs to every always-on (path-less) file --
  concepts first, then core rules; domain rules omitted. This is the
  authoring surface for the `@`->AGENTS.md compiler (V29/T48). `sync-set`
  copies it alongside the set tree.
- Multi-channel emit driven by the meta map (T47, V17/V30): mkSet now
  emits two rule channels per the channel resolved for each file -- core
  categories (generic, git) emit path-less always-on rules (no
  frontmatter, load every turn per V18/V32); domain categories emit
  conditional rules with the agent's conditional-load field + globs
  (V19). A per-file override (meta.channelOverrides, e.g. generic/rtk.md)
  flips an individual file's channel. Per-file rule writing extracted to
  `emit-rule.sh`. Works for both the nix package path and the run-time
  app path (C9). Supersedes the rules-only emit (T40-T44).
- Refactor mkSet emission to facets-as-linked-files (T35): domain
  categories now emit `<cat>/SKILL.md` with frontmatter + core body +
  markdown links to raw-cloned facet files instead of concatenating all
  content into a single file. Always-on categories retain concatenation.
  `sync-set` clean-replaces `.claude/skills/set/` before copying (V26).

- Evolve `mkSet` into the skill-set emitter: groups each category into an
  Agent-Skills folder (`.claude/skills/set/<category>/SKILL.md`) with
  derived `name`/`description` and a conditional-load `paths` field;
  cross-cutting categories emit as always-on `.claude/rules/<category>.md`
  (no paths). Loose top-level `<topic>.md` (e.g. `cli.md`) folds into its
  category. Expose `packages.set`; `exclude` retained, `extra`/
  `extraPaths` dropped (V9 retired, T6 trimmed). New `compose-set` check.
- Add micro-skill vocabulary to the `narrow-language-markdown`
  dictionary so the new skill files lint clean.
- Scope `narrow-language-other` to yml/toml/justfile/Gemfile via a
  local glob override so it no longer flags LICENSE and dotfiles
  (matches `language/narrow` skill intent).
- Add a heading to each prototype micro-skill file and fix word
  typos so they pass markdownlint and typos checks.
- Record repo-wide lint debt from stricter upstream nix-lefthook as
  SPEC bug B1 and task T32.
- Add `gnu/kill`: how to signal a whole process group portably, and
  the SIGTTOU/SIGTTIN background-group tty stop that freezes pre-push
  hooks (`[ -t 0 ]` does not catch it; `trap '' TTOU TTIN` before
  `/dev/tty` access)
- Update `opensource/ci`: reflect hosted CI via nix-lefthook-ci-action
  three-platform pattern
- Update `lefthook/wrapper-flake-inputs`: add single nix-lefthook
  mega-input as preferred alternative to individual inputs
- Add `nix/python-package`: buildPythonPackage + PyPI wheel patterns
- Add `opensource/repo-scaffold`: standard file set for nix package repos
- Add drafts tree (`set/drafts/`) mirroring `set/skills/` structure
  with 18 atomic skill files and 4 bundle files across 5 categories:
  skill, agent, nix, ops, context
- Generalize hardware concepts into composable templates under
  `concepts/hardware/<vendor>/<model>.md` -- describe capabilities
  not roles (apple/m4, apple/m1pro, pc/ryzen-3700x, pc/thinkpad-t480,
  peripheral/usb-pendrive)
- Rename `security/credentials.md` to `security/auth-hygiene.md` to
  avoid false-positive scanner alerts on filename
- Add `language/active`: prefer active voice over passive
- Add `language/concise`: cut filler, short synonyms, one idea per
  sentence
- Add `language/anodyne`: use neutral language in policy docs to
  avoid AI model refusals
- Add `language/operator`: write docs for operators not developers
- Add `language/imperative`: imperative mood in commits and changelogs
- Add `language/language` bundle composing all 6 language atomics
- Add `lefthook/agentic`: Unix-philosophy output, silence on success
- Add `lefthook/glob`: use glob not exclude for file filtering
- Add `architecture/remote/first`: remote-first execution pattern
- Add `test/qemu/direct-boot`: direct kernel boot for faster smoke
  tests
- Add `test/qemu/cleanup`: kill stale processes and clear boot dirs
- Add `test/qemu/mdns`: flush mDNS cache after QEMU guest shutdown
- Add `test/integration/shared`: shared Tcl health-check library
- Add `test/integration/remote`: fast-fail SSH connectivity with
  exponential backoff

### Setting (standards)

- Split `mkSetting` into two output kinds (V22/T28): materialized
  (`.markdownlint.yml`, `.yamllint.yml` -- always synced, gitignored)
  and seed/init (`.editorconfig`, `.gitattributes`, `.gitignore`,
  `config/lefthook/file_size_limits.yml`, `.narrow-language-*.dic`,
  `.nix-embedded-shell-allowlist` -- scaffolded once, skip-if-exists,
  tracked by consumer). Two scripts: `bin/sync-setting` (materialize,
  always overwrites) and `bin/sync-setting-init` (scaffold, skips
  files that exist). Expose `packages.setting` (materialized-only,
  symmetric with `packages.set`). Add `compose-setting` nix check
  verifying the split. Default gitignore fragments now include
  `"setting"` so materialized configs are gitignored out of the box.
  Setting drift check (`mkSettingDriftCheck`) scoped to materialized
  files only -- seed files are consumer-owned after scaffolding
- Add `setting` gitignore fragment (`.setting`) so a consumer can
  out-link `agent-setting` to `.setting` and have it ignored by the
  managed `.gitignore` -- keeps the out-link drift-clean without a
  hand-edited ignore. Opt in via `gitignore = [ ... "setting" ]`.
  No trailing slash: the out-link is a symlink, and a `dir/` pattern
  matches directories only, not a symlink-to-directory
- `mkSetting`: bundle lint configs (`.markdownlint.yml`, `.yamllint.yml`,
  `config/lefthook/file_size_limits.yml`) into the `agent-setting`
  derivation behind `markdownlint`/`yamllint`/`fileSizeLimits` toggles.
  `sync-setting` still copies only the files git must read as regular
  files; the lint configs stay in the derivation so consumers can
  out-link and point tools at them via `LEFTHOOK_*_CONFIG` -- no
  committed root file, no drift
- `mkSetting`: build the bundle declaratively (`writeTextDir` per file +
  `symlinkJoin`, toggles via `lib.optional`) instead of splicing shell
  command strings into a `runCommand`; extract `sync-setting` into its
  own script

### Spec

- Backprop the opencode loading model (B5, V39; correct V19): opencode
  `opencode.json` `instructions` + `AGENTS.md` are always-on (not
  per-open-file conditional), and opencode ignores per-file frontmatter.
  So only the universal core is always-on for opencode; domains reach it
  via `SKILL.md` + Read-on-demand. Verified vs opencode.ai docs.
- Reconcile task status against the multi-channel/smart-mat reality:
  T40 (rules-only mirror) marked superseded by T47; T42 (apps +
  materialize-check + sync to `.claude/rules/set`) marked done; T43
  folded into T52; T44 reframed as multi-channel re-dogfood (add
  `AGENTS.md` + `SKILL.md` channels to the already-dogfooded rules).
- Spec smart auto-materialization (T53 + V34-V38): mkSet `--auto`
  installs only the *applicable* skill set, derived from repo evidence
  (`paths` AND `content` grep over `git ls-files`) at facet granularity.
  Facets are structural dependencies (facet -> topic core, no declared
  DAG); content is materialize-time-only (`paths` do double duty);
  always-on stays universal-only; selection is audited in the manifest.
  Extend I.meta (`content`), add I.applicability, expand T41 (the meta
  relevance map) as its prerequisite.
- Backprop T50 probe findings: narrow B2 (`SKILL.md` is description-gated,
  not broken -- model-invokes on a matching prompt, just not always-on)
  and add V32 recording the confirmed semantics (path-less rules always-on,
  `@`-recursion, `@`-in-rules, symlink load, `disable-model-invocation`
  blocks) plus the open G2 write-trigger.
- Multi-channel per-agent emit (B3): rules-only over-corrected
  (`.claude/rules` is Claude-only; `@`-import is Claude-only -- opencode
  uses `opencode.json` globs). Best-of-both: per-agent **profile** +
  sidecar **meta map** (`set/meta.nix`) + three channels (always-on core,
  conditional domains, portable `SKILL.md`) + `@`->`AGENTS.md` **compiler**
  for portable always-on + Claude `disable-model-invocation` dedup --
  **gated by a mechanism test suite** (headless agent probes, T50).
  Target Claude now, opencode later. Rewrite V17-V21; add V29-V31,
  I.agentProfile/I.meta/I.compiler/I.mechanism-tests; tasks T45-T52.
- Reverse the emit model to **rules-only** (B2): `.claude/skills/`
  `SKILL.md` is model-invoked and doesn't reliably autoload; only
  `.claude/rules/` loads deterministically. mkSet now mirrors `set/` into
  `.claude/rules/set/` as path-scoped rules (verbatim body + `paths:`),
  **everything path-scoped** (core/universal broad globs, domains narrow)
  to gate loading and avoid context exhaustion. Drop SKILL.md/frontmatter/
  facets-links (rewrite V17-V20, V24, V25; seam -> `{ dir, condField }`).
  Tasks T40-T44 rework the shipped emitter/apps/check/dogfood to rules.
- Specify the zero-dependency `nix run` delivery path (C9): runnable
  `apps.<sys>.{mkSet,mkSetting,mkSetting-init,bootstrap}` that materialize
  skills into `./.claude/skills/set/` from one command (run-time emit).
  Coarse one-SKILL.md-per-category (V24), facets cloned as markdown-linked
  on-demand files (V25), clean-replace per category (V26), core+opt-in
  selection (V27), one emitter for all three paths (V28). Adds I.apps,
  I.manifest; tasks T35-T39 (incl README first-impression WOW). Flips
  done-in-#12 tasks T25/26/27/29 to done.
- Mark T32 done and B1 fixed: repo-wide `lefthook --all-files` is green
  and CI runs the full suite.
- T24: rename propagation mechanism for consumers to detect upstream
  skill renames and update synced copies
- Replace the multi-agent adapter abstraction (drop `I.concepts`,
  `I.agentProfile`, `I.mkAgentDir`, old V20-23, T25-31) with a narrower
  model: two single-source-of-truth builders. `mkSet` emits the
  composable `packages.set` (Agent-Skills open standard) into
  `.claude/skills/set/`; `mkSetting` owns unified config -- materialized
  & gitignored (markdownlint/yamllint/`.claude/`) versus seed/init
  scaffolds for repo-specific files (gitattributes/editorconfig/
  file_size_limits/dics/allowlist). Per-agent surface reduced to a
  `{ dir, condField, alwaysOnFile }` seam. This repo dogfoods
  `packages.set` into a gitignored `.claude/skills/set/` (supersedes T1).
- Agnosticism proof targets the opencode seam (T31); other agents
  (Cursor, Codex, Gemini CLI, Copilot, Amp) move to a future extension
  list (T34).
- Expose `packages.setting` (mkSetting materialize output) for symmetry
  with `packages.set`; seed/init scaffold stays separate.

### Infrastructure

- T20: set up cachix cache for nix builds. Add a `cache-push` CI job
  that builds `packages.x86_64-linux.set` and
  `packages.x86_64-linux.setting` and pushes to the `pr0d1r2` cachix
  cache on main-branch merges. Uses `cachix/install-nix-action` +
  `cachix/cachix-action` directly, bypassing the broken embedded cachix
  inside `nix-lefthook-ci-action` (B8/B10). Runs after all three
  platform checks pass. Requires `CACHIX_AUTH_TOKEN` repo secret. The
  flake `nixConfig` already declares the cache substituter and public
  key so consumers pull from cache without manual setup.
- Extract `mkSet`'s embedded build shell into `set/lib/mk-set.sh`,
  `emit-skill.sh`, and `sync-set.sh` (parametrized via env, no functions);
  `mk-set.nix` drops out of the nix-no-embedded-shell allowlist. Covered
  by `tests/emit-skill.bats`.
- Switch CI to `nix-lefthook-ci-action` (SHA-pinned), replacing the
  hand-rolled `nix flake check` workflow. Three jobs -- Linux gates
  macOS + aarch64-linux (QEMU). Runs the full lefthook suite (incl
  `bats-unit` + `nix-flake-check`) over all files via the `ci` devShell;
  `skip-build` (no `packages.default`); `changelog-touched` excluded
  (commit-gate hook). Caches via cachix `pr0d1r2`. The macOS cold-runner
  flake-check timeout is handled upstream (nix-lefthook-nix-flake-check
  platform-aware default: Darwin 120s).
- Clear the repo-wide lint debt (B1/T32) so `lefthook --all-files` is
  green: fix markdownlint (MD031/032/038/040, fence languages + blank
  lines) across 16 skill files, fix editorconfig left-padding across 11
  files, baseline-freeze the markdown narrow-language dictionary (add the
  repo's existing prose vocabulary), and raise the `.dic` file-size limit
  to fit it. Unblocks running lefthook in CI.
- Extract the drift comparator from `mk-drift-check.nix` and
  `mk-setting-drift-check.nix` into one generic, layout-parametrized
  `lib/drift-check.sh` (no embedded shell in nix; both builders now just
  set env + invoke it). Covered by `tests/drift-check.bats`.
- Add `nix-lefthook-bats-parse` and `nix-lefthook-bats-unit` hooks
  (remotes + flake inputs + devShell wrappers) to lint and run bats unit
  tests, enabling TDD coverage of shell extracted from nix files.
- Add narrow-language dictionary words for the `update-pins` workflow
  (`.github/workflows/update-pins.yml`) so the nix and other hooks pass
- Add `.envrc` -- direnv loads the dev shell from the flake via
  `use flake`, with `watch_file` entries for `flake.lock` and the
  imported nix modules so the shell reloads when they change
- Bump `nix-lefthook-yamllint-src` and `nix-lefthook-file-size-check-src`
  so the bundled wrappers honor `LEFTHOOK_YAMLLINT_CONFIG` and
  `LEFTHOOK_FILE_SIZE_CONFIG` -- consumers can out-link those configs too
- Bump `nix-lefthook-markdownlint-src` to pick up
  `LEFTHOOK_MARKDOWNLINT_CONFIG`, so the bundled wrapper can read a
  markdownlint config from an out-link instead of a committed root file
- Drop `nix-dev-shell-agentic` input -- replace with 18 `flake=false`
  source inputs + `nix-lefthook` flake. Lock reduced 85% (4083 to 626
  lines, 130 to 37 nodes)
- Add `get-file-size-limit` companion wrapper for file-size-check hook
- Add `.nix-embedded-shell-allowlist` for flake.nix
- Add `config/lefthook/file_size_limits.yml` with per-extension limits
- Add `.markdownlint.yml` for SPEC.md/CHANGELOG.md formatting rules
- Replace all em-dashes with `--` for ascii-only compliance
- Wire drafts categories into `mkSet` and flake.nix `drafts` output
- SPEC.md: add V11-V16 invariants, T10-T23 tasks, I.drafts interface
- Wire lefthook hooks: no-shell-functions, shellcheck, shfmt,
  unicode-lint, changelog-touched, commit-msg-lint, nix-flake-eval,
  narrow-language
- Add `.yamllint.yml` raising line-length for lefthook.yml commands
- Add `.claude/` to `.gitignore`

## 0.1.0 -- 2026-05-28

Initial release.

### Set (skills)

- 15 skill categories: generic, architecture, ci, git, gnu, just,
  language, lefthook, nix, nixos, opensource, product, security, test,
  update
- 81 markdown skill files across categories
- 2 concept files (user, hardware)
- `mkSet` builder with category selection, exclude, extra, extraPaths
- Category prefix preserved in output paths to avoid collisions
- `sync-set` script for copying skills to consumer repos
- `set.md` manifest with ordered `@` references

### Setting (standards)

- `.editorconfig` for sh, nix, md, yml, tcl, just, Makefile
- `.gitattributes` marking flake.lock as linguist-generated
- `.gitignore` fragments: nix (.direnv, result), claude (.claude/)
- `mkSetting` builder with composable gitignore fragments
- `sync-setting` script for copying standards to consumer repos

### Infrastructure

- `mkDriftCheck` for CI verification of synced files
- `nix flake check` on aarch64-darwin, x86_64-darwin, x86_64-linux,
  aarch64-linux
- MIT license
- Self-wiring via CLAUDE.md direct `@` references
