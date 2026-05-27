# Product

Product management lives in-repo, not in external tools.

## Release workflow

1. Daily coding sessions append to `## Unreleased` in `CHANGELOG.md`
   as features land.
2. When a release is ready: rename `## Unreleased` to
   `## YYYY-MM-DD (short-sha)`, add a fresh `## Unreleased` section,
   commit, tag, build.
3. Each release produces a deployable artifact.

## CHANGELOG.md

Single source of truth for what changed and when. Group entries by
theme, not by commit. Write entries for the operator, not the
developer -- focus on what the release delivers, not implementation
details.

After completing work on a feature or fix, append a one-line entry
to the relevant group under `## Unreleased`. Create a new group
heading if nothing fits.

## Commit cadence vs release cadence

Commits happen continuously during a session (one per decision).
Releases happen when the `## Unreleased` section represents a
coherent, tested, deployable state.

## What triggers a release

- Security changes that need to reach production
- New capabilities or runtime fixes
- Accumulated quality-of-life improvements worth deploying

There is no fixed schedule. Release when the unreleased work is
worth deploying.
