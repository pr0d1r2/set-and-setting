# shellcheck shell=bash
# shellcheck disable=SC2154  # $src injected by mkSetting (materialized bundle)
target="${1:-.}"
find -L "$src" -type f | while read -r f; do
  rel="${f#"$src/"}"
  mkdir -p "$target/$(dirname "$rel")"
  cp -f "$f" "$target/$rel"
done
echo "synced setting -> $target"
