#!/usr/bin/env bash
# resolve-agent.sh -- resolve an agent name to its seam values.
# Prints dir,condField to stdout if found; exits 1 with known agent
# names on stderr if not found.
# Env in: AGENT_SEAMS (agent=dir,condField,skillDir,disableInvoc,alwaysOnImport,
#         alwaysOnFile,condMechanism;...), AGENT_NAME (name to resolve)
set -euo pipefail

IFS=';' read -ra seam_entries <<<"${AGENT_SEAMS:-}"

for entry in "${seam_entries[@]:-}"; do
    [ -n "$entry" ] || continue
    aname="${entry%%=*}"
    if [ "$aname" = "$AGENT_NAME" ]; then
        echo "${entry#*=}"
        exit 0
    fi
done

names=()
for entry in "${seam_entries[@]:-}"; do
    [ -n "$entry" ] || continue
    names+=("${entry%%=*}")
done
echo "error: unknown agent '$AGENT_NAME'" >&2
echo "Available agents: ${names[*]}" >&2
exit 1
