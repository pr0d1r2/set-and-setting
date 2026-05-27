# GNU sed

Always use `sed` from the dev shell (GNU sed via nixpkgs `gnused`).
Never use macOS built-in `/usr/bin/sed` which is BSD sed and has
incompatible flag syntax (e.g. `-i ''` vs `-i`). The dev shell
provides GNU sed on all architectures so scripts stay portable.
