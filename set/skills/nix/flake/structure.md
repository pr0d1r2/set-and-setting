# Nix flake: structure

Use this method when a flake has multiple independent outputs of the same
shape, repeated declarations, or an output type that dominates `flake.nix`.
Leave a thin, cohesive leaf flake alone.

## Assemble outputs

Keep `flake.nix` as a manifest. Put output implementation under `flake/`,
with `flake/default.nix` threading `inputs`, `self`, and supported systems
through the modules and merging their returned output attribute sets.

Give each output type a directory of independent leaf modules.

- Use a directory for multiple independent, same-shaped leaves.
- Use one file for a cohesive builder or pure assembly glue.
- List modules explicitly when each attribute name is a public contract,
  such as a verb invoked with `nix run .#bootstrap`.
- Use `builtins.readDir` only for bulk-uniform internal leaves, such as
  generated per-hook canaries.
- Import each domain library once in `flake/lib.nix`. Expose helpers such as
  `mkSet`, `mkSetting`, and `mkLefthookCheck` through `self.lib`; consume
  `self.lib.*` in leaves instead of repeating imports.
- Preserve every public output attribute byte-for-byte while moving it.
  A tidy filename does not justify renaming `bootstrap`, `migrate`, or any
  other fleet contract: a renamed `nix run .#<app>` can silently no-op.
- Make leaves depend only on `self` and explicit arguments. Never import a
  sibling leaf, such as importing `../apps/x.nix` from a check. Extract a
  shared helper to `flake/lib.nix` or pass shared data from the assembler.

## Project this repository

Use this target as the specification for the standards hub migration; it
describes the intended layout and does not claim that migration is complete:

```text
flake/
  default.nix          # assembler: thread systems/self/inputs; merge outputs
  systems.nix          # forAllSystems glue
  registry.nix         # sets/drafts/settings path-map glue
  lib.nix              # self.lib: mkSet/mkSetting/mk*Check; one import site
  apps/                # 10 verb leaves, mk-app.nix, and explicit default.nix
  packages/            # set.nix, setting.nix, and default.nix
  checks/              # generated lefthook plus set/setting/drift/migrate leaves
  hooks/               # registry.nix, generators.nix, and wrap.nix
  devshells/           # one cohesive default.nix builder
```

Split `devshells/default.nix` per shell only when the shells stop sharing a
base. Keep public app names explicit even when their filenames differ.

## Generate hook outputs from one registry

Declare each lefthook integration once. Generate its wrapper, check, and
`-catches-violation` canary from the same record instead of maintaining the
hook at four sites:

```nix
# flake/hooks/registry.nix
{ inputs }:
{
  nixfmt = {
    src = inputs.nix-lefthook-nixfmt-src;
    pkg = "nixfmt-rfc-style";
    fixture = ./fixtures/nixfmt;
  };
  shfmt = {
    src = inputs.nix-lefthook-shfmt-src;
    pkg = "shfmt";
    fixture = ./fixtures/shfmt;
  };
}
```

Put shape-specific construction in `hooks/generators.nix` and wrapper
mechanics in `hooks/wrap.nix`. Have checks consume the generated result
through `self`, never by importing a hook or app leaf.
