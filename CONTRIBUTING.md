# Contributing

## Prerequisites

- [Nix](https://nixos.org/) with flakes enabled

## Development

```bash
nix flake check
```

## Adding skills

Add markdown files under `set/skills/<category>/`. Follow the
`<topic>.md` + `<topic>/<aspect>.md` naming convention.

Register new categories in both `flake.nix` (`sets` attrset) and
`set/lib/mk-set.nix` (`categoryDirs` attrset).

## Adding standards

Add files under `setting/standards/`. For gitignore fragments, use
`setting/standards/gitignore/<name>.gitignore`.

## Commits

Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`,
`ci:`, `test:`.

## License

By contributing you agree your work is licensed under MIT.
