# Scrub the git environment a hook exports into the specs it runs.
#
# Git sets GIT_DIR, and an author identity, for every hook it invokes, and this
# suite runs from pre-push. Inherited, a spec's `git init` and `git commit`
# address the repository being pushed rather than the fixture it cd'd into --
# GIT_DIR outranks the working directory, so the `cd` buys nothing. Commits
# land on the real HEAD, a fixture identity is written to the real config, and
# from a linked worktree, whose GIT_DIR does not end in `/.git`, `git init`
# cannot infer a work tree and marks the shared config bare, which disables the
# main checkout outright.
#
# Load it from any spec that runs git: `load git-env` (`load ../git-env` from a
# subdirectory). tests/git-env.bats proves the scrub and holds every such spec
# to loading it (B97).
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_PREFIX
unset GIT_COMMON_DIR GIT_NAMESPACE GIT_ALTERNATE_OBJECT_DIRECTORIES
unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_AUTHOR_DATE
unset GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL GIT_COMMITTER_DATE
