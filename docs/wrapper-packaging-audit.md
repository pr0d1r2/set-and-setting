# Pinned wrapper packaging audit

Audited 2026-08-11 against the `flake.nix`/Nix packaging in each pinned
`nix-lefthook-*` source input. “Match” means the wrapper script and upstream
runtime inputs/build substitutions are represented locally; “intentional”
documents a deliberate repository-specific adaptation.

| wrapper | upstream packaging | result |
| --- | --- | --- |
| commit-msg-lint | `coreutils`, `gnused` | Fixed: added `gnused`. |
| changelog-touched | `git`, `gnugrep` | Match. |
| ascii-only | `gnugrep` | Match. |
| deadnix | `deadnix` | Match. |
| editorconfig-checker | `editorconfig-checker` | Match. |
| execute-permissions | `gnugrep` | Match. |
| file-size-check | `get-file-size-limit`, `gawk`, `gnugrep`, `coreutils` | Match; helper is rebuilt locally from the pinned source. |
| git-conflict-markers | `gnugrep` | Match. |
| gitleaks | `gitleaks`, `coreutils` | Match. |
| git-no-local-paths | `gnugrep` plus upstream substitution | Intentional: the source script is used with the same local substitution-free behavior currently required by this checker; placeholder validation guards future substitutions. |
| missing-final-newline | none | Match. |
| narrow-language (4 wrappers) | coreutils/awk/grep/sed and, where used, git | Match. |
| nix-flake-check/eval | `nix` | Match. |
| nixfmt | `nixfmt` | Match. |
| nix-no-embedded-shell | injected scanner path | Intentional and equivalent: injects the scanner from the pinned source. |
| no-shell-functions | none | Match. |
| shellcheck | `shellcheck` | Match. |
| shfmt | `shfmt` | Match. |
| statix | `statix` | Match. |
| trailing-whitespace | `gnugrep` | Match. |
| typos | `typos` | Match. |
| unicode-lint | `gnugrep`, `libiconv`, `python3`, `perl` | Fixed: added `python3` and `perl`. |
| yamllint | `yamllint` | Match. |
| markdownlint | `markdownlint-cli`, classifier helper | Intentional: classifier is repository-specific but supplies upstream’s required helper. |
| markdownlint-agentic | `markdownlint-cli`, classifier helper, config substitution | Intentional: substitutes the repository’s standards config and supplies its classifier; placeholder check prevents omission. |

## Consumption decision

The inputs remain `flake = false`. Building upstream package outputs directly
would require evaluating each upstream flake with its transitive inputs and
would make the checks resolve through a different package graph than the
repository’s pinned-source design. The local wrappers preserve the existing
offline/pinned check behavior. This audit plus the install-time placeholder
check is the selected drift-control boundary; runtime dependency omissions are
reviewed whenever a source pin changes.
