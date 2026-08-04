#!/usr/bin/env bash
# shellcheck disable=SC2154
# app-seed.sh -- generic canonical-tree installer.
# Skips files that already exist (repo-owned after seeding).
# Env in: SEED_SRC (path to leaf-seed derivation)
set -euo pipefail

app_name="${CANON_APP_NAME:-seed}"
app_label="${CANON_APP_LABEL:-seed}"

if [ "${1:-}" = "--help" ]; then
  echo "Usage: $app_name [--help] [--list] [--dry-run] [--owner OWNER] [--repo REPO]"
  echo ""
  echo "Emit a canonical repository tree."
  echo "The selected source bundle determines the emitted files."
  echo ""
  echo "Options:"
  echo "  --owner OWNER    Repository owner (or TRIP_OWNER)"
  echo "  --repo REPO      Repository name (or TRIP_REPO)"
  echo "  --description D  Project description (or TRIP_DESCRIPTION)"
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
description="${TRIP_DESCRIPTION:-Describe the project and the problem it solves.}"

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)
      dry_run=1
      ;;
    --list)
      list=1
      ;;
    --owner | --repo | --description | --holder | --year)
      option="$1"
      shift
      if [ $# -eq 0 ]; then
        echo "error: $option requires a value" >&2
        exit 1
      fi
      case "$option" in
        --owner) owner="$1" ;;
        --repo) repo="$1" ;;
        --description) description="$1" ;;
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
  echo "${app_label^} files:"
  find -L "$SEED_SRC" -type f | sort | while read -r f; do
    rel="${f#"$SEED_SRC/"}"
    echo "  $rel"
  done
  exit 0
fi

if [ "$dry_run" -eq 1 ]; then
  echo "Would $app_label into CWD (skip existing):"
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

# The leaf depends on every repository in this foundation set, either
# directly or transitively. Installing it into one of those repositories
# would therefore replace the repository's own flake with a self-edge.
# Refuse before copying anything, including when coordinates were inferred
# only from the working-directory name.
target_repo="${repo:-${PWD##*/}}"
case "$target_repo" in
  set-and-setting | nix-lefthook | nixpkgs-lock)
    echo "error: refusing to seed leaf template into foundation repository: $target_repo" >&2
    exit 1
    ;;
esac

find -L "$SEED_SRC" -type f | sort | while read -r f; do
  rel="${f#"$SEED_SRC/"}"
  if [ -e "$rel" ]; then
    continue
  fi
  mkdir -p "$(dirname "$rel")"
  cp "$f" "$rel"
  if grep -q '__REPO__\|__DESCRIPTION__' "$rel"; then
    repo_title="${repo:-${PWD##*/}}"
    escaped_repo="$(printf '%s' "$repo_title" | sed 's#[\\&/]#\\&#g')"
    escaped_description="$(printf '%s' "$description" | sed 's#[\\&/]#\\&#g')"
    sed -e "s/__DESCRIPTION__/$escaped_description/g" \
      -e "1s/__REPO__/$escaped_repo/" "$rel" >"$rel.tmp"
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
  echo "${app_label}ed: $rel"
done

if [ "${CANON_INSTALL_HOOKS:-0}" -eq 1 ]; then
  if git rev-parse --git-dir >/dev/null 2>&1; then
    lefthook install
    echo "installed: lefthook"
  else
    echo "deferred: lefthook install (not a git repository)"
  fi
fi
echo "$app_label complete -> ."
