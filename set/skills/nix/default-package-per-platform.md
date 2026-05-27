# Nix: default package per platform

Multi-platform config repos should map `packages.default` to the
current platform's system config. Then `nix build` just works on
any supported platform with no flags or config names to remember.

## Implementation

```nix
packages = forAllSystems (pkgs: {
  default =
    {
      "aarch64-darwin" = self.darwinConfigurations."macos-arm".system;
      "x86_64-linux" = self.nixosConfigurations."linux".config.system.build.toplevel;
      "aarch64-linux" = self.nixosConfigurations."linux-arm".config.system.build.toplevel;
    }
    .${pkgs.stdenv.hostPlatform.system};
});
```

Requires `self` in the outputs function args.

## Benefits

- `nix build` works on any platform — no flags needed
- CI actions that run `nix build` (like nix-lefthook-ci-action)
  work without `skip-build`
- `build.sh` simplifies to just `nix build`
- Integration tests can check `./result` exists regardless of
  platform

## CI consequence

With `packages.default`, remove `skip-build: "true"` from
ci-action inputs. The action's internal `nix build` step builds
the correct config automatically per runner platform.
