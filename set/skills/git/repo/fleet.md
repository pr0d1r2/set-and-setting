# Git repo: fleet links

A repository that names a sibling repository in prose should link it.
A bare name is easy to follow only for a reader who already knows the
fleet, and that reader did not need the sentence. The link is what
turns a name into a door.

The fleet these links describe is the **public** one. A repository
that anyone can open is a repository that can be named, linked and
cited; a private one is not part of the graph a public reader can
walk, and naming it leaks rather than connects. Interconnectivity is
a property of open-source repositories, so everything below assumes
both ends are public.

## Where a link belongs

Link the **first** mention in each document, not every mention:

- `README.md` -- in the sentence that explains why the sibling
  exists, not in a bare "see also" list at the end
- `SPEC.md` -- wherever a rule, task or bug row names another repo's
  rule; a cross-repo reference without a link is a dead reference
- `ATTRIBUTION.md` and dependency notes -- every named upstream
- commit messages and pull request bodies -- see `pr/cross-repo.md`

Use the full `https://github.com/OWNER/REPO` form in Markdown prose.
Inside GitHub's own text fields (issues, pull requests, commit
messages read on the site) the short `OWNER/REPO#N` form renders as a
live link carrying the target's title, so prefer it there.

## Say what the edge is

A link alone says two repos are related; it does not say how. Name
the direction in the same sentence, using the words in `upstream.md`
and `downstream.md`:

```markdown
Spec structure comes from [microlith](https://github.com/OWNER/microlith),
which owns the in-file rules this crate calls rather than rewrites.
```

That reads as an edge. "See also microlith" does not.

## Link both directions

If A depends on B, B's `README.md` should name A as a user. A link in
one direction only means a reader who lands on the dependency cannot
tell what breaks when it changes -- and neither can the person who
owns it.

Such a link goes stale: when a dependency is dropped, remove the link
on both sides in the same change.

## Link only what the reader can open

Every cross-repo link in a public file must work for anyone. In
public `README.md` files, specs, commit messages and pull request
bodies, that rules out:

- **private repositories** -- a link a reader cannot open points at
  something they cannot reach, and the name by itself may give away
  work that is not public yet
- **local file paths** -- a home directory or checkout path names a
  machine, not a repository, and gives away the layout of a private
  tree
- **tool and session URLs** -- agent session links, build dashboards
  behind a login, internal ticket systems

When a measurement or a bug came from a private tree, keep the
finding and drop the name: "one spec in the fleet gains 41 bytes over
31 rows" carries the evidence; naming the private repo carries the
evidence plus a leak.

## Evidence without names

Counts and ratios cross the public boundary without naming anything:
"116 of 673 specs", "4 projects", "22 specs, 8.5%". State what the
number is measured against, so it can be weighed, and name the repos
only when every one of them is public.
