#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-seed.sh -- emit the committed minimum for a leaf consumer repo (#95).
# Seeds: thin flake.nix, .gitignore, CI caller workflow, README, and LICENSE.
# Skips files that already exist (repo-owned after seeding).
# Env in: SEED_SRC (path to leaf-seed derivation)
set -euo pipefail

if [ "${1:-}" = "--help" ]; then
  echo "Usage: seed [--help] [--list] [--dry-run] [--owner OWNER] [--repo REPO]"
  echo ""
  echo "Emit the committed minimum for a leaf consumer repo."
  echo "Seeds: flake.nix, .gitignore, .github/workflows/ci.yml, README.md, LICENSE"
  echo ""
  echo "Options:"
  echo "  --owner OWNER    Repository owner (or TRIP_OWNER)"
  echo "  --repo REPO      Repository name (or TRIP_REPO)"
  echo "  --holder HOLDER  Copyright holder (or TRIP_HOLDER; defaults to owner)"
  echo "  --year YEAR      Copyright year (or TRIP_YEAR; defaults to current year)"
  echo ""
  echo "Skips files that already exist. After seeding, run:"
  echo "  nix flake update"
  echo "  nix develop -c lefthook install"
  exit 0
fi

dry_run=0
list=0
owner="${TRIP_OWNER:-}"
repo="${TRIP_REPO:-}"
holder="${TRIP_HOLDER:-}"
year="${TRIP_YEAR:-$(date -u +%Y)}"

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)
      dry_run=1
      ;;
    --list)
      list=1
      ;;
    --owner | --repo | --holder | --year)
      option="$1"
      shift
      if [ $# -eq 0 ]; then
        echo "error: $option requires a value" >&2
        exit 1
      fi
      case "$option" in
        --owner) owner="$1" ;;
        --repo) repo="$1" ;;
        --holder) holder="$1" ;;
        --year) year="$1" ;;
      esac
      ;;
    *)
      echo "error: unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

case "$owner$repo" in
  *[!A-Za-z0-9._-]*)
    echo "error: owner and repo may contain only letters, numbers, dot, underscore, and hyphen" >&2
    exit 1
    ;;
esac
case "$year" in
  *[!0-9]* | "")
    echo "error: year must contain only digits" >&2
    exit 1
    ;;
esac

if [ "$list" -eq 1 ]; then
  echo "Seed files:"
  find -L "$SEED_SRC" -type f | sort | while read -r f; do
    rel="${f#"$SEED_SRC/"}"
    echo "  $rel"
  done
  exit 0
fi

if [ "$dry_run" -eq 1 ]; then
  echo "Would seed into CWD (skip existing):"
  find -L "$SEED_SRC" -type f | sort | while read -r f; do
    rel="${f#"$SEED_SRC/"}"
    if [ -e "$rel" ]; then
      echo "  $rel (skip -- exists)"
    else
      echo "  $rel"
    fi
  done
  exit 0
fi

if { [ -z "$owner" ] || [ -z "$repo" ]; } && git remote get-url origin >/dev/null 2>&1; then
  remote="$(git remote get-url origin)"
  remote="${remote%.git}"
  case "$remote" in
    git@*:*) coordinates="${remote#*:}" ;;
    *github.com/*) coordinates="${remote#*github.com/}" ;;
    *) coordinates="" ;;
  esac
  if [ -n "$coordinates" ] && [ "${coordinates#*/}" != "$coordinates" ]; then
    inferred_owner="${coordinates%%/*}"
    inferred_repo="${coordinates#*/}"
    case "$inferred_owner$inferred_repo" in
      *[!A-Za-z0-9._-]*) ;;
      *)
        [ -n "$owner" ] || owner="$inferred_owner"
        [ -n "$repo" ] || repo="$inferred_repo"
        ;;
    esac
  fi
fi

if [ -n "$owner" ] && [ -z "$holder" ]; then
  holder="$owner"
fi

find -L "$SEED_SRC" -type f | sort | while read -r f; do
  rel="${f#"$SEED_SRC/"}"
  if [ -e "$rel" ]; then
    continue
  fi
  mkdir -p "$(dirname "$rel")"
  cp "$f" "$rel"
  if [ "$rel" = "README.md" ]; then
    repo_title="${repo:-${PWD##*/}}"
    {
      printf '# %s\n' "$repo_title"
      tail -n +2 "$rel"
    } >"$rel.tmp"
    mv "$rel.tmp" "$rel"
    if [ -n "$owner" ] && [ -n "$repo" ]; then
      sed -e "s/__OWNER__/$owner/g" -e "s/__REPO__/$repo/g" \
        -e '/^<!-- Fill in __OWNER__ and __REPO__/d' "$rel" >"$rel.tmp"
      mv "$rel.tmp" "$rel"
    fi
  elif [ "$rel" = "LICENSE" ]; then
    sed -e "s/__YEAR__/$year/g" "$rel" >"$rel.tmp"
    mv "$rel.tmp" "$rel"
    if [ -n "$holder" ]; then
      escaped_holder="$(printf '%s' "$holder" | sed 's#[\\&]#\\&#g')"
      sed "s/__HOLDER__/$escaped_holder/g" "$rel" >"$rel.tmp"
      mv "$rel.tmp" "$rel"
    fi
  fi
  echo "seeded: $rel"
done
echo "seed complete -> ."
