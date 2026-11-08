# CI: QEMU must install before nix-daemon

For aarch64-linux, use a native `ubuntu-24.04-arm` runner instead of
QEMU (see `ci/multi-platform-gate`). Use QEMU only for a platform with
no native runner.

`nix-lefthook-ci-action` installs QEMU itself when `extra-platforms`
is set. On Ubuntu 26.04 `qemu-user-static` is a virtual package, so
the install below fails there; the action picks `qemu-user-binfmt`
instead. Hand-written steps must do the same.

`extra-platforms` lets the daemon build foreign derivations, but
`nix build` and `nix flake check` still target the host system. Name
the foreign system explicitly, or the job builds nothing foreign:

```bash
nix build -L .#packages.aarch64-linux.default
nix flake check -L --system aarch64-linux
```

When using QEMU for cross-architecture nix builds, install QEMU and
register binfmt BEFORE nix-installer-action.

The nix-daemon reads `extra-platforms` at startup and checks for
kernel binfmt_misc handlers. If QEMU isn't registered yet, the daemon
sees no handler and builds fail with "platform mismatch".

## Correct order

```yaml
steps:
  - name: Set up QEMU
    run: |
      sudo apt-get update -q
      sudo apt-get install -yq qemu-user-static binfmt-support
      sudo update-binfmts --enable qemu-aarch64

  - uses: DeterminateSystems/nix-installer-action@main
    with:
      extra-conf: extra-platforms = aarch64-linux
```

## Wrong order

```yaml
steps:
  - uses: DeterminateSystems/nix-installer-action@main  # daemon starts, no binfmt
  - run: sudo apt-get install -yq qemu-user-static      # too late
```

## Platform detection in tests

Use `nix eval --raw --impure --expr builtins.currentSystem` instead
of `uname -m`. On QEMU runners, uname returns the host arch (x86_64)
but nix correctly reports aarch64-linux when extra-platforms is set.
