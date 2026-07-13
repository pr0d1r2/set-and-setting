#!/usr/bin/env bash
# migrate.sh -- mechanical vendored->referenced transform (#96).
# Deterministic, idempotent, non-LLM, confirmator-gated. Runs against the
# INVOKING repo (CWD, a git repo). One repo at a time; safe at scale.
#
# Flow (per repo):
#   1. detect   state (vendored / referenced / bare / partial)
#               already-referenced => no-op
#   2. strip    vendored artifacts (full flake.nix / lefthook.yml / ci.yml)
#               so they become derived (materialized + gitignored)
#   3. plant    the seed (#95): thin flake.nix, .gitignore, CI caller,
#               auto-update workflow (skip-if-exists)
#   4. confirm-equivalence: assert the new materialized check-set covers
#               every check the old vendored lefthook enforced (the safety
#               net), then dry-run the confirmator (#94) on the new state.
#               The FULL confirmator + `nix flake check` run in CI once
#               `nix flake update` has produced flake.lock.
#
# Env in:
#   SEED_SRC          path to leaf-seed derivation (#95)
#   SETTING_SRC       path to materialized config bundle (markdownlint/yamllint)
#   FRAGMENTS_DIR     path to integration fragment sources
#   ASSEMBLE_SCRIPT   path to assemble-lefthook.sh
#   DETECT_SCRIPT     path to detect-fragments.sh
#   CONFIRM_SCRIPT    path to confirm.sh (#94)
#   CONFIRM_REV       the standard rev this migrator was built from
#   CHECKS_UNIVERSE   space-separated names of every pinned flake check the
#                     referenced architecture provides (checksFor over all
#                     fragments). Post-#93 FLIP the real guardrails are pinned
#                     `checks.<sys>.<tool>`, NOT lefthook commands -- so the
#                     referenced effective check-set is these names UNION the
#                     lefthook.yml commands.
#   FULL_LEFTHOOK     (optional) path to a lefthook.yml assembled from ALL
#                     fragments -- its command names complete the universe of
#                     guardrails the referenced architecture can provide.
#   MIGRATE_DETECT_ONLY   if "1", print detected state and exit 0
#   MIGRATE_DRY_RUN       if "1", print the plan and exit 0 (writes nothing)
# shellcheck disable=SC2154,SC2086
set -euo pipefail

# --- structured failure diagnostic (#114) ---
_migrate_stage="detect"
_migrate_fail_emitted=0

_check_fragment() {
    case "$1" in
        commit-msg-lint|changelog-touched|gitleaks|git-conflict-markers|\
git-no-local-paths|execute-permissions|file-size-check|\
trailing-whitespace|missing-final-newline|editorconfig-checker|\
typos|narrow-language-nix|narrow-language-shell|\
narrow-language-markdown|narrow-language-other|bats-parse|bats-unit)
            echo "base";;
        nixfmt|statix|deadnix|nix-no-embedded-shell|\
nix-flake-check|nix-flake-eval)
            echo "nix";;
        shellcheck|shfmt|no-shell-functions)
            echo "shell";;
        ascii-only|unicode-lint)
            echo "ascii";;
        markdownlint|markdownlint-agentic)
            echo "markdown";;
        yamllint)
            echo "yaml";;
        set-skill-extension|set-skill-size|set-ref-resolution|\
set-bundle-content)
            echo "set";;
        *) echo "";;
    esac
}

_fragment_trigger() {
    case "$1" in
        base|ascii) echo "always active";;
        nix)        echo "tracked *.nix files";;
        shell)      echo "tracked *.sh/*.bash files";;
        markdown)   echo "tracked *.md files";;
        yaml)       echo "tracked *.yml/*.yaml files";;
        set)        echo "tracked set/*.md files";;
        *)          echo "";;
    esac
}

_on_err() {
    local rc=$?
    if [ "$_migrate_fail_emitted" -eq 0 ]; then
        _migrate_fail_emitted=1
        echo ""
        echo "MIGRATE-FAIL: stage=$_migrate_stage reason=unexpected"
        echo "  detail: command failed with exit $rc at stage=$_migrate_stage"
        echo "  resolution:"
        echo "    - inspect the output above for the root cause"
        echo "    - file a backprop issue at github:pr0d1r2/set-and-setting with the full output"
        echo "  retry: idempotent"
    fi
}
trap '_on_err' ERR

