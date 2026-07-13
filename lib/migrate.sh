#!/usr/bin/env bash
# migrate.sh -- mechanical vendored->referenced transform (#96).
# Deterministic, idempotent, non-LLM, confirmator-gated. Runs against the
# INVOKING repo (CWD, a git repo). One repo at a time; safe at scale.
#
# Flow (per repo):
#   1. pre-flight  CWD sanity (git repo, clean worktree, not detached)
#   2. detect      state -- referenced (no-op) | bare | vendored |
#                  sub-classified partial states (#115):
#                    partial-tracked-lefthook
#                    partial-no-gitignore
#                    partial-no-materialization
#   3. strip       vendored artifacts (full flake.nix / lefthook.yml / ci.yml)
#                  so they become derived (materialized + gitignored).
#                  Custom flake.nix content => MIGRATE-FAIL, not silent drop.
#                  Extra workflows beyond vendored ci.yml => preserved.
#   4. plant       the seed (#95): thin flake.nix, .gitignore, CI caller,
#                  auto-update workflow (skip-if-exists)
#   5. confirm-equivalence: assert the new materialized check-set covers
#                  every check the old vendored lefthook enforced (the safety
#                  net), then dry-run the confirmator (#94) on the new state.
#                  The FULL confirmator + `nix flake check` run in CI once
#                  `nix flake update` has produced flake.lock.
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
_migrate_stage="pre-flight"
_migrate_fail_emitted=0

_emit_fail() {
  local reason="$1"
  shift
  _migrate_fail_emitted=1
  echo ""
  echo "MIGRATE-FAIL: stage=$_migrate_stage reason=$reason"
  for line in "$@"; do
    echo "  $line"
  done
  echo "  retry: idempotent"
}

_check_fragment() {
  case "$1" in
    gitleaks | git-conflict-markers | \
      git-no-local-paths | execute-permissions | file-size-check | \
      trailing-whitespace | missing-final-newline | editorconfig-checker | \
      typos)
      echo "base"
      ;;
    nixfmt | statix | deadnix | nix-no-embedded-shell)
      echo "nix"
      ;;
    shellcheck | shfmt | no-shell-functions)
      echo "shell"
      ;;
    ascii-only)
      echo "ascii"
      ;;
    markdownlint | markdownlint-agentic)
      echo "markdown"
      ;;
    yamllint)
      echo "yaml"
      ;;
    set-skill-extension | set-skill-size | set-ref-resolution | \
      set-bundle-content)
      echo "set"
      ;;
    *) echo "" ;;
  esac
}

_fragment_trigger() {
  case "$1" in
    base | ascii) echo "always active" ;;
    nix) echo "tracked *.nix files" ;;
    shell) echo "tracked *.sh/*.bash files" ;;
    markdown) echo "tracked *.md files" ;;
    yaml) echo "tracked *.yml/*.yaml files" ;;
    set) echo "tracked set/*.md files" ;;
    *) echo "" ;;
  esac
}

_on_err() {
  local rc=$?
  if [ "$_migrate_fail_emitted" -eq 0 ]; then
    _emit_fail "unexpected" \
      "detail: command failed with exit $rc at stage=$_migrate_stage" \
      "resolution:" \
      "  - inspect the output above for the root cause" \
      "  - file a backprop issue at github:pr0d1r2/set-and-setting with the full output"
  fi
}
trap '_on_err' ERR

# --- pre-flight: CWD sanity (#115) ---
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  _emit_fail "not-a-git-repo" \
    "detail: CWD is not inside a git repository" \
    "resolution:" \
    "  - run from the root of a git repository" \
    "  - or: git init && git add . && git commit -m 'initial'"
  exit 1
fi

if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  _emit_fail "no-commits" \
    "detail: git repository has no commits (orphan branch)" \
    "resolution:" \
    "  - create an initial commit: git add . && git commit -m 'initial'"
  exit 1
fi

if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]; then
  _emit_fail "bare-git-repo" \
    "detail: CWD is inside a bare git repository (no worktree)" \
    "resolution:" \
    "  - run from a cloned (non-bare) worktree"
  exit 1
fi

head_ref="$(git symbolic-ref HEAD 2>/dev/null || true)"
if [ -z "$head_ref" ]; then
  _emit_fail "detached-head" \
    "detail: HEAD is detached (not on a branch)" \
    "resolution:" \
    "  - check out a branch: git checkout main" \
    "  - migration commits need a branch to land on"
  exit 1
fi

if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  _emit_fail "dirty-worktree" \
    "detail: uncommitted changes in the working tree" \
    "resolution:" \
    "  - commit or stash changes before migrating" \
    "  - migration modifies tracked files; a clean state prevents data loss"
  exit 1
fi

_migrate_stage="detect"

