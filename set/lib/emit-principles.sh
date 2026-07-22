#!/usr/bin/env bash
# shellcheck disable=SC2016 # Markdown backticks are intentional literals.
# Project every top-level principle into one compact, always-on prompt rule.
# A principle's filename is its citation slug, its first H1 is its name, and
# its first prose paragraph is its one-line rule. The projection also defines
# the accord lens used before merge. No functions (sh/modularity).
# Env in: PRINCIPLES_DIR, DEST
set -euo pipefail

principles_dir="${PRINCIPLES_DIR:?PRINCIPLES_DIR must be set}"
dest="${DEST:?DEST must be set}"

[ -d "$principles_dir" ] || exit 0

files=()
while IFS= read -r file; do
  files+=("$file")
done < <(find "$principles_dir" -maxdepth 1 -name '*.md' | sort)

# An empty registry is deliberately a no-op.
[ "${#files[@]}" -gt 0 ] || exit 0

mkdir -p "$(dirname "$dest")"
tmp="${dest}.tmp"
trap 'rm -f "$tmp"' EXIT

{
  printf '# Active principles\n\n'
  printf 'Apply every active principle to all planning, implementation, '
  printf 'verification, reporting, and review. Cite a principle by its '
  printf 'unique slug as `[[slug]]`.\n\n'
  printf '## Registry\n\n'
} >"$tmp"

for file in "${files[@]}"; do
  slug="${file##*/}"
  slug="${slug%.md}"
  if [[ ! "$slug" =~ ^[a-z0-9]+$ ]]; then
    echo "FAIL: principle slug '$slug' must be one lowercase word" >&2
    exit 1
  fi

  name="$(sed -n 's/^# //p' "$file" | head -1)"
  if [ -z "$name" ]; then
    echo "FAIL: principle '$slug' has no H1 name" >&2
    exit 1
  fi

  rule="$(awk '
    /^# / { heading = 1; next }
    heading && /^[[:space:]]*$/ { if (started) exit; next }
    heading { printf "%s%s", (started ? " " : ""), $0; started = 1 }
  ' "$file")"
  if [ -z "$rule" ]; then
    echo "FAIL: principle '$slug' has no one-line rule" >&2
    exit 1
  fi

  printf -- '- `[[%s]]` **%s** -- %s\n' "$slug" "$name" "$rule" >>"$tmp"
done

{
  printf '\n## Accord lens: principles\n\n'
  printf 'Before merge, review the diff and reported results against every '
  printf 'active principle above. An objective violation blocks accord until '
  printf 'it is fixed or the change is rejected. For subjective judgments, '
  printf 'weight evidence by relevant demonstrated track record '
  printf '(`[[believability]]`) and record the rationale. In particular, do '
  printf 'not accept symptom patches (`[[rootcause]]`), unexamined downstream '
  printf 'effects (`[[consequences]]`), or hidden and misreported failures '
  printf '(`[[truth]]`). References to inactive example slugs are illustrative, '
  printf 'not additional active principles.\n'
} >>"$tmp"

mv "$tmp" "$dest"
trap - EXIT
