# Linter

Every file type tracked in git must have an assigned check. When adding
a new file type to the repo, add its check before committing.

## Stacked devShells

Two shells, one gate:

- `default` — CI + non-LLM full tooling (linters, formatters, test
  runners, coreutils). CI runs this shell.
- `agentic` — `default` + LLM tools. Inherits `default` via
  `inputsFrom`; never duplicates its packages.

`default ⊂ agentic`. Every linter, hook tool, and non-LLM dev tool
(asciinema, formatters, test runners) goes in `basePackages`.
`agentic` gets them automatically via stacking.
Only LLM-specific tools (claude, trip harness) go in
`agenticPackages`.

CI runs the same lefthook gate as local hooks — `nix develop .#default`
with no skip. A commit that passes locally passes CI; a commit that
fails CI fails locally.

## Closing gaps

When adding a new file type, close the linter gap in a follow-up
commit: add the linter tool, configure its check, fix violations.
Do not leave uncovered extensions.

## How to verify coverage

Run this to find uncovered extensions:

```bash
git ls-files | sed 's/.*\.//' | sort -u
```

Compare against the project's linter coverage table. Any new extension
must be assigned a linter or explicitly marked as exempt with a reason.

## Adding a new linter

1. Add the pinned flake input for the tool (`nix-lefthook-<tool>-src`), so the lint logic is pinned and updates via `nix flake update` rather than a runtime fetch.
2. Add a `lib.mk<Tool>Check` convenience helper closing over that input, built on `lib/mk-lefthook-check.nix`. Its arguments include `suffices` (`null` for glob-less whole-tree tools) and `checkFlag` (`""` for wrappers with no check flag).
3. Register the check in `lib/check-fragment-map.nix`: add it to `checksPerFragment` for its fragment and to `pinnedChecks` because it has a `mk*Check` equivalent. Consumers then receive it automatically through `checksFor`.
4. Add a `<tool>-catches-violation` proof, matching the pattern every converted tier follows. A check that has never been shown to fail is not evidence.
5. Keep the tool in the devShell packages if it is wanted for local runs; that is separate from the check.
6. Fix existing violations before committing.

V41's constraint still applies: a tool delivered as a pinned check must not
also appear as a lefthook `remotes:` entry. Post-FLIP there are no remotes at
all, so do not add one.

`lefthook.yml` is an assembled artifact. Content that belongs in a hook goes
in the matching fragment under `setting/integrations/lefthook/`, never in the
assembled file.
