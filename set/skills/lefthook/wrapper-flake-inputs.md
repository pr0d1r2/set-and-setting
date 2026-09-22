# Lefthook: wrapper flake inputs

Every `nix-lefthook-*` remote in `lefthook.yml` needs a matching
wrapper binary in the devShell. The remote defines WHAT hook runs.
The wrapper provides the `lefthook-*` script that actually runs.

## Preferred: single nix-lefthook input

Use `github:pr0d1r2/nix-lefthook` as a single flake input. It
bundles all lefthook wrappers, the lefthook binary, and all linter
tools. Compose via `inputsFrom`:

```nix
inputs.nix-lefthook = {
  url = "github:pr0d1r2/nix-lefthook";
  inputs.nixpkgs.follows = "nixpkgs";
};

devShells = forAllSystems (pkgs: {
  ci = pkgs.mkShell {
    inputsFrom = [ nix-lefthook.devShells.${pkgs.stdenv.hostPlatform.system}.ci ];
    packages = [ myPackage ];
  };

  default = pkgs.mkShell {
    inputsFrom = [ nix-lefthook.devShells.${pkgs.stdenv.hostPlatform.system}.ci ];
    packages = [ myPackage ];
    shellHook = builtins.readFile ./dev.sh;
  };
});
```

One input replaces 10+ individual nix-lefthook-* inputs. Simpler
flake.nix, fewer lock entries, single version to update.

## Legacy: individual inputs

Older repos may use individual flake inputs per wrapper:

```nix
nix-lefthook-deadnix.packages.${sys}.default
```

Missing the flake input → `exit 127: No such file or directory`.

### Checklist when adding a new lefthook remote (legacy pattern)

1. Add remote to `lefthook.yml`
2. Add flake input: `nix-lefthook-FOO.url = "github:pr0d1r2/nix-lefthook-FOO"`
3. Add to outputs parameter list
4. Add `nix-lefthook-FOO.packages.${sys}.default` to BOTH `default`
  and `ci` devShell packages
5. Run `nix flake lock --update-input nix-lefthook-FOO`
6. Reload direnv

### Keep legacy hook locks shared

Every individual hook input must follow the consumer's foundation inputs. Add
the edges that exist in the hook's own lock; older hooks also need the
`nix-dev-shell-agentic` edge:

```nix
inputs.nix-lefthook-FOO = {
  url = "github:pr0d1r2/nix-lefthook-FOO";
  inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixpkgs-lock.follows = "nixpkgs-lock";
  inputs.set-and-setting.follows = "nix-lefthook-FOO/set-and-setting";
  inputs.nix-dev-shell-agentic.follows =
    "nix-lefthook-FOO/nix-dev-shell-agentic";
};
```

The hook's lock is authoritative: omit follows for inputs it no longer
declares, and verify `nix-lefthook-nixfmt` separately because it cannot use
the shared `set-and-setting` input. Without these follows, a consumer with
many legacy hooks fans out the same foundation trees once per hook.

## Common miss

Tools like deadnix, nixfmt, shellcheck exist as `pkgs.deadnix` etc.
in the devShell — but lefthook remotes call `lefthook-deadnix`, not
`deadnix`. The wrapper adds timeout handling, file filtering, and
diff output formatting. Both the tool AND the wrapper are needed.
