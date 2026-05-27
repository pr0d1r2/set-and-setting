# CI

Everything starts with Lefthook git hook manager which wraps all unit
and integration testing into pre-commit and pre-push hooks.
Effectively CI happens on local machine running Linux or a remote
builder implementing the remote builder paradigm.
Ensure that we do not push another time if we have integration testing
running in the background.
As we treat our pre-push effectively as CI process -- we need to run
all unit tests with it not only for changed files.
