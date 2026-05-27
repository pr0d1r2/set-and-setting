# Open-source: repo scaffold

Standard file set for open-source nix package repos.

## Required files

```
repo/
├── .editorconfig          # formatting rules (2-space indent, LF, UTF-8)
├── .envrc                 # `use flake` for direnv
├── .gitignore             # result, result-*, .direnv, .claude/settings.local.json
├── .github/workflows/
│   └── ci.yml             # three-platform CI via nix-lefthook-ci-action
├── .gitleaks.toml         # secret scanning config
├── .markdownlint.yml      # MD013 false, MD024 false
├── .yamllint.yml          # truthy check-keys false, line-length disable
├── LICENSE                # MIT
├── README.md              # badge, usage as flake input, cachix setup
├── SPEC.md                # CAVEKIT format: §G §C §I §V §T §B
├── cachix-check.sh        # verify binary cache per system
├── dev.sh                 # shell hook: NIX_CONFIG + lefthook install
├── flake.lock             # committed, reproducible
├── flake.nix              # cachix nixConfig, nix-lefthook input, ci+default shells
├── lefthook.yml           # 15+ remotes, pre-commit/pre-push parallel
└── package.nix            # actual build expression
```

## flake.nix pattern

Three inputs: nixpkgs, source (flake=false), nix-lefthook.
Two devShells: `ci` (for CI, no shellHook) and `default` (with
dev.sh shellHook). Both use `inputsFrom` from nix-lefthook.

## Initialization

```bash
mkdir repo && cd repo && git init && git checkout -b main
# create all files
git add -A
nix flake lock
nix develop .#ci --command bash -c 'nixfmt *.nix && git add -A && lefthook install && git commit -m "Initial release"'
gh repo create owner/repo --public --source . --remote origin --push
```

## Branch protection

```bash
gh api repos/OWNER/REPO/branches/main/protection -X PUT --input - <<'JSON'
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON
```

## Cachix

Set secret: `gh secret set CACHIX_AUTH_TOKEN --repo OWNER/REPO`

Public key in flake.nix nixConfig — consumers get cache without
manual setup.
