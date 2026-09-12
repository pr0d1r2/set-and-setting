# Lefthook: hk.pkl scripts

Keep `hk.pkl` step bodies as paths to executable scripts. A step value must
be a one-line path such as `check = ".gate/module-size.sh"`; never put a
newline or shell program in a Pkl string. This leaves the body visible to
`shellcheck` and `shfmt`, and makes it possible to test without breaking the
project.

Put shared shell behaviour in `.gate/prelude.sh` and source it from every
gate script:

```sh
#!/bin/sh
set -eu

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

need_tool() {
  command -v "$1" >/dev/null 2>&1 || fail "$2"
}
```

Scripts should source the prelude, call `need_tool` before using an external
tool, and call `fail` from an explicit `if` branch. Do not use a bare
`condition && echo ...` as the final command: under hk's `-e`, a false
condition is a failed step. Keep the prelude's dialect fixed (`sh`, `set -eu`)
and make scripts executable.

Keep advice in data, not in an interpolated shell command. Prefer a quoted
variable or a single-quoted argument to `fail`, for example:

```sh
hint='hk: run `direnv allow` and retry'
if ! command -v direnv >/dev/null 2>&1; then
  fail "$hint"
fi
```

The backticks above are literal text because they are inside the value; they
are never placed in a double-quoted command argument containing shell source.
Quote paths and data, and put `awk` programs in the script itself so the
shell and Pkl do not provide a second escaping layer.

When migrating an existing step, copy its body verbatim into a `.gate/*.sh`
file first, add the prelude and shebang, then fix shell semantics under
`shellcheck`/`shfmt`. Exercise both the passing and failing branches directly
and compare their output with the old step before replacing the Pkl body.

Add a repository check that parses `hk.pkl` step assignments and fails if a
step value contains a newline. Run it for both tracked and staged files, and
run `shellcheck` and `shfmt` over `.gate/*.sh`; the gate must lint its own
gate. This is a structural check, not a convention: a multiline `check` or
`fix` body is an error even when its shell happens to work.
