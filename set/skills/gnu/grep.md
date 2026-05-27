# GNU grep

Always use `grep` from the dev shell (GNU grep via nixpkgs `gnugrep`).
BSD grep on macOS lacks `-P` (Perl regex) and has different
`--include`/`--exclude` behavior. GNU grep is consistent across
all architectures.
