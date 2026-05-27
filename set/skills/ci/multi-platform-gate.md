# CI: multi-platform build gating with nix-lefthook-ci-action

When a flake supports multiple arch-OS combinations, structure CI so
the cheapest platform gates the expensive ones. Use
`nix-lefthook-ci-action` everywhere — it bundles DeterminateSystems
nix installer + cachix.

## Pattern

```
check-linux (lint + build x86_64) ──> check-darwin (macos runner)
                                  └──> check-linux-arm (QEMU aarch64)
```

Linux x86_64 runs first (free tier, fast). Darwin and ARM only start
after linux passes. No duplicate work.

## Implementation

### Repos with lefthook (lint + build)

```yaml
jobs:
  check-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: pr0d1r2/nix-lefthook-ci-action@SHA
        with:
          skip-build: "true"
          keep-home: "true"
          extra-env: "LEFTHOOK_EXCLUDE=flake-nix-build"
          cachix-auth-token: ${{ secrets.CACHIX_AUTH_TOKEN }}
      - run: nix build .#nixosConfigurations.linux.config.system.build.toplevel -L

  check-darwin:
    needs: check-linux
    runs-on: macos-latest
    steps:
      - uses: pr0d1r2/nix-lefthook-ci-action@SHA
        with:
          skip-build: "true"
          skip-lefthook: "true"
          cachix-auth-token: ${{ secrets.CACHIX_AUTH_TOKEN }}
      - run: nix build .#darwinConfigurations.macos-arm.system -L

  check-linux-arm:
    needs: check-linux
    runs-on: ubuntu-latest
    steps:
      - name: Set up QEMU for aarch64
        run: |
          sudo apt-get update -q
          sudo apt-get install -yq qemu-user-static binfmt-support
          sudo update-binfmts --enable qemu-aarch64
      - uses: pr0d1r2/nix-lefthook-ci-action@SHA
        with:
          skip-build: "true"
          skip-lefthook: "true"
          cachix-auth-token: ${{ secrets.CACHIX_AUTH_TOKEN }}
          pre-build-commands: |
            echo "extra-platforms = aarch64-linux" | sudo tee -a /etc/nix/nix.conf
            sudo systemctl restart nix-daemon
      - run: nix build .#nixosConfigurations.linux-arm.config.system.build.toplevel -L
```

### Repos without lefthook (flake check only)

Same structure but replace `nix build` with `nix flake check`:

```yaml
      - run: nix flake check --accept-flake-config
```

For linux-arm, add `--system aarch64-linux` to only check that system.

## QEMU must come before nix-daemon

Install QEMU as a step BEFORE `nix-lefthook-ci-action`. The kernel
binfmt_misc handler must be registered before nix-daemon starts.
Then use `pre-build-commands` to add `extra-platforms` to nix.conf
and restart the daemon.

## Cachix

All jobs use `cachix-auth-token` for push. First run warms cache,
subsequent runs pull from `pr0d1r2` cachix. Set secret:

```bash
gh secret set CACHIX_AUTH_TOKEN --repo OWNER/REPO
```

## Branch protection

Required status checks must list all platform jobs:

```bash
gh api repos/OWNER/REPO/branches/main/protection/required_status_checks \
  -X PATCH --input - <<'EOF'
{
  "strict": true,
  "checks": [
    {"context": "check-linux", "app_id": 15368},
    {"context": "check-darwin", "app_id": 15368},
    {"context": "check-linux-arm", "app_id": 15368}
  ]
}
EOF
```
