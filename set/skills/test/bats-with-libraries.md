# Bats: use bats.withLibraries in nix

Never set `BATS_LIB_PATH` manually in `mkShell`. Use
`pkgs.bats.withLibraries` which bakes the path into a wrapper script.

## Why

Manual `BATS_LIB_PATH` env var breaks in two ways:

1. `nix develop --ignore-environment` (CI) may not preserve it
2. Multiple bats wrappers create colon-joined `BATS_LIB_PATH` —
   `load "${BATS_LIB_PATH}/bats-support/load.bash"` embeds colons
   in path and fails

## Fix

```nix
batsWithLibs = pkgs.bats.withLibraries (p: [
  p.bats-support
  p.bats-assert
  p.bats-file
]);
```

Add `batsWithLibs` to devShell packages. No `BATS_LIB_PATH` env var
needed — wrapper sets it.

## Tests must use bats_load_library

```bash
setup() {
    bats_load_library bats-support
    bats_load_library bats-assert
}
```

Not `load "${BATS_LIB_PATH}/..."` — that breaks with colon-separated
paths. `bats_load_library` iterates BATS_LIB_PATH correctly.

## Upstream tools

Any nix package using `writeShellApplication` with `runtimeInputs`
containing bats must also use `bats.withLibraries`, not plain `bats`.
Otherwise the bundled bats lacks library paths.
