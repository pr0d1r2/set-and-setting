#!/usr/bin/env bash
set -euo pipefail

flake=""
for path in "$@"; do
  case "$path" in *flake.nix)
    flake=$path
    break
    ;;
  esac
done
[ -n "$flake" ] || [ ! -f flake.nix ] || flake=flake.nix
[ -n "$flake" ] || exit 0
github_inputs=$(awk '/url[[:space:]]*=[[:space:]]*"(github:|https:\/\/github\.com\/)/ { count++ } END { print count + 0 }' "$flake")
[ "$github_inputs" -gt 10 ] || exit 0

status=0
for path in "$@"; do
  case "$path" in
    *.yml | *.yaml)
      awk -v path="$path" -v inputs="$github_inputs" '
        function report() {
          printf "%s:%d: flake has %d GitHub inputs; authenticate Nix with `NIX_CONFIG` at workflow/job level or `pre-build-commands: |\\n  echo \"access-tokens = github.com=${{ secrets.GITHUB_TOKEN }}\" | sudo tee -a /etc/nix/nix.conf`\\n", path, job_line, inputs
        }
        /^[[:space:]]*jobs:[[:space:]]*$/ { in_jobs=1; next }
        in_jobs && /^[[:space:]]{2}[^[:space:]][^:]*:[[:space:]]*$/ {
          if (job && !workflow_token && !job_token && !prebuild) report()
          job=1; job_line=FNR; job_token=0; prebuild=0; composite=0
          next
        }
        /^[[:space:]]*env:[[:space:]]*$/ && !in_jobs { workflow_env=1; next }
        workflow_env && /NIX_CONFIG:.*access-tokens[[:space:]]*=/ { workflow_token=1 }
        workflow_env && /NIX_CONFIG:/ { workflow_nix=1 }
        workflow_nix && /access-tokens[[:space:]]*=[[:space:]]*github\.com/ { workflow_token=1 }
        workflow_env && /^[[:space:]]{2}[^[:space:]][^:]*:/ { workflow_env=0 }
        job && /^[[:space:]]{4}env:[[:space:]]*$/ { job_env=1; next }
        job_env && /^[[:space:]]{4}[^[:space:]-]/ { job_env=0 }
        job_env && /NIX_CONFIG:.*access-tokens[[:space:]]*=/ { job_token=1 }
        job && /^[[:space:]]{6}-[[:space:]]*uses:/ { composite=1; next }
        composite && /pre-build-commands:/ { prebuild_key=1 }
        prebuild_key && /access-tokens[[:space:]]*=[[:space:]]*github\.com/ { prebuild=1 }
        job && /^[[:space:]]{6}[-] uses:/ { composite=0 }
        END {
          if (job && !workflow_token && !job_token && !prebuild) report()
          if (job && (!workflow_token && !job_token && !prebuild)) exit 1
        }
      ' "$path" || status=1
      ;;
  esac
done
exit "$status"
