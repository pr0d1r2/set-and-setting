#!/usr/bin/env bash
# graduate-draft.sh -- move a draft category to stable skills (T13).
# Copies set/drafts/<cat>/ files into set/skills/<cat>/, updates @-refs
# from @set/drafts/<cat>/ to @set/<cat>/, removes the draft directory.
# For new categories (not in categories.nix), reports the required nix
# config changes. Supports --dry-run, --list, --help.
# Env in:
#   ALL_CATEGORIES  space-separated stable category names (from flake)
set -euo pipefail

drafts_dir="./set/drafts"
skills_dir="./set/skills"
read -ra all_cats <<<"${ALL_CATEGORIES:-}"

dry_run=0
category=""

while [ $# -gt 0 ]; do
  case "$1" in
    --help)
      echo "Usage: graduate <CATEGORY> [--dry-run]"
      echo ""
      echo "Graduate a draft skill category to stable."
      echo "Moves set/drafts/<cat>/ into set/skills/<cat>/,"
      echo "updates @-refs, removes the draft directory."
      echo ""
      echo "Options:"
      echo "  --help     Show this help and exit"
      echo "  --list     List available draft categories and exit"
      echo "  --dry-run  Show what would happen without writing"
      echo ""
      echo "Examples:"
      echo "  graduate nix          # merge drafts/nix into skills/nix"
      echo "  graduate ops          # create new skills/ops category"
      echo "  graduate --dry-run ops # preview without changes"
      exit 0
      ;;
    --list)
      echo "Available draft categories:"
      found=0
      for d in "$drafts_dir"/*/; do
        [ -d "$d" ] || continue
        found=1
        base="${d%/}"
        base="${base##*/}"
        count=$(find "$d" -name '*.md' -type f | wc -l)
        if [ -d "$skills_dir/$base" ]; then
          echo "  $base ($count files, merge into existing)"
        else
          echo "  $base ($count files, new category)"
        fi
      done
      if [ "$found" -eq 0 ]; then
        echo "  (none)"
      fi
      exit 0
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -*)
      echo "error: unknown option '$1'"
      echo "Run 'graduate --help' for usage."
      exit 1
      ;;
    *)
      if [ -n "$category" ]; then
        echo "error: only one category at a time"
        echo "Run 'graduate --help' for usage."
        exit 1
      fi
      category="$1"
      shift
      ;;
  esac
done

if [ -z "$category" ]; then
  echo "error: category required"
  echo "Run 'graduate --help' for usage."
  exit 1
fi

draft_src="$drafts_dir/$category"
if [ ! -d "$draft_src" ]; then
  echo "error: draft category '$category' not found at $draft_src"
  echo ""
  echo "Available drafts:"
  for d in "$drafts_dir"/*/; do
    [ -d "$d" ] || continue
    base="${d%/}"
    echo "  ${base##*/}"
  done
  exit 1
fi

target="$skills_dir/$category"
is_merge=0
[ -d "$target" ] && is_merge=1

if [ "$is_merge" -eq 1 ]; then
  echo "Graduating '$category' (merge into existing stable category)"
else
  echo "Graduating '$category' (new stable category)"
fi
echo ""

files=()
while IFS= read -r f; do
  files+=("$f")
done < <(find "$draft_src" -name '*.md' -type f | sort)

if [ ${#files[@]} -eq 0 ]; then
  echo "error: no .md files found in $draft_src"
  exit 1
fi

for f in "${files[@]}"; do
  rel="${f#"$draft_src"/}"
  dest="$target/$rel"
  if [ "$dry_run" -eq 1 ]; then
    echo "  would copy: $rel"
    if grep -q "@set/drafts/$category/" "$f"; then
      echo "    would update @-refs: @set/drafts/$category/ -> @set/$category/"
    fi
  else
    mkdir -p "$(dirname "$dest")"
    cp "$f" "$dest"
    sed -i "s|@set/drafts/$category/|@set/$category/|g" "$dest"
    echo "  $rel"
  fi
done

if [ "$dry_run" -eq 0 ]; then
  rm -rf "$draft_src"
  echo ""
  echo "Removed $draft_src"
fi

is_known=0
for c in "${all_cats[@]:-}"; do
  [ -z "$c" ] && continue
  [ "$c" = "$category" ] && is_known=1 && break
done

if [ "$is_known" -eq 0 ] && [ "$is_merge" -eq 0 ]; then
  echo ""
  echo "=== New category '$category': manual nix changes needed ==="
  echo "1. set/lib/categories.nix: add \"$category\" to 'all' list"
  echo "2. set/lib/categories.nix: add '$category' globs to 'globs' map"
  echo "3. flake.nix: add '$category = ./set/skills/$category;' to 'sets'"
  echo "4. flake.nix: remove '$category' from 'drafts' (if present)"
  echo "5. set/meta.nix: optionally add overrides for specific files"
elif [ "$is_merge" -eq 0 ]; then
  echo ""
  echo "=== Category '$category' already in categories.nix ==="
  echo "1. flake.nix: remove '$category' from 'drafts' (if present)"
  echo "2. flake.nix: verify 'sets.$category' points to ./set/skills/$category"
fi

remaining=$(find "$drafts_dir" -name "*.md" -type f 2>/dev/null | wc -l)
if [ "$dry_run" -eq 0 ]; then
  echo ""
  if [ "$remaining" -eq 0 ]; then
    echo "All drafts graduated. Remove 'drafts' attrset from flake.nix."
  else
    echo "Remaining draft files: $remaining"
  fi
fi
