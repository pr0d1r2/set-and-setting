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
#
# NOTE: this script is deliberately functionless (no `name()` definitions) to
# satisfy the no-shell-functions guardrail. The lefthook check-name extractor
# (an awk program scoped to keys under a `commands:` block, so
# `remotes:`/`scripts:` list fields like `ref:`/`configs:`/`git_url:` are NOT
# mistaken for checks) is inlined verbatim at each of its three call sites
# rather than shared via a function; failure diagnostics are inlined too.
# shellcheck disable=SC2154,SC2086
set -euo pipefail

# --- structured failure diagnostic (#114) ---
_migrate_stage="pre-flight"
_migrate_fail_emitted=0

# Emit the generic "unexpected failure" diagnostic if a command fails without
# a prior explicit MIGRATE-FAIL (inlined ERR trap; no function per guardrail).
trap '
    rc=$?
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
' ERR

# --- pre-flight: CWD sanity (#115) ---
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  _migrate_fail_emitted=1
  echo ""
  echo "MIGRATE-FAIL: stage=$_migrate_stage reason=not-a-git-repo"
  echo "  detail: CWD is not inside a git repository"
  echo "  resolution:"
  echo "  - run from the root of a git repository"
  echo "  - or: git init && git add . && git commit -m 'initial'"
  echo "  retry: idempotent"
  exit 1
fi

if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  _migrate_fail_emitted=1
  echo ""
  echo "MIGRATE-FAIL: stage=$_migrate_stage reason=no-commits"
  echo "  detail: git repository has no commits (orphan branch)"
  echo "  resolution:"
  echo "  - create an initial commit: git add . && git commit -m 'initial'"
  echo "  retry: idempotent"
  exit 1
fi

if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]; then
  _migrate_fail_emitted=1
  echo ""
  echo "MIGRATE-FAIL: stage=$_migrate_stage reason=bare-git-repo"
  echo "  detail: CWD is inside a bare git repository (no worktree)"
  echo "  resolution:"
  echo "  - run from a cloned (non-bare) worktree"
  echo "  retry: idempotent"
  exit 1
fi

head_ref="$(git symbolic-ref HEAD 2>/dev/null || true)"
if [ -z "$head_ref" ]; then
  _migrate_fail_emitted=1
  echo ""
  echo "MIGRATE-FAIL: stage=$_migrate_stage reason=detached-head"
  echo "  detail: HEAD is detached (not on a branch)"
  echo "  resolution:"
  echo "  - check out a branch: git checkout main"
  echo "  - migration commits need a branch to land on"
  echo "  retry: idempotent"
  exit 1
fi

if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  _migrate_fail_emitted=1
  echo ""
  echo "MIGRATE-FAIL: stage=$_migrate_stage reason=dirty-worktree"
  echo "  detail: uncommitted changes in the working tree"
  echo "  resolution:"
  echo "  - commit or stash changes before migrating"
  echo "  - migration modifies tracked files; a clean state prevents data loss"
  echo "  retry: idempotent"
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
  grep -qE '(^|[[:space:]])overlays?[[:space:]]*[.=\[]' flake.nix 2>/dev/null && has_overlays=1

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

# --- reconciliation attempt (#127) ---
# When a custom flake is detected, try to reconcile: extract custom inputs
# and output blocks from the vendored flake, inject them into the seed
# template. Only fall back to MIGRATE-FAIL when reconciliation is impossible.
reconcile_flake=0
reconciled_inputs=""
reconciled_input_names=""
reconciled_outputs=""
unreconcilable=""

