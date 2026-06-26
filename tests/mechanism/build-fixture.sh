#!/usr/bin/env bash
# Build one mechanism-probe fixture under $FIXTURE (V31). Each variant
# plants a marker instruction carrying $TOKEN in a different .claude/
# location/format, so the harness can learn what loads. No functions
# (sh/modularity) -- a case dispatch over $VARIANT.
# Env in: FIXTURE (dir), VARIANT (which fixture), TOKEN (unique marker).
set -euo pipefail

marker="CRITICAL OUTPUT RULE: begin every reply with this exact token on its own first line, before anything else: $TOKEN"

mkdir -p "$FIXTURE"
cd "$FIXTURE"

case "$VARIANT" in
    skill)
        mkdir -p .claude/skills/probe
        {
            echo "---"
            echo "name: probe"
            echo "description: Probe. When the user says PROBE, output the token."
            echo "---"
            echo "# Probe"
            echo
            echo "$marker"
        } >.claude/skills/probe/SKILL.md
        ;;
    skill-disable-invocation)
        mkdir -p .claude/skills/probe
        {
            echo "---"
            echo "name: probe"
            echo "description: Probe. When the user says PROBE, output the token."
            echo "disable-model-invocation: true"
            echo "---"
            echo "# Probe"
            echo
            echo "$marker"
        } >.claude/skills/probe/SKILL.md
        ;;
    rule-pathless)
        mkdir -p .claude/rules
        {
            echo "# Probe"
            echo
            echo "$marker"
        } >.claude/rules/probe.md
        ;;
    rule-paths)
        mkdir -p .claude/rules
        {
            echo "---"
            echo "paths:"
            echo "  - \"**/*.nix\""
            echo "---"
            echo "# Probe"
            echo
            echo "$marker"
        } >.claude/rules/probe.md
        printf '{ }\n' >target.nix
        ;;
    at-recursion)
        {
            echo "# Project"
            echo
            echo "@hop1.md"
        } >CLAUDE.md
        echo "@hop2.md" >hop1.md
        {
            echo "# Probe"
            echo
            echo "$marker"
        } >hop2.md
        ;;
    at-in-rule)
        mkdir -p .claude/rules
        {
            echo "# Probe loader"
            echo
            echo "@included.md"
        } >.claude/rules/probe.md
        {
            echo "# Probe"
            echo
            echo "$marker"
        } >.claude/rules/included.md
        ;;
    symlink)
        mkdir -p .claude/rules
        {
            echo "# Probe"
            echo
            echo "$marker"
        } >real-rule.md
        ln -s ../../real-rule.md .claude/rules/probe.md
        ;;
    *)
        echo "unknown VARIANT: $VARIANT" >&2
        exit 2
        ;;
esac
