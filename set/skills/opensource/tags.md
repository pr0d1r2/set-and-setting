# Open-source: tags

Every repository should have a small, deliberate set of tags. Tags make a
project discoverable and keep its identity consistent wherever it is
published.

## One vocabulary

Maintain one canonical, lowercase, hyphen-separated tag list for each
project. Reuse that list across every release surface that supports tags or
keywords:

- GitHub repository topics
- crates.io `keywords` (and `categories` where the platform has a separate
  category field)
- package registries, catalogs, and release metadata

The list is a shared vocabulary, not a copy of every platform's categories.
When a platform imposes a limit or has a controlled vocabulary, keep the
most-specific applicable entries and document any deliberate omission.

## Rust crates

For a Rust repository, treat the crate manifest's `package.keywords` as the
canonical source. Mirror those keywords to GitHub repository topics and to
other release metadata. Keep `package.categories` aligned with the project's
actual domain, but do not substitute categories for keywords when mirroring.

Review tags whenever the crate manifest changes, before publishing a release,
and when the repository's purpose changes. Remove stale tags; do not add
near-duplicates such as both `rust-lang` and `rust` unless they communicate
different, useful concepts.

## Other repositories

When there is no crate manifest, define the canonical list in the repository's
primary package or release metadata, then mirror it to the repository host and
all registries. Prefer a few accurate tags over a long list of adjacent
terms. Tags describe what users can find and use, not implementation details
that are invisible to users.

Before a release, verify that every platform's tags are present, equivalent,
and within that platform's limits. A tag mismatch is release metadata drift
and should be fixed alongside the release rather than deferred.
