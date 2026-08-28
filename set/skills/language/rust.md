# Rust

Rust repositories are `hk`-gated by design. `set-and-setting` ships the
skills half of that contract and never emits Rust lint fragments.

## What this standard provides

- `mkSet` may provide this skill, including the `language` category's Rust
  guidance.
- The guidance describes the repository's gate as `hk check`.
- `mkSetting` does not provide a Rust setting or configure Rust checks.

## What this standard never provides

There is no `nix-lefthook-clippy`, `nix-lefthook-rustfmt`, or
`nix-lefthook-cargo-*` fragment. An `hk`-gated Rust repository already owns the
complete gate: clippy, rustfmt, `cargo test`, MSRV, and `cargo deny`. Adding
lefthook fragments would create two managers for the same checks and could
silently demote the richer `hk` gate when `lefthook.yml` wins.

Consequently, Rust repositories are not under-covered by the linter coverage
or fidelity checks merely because the standard emits none of their Rust
checks. Those checks compare only against the standard's emitted check set.
