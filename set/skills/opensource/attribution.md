# Open-source: attribution

`ATTRIBUTION.md` at the repo root lists all external software,
services, and sources. Update it whenever a dependency enters or
leaves the project.

## When to update

- Adding a package to `flake.nix` (devShell or system) -- add to
  dev tools or system packages
- Adding a flake input -- add to flake inputs
- New runtime API dependency -- add to external services
- Removing a dependency -- remove the row

## License column

Include the license for platform and tooling entries. For nixpkgs
packages, the license is implicit (nixpkgs tracks it).