if [ "$has_custom_flake" -eq 1 ]; then
  # un-reconcilable: overlays applied to pkgs (not just defined as outputs)
  if [ "$has_overlays" -eq 1 ] && grep -qE 'overlays\s*=\s*\[' flake.nix; then
    unreconcilable="overlays applied to pkgs (not just defined as output attributes)"
  fi

  # extract custom input declarations
  if [ -z "$unreconcilable" ] && [ -n "$extra_inputs" ]; then
    reconciled_input_names="$extra_inputs"
    for inp in $extra_inputs; do
      inp_lines="$(grep -E "(^[[:space:]]*|^[[:space:]]*inputs\.)${inp}\." flake.nix | sed 's/^[[:space:]]*inputs\.//' || true)"
      if [ -z "$inp_lines" ]; then
        unreconcilable="${unreconcilable:+$unreconcilable; }input $inp: declaration not extractable"
      else
        reconciled_inputs="${reconciled_inputs:+${reconciled_inputs}
}${inp_lines}"
      fi
    done
  fi

  # extract custom output blocks (brace-counted)
  if [ -z "$unreconcilable" ] && { [ "$has_extra_outputs" -eq 1 ] || [ "$has_overlays" -eq 1 ]; }; then
    reconciled_outputs="$(awk '
      BEGIN { cap=0; depth=0; buf=""; result="" }
      /^[[:space:]]*(nixosConfigurations|homeConfigurations|nixosModules|darwinConfigurations|templates|overlays)[[:space:]]*[.=]/ {
        if (!cap) { cap=1; depth=0; buf="" }
      }
      cap {
        buf = buf $0 "\n"
        for (i=1; i<=length($0); i++) {
          c = substr($0, i, 1)
          if (c == "{" || c == "[" || c == "(") depth++
          if (c == "}" || c == "]" || c == ")") depth--
        }
        if (depth <= 0 && /;[[:space:]]*$/) {
          result = result buf
          cap=0; depth=0; buf=""
        }
        next
      }
      END { printf "%s", result }
    ' flake.nix)"
    if [ -z "$reconciled_outputs" ]; then
      unreconcilable="${unreconcilable:+$unreconcilable; }custom output blocks not extractable"
    fi
  fi

  if [ -z "$unreconcilable" ]; then
    reconcile_flake=1
    echo "migrate: custom flake detected, reconciling ($custom_flake_details)"
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

# custom flake, un-reconcilable => refuse with specific detail (#127)
if [ "$has_custom_flake" -eq 1 ] && [ "$reconcile_flake" -eq 0 ]; then
  _migrate_fail_emitted=1
  echo ""
  echo "MIGRATE-FAIL: stage=$_migrate_stage reason=unreconcilable-flake"
  echo "  detail: custom flake content cannot be automatically reconciled"
  echo "  $unreconcilable"
  echo "  resolution:"
  echo "    - manually reconcile custom content with the referenced thin flake"
  echo "    - the seed flake is at: $SEED_SRC/flake.nix"
  echo "    - after reconciliation, re-run migrate"
  echo "  retry: idempotent"
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
  [ "$reconcile_flake" -eq 1 ] && echo "  reconcile: flake.nix (custom content preserved in seed)"
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
saved_vendored=""
if [ "$lefthook_present" -eq 1 ]; then
  saved_vendored="$(mktemp)"
  cp lefthook.yml "$saved_vendored"
fi
trap 'rm -f "$old_checks" "$new_checks" "${saved_vendored:-}"' EXIT

_migrate_stage="strip"
if [ "$lefthook_present" -eq 1 ]; then
  awk '
        /^[A-Za-z]/                      { insec = 0 }
        /^  commands:[[:space:]]*$/      { insec = 1; next }
        /^  [A-Za-z]/ && !/^  commands:/ { insec = 0 }
        insec && /^    [A-Za-z][A-Za-z0-9_-]*:/ {
            k = $1
            sub(/:.*/, "", k)
            print k
        }
    ' lefthook.yml | sort -u >"$old_checks" || true
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
# --- reconcile flake.nix (#127): inject custom content into seed template ---
if [ "$reconcile_flake" -eq 1 ]; then
  awk -v custom_inputs="$reconciled_inputs" \
    -v custom_names="$reconciled_input_names" \
    -v custom_outputs="$reconciled_outputs" '
    { lines[NR] = $0 }
    END {
      last_close = 0
      for (i = NR; i >= 1; i--) {
        if (lines[i] ~ /^    };/) { last_close = i; break }
      }
      n_names = split(custom_names, input_names, " ")
      for (i = 1; i <= NR; i++) {
        skip = 0
        if (lines[i] ~ /set-and-setting\.url/) {
          print lines[i]
          if (custom_inputs != "") {
            print ""
            n_inp = split(custom_inputs, inp_lines, "\n")
            for (j = 1; j <= n_inp; j++) {
              if (inp_lines[j] != "") {
                line = inp_lines[j]
                gsub(/^[[:space:]]+/, "", line)
                print "    " line
              }
            }
          }
          skip = 1
        }
        if (!skip && lines[i] ~ /^      set-and-setting,$/) {
          print lines[i]
          for (j = 1; j <= n_names; j++) {
            print "      " input_names[j] ","
          }
          skip = 1
        }
        if (!skip && i == last_close && custom_outputs != "") {
          print ""
          n_out = split(custom_outputs, out_lines, "\n")
          min_indent = 9999
          for (j = 1; j <= n_out; j++) {
            if (out_lines[j] == "") continue
            match(out_lines[j], /^[[:space:]]*/)
            if (RLENGTH < min_indent) min_indent = RLENGTH
          }
          if (min_indent == 9999) min_indent = 0
          for (j = 1; j <= n_out; j++) {
            if (out_lines[j] == "") continue
            stripped = substr(out_lines[j], min_indent + 1)
            print "      " stripped
          }
        }
        if (!skip) print lines[i]
      }
    }
  ' "$SEED_SRC/flake.nix" >flake.nix
  echo "reconciled: flake.nix (custom content preserved)"
