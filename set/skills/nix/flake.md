# Nix: flake

The project starts with nix flake.
Give the flake dev shells that support macOS and Linux on arm and amd64.
Extract embedded shell into nix/dev/shell.sh.

Keep a thin leaf flake in one file. When independent, same-shaped outputs
start repeating or one output type dominates the file, modularize it with
the method in [flake/structure.md](flake/structure.md).

Treat `flake.nix` as a manifest: keep only `description`, `nixConfig`,
literal `inputs`, and a one-line output import:

```nix
outputs = inputs: import ./flake inputs;
```
