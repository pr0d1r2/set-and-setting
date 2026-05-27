# Open-source: licensing

The project is MIT-licensed. All contributions fall under the same
terms. No CLA required.

## Dependency compatibility

MIT is permissive -- compatible with most licenses. When adding nix
dependencies:

| License | Compatible | Notes |
| ------- | ---------- | ----- |
| MIT, ISC, BSD-2, BSD-3 | yes | Permissive, no issues |
| Apache-2.0 | yes | Patent grant clause, compatible with MIT |
| MPL-2.0 | yes | File-level copyleft, compatible at project level |
| LGPL-2.1, LGPL-3.0 | yes | Dynamic linking OK, nix packages are separate |
| GPL-2.0, GPL-3.0 | no | Would require entire project to be GPL |
| AGPL-3.0 | no | Network-use trigger, incompatible |
| Proprietary | no | Cannot redistribute |

## How to check

Inspect a package's license before adding it:

```bash
nix eval nixpkgs#PACKAGE.meta.license.spdxId
```

## Third-party code

No vendored third-party code in the repo. All dependencies come
through nixpkgs. If vendoring becomes necessary, add the source's
license file alongside it and note the license in CHANGELOG.md.
