# Ops: wrapup

`/wrapup` is a session-closing command. It turns the current working
state into a compact, safe handoff and leaves a clear starting point for
the next session.

## Command

When invoked, ask:

```text
What is left in this session?
My intention is to spec all unspecced and potentially fill upstream gh issues in anonymized way and start new session.
File issues only in my own repos.
```

Then inspect the current session and repository without making changes.
Report:

1. Work completed, work still in progress, and the next concrete action.
2. Uncommitted changes, untracked files, failing checks, and unresolved
  decisions.
3. Observations that are not yet specified, each with a proposed
  invariant, task, or bug entry and the evidence needed to support it.
4. Candidate upstream issues, with identifying details removed and the
  owning repository named. Do not file them automatically.
5. A short handoff for the next session, including the first command or
  file to inspect.

## Boundaries

- Treat the request as a review and handoff, not permission to edit,
  commit, push, open issues, or start another session.
- Only issue candidates for repositories the user owns. Never file an
  issue in an upstream or third-party repository without explicit,
  separate authorization.
- Anonymize repository-local paths, usernames, hostnames, tokens,
  session links, and other identifying details before presenting an
  upstream candidate. Preserve only the facts needed to reproduce the
  problem.
- Distinguish observed facts from hypotheses and mark missing evidence.
- If the working tree or checks are dirty, surface that prominently;
  do not imply that the session is ready to close.
