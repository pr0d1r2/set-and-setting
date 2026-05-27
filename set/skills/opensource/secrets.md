# Open-source: secrets

No credentials, keys, or tokens in tracked files. This is enforced
at multiple levels.

## Gitignored directories

- `secrets/` -- SSH host keys, authorized_keys, credential caches
- Config allowlists -- operator IP allowlists (contain real IPs)
- `.claude/` -- Claude Code session state and credentials
- `outputs/` -- results that may contain runtime credentials

## .example templates

Every gitignored config file has a tracked `.example` counterpart.
When adding a new secret or config file, create the `.example` first.

## Nix evaluation boundary

Secrets should be read at activation time, not flake eval time.
Secret directories are referenced via relative paths -- these files
must exist at build time but their contents should never enter the
nix store derivation as strings.

## What to check before committing

- `git diff --cached --name-only` -- no files under `secrets/`, no
  `.credentials.json`, no `.env`, no private keys
- No hardcoded IPs (operator addresses belong in gitignored
  allowlists)
- No OAuth tokens or API keys in string literals
- `.example` files use placeholder values
