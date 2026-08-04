#!/usr/bin/env bash
# branch-protection.sh -- T19: enable main branch protection requiring PRs.
# Configures GitHub branch protection via gh api. Requires gh auth.
#
# Env in (optional):
#   REQUIRED_STATUS_CONTEXTS  pipe-separated standard-derived contexts
#                             (from check-fragment-map.nix via flake wiring;
#                             pipe-separated because each context has spaces,
#                             e.g. "guardrails / check|guardrails / check-darwin")
set -euo pipefail

branch="main"
repo=""
dry_run=0
status_checks=""
from_standard=0

while [ $# -gt 0 ]; do
  case "$1" in
    --help)
      echo "Usage: branch-protection [--help] [--dry-run] [--repo OWNER/REPO]"
      echo "                         [--branch BRANCH] [--status-checks CHECKS]"
      echo "                         [--from-standard]"
      echo ""
      echo "Enable branch protection requiring PRs on a GitHub repository."
      echo ""
      echo "Options:"
      echo "  --help                 Show this help and exit"
      echo "  --dry-run              Show what would be configured without applying"
      echo "  --repo OWNER/REPO      GitHub repository (default: from git remote)"
      echo "  --branch BRANCH        Branch to protect (default: main)"
      echo "  --status-checks CHECKS Comma-separated required status checks"
      echo "                         (default: none)"
      echo "  --from-standard        Use the standard-derived required status"
      echo "                         contexts (from check-fragment-map.nix)"
      exit 0
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --from-standard)
      from_standard=1
      shift
      ;;
    --repo)
      shift
      if [ $# -eq 0 ]; then
        echo "error: --repo requires OWNER/REPO"
        exit 1
      fi
      repo="$1"
      shift
      ;;
    --branch)
      shift
      if [ $# -eq 0 ]; then
        echo "error: --branch requires a name"
        exit 1
      fi
      branch="$1"
      shift
      ;;
    --status-checks)
      shift
      if [ $# -eq 0 ]; then
        echo "error: --status-checks requires a value"
        exit 1
      fi
      status_checks="$1"
      shift
      ;;
    *)
      echo "error: unknown option '$1'"
      echo "Run 'branch-protection --help' for usage."
      exit 1
      ;;
  esac
done

if [ "$from_standard" -eq 1 ] && [ -n "$status_checks" ]; then
  echo "error: --from-standard and --status-checks are mutually exclusive"
  exit 1
fi

if [ "$from_standard" -eq 1 ]; then
  if [ -z "${REQUIRED_STATUS_CONTEXTS:-}" ]; then
    echo "error: --from-standard requires REQUIRED_STATUS_CONTEXTS env var"
    echo "  (set automatically when run via nix run .#branch-protection)"
    exit 1
  fi
  status_checks="$(echo "$REQUIRED_STATUS_CONTEXTS" | tr '|' ',')"
fi

if [ -z "$repo" ]; then
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "error: not a git repository and --repo not specified"
    exit 1
  fi
  remote_url="$(git remote get-url origin 2>/dev/null || true)"
  if [ -z "$remote_url" ]; then
    echo "error: no origin remote and --repo not specified"
    exit 1
  fi
  repo="$(echo "$remote_url" | sed -E 's|.*github\.com[:/]||; s|\.git$||')"
fi

if ! echo "$repo" | grep -qE '^[^/]+/[^/]+$'; then
  echo "error: invalid repo format '$repo' (expected OWNER/REPO)"
  exit 1
fi

status_checks_json="null"
if [ -n "$status_checks" ]; then
  IFS=',' read -ra checks <<<"$status_checks"
  contexts_json="$(printf '%s\n' "${checks[@]}" | jq -R . | jq -s .)"
  status_checks_json="$(
    jq -n \
      --argjson contexts "$contexts_json" \
      '{strict: true, contexts: $contexts}'
  )"
fi

payload="$(
  jq -n \
    --argjson status_checks "$status_checks_json" \
    '{
            required_status_checks: $status_checks,
            enforce_admins: true,
            required_pull_request_reviews: {
                required_approving_review_count: 0,
                dismiss_stale_reviews: false,
                require_code_owner_reviews: false
            },
            restrictions: null,
            required_linear_history: false,
            allow_force_pushes: false,
            allow_deletions: false,
            required_conversation_resolution: true
        }'
)"

if [ "$dry_run" -eq 1 ]; then
  echo "Would configure branch protection on $repo/$branch:"
  echo "$payload" | jq .
  exit 0
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh CLI not found"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "error: gh not authenticated (run 'gh auth login')"
  exit 1
fi

echo "Configuring branch protection on $repo/$branch..."
gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/$repo/branches/$branch/protection" \
  --input - <<<"$payload"

echo "Branch protection enabled on $repo/$branch"
