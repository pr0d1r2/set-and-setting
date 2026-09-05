# Git PR: cross-repo references

A change is seldom limited to one repository. A bug found in one tree
is often owned by another, and a fix here is often what frees a bump
there. The pull request body is where that goes, because it is what a
reviewer reads before the diff.

## Point at the other repo's work, not just its name

GitHub resolves `OWNER/REPO#N` across repositories and renders it
with the target's title and state. Use it for the pull request, issue
or thread that this change answers:

```markdown
Found while linking this repo to OWNER/sherd.
Sent upstream as OWNER/microlith#17; this change is the user half.
```

For a commit in another repo, link the full commit URL -- a bare sha
resolves only inside the repo you are reading.

## Name which half of the work this is

When a change spans repos, say where the other half lives and what
state it is in. Three shapes cover most cases:

- **blocked on** -- this cannot merge until the other lands
- **frees** -- the other is waiting on this
- **independent** -- both hold on their own; the link is context

A reviewer who cannot tell which of the three applies will either
block a change that could merge, or merge a broken one.

## Send a bug to the repo that owns the rule

When the cause sits upstream, file it there and link it here rather
than fixing it locally. A local fix makes the two builds disagree,
which is the same bug one layer up.

The same holds in reverse, and that is the half that gets skipped:
**a bug sent upstream has to be read upstream.** Link it from the
owning repo's own task list or spec, not only from the repo that
found it, or the report sits there while both trees carry the bug.

## Keep the link stable after the merge

A squash merge rewrites the branch sha, so a body that names a branch
commit points at nothing once the branch is gone. Name the pull
request number, which lives on, rather than a sha on a branch that is
about to be deleted.

## Do not paste tool URLs

A pull request body is public and it stays. Agent session links,
local paths and build dashboards behind a login are not references a
reader can follow; they are private data in the shape of a link. Name
the repo, the pull request number, or the file path relative to the
repo root -- see `repo/fleet.md`.
