# Compare the effective checks selected by a consumer with the emitted hook
# artifact.  Pinned checks come from checksFor; hook-only checks come from the
# materialized lefthook.yml.  Extra names are allowed as repo-local checks.
{
  pkgs,
  fragments,
  checks,
  consumerChecks ? { },
  materialization,
  expectedMaterialization,
}:

let
  cfm = import ./check-fragment-map.nix;
  fragmentText = builtins.concatStringsSep " " fragments;
  pinned = builtins.concatStringsSep "\n" (builtins.attrNames checks);
  claimed = builtins.concatLists (map (f: cfm.checksPerFragment.${f}) fragments);
  covered = builtins.concatLists (builtins.attrValues cfm.coveragePerFileClass);
  uncovered = builtins.filter (name: !(builtins.elem name covered)) claimed;
in
assert
  uncovered == [ ]
  || builtins.throw "coverage-drift: checks claim file classes without coverage: ${builtins.concatStringsSep ", " uncovered}";
pkgs.runCommand "coverage-drift-check"
  {
    nativeBuildInputs = [
      pkgs.gawk
      pkgs.coreutils
    ];
    EXPECTED_HOOK = "${expectedMaterialization}/lefthook.yml";
    ACTUAL_HOOK = "${materialization.files}/lefthook.yml";
    EXPECTED_PINNED = pinned;
    CONSUMER_CHECKS = builtins.concatStringsSep "\n" (builtins.attrNames consumerChecks);
    FRAGMENTS = fragmentText;
  }
  ''
    set -euo pipefail

    commands() {
      awk '
        /^    [A-Za-z0-9][A-Za-z0-9_.-]*:$/ {
          name=$0; sub(/^    /, "", name); sub(/:$/, "", name); print name
        }
      ' "$1" | sort -u
    }

    expected=$(mktemp)
    actual=$(mktemp)
    trap 'rm -f "$expected" "$actual"' EXIT
    {
      printf '%s\n' "$EXPECTED_PINNED"
      commands "$EXPECTED_HOOK"
    } | sed '/^$/d' | sort -u >"$expected"
    {
      printf '%s\n' "$EXPECTED_PINNED"
      commands "$ACTUAL_HOOK"
      printf '%s\n' "$CONSUMER_CHECKS"
    } | sed '/^$/d' | sort -u >"$actual"

    missing=$(comm -23 "$expected" "$actual" || true)
    if [ -n "$missing" ]; then
      echo "coverage-drift: missing emitted checks for fragments [$FRAGMENTS]:" >&2
      printf '  %s\n' "$missing" >&2
      exit 1
    fi

    extra=$(comm -13 "$expected" "$actual" || true)
    if [ -n "$extra" ]; then
      echo "coverage-drift: repo-local checks (allowed):" >&2
      printf '  %s\n' "$extra" >&2
    fi
    echo "coverage-drift: PASS"
    touch "$out"
  ''