fi

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
    awk '
            /^[A-Za-z]/                      { insec = 0 }
            /^  commands:[[:space:]]*$/      { insec = 1; next }
            /^  [A-Za-z]/ && !/^  commands:/ { insec = 0 }
            insec && /^    [A-Za-z][A-Za-z0-9_-]*:/ {
                k = $1
                sub(/:.*/, "", k)
                print k
            }
        ' "$FULL_LEFTHOOK" | sort -u
  awk '
        /^[A-Za-z]/                      { insec = 0 }
        /^  commands:[[:space:]]*$/      { insec = 1; next }
        /^  [A-Za-z]/ && !/^  commands:/ { insec = 0 }
        insec && /^    [A-Za-z][A-Za-z0-9_-]*:/ {
            k = $1
            sub(/:.*/, "", k)
            print k
        }
    ' lefthook.yml | sort -u
} | grep -v '^$' | sort -u >"$new_checks"

dropped="$(comm -23 "$old_checks" "$new_checks" || true)"

# --- carry-through: repo-local checks (#126) ---
# Identify vendored checks with no standard fragment equivalent. These
# are repo-local checks (e.g., a nix-lefthook-taplo repo's own taplo
# hook) that the CHECKS_UNIVERSE cannot provide. Extract them from the
# saved vendored lefthook.yml and write a tracked lefthook-repo.yml so
# they survive materialization, equivalence passes, and the repo keeps
# dogfooding its own check.
if [ -n "$dropped" ] && [ -n "${saved_vendored:-}" ] && [ -f "${saved_vendored:-}" ]; then
  local_dropped=""
  for check in $dropped; do
    # inline fragment lookup (no function per no-shell-functions guardrail)
    frag=""
    case "$check" in
      gitleaks | git-conflict-markers | \
        git-no-local-paths | execute-permissions | file-size-check | \
        trailing-whitespace | missing-final-newline | editorconfig-checker | \
        typos)
        frag="base"
        ;;
      nixfmt | statix | deadnix | nix-no-embedded-shell)
        frag="nix"
        ;;
      shellcheck | shfmt | no-shell-functions)
        frag="shell"
        ;;
      ascii-only)
        frag="ascii"
        ;;
      markdownlint | markdownlint-agentic)
        frag="markdown"
        ;;
      yamllint)
        frag="yaml"
        ;;
      set-skill-extension | set-skill-size | set-ref-resolution | \
        set-bundle-content)
        frag="set"
        ;;
      *) frag="" ;;
    esac
    [ -z "$frag" ] && local_dropped="$local_dropped $check"
  done
  local_dropped="${local_dropped# }"

  if [ -n "$local_dropped" ]; then
    # Extract repo-local command blocks from the saved vendored
    # lefthook.yml. The awk program finds commands matching the check
    # names under their hook sections (pre-commit/pre-push), collects
    # each block (key + sub-keys), and emits a valid fragment YAML.
    repo_frag="$(awk -v checks="$local_dropped" '
      BEGIN {
        n = split(checks, arr, " ")
        for (i = 1; i <= n; i++) wanted[arr[i]] = 1
        hook = ""; in_cmds = 0; cap = 0; cmd_key = ""
      }
      /^(pre-commit|pre-push):/ {
        hook = $1; sub(/:$/, "", hook)
        in_cmds = 0; cap = 0; next
      }
      /^  commands:[[:space:]]*$/ { in_cmds = 1; next }
      /^  [A-Za-z]/ && !/^  commands:/ { in_cmds = 0; cap = 0; next }
      /^[A-Za-z]/ { in_cmds = 0; cap = 0; next }
      in_cmds && /^    [A-Za-z][A-Za-z0-9_-]*:/ {
        k = $1; sub(/:.*/, "", k)
        if (k in wanted) {
          cap = 1; cmd_key = hook SUBSEP k
          lines[cmd_key] = (lines[cmd_key] ? lines[cmd_key] "\n" : "") $0
          hooks[hook] = 1
        } else { cap = 0 }
        next
      }
      cap { lines[cmd_key] = lines[cmd_key] "\n" $0 }
      END {
        if ("pre-commit" in hooks) {
          printf "\npre-commit:\n  commands:\n"
          for (key in lines) {
            split(key, parts, SUBSEP)
            if (parts[1] == "pre-commit") printf "%s\n", lines[key]
          }
        }
        if ("pre-push" in hooks) {
          printf "\npre-push:\n  commands:\n"
          for (key in lines) {
            split(key, parts, SUBSEP)
            if (parts[1] == "pre-push") printf "%s\n", lines[key]
          }
        }
      }
    ' "$saved_vendored")"

    if [ -n "$repo_frag" ]; then
      printf '# Repo-local checks carried through from vendored lefthook.yml (#126).\n---\n%s\n' "$repo_frag" >lefthook-repo.yml

      # Re-assemble lefthook.yml to include the repo-local fragment
      mat_out2="$(mktemp -d)"
      FRAGMENTS="$detected" out="$mat_out2" bash "$ASSEMBLE_SCRIPT"
      cp -f "$mat_out2/lefthook.yml" lefthook.yml
      rm -rf "$mat_out2"

      git add lefthook-repo.yml

      # Update new_checks with carried-through names so equivalence passes
      printf '%s\n' $local_dropped >>"$new_checks"
      sort -u -o "$new_checks" "$new_checks"
      dropped="$(comm -23 "$old_checks" "$new_checks" || true)"

      echo "carried-through: $local_dropped (repo-local checks preserved in lefthook-repo.yml)"
    fi
  fi
