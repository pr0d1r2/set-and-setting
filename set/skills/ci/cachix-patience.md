# CI: cachix cold cache is temporary

First CI run after adding cachix is slow — builds everything from
source and uploads to cache. Every subsequent run pulls from cache
and is fast.

Do not bypass slow hooks or checks during the warm-up period.
Skipping locally then pushing wastes GitHub compute when the same
checks fail remotely. The slowness is temporary.

## What to expect

- First run: full build time (minutes to hours depending on closure)
- Second run: mostly cache hits, much faster
- Steady state: near-instant for unchanged derivations

## Common mistake

Hook like vulnix-scan takes long on cold cache. Developer skips it
with `LEFTHOOK_EXCLUDE=vulnix-scan` and pushes. CI runs the same
hook, also slow, wastes compute. Next run would have been fast
from cache — the bypass saved nothing.

## Rule

Fix all hooks locally. Push clean. Cold cache pain is one-time.
