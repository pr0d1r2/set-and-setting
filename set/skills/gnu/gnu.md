# GNU over BSD

Prefer GNU versions of command-line tools over BSD equivalents.
The dev shell provides GNU coreutils, grep, sed, gawk, findutils
via nixpkgs so scripts behave identically on macOS and Linux. This
keeps the environment as close to Linux as possible even on macOS
where BSD variants ship by default. NixOS modules also use explicit
GNU packages (gawk, coreutils, gnugrep, gnused, findutils) in
service PATH declarations.

Never use `/usr/bin/` paths -- always rely on dev shell or NixOS
module PATH which resolve to GNU variants.
