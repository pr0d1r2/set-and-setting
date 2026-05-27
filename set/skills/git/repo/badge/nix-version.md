# Git repo: NixOS version badge

The NixOS version badge in README.md shows which nixpkgs channel the
project is built against. This tells contributors which package set
and kernel to expect.

## Badge format

```markdown
[![NixOS VERSION](https://img.shields.io/badge/NixOS-VERSION-blue.svg?logo=nixos)](https://nixos.org)
```

## When to update

Update the badge when bumping the nixpkgs input in `flake.nix`. The
version number comes from the channel URL:

```nix
nixpkgs.url = "github:NixOS/nixpkgs/nixos-VERSION";
```

Change the version in the badge to match. This is a manual step --
there is no auto-sync between flake.nix and README.md badges.