# --- detect state ---
tracked="$(git ls-files 2>/dev/null || true)"

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

# --- custom flake detection (#115) ---
has_custom_flake=0
custom_flake_details=""
if [ "$flake_present" -eq 1 ] && [ "$references_sns" -eq 0 ]; then
  seed_inputs="nixpkgs-lock nixpkgs set-and-setting"
  extra_inputs=""
  while IFS= read -r inp; do
    is_seed=0
    for si in $seed_inputs; do
      if [ "$inp" = "$si" ]; then
        is_seed=1
        break
      fi
    done
    [ "$is_seed" -eq 0 ] && extra_inputs="$extra_inputs $inp"
  done < <(grep -oE '[a-zA-Z_-]+\.url\s*=' flake.nix | sed 's/\.url\s*=//;s/[[:space:]]//g' || true)
  extra_inputs="${extra_inputs# }"

  has_overlays=0
  grep -qE 'overlays|overlay' flake.nix 2>/dev/null && has_overlays=1

  has_extra_outputs=0
  grep -qE 'nixosConfigurations|homeConfigurations|nixosModules|darwinConfigurations|templates|lib\.' flake.nix 2>/dev/null && has_extra_outputs=1

  if [ -n "$extra_inputs" ] || [ "$has_overlays" -eq 1 ] || [ "$has_extra_outputs" -eq 1 ]; then
    has_custom_flake=1
    details=""
    [ -n "$extra_inputs" ] && details="extra inputs: $extra_inputs"
    [ "$has_overlays" -eq 1 ] && details="${details:+$details; }overlays detected"
    [ "$has_extra_outputs" -eq 1 ] && details="${details:+$details; }extra outputs detected"
    custom_flake_details="$details"
  fi
fi

# --- extra workflow detection (#115) ---
extra_workflows=""
if [ -d .github/workflows ]; then
  while IFS= read -r wf; do
    wfname="$(basename "$wf")"
    case "$wfname" in
      ci.yml | auto-update.yml) ;;
      *) extra_workflows="$extra_workflows $wfname" ;;
    esac
  done < <(find .github/workflows -maxdepth 1 -name '*.yml' -o -name '*.yaml' | sort)
  extra_workflows="${extra_workflows# }"
fi

# classify: referenced (no-op) | bare | partial-* (#115) | vendored
state="vendored"
if [ "$references_sns" -eq 1 ] && [ "$uses_materialization" -eq 1 ] &&
  [ "$lefthook_tracked" -eq 0 ] && [ "$gitignores_lefthook" -eq 1 ]; then
  state="referenced"
elif [ "$flake_present" -eq 0 ] && [ "$lefthook_present" -eq 0 ]; then
  state="bare"
elif [ "$references_sns" -eq 1 ]; then
  if [ "$lefthook_tracked" -eq 1 ]; then
    state="partial-tracked-lefthook"
  elif [ "$gitignores_lefthook" -eq 0 ]; then
    state="partial-no-gitignore"
  elif [ "$uses_materialization" -eq 0 ]; then
    state="partial-no-materialization"
  fi
fi

echo "migrate: detected state=$state"

if [ -n "$extra_workflows" ]; then
  echo "migrate: extra workflows detected (will preserve): $extra_workflows"
fi

if [ "${MIGRATE_DETECT_ONLY:-}" = "1" ]; then
  exit 0
fi

# already-referenced => no-op (idempotent: a migrated repo re-migrates clean)
if [ "$state" = "referenced" ]; then
  echo "migrate: already referenced -- no-op"
  exit 0
fi

# custom flake => refuse (never silently drop custom content)
if [ "$has_custom_flake" -eq 1 ]; then
  _emit_fail "custom-flake" \
    "detail: flake.nix contains custom content a blind strip would lose" \
    "  $custom_flake_details" \
    "resolution:" \
    "  - reconcile custom content with the referenced thin flake manually" \
    "  - the seed flake is at: $SEED_SRC/flake.nix" \
    "  - after reconciliation, re-run migrate"
  exit 1
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
  [ -n "$extra_workflows" ] && echo "  preserve: extra workflows ($extra_workflows)"
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

_migrate_stage="materialize"
# --- materialize the new state (gitignored) for equivalence + confirm ---
detected="$(bash "$DETECT_SCRIPT")"
mat_out="$(mktemp -d)"
FRAGMENTS="$detected" out="$mat_out" bash "$ASSEMBLE_SCRIPT"
cp -f "$mat_out/lefthook.yml" lefthook.yml
cp -f "$SETTING_SRC/.markdownlint.yml" .markdownlint.yml
cp -f "$SETTING_SRC/.yamllint.yml" .yamllint.yml
rm -rf "$mat_out"

_migrate_stage="equivalence"
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
