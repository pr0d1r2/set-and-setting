# Linter

Every file type tracked in git must have an assigned linter in
lefthook.yml (both pre-commit and pre-push). When adding a new file
type to the repo, add its linter before committing.

## Closing gaps

When adding a new file type, close the linter gap in a follow-up
commit: add the linter tool, configure lefthook, fix violations.
Do not leave uncovered extensions.

## How to verify coverage

Run this to find uncovered extensions:

```bash
git ls-files | sed 's/.*\.//' | sort -u
```

Compare against the project's linter coverage table. Any new extension
must be assigned a linter or explicitly marked as exempt with a reason.

## Adding a new linter

1. Add the tool to both devShells in `flake.nix`
2. Add a command to both `pre-commit` and `pre-push` in `lefthook.yml`
3. Use `glob` to scope to the right file extensions
4. Pre-commit: lint `{staged_files}` only; pre-push: lint all tracked files
5. Fix any existing violations before committing
