# Nix develop

All work must happen inside `nix develop` (or via direnv which
activates it). The dev shell provides every tool the repo needs:
linters, formatters, test runners, GNU coreutils, and lefthook
hook commands. Running commands outside the dev shell will hit
missing tools or macOS BSD variants.

Use `nix develop --command <cmd>` for one-shot operations like
commits and pushes that need lefthook hooks to pass.

Using `nix develop` should supersede `direnv exec .` invocations
as they are the same with extra wrapping.
