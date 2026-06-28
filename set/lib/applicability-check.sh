#!/usr/bin/env bash
# Check the applicability filter (V34/V35/V36). Builds a fixture repo with
# real files (content grep needs them), runs the filter over the meta
# signals, and asserts the kept set + reasons. Extracted per nix/modularity.
# Env in: SIGNALS (meta signals), FILTER (applicability.sh path).
set -uo pipefail

d="$(mktemp -d)"
cd "$d" || exit 1

# A nix repo that runs QEMU integration tests and packages Python, but
# uses no cachix, no ISO build, no systemd hardening.
mkdir -p src tests/integration
printf '{ }\n' >flake.nix
printf 'config\n' >src/main.nix
printf 'pyproject = true; buildPythonPackage\n' >pkg.nix
printf 'lefthook\n' >lefthook.yml
printf 'spawn qemu -enable-kvm -serial stdio\n' >tests/integration/boot.exp
printf '# readme\n' >README.md

tracked="$(printf '%s\n' flake.nix src/main.nix pkg.nix lefthook.yml \
    tests/integration/boot.exp README.md)"

out="$(SIGNALS="$SIGNALS" CORE="generic git" TRACKED="$tracked" bash "$FILTER")"

# helper assertions (no functions: inline greps)
case "$out" in
    *"generic/skill.md|core"*) ;;
    *)
        echo "FAIL: core generic not kept"
        exit 1
        ;;
esac
case "$out" in
    *"git/git.md|core"*) ;;
    *)
        echo "FAIL: core git not kept"
        exit 1
        ;;
esac
case "$out" in
    *"nix/flake.md|paths:"*) ;;
    *)
        echo "FAIL: nix kept by paths"
        exit 1
        ;;
esac
case "$out" in
    *"lefthook/lefthook.md|paths:lefthook.yml"*) ;;
    *)
        echo "FAIL: lefthook kept by paths"
        exit 1
        ;;
esac
case "$out" in
    *"test/qemu.md|content:qemu,enable-kvm"*) ;;
    *)
        echo "FAIL: qemu kept by content"
        exit 1
        ;;
esac
case "$out" in
    *"nix/python-package.md|content:buildPythonPackage"*) ;;
    *)
        echo "FAIL: python-package kept by content (top-level pkg.nix)"
        exit 1
        ;;
esac

# pruned: no evidence for these features
case "$out" in
    *"opensource/cachix.md"*)
        echo "FAIL: cachix kept without evidence"
        exit 1
        ;;
esac
case "$out" in
    *"test/iso.md"*)
        echo "FAIL: iso kept without evidence"
        exit 1
        ;;
esac
case "$out" in
    *"security/hardening.md"*)
        echo "FAIL: hardening kept without evidence"
        exit 1
        ;;
esac

# determinism: a second run is identical
out2="$(SIGNALS="$SIGNALS" CORE="generic git" TRACKED="$tracked" bash "$FILTER")"
[ "$out" = "$out2" ] || {
    echo "FAIL: nondeterministic"
    exit 1
}

echo PASS
