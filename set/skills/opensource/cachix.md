# Open-source: cachix

Open-source Nix projects should use Cachix free tier to serve
pre-built binary caches. Without a cache, every contributor and
CI run rebuilds from source -- slow and wasteful.

## Setup

1. Create cache at cachix.org (free for open-source)
2. Add `cachix use <name>` to CONTRIBUTING.md setup steps
3. Configure substituters in `flake.nix` `nixConfig` or
  `extra-substituters`
4. Push builds with `cachix push <name>` after successful `nix build`

## Cross-repo flake dependencies

When repo A depends on repo B as a flake input, Nix rebuilds B
from source unless a binary cache has it. A shared Cachix cache
across related repos eliminates redundant builds. One cache per
org/user serving all repos is simpler than per-repo caches.

## PII and secrets risk

Nix store paths are hash-based, but `builtins.readFile` and
`pkgs.writeText` embed file contents into derivations at eval
time. Any derivation built from config containing IPs, SSH keys,
hostnames, or credentials will have those values in the binary
cache.

**Gitignore does not protect against this.** `builtins.readFile`
reads files at eval time regardless of git state. If those
derivations are then pushed to cachix, the secrets become public.

**Safe to cache publicly:** devShell (no `readFile` of secrets),
generic build tools -- no project data.

**Never cache publicly:** system derivations that embed firewall
allowlists, SSH keys, or tunnel config at eval time.

**Selective push:** only push safe outputs explicitly:

```sh
cachix push <name> $(nix build .#devShells.x86_64-linux.default --print-out-paths)
```

Never use blanket `cachix push` after a full system build.

Rule: only push derivations whose inputs are already public
(nixpkgs, flake inputs, open-source scripts).

## Additional risks

- **No undo:** once pushed, clients cache locally. Deleting from
  cachix does not recall already-fetched store paths.
- **Build logs:** cachix stores build logs. If builds print
  secrets to stdout/stderr, logs are public.
- **Signing key:** cachix auth token and signing key are
  deployment-grade secrets. Leaked key = attacker pushes trusted
  malicious binaries to all cache users.
- **Reference graph:** narinfo exposes full dependency tree of
  pushed derivation. System narinfo = complete package list =
  attack surface map. Only push leaf packages, not full closures.
- **Store path names:** name component of `/nix/store/<hash>-name`
  reveals package versions and build variant info.

## Convention

- Cache name matches repo name or org name when shared
- Public key goes in flake.nix so users get cache without manual setup
- CI pushes to cache on every successful main build
- Never push secrets or private derivations to public cache
- Audit `builtins.readFile` targets before adding new cache pushes
