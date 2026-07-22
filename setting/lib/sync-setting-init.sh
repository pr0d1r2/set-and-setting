# shellcheck shell=bash
# shellcheck disable=SC2154  # $src injected by mkSetting (seed bundle)
target="${1:-.}"
find -L "$src" -type f | while read -r f; do
  rel="${f#"$src/"}"
  if [ -e "$target/$rel" ]; then
    continue
  fi
  mkdir -p "$target/$(dirname "$rel")"
  cp "$src/$rel" "$target/$rel"
  if [ "$rel" = "README.md" ]; then
    repo_name="${target%/}"
    repo_name="${repo_name##*/}"
    {
      printf '# %s\n' "$repo_name"
      tail -n +2 "$target/$rel"
    } >"$target/$rel.tmp"
    mv "$target/$rel.tmp" "$target/$rel"
  fi
  echo "scaffolded: $rel"
done
echo "synced setting-init -> $target"
