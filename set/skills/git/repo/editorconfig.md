# Git repo: editorconfig

`.editorconfig` defines formatting defaults for editors that support
EditorConfig. It ensures consistent indentation and line endings for
contributors who don't use the nix dev shell.

## Rules

- All files: LF line endings, UTF-8, final newline, trim trailing
  whitespace.
- Shell (`.sh`, `.bats`): 4-space indent.
- Nix (`.nix`): 2-space indent.
- Data (`.md`, `.yml`, `.json`, `.toml`): 2-space indent.
- Expect/Tcl (`.exp`, `.tcl`): 4-space indent.
- Just (`justfile`, `.just`): 4-space indent.

## When to update

Add a section when introducing a new file type with non-default
indentation. Keep the file sorted by extension group. Match indent
sizes to what `shfmt`, `nixfmt`, or the relevant formatter enforces.
