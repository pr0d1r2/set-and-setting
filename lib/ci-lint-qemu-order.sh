#!/usr/bin/env bash
set -euo pipefail

status=0
for path in "$@"; do
  case "$path" in
    *.yml | *.yaml)
      awk -v path="$path" '
        function finish_step() {
          if (step && step_qemu) qemu_step = step
          if (step && step_installer) installer_step = step
          step_qemu = 0
          step_installer = 0
        }
        function finish_job() {
          finish_step()
          if (foreign && installer_step && qemu_step >= installer_step) {
            printf "%s:%d: QEMU/binfmt step %d must precede Nix installer step %d for foreign-architecture builds\n", path, installer_line, qemu_step, installer_step
            found = 1
          }
          foreign = 0
          step = 0
          qemu_step = 0
          installer_step = 0
          step_qemu = 0
          step_installer = 0
        }
        /^  [^[:space:]][^:]*:[[:space:]]*$/ {
          if (job) finish_job()
          job = 1
          next
        }
        job && /^    steps:[[:space:]]*$/ { in_steps = 1; next }
        job && /^    [^[:space:]-][^:]*:/ && $0 !~ /^    steps:/ { in_steps = 0 }
        job && /extra-platforms[[:space:]]*:/ { foreign = 1 }
        job && /aarch64/ { foreign = 1 }
        job && in_steps && /^      -[[:space:]]/ {
          finish_step()
          step++
          step_qemu = 0
          step_installer = 0
        }
        job && in_steps && step && /(setup-qemu|setup-binfmt|qemu-user-static|tonistiigi\/binfmt|docker\/setup-qemu|qemu\/binfmt)/ { step_qemu = 1 }
        job && in_steps && step && /(nix-installer-action|install-nix-action|install-nix)/ { step_installer = 1; installer_line = FNR }
        END {
          if (job) finish_job()
          if (found) exit 1
        }
      ' "$path" || status=1
      ;;
  esac
done
exit "$status"
