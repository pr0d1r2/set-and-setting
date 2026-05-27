# Test: QEMU

QEMU is used for integration testing: smoke boot validation, full
health checks, and sandboxed environment testing.

## Resource allocation

Guest resources scale dynamically to the builder host. Environment
variables override auto-detection. Auto-detect uses 75% of host
cores/RAM with sensible minimums.

## Remote vs local execution

QEMU requires KVM (Linux x86_64). On macOS, scripts delegate to a
remote builder via SSH.

## Key QEMU flags

- `-enable-kvm -cpu host` -- near-native performance
- `-serial stdio -display none -monitor none` -- headless serial
  console
- `-no-reboot` -- exit on guest shutdown instead of rebooting
- `-fw_cfg` -- inject config into guest

## Build caching

The artifact is built once per git SHA. Build scripts search by SHA
both locally and on remote builders. Within a single pre-push run,
the first test builds; subsequent tests reuse the cached artifact.
