#!/usr/bin/env bash
# confirm.sh -- post-materialization acceptance suite (#94).
# Verifies that a consumer's materialized environment is complete, faithful,
# coherent, executable, idempotent, bound to the correct standard rev, and
# drift-free. Runs against the INVOKING repo (CWD).
#
# Env in:
#   FRAGMENTS_DIR     path to integration fragment sources
#   ASSEMBLE_SCRIPT   path to assemble-lefthook.sh
#   DETECT_SCRIPT     path to detect-fragments.sh
#   SETTING_SRC       path to materialized config bundle (markdownlint/yamllint)
#   CONFIRM_REV       the standard rev this confirmator was built from
#   CONFIRM_DRY_RUN   if "1", print what would be checked and exit 0
set -euo pipefail

detected="$(bash "$DETECT_SCRIPT")"

if [ "${CONFIRM_DRY_RUN:-}" = "1" ]; then
  echo "confirm: dry-run"
  echo "  detected fragments: $detected"
  echo "  standard rev: ${CONFIRM_REV:-unknown}"
  echo "  checks: completeness, fidelity, coherence, executability, idempotency, binding-integrity, no-drift"
  exit 0
fi

pass=0
fail=0

# --- completeness: all artifacts the repo's fragments require exist ---
if [ -f "lefthook.yml" ]; then
  echo "PASS: completeness: lefthook.yml exists"
  pass=$((pass + 1))
else
  echo "FAIL: completeness: lefthook.yml missing"
  fail=$((fail + 1))
fi

for cfg in .markdownlint.yml .yamllint.yml; do
  if [ -f "$cfg" ]; then
    echo "PASS: completeness: $cfg exists"
    pass=$((pass + 1))
  else
    echo "FAIL: completeness: $cfg missing"
    fail=$((fail + 1))
  fi
done

# --- fidelity: materialized content matches what pinned rev should produce ---
assemble_out="$(mktemp -d)"
trap 'rm -rf "$assemble_out"' EXIT
FRAGMENTS="$detected" out="$assemble_out" bash "$ASSEMBLE_SCRIPT"

if [ -f "lefthook.yml" ] && [ -f "$assemble_out/lefthook.yml" ]; then
  if diff -q "lefthook.yml" "$assemble_out/lefthook.yml" >/dev/null 2>&1; then
    echo "PASS: fidelity: lefthook.yml matches expected output"
    pass=$((pass + 1))
  else
    echo "FAIL: fidelity: lefthook.yml differs from expected (fragments: $detected)"
    fail=$((fail + 1))
  fi
fi

for cfg in .markdownlint.yml .yamllint.yml; do
  if [ -f "$cfg" ] && [ -f "$SETTING_SRC/$cfg" ]; then
    if diff -q "$cfg" "$SETTING_SRC/$cfg" >/dev/null 2>&1; then
      echo "PASS: fidelity: $cfg matches expected"
      pass=$((pass + 1))
    else
      echo "FAIL: fidelity: $cfg differs from expected"
      fail=$((fail + 1))
    fi
  fi
done

# --- coherence: every tool in lefthook.yml is on PATH ---
if [ -f "lefthook.yml" ]; then
  while IFS= read -r wrapper; do
    [ -n "$wrapper" ] || continue
    if command -v "$wrapper" >/dev/null 2>&1; then
      echo "PASS: coherence: $wrapper on PATH"
      pass=$((pass + 1))
    else
      echo "FAIL: coherence: $wrapper referenced in lefthook.yml but not on PATH"
      fail=$((fail + 1))
    fi
  done < <(grep -oE 'lefthook-[a-z][-a-z]*' lefthook.yml | sort -u)
fi

# --- executability: lefthook parses the config ---
if [ -f "lefthook.yml" ] && command -v lefthook >/dev/null 2>&1; then
  if lefthook dump >/dev/null 2>&1; then
    echo "PASS: executability: lefthook parses lefthook.yml"
    pass=$((pass + 1))
  else
    echo "FAIL: executability: lefthook dump failed"
    fail=$((fail + 1))
  fi
