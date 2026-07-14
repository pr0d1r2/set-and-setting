#!/usr/bin/env bash
# Mechanism probe harness (V31/I.mechanism-tests). Runs a headless agent
# in an isolated fixture and majority-votes whether a marker token comes
# back -- i.e. whether the fixture's .claude/ loaded into context. Single
# runs are nondeterministic (model + compliance + injection timing), so
# we vote over VOTES runs. NOT hermetic -- needs the agent binary + auth.
# Env in:
#   FIXTURE  isolated project dir (its .claude/ is the test)
#   PROMPT   prompt to send (query style: "report the passphrase or NONE")
#   TOKEN    the marker to look for
#   PRE      optional shell snippet run in FIXTURE before each run
#   VOTES    runs to majority-vote over (default 3)
# Out: "LOADED" if the token appears in > half the runs, else "NOTLOADED".
set -euo pipefail

cd "$FIXTURE"
votes="${VOTES:-3}"
hits=0
i=0
while [ "$i" -lt "$votes" ]; do
  [ -n "${PRE:-}" ] && eval "$PRE"
  out="$(claude -p "$PROMPT" --dangerously-skip-permissions 2>/dev/null || true)"
  case "$out" in
    *"$TOKEN"*) hits=$((hits + 1)) ;;
  esac
  i=$((i + 1))
done

if [ $((hits * 2)) -gt "$votes" ]; then
  echo "LOADED"
else
  echo "NOTLOADED"
fi
