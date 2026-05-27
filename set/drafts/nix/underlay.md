# Nix: underlay

An underlay is a nixpkgs overlay pattern that provides packages
without overriding existing ones. It adds to the package set rather
than replacing.

## Rules

- Underlay adds new attributes to pkgs, never shadows existing ones.
- Use `final: prev:` overlay syntax. Check `prev ? attrName` before
  adding to avoid collision.
- Expose underlay via flake `overlays.default` output.
- Consumer applies underlay in their nixpkgs instance:
  `nixpkgs.overlays = [ repo.overlays.default ]`.
- Test: verify underlay makes expected packages available without
  breaking existing package evaluation.
- Composable: multiple underlays from different repos stack without
  conflict as long as attribute names are unique.
