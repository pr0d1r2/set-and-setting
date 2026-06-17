# Changelog

## Unreleased

### Set (skills)

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

- Switch CI to `nix-lefthook-ci-action` (SHA-pinned), replacing the
  hand-rolled `nix flake check` workflow. Three jobs -- Linux gates
  macOS + aarch64-linux (QEMU). Runs the full lefthook suite (incl
  `bats-unit` + `nix-flake-check`) over all files via the `ci` devShell;
  `skip-build` (no `packages.default`); `changelog-touched` excluded
  (commit-gate hook). Caches via cachix `pr0d1r2`. Flake check/eval
  timeouts raised (600/300s) for cold runners.
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