# --- detect state (CWD is a git repo) ---
tracked=""
if git rev-parse --git-dir >/dev/null 2>&1; then
    tracked="$(git ls-files 2>/dev/null || true)"
fi

flake_present=0
[ -f flake.nix ] && flake_present=1

lefthook_present=0
[ -f lefthook.yml ] && lefthook_present=1

lefthook_tracked=0
printf '%s\n' "$tracked" | grep -qx 'lefthook.yml' && lefthook_tracked=1

references_sns=0
if [ "$flake_present" -eq 1 ] && grep -q 'set-and-setting' flake.nix; then
    references_sns=1
fi

uses_materialization=0
if [ "$flake_present" -eq 1 ] && grep -qE 'materializationFor|checksFor' flake.nix; then
    uses_materialization=1
fi

gitignores_lefthook=0
if [ -f .gitignore ] && grep -qxF 'lefthook.yml' .gitignore; then
    gitignores_lefthook=1
fi

ci_present=0
[ -f .github/workflows/ci.yml ] && ci_present=1

ci_guardrails=0
if [ "$ci_present" -eq 1 ] && grep -q 'guardrails.yml' .github/workflows/ci.yml; then
    ci_guardrails=1
fi

# classify: referenced (no-op) | bare | partial | vendored
state="vendored"
if [ "$references_sns" -eq 1 ] && [ "$uses_materialization" -eq 1 ] &&
    [ "$lefthook_tracked" -eq 0 ] && [ "$gitignores_lefthook" -eq 1 ]; then
    state="referenced"
elif [ "$flake_present" -eq 0 ] && [ "$lefthook_present" -eq 0 ]; then
    state="bare"
elif [ "$references_sns" -eq 1 ] || [ "$gitignores_lefthook" -eq 1 ]; then
    state="partial"
fi

echo "migrate: detected state=$state"

if [ "${MIGRATE_DETECT_ONLY:-}" = "1" ]; then
    exit 0
fi

# already-referenced => no-op (idempotent: a migrated repo re-migrates clean)
if [ "$state" = "referenced" ]; then
    echo "migrate: already referenced -- no-op"
    exit 0
fi

# --- plan (shared by dry-run report and the real transform) ---
strip_flake=0
if [ "$flake_present" -eq 1 ] &&
    ! { [ "$references_sns" -eq 1 ] && [ "$uses_materialization" -eq 1 ]; }; then
    strip_flake=1
fi

strip_ci=0
if [ "$ci_present" -eq 1 ] && [ "$ci_guardrails" -eq 0 ]; then
    strip_ci=1
fi

strip_lefthook="$lefthook_present"

if [ "${MIGRATE_DRY_RUN:-}" = "1" ]; then
    echo "migrate: dry-run plan for state=$state"
    [ "$strip_flake" -eq 1 ] && echo "  strip: flake.nix (vendored -> derived)"
    [ "$strip_ci" -eq 1 ] && echo "  strip: .github/workflows/ci.yml (vendored -> guardrails caller)"
    [ "$strip_lefthook" -eq 1 ] && echo "  strip: lefthook.yml (vendored -> materialized+gitignored)"
    echo "  plant: seed (thin flake.nix, .gitignore, ci.yml, auto-update.yml) skip-if-exists"
    echo "  confirm-equivalence: new check-set must cover the vendored one"
    exit 0
fi

# --- capture the vendored check-set BEFORE stripping (the equivalence baseline) ---
old_checks="$(mktemp)"
new_checks="$(mktemp)"
trap 'rm -f "$old_checks" "$new_checks"' EXIT

_migrate_stage="strip"
if [ "$lefthook_present" -eq 1 ]; then
    grep -oE '^    [a-zA-Z][a-zA-Z0-9_-]*:' lefthook.yml | tr -d ' :' | sort -u >"$old_checks" || true
fi

# --- strip vendored artifacts (stage: strip) ---
if [ "$strip_flake" -eq 1 ]; then
    git rm -q --cached --ignore-unmatch flake.nix 2>/dev/null || true
    rm -f flake.nix
    echo "stripped: flake.nix (vendored)"
fi
if [ "$strip_ci" -eq 1 ]; then
    git rm -q --cached --ignore-unmatch .github/workflows/ci.yml 2>/dev/null || true
    rm -f .github/workflows/ci.yml
    echo "stripped: .github/workflows/ci.yml (vendored)"
