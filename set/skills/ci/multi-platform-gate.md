# CI: multi-platform build gating with nix-lefthook-ci-action

When a flake supports multiple arch-OS combinations, structure CI so
the cheapest platform gates the expensive ones. Use
`nix-lefthook-ci-action` everywhere — it bundles DeterminateSystems
nix installer + cachix.

## Pattern

```text
check-linux (lint + build x86_64) ──> check-darwin (macos runner)
                                  └──> check-linux-arm (native aarch64)
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
    runs-on: ubuntu-24.04-arm
    steps:
      - uses: pr0d1r2/nix-lefthook-ci-action@SHA
        with:
          skip-build: "true"
          skip-lefthook: "true"
          cachix-auth-token: ${{ secrets.CACHIX_AUTH_TOKEN }}
      - run: nix build .#nixosConfigurations.linux-arm.config.system.build.toplevel -L
```

### Repos without lefthook (flake check only)

Same structure but replace `nix build` with `nix flake check`:

```yaml
      - run: nix flake check --accept-flake-config
```

On the native ARM runner, `nix flake check` checks aarch64-linux by default.
It builds only `checks`, so a flake whose checks do not depend on its
package passes without building it. Add a check that depends on the
package, or also run `nix build -L`.

## Use a native ARM runner

Run the ARM job on `ubuntu-24.04-arm`, not on an x86_64 runner with
`extra-platforms`. `nix build` and `nix flake check` target the host
system, so an x86_64 job with `extra-platforms = aarch64-linux` passes
without building aarch64-linux at all. A native runner also avoids
QEMU emulation, which is slow.

Use QEMU only for a platform with no native runner. See the
`ci/qemu-nix-order` skill.

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
