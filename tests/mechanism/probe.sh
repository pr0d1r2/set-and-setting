#!/usr/bin/env bash
# Mechanism probe harness (V31/I.mechanism-tests). Runs a headless agent
# in an isolated fixture project and echoes its reply, so a caller can
# grep for a marker token to learn whether a given .claude/ fixture
# loaded into context. NOT hermetic -- needs the agent binary + auth.
# Env in:
#   FIXTURE   path to the isolated project dir (its .claude/ is the test)
#   PROMPT    the prompt to send
#   PRE       optional shell snippet run in FIXTURE before the agent
#             (e.g. seed a file the prompt will read/write)
set -euo pipefail

cd "$FIXTURE"
[ -n "${PRE:-}" ] && eval "$PRE"

# -p headless; skip permission prompts so read/write probes can act.
# --add-dir nothing; cwd is a fresh tmp so no ancestor CLAUDE.md leaks in.
claude -p "$PROMPT" --dangerously-skip-permissions 2>/dev/null