fi
if [ "$strip_lefthook" -eq 1 ]; then
    git rm -q --cached --ignore-unmatch lefthook.yml 2>/dev/null || true
    rm -f lefthook.yml
    echo "stripped: lefthook.yml (-> materialized)"
fi

_migrate_stage="plant"
# --- plant the seed (#95): skip-if-exists ---
find -L "$SEED_SRC" -type f | sort | while read -r f; do
    rel="${f#"$SEED_SRC/"}"
    [ -e "$rel" ] && continue
    mkdir -p "$(dirname "$rel")"
    cp "$f" "$rel"
    echo "planted: $rel"
done

# --- ensure the .gitignore ignores every materialized artifact (merge, DRY) ---
while IFS= read -r entry; do
    [ -n "$entry" ] || continue
    if [ -f .gitignore ] && grep -qxF "$entry" .gitignore; then
        continue
    fi
    printf '%s\n' "$entry" >>.gitignore
    echo "gitignore += $entry"
done <"$SEED_SRC/.gitignore"

# --- stage the committed minimum so detection reflects the NEW tracked set ---
# (materialized artifacts stay gitignored/untracked; caller commits the rest)
git add -A

_migrate_stage="equivalence"
# --- materialize the new state (gitignored) for equivalence + confirm ---
detected="$(bash "$DETECT_SCRIPT")"
mat_out="$(mktemp -d)"
FRAGMENTS="$detected" out="$mat_out" bash "$ASSEMBLE_SCRIPT"
cp -f "$mat_out/lefthook.yml" lefthook.yml
cp -f "$SETTING_SRC/.markdownlint.yml" .markdownlint.yml
cp -f "$SETTING_SRC/.yamllint.yml" .yamllint.yml
rm -rf "$mat_out"

# --- confirm-equivalence (the safety net) ---
# The referenced architecture PROVIDES a fixed universe of guardrails:
# pinned flake checks (CHECKS_UNIVERSE) UNION every lefthook command across
# all fragments (FULL_LEFTHOOK). A vendored (pre-FLIP) repo carried its
# guardrails inline as lefthook commands; the transform must not silently
# drop any check the referenced architecture cannot provide. (Whether a
# provided check ACTIVATES depends on file presence -- same for both states
# -- so we compare provided-universe membership, not per-file activation.)
{
    printf '%s\n' ${CHECKS_UNIVERSE:-}
    [ -n "${FULL_LEFTHOOK:-}" ] && [ -f "$FULL_LEFTHOOK" ] &&
        grep -oE '^    [a-zA-Z][a-zA-Z0-9_-]*:' "$FULL_LEFTHOOK" | tr -d ' :'
    grep -oE '^    [a-zA-Z][a-zA-Z0-9_-]*:' lefthook.yml | tr -d ' :'
} | grep -v '^$' | sort -u >"$new_checks"

dropped="$(comm -23 "$old_checks" "$new_checks" || true)"
if [ -n "$dropped" ]; then
    _migrate_fail_emitted=1
    dropped_list="$(echo $dropped | tr '\n' ' ' | sed 's/ *$//')"
    echo ""
    echo "MIGRATE-FAIL: stage=equivalence reason=uncovered-checks"
    echo "  dropped: $dropped_list"
    echo "  resolution:"
    for check in $dropped; do
        frag="$(_check_fragment "$check")"
        if [ -n "$frag" ]; then
            trigger="$(_fragment_trigger "$frag")"
            echo "    - $check: standard fragment \`$frag\` covers this ($trigger)"
        else
            echo "    - $check: NO standard equivalent (repo-local). Choose:"
            echo "        (a) keep     -- add a repo-local lefthook fragment that survives materialization"
            echo "        (b) retire   -- confirm obsolete, drop it"
            echo "        (c) upstream -- file a set-and-setting issue: add fragment covering $check"
        fi
    done
    echo "  retry: idempotent"
    exit 1
fi
old_count="$(wc -l <"$old_checks" | tr -d ' ')"
echo "PASS: equivalence -- new check-set [$detected] covers all $old_count vendored checks"

_migrate_stage="confirm"
# --- confirmator (#94) wiring check on the new state (dry-run) ---
# The FULL confirmator + `nix flake check` run in CI once `nix flake update`
# has produced flake.lock; here we validate detection + rev wiring.
echo "--- confirmator (dry-run) on new state ---"
CONFIRM_DRY_RUN=1 bash "$CONFIRM_SCRIPT"

echo ""
echo "migrate: $state -> referenced complete. Next: nix flake update, commit, open PR."
