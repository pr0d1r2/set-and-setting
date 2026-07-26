# Parallel

Use parallelization wherever it is both possible and stable. The
second half is the hard part: stability has to be established, not
assumed, and this repo established it the expensive way.

## The stability test

Parallel units are safe when they share no mutable state -- no shared
index, no shared lock, no shared working tree. Treat parallelism as
suspect the moment the units touch the same repository, or run under
emulation.

## Known-unstable, with cause

- **Concurrent processes touching a git repository** collide on
  `.git/index.lock`. The locks involved are mandatory ones, taken by
  libgit2 and by git's own internal calls, so `GIT_OPTIONAL_LOCKS=0`
  does **not** prevent the collision -- it suppresses optional index
  refreshes only. Three rounds were spent learning that.
- **Parallel execution under emulation** -- for example aarch64 jobs
  on x86 runners via binfmt_misc -- corrupts results through
  unreliable syscall emulation. The failures look flaky rather than
  deterministic, which makes them easy to misread as test bugs.

## Opting back in

Parallelism is not a repo default; it is a local choice. Re-enable it
for your own runs in `lefthook-local.yml`. CI runs sequentially by
decision, not by oversight.

## A related trap

A locally defined command does not necessarily win over a remote one
of the same name. A fix that appears to land can be silently defeated
by config priority, so verify that the behaviour changed rather than
trusting that the edit took effect.