fi

if [ -n "$dropped" ]; then
  _migrate_fail_emitted=1
  dropped_list="$(echo $dropped | tr '\n' ' ' | sed 's/ *$//')"
  echo ""
  echo "MIGRATE-FAIL: stage=equivalence reason=uncovered-checks"
  echo "  dropped: $dropped_list"
  echo "  resolution:"
  for check in $dropped; do
    # inline fragment lookup (no function per no-shell-functions guardrail)
    frag=""
    case "$check" in
      gitleaks | git-conflict-markers | \
        git-no-local-paths | execute-permissions | file-size-check | \
        trailing-whitespace | missing-final-newline | editorconfig-checker | \
        typos)
        frag="base"
        ;;
      nixfmt | statix | deadnix | nix-no-embedded-shell)
        frag="nix"
        ;;
      shellcheck | shfmt | no-shell-functions)
        frag="shell"
        ;;
      ascii-only)
        frag="ascii"
        ;;
      markdownlint | markdownlint-agentic)
        frag="markdown"
        ;;
      yamllint)
        frag="yaml"
        ;;
      set-skill-extension | set-skill-size | set-ref-resolution | \
        set-bundle-content)
        frag="set"
        ;;
      *) frag="" ;;
    esac
    if [ -n "$frag" ]; then
      # inline trigger lookup (no function per no-shell-functions guardrail)
      trigger=""
      case "$frag" in
        base | ascii) trigger="always active" ;;
        nix) trigger="tracked *.nix files" ;;
        shell) trigger="tracked *.sh/*.bash files" ;;
        markdown) trigger="tracked *.md files" ;;
        yaml) trigger="tracked *.yml/*.yaml files" ;;
        set) trigger="tracked set/*.md files" ;;
        *) trigger="" ;;
      esac
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
