# Nix: composability

Nix modules across multiple repos compose into an infinite attachable
tree. Each repo is a puzzle piece on an infinite canvas — it exposes
typed interfaces that other repos snap into.

## Rules

- Every repo exposes its module via flake outputs. Consumer imports
  as flake input.
- Module interface is the public API. Internal structure can change
  without breaking consumers.
- Minimize overlap: if two repos need the same logic, extract to a
  third repo rather than duplicating.
- Composition is always via nix module system (imports, options,
  config), never via file copying or shell scripts at build time.
- Test composition: consumer repo's `nix flake check` must verify
  that imported modules evaluate correctly together.
- Pin versions via flake.lock. Upgrade deliberately via
  `nix flake update`, never implicitly.
