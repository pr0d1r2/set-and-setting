#!/bin/sh
# Extracted by rekall from set/skills/gnu/sed.md:3-6 (id 4116dcd).
#
# THE RULE, verbatim:
# rekall:payload
# Always use `sed` from the dev shell (GNU sed via nixpkgs `gnused`).
# Never use macOS built-in `/usr/bin/sed` which is BSD sed and has
# incompatible flag syntax (e.g. `-i ''` vs `-i`). The dev shell
# provides GNU sed on all architectures so scripts stay portable.
# rekall:/payload
#
# SCOPED TO WHAT RUNS, not to what is written about. `set/skills/gnu/awk.md`
# names `/usr/bin/awk` in order to forbid it, and prose that forbids a thing
# has to be allowed to name it -- so this reads executable content only and
# leaves Markdown alone. `.rekall/` is excluded for the same reason one line
# up: this script quotes the rule it enforces.
#
# ## Fires when
#
# ```rekall
# tool = ["Bash"]
# word = ["/usr/bin/sed", "sed -i ''"]
# ```
#
# ## Does NOT fire when
#
# ```rekall
# word = ["rekall", "grep -n"]
# ```
hits=$(git grep -nE "/usr/bin/sed|sed -i ''" -- '*.sh' '*.bash' '*.nix' '*.yml' '*.yaml' 'justfile' ':!.rekall/**' 2>/dev/null || true)
[ -z "$hits" ] && exit 0
echo 'rekall: BSD sed reached executable content, and this fleet builds on GNU sed from the dev shell.' >&2
echo "$hits" >&2
echo "Use plain \`sed\` so the dev shell's GNU build is picked up; for in-place edits write \`sed -i\` without the BSD empty-suffix argument." >&2
exit 1
