# Nix: modularity

Extract embedded shell from Nix files into parameterized shell scripts.
Add a `watch_file` entry to `.envrc` for every file extracted this way.
Extract embedded XML into separate files.

Keep Nix modules independent. Pass shared dependencies through arguments
or a stable assembly interface such as flake-level `self`; never import a
sibling module. If two modules need the same logic, extract that logic into
a common library and import it once at the assembly boundary.

For flake output modules, follow the concrete split, discovery, library,
and contract rules in the "Nix flake: structure" section. Threading
`self` into independent leaves is assembly, not module-to-module coupling.
