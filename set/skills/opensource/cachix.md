# Open-source: Cachix

Every open-source repository that contains Nix code uses the shared
`pr0d1r2` binary cache. This keeps the cache setup consistent across the
fleet and lets a contributor reuse the outputs built by CI.

## Flake configuration

Put the shared cache and its public key in the flake's `nixConfig`:

```nix
nixConfig = {
  extra-substituters = [ "https://pr0d1r2.cachix.org" ];
  extra-trusted-public-keys = [
    "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM="
  ];
};
```

The cache is a substitute, not a requirement for evaluation or building.
The repository must remain usable when the cache is unavailable.

## GitHub Actions

The workflow installs Nix with the shared cache configured, then realizes the
outputs that contributors need. Add Cachix immediately after the build step:

```yaml
- name: Build outputs
  run: nix build .#default .#devShells.x86_64-linux.default --no-link
- name: Push built paths to the shared cache
  continue-on-error: true
  uses: cachix/cachix-action@5f2d7c5294214f71b873db4b969586b980625e71 # v17
  with:
    name: pr0d1r2
    authToken: ${{ secrets.CACHIX_AUTH_TOKEN }}
```

Use a full commit SHA for the action, with its release tag in a comment. Set
`CACHIX_AUTH_TOKEN` as a repository secret; never put the token in YAML, a
flake, or a tracked example file. Pull requests from forks may not have the
secret, so the push step must be conditional when the workflow would
otherwise invoke it without a token:

```yaml
if: secrets.CACHIX_AUTH_TOKEN != ''
```

The cache push may not decide a build or release. It runs after the outputs
already succeeded, and its result concerns the cache service and network.
`continue-on-error: true` keeps a slow or unavailable cache from blocking a
release while still reporting the failed step in the Actions run.

Push only outputs whose inputs are public. Do not blanket-push system
closures or derivations that read secrets, private configuration, SSH keys,
firewall allowlists, or other operator data at evaluation time. Prefer leaf
packages and explicitly selected dev shells.

## Checklist

- `flake.nix` names `https://pr0d1r2.cachix.org` and the matching public key.
- CI configures the same substituter before Nix evaluates the flake.
- CI builds the outputs that developers actually consume.
- A post-build `cachix/cachix-action` step pushes to `pr0d1r2`.
- The push has `continue-on-error: true` and is conditional on the token when
  forked pull requests can reach the job.
- `CACHIX_AUTH_TOKEN` exists only as a repository secret.
- Every pushed derivation has public inputs and contains no secret data.