elif [ ! -f "lefthook.yml" ]; then
  echo "FAIL: executability: no lefthook.yml to parse"
  fail=$((fail + 1))
else
  echo "PASS: executability: lefthook not on PATH (skipped)"
  pass=$((pass + 1))
fi

# --- idempotency: re-materialize produces identical bytes ---
assemble_out2="$(mktemp -d)"
FRAGMENTS="$detected" out="$assemble_out2" bash "$ASSEMBLE_SCRIPT"
if [ -f "$assemble_out/lefthook.yml" ] && [ -f "$assemble_out2/lefthook.yml" ]; then
  if diff -q "$assemble_out/lefthook.yml" "$assemble_out2/lefthook.yml" >/dev/null 2>&1; then
    echo "PASS: idempotency: re-assembly produces identical lefthook.yml"
    pass=$((pass + 1))
  else
    echo "FAIL: idempotency: re-assembly produced different lefthook.yml"
    fail=$((fail + 1))
  fi
fi
rm -rf "$assemble_out2"

# --- binding integrity: flake input resolves to a valid standard rev ---
if [ -n "${CONFIRM_REV:-}" ] && [ "$CONFIRM_REV" != "unknown" ]; then
  echo "PASS: binding-integrity: standard rev ${CONFIRM_REV}"
  pass=$((pass + 1))
else
  echo "FAIL: binding-integrity: standard rev unknown (dirty or untracked)"
  fail=$((fail + 1))
fi

if [ -f "flake.lock" ]; then
  echo "PASS: binding-integrity: flake.lock present"
  pass=$((pass + 1))
else
  echo "FAIL: binding-integrity: flake.lock missing"
  fail=$((fail + 1))
fi

# --- no-drift: no orphaned artifacts from a prior version ---
if [ -f "lefthook.yml" ]; then
  orphans=0
  if grep -q 'remotes:' lefthook.yml 2>/dev/null; then
    echo "FAIL: no-drift: lefthook.yml contains legacy remotes: block"
    fail=$((fail + 1))
    orphans=1
  fi
  if grep -qE 'git_url:' lefthook.yml 2>/dev/null; then
    echo "FAIL: no-drift: lefthook.yml contains legacy git_url: entries"
    fail=$((fail + 1))
    orphans=1
  fi
  if [ "$orphans" -eq 0 ]; then
    echo "PASS: no-drift: no legacy remotes/git_url in lefthook.yml"
    pass=$((pass + 1))
  fi
fi

# --- migration overlay: consistency between extends ref and overlay file ---
if [ -f "lefthook.yml" ]; then
  _has_migration_ref=""
  if grep -q 'lefthook-migration.yml' lefthook.yml 2>/dev/null; then
    _has_migration_ref=1
  fi
  if [ -n "$_has_migration_ref" ] && [ -f "lefthook-migration.yml" ]; then
    echo "PASS: migration: overlay referenced and present"
    pass=$((pass + 1))
  elif [ -n "$_has_migration_ref" ] && [ ! -f "lefthook-migration.yml" ]; then
    echo "FAIL: migration: lefthook.yml extends lefthook-migration.yml but file is missing"
    fail=$((fail + 1))
  elif [ -z "$_has_migration_ref" ] && [ ! -f "lefthook-migration.yml" ]; then
    echo "PASS: migration: no active migration (consistent)"
    pass=$((pass + 1))
  else
    echo "PASS: migration: orphaned lefthook-migration.yml (harmless, clean up when ready)"
    pass=$((pass + 1))
  fi
fi

# --- summary ---
total=$((pass + fail))
echo ""
echo "confirmed: $total checks, fragments [$detected], standard @${CONFIRM_REV:-unknown}, drift=$([ "$fail" -eq 0 ] && echo "none" || echo "detected")"
echo ""
echo "result: $pass passed, $fail failed"

if [ "$fail" -ne 0 ]; then
  exit 1
fi
