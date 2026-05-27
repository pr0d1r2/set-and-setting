# CI: QEMU must install before nix-daemon

When using QEMU for cross-architecture nix builds (e.g. aarch64-linux
on x86_64), install QEMU and register binfmt BEFORE nix-installer-action.

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
