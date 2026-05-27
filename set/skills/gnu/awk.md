# GNU awk

Always use `gawk` from the dev shell (nixpkgs `gawk`). BSD awk
on macOS lacks `gensub()`, `FPAT`, `nextfile`, `@include`, and
other GNU extensions. Use `awk` (which points to gawk in the dev
shell) not `/usr/bin/awk`.
