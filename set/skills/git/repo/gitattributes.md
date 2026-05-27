# Git repo: gitattributes

`.gitattributes` controls how git and GitHub handle specific files.
Used primarily to mark generated files so they're hidden in diffs and
excluded from language statistics.

## When to update

Add an entry when a new generated or vendored file enters the repo.
Candidates: lock files, bundled dependencies, build artifacts that
must be tracked. Use `linguist-generated=true` to hide from GitHub
diffs and language stats. Use `linguist-vendored=true` for third-party
code that should be excluded from stats but still visible in diffs.
