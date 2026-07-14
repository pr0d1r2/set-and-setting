#!/usr/bin/env bash
# Check the @->AGENTS.md compiler (V29). Builds a fixture manifest tree and
# asserts Claude @-parse fidelity: recursion, fence/code-span skipping,
# block HTML-comment stripping, and the MAXDEPTH hop limit. Extracted per
# nix/modularity.
# Env in: SCRIPT (agents-md-compile.sh path), out.
# shellcheck disable=SC2154  # $out is provided by the nix runCommand env
# shellcheck disable=SC2016  # single-quoted @refs are intentional literals
set -euo pipefail

d="$(mktemp -d)"
mkdir -p "$d/set"

# Recursion: root -> set/a -> set/b. @ resolves relative to each file's
# own dir, so a.md (inside set/) refers to its sibling as @b.md.
printf '@set/a.md\n' >"$d/root.md"
printf 'AONE\n@b.md\n' >"$d/set/a.md"
printf 'BTWO\n' >"$d/set/b.md"

out1="$(INPUT="$d/root.md" BASE="$d" SELF="$SCRIPT" bash "$SCRIPT")"
case "$out1" in *AONE*) ;; *)
    echo "FAIL: recurse hop1"
    exit 1
    ;;
esac
case "$out1" in *BTWO*) ;; *)
    echo "FAIL: recurse hop2"
    exit 1
    ;;
esac
case "$out1" in *'@set/'*)
    echo "FAIL: unresolved ref remains"
    exit 1
    ;;
esac

# Fence + code span + HTML comment fidelity.
{
    printf 'before\n'
    printf '```\n@set/should-not-resolve.md\n```\n'
    printf 'span `@set/nope.md` end\n'
    printf '<!-- secret comment -->visible\n'
    printf '@c.md\n'
} >"$d/set/a2.md"
printf 'CTHREE\n' >"$d/set/c.md"
printf 'NOPE\n' >"$d/set/should-not-resolve.md"

out2="$(INPUT="$d/set/a2.md" BASE="$d/set" SELF="$SCRIPT" bash "$SCRIPT")"
case "$out2" in *CTHREE*) ;; *)
    echo "FAIL: ref after fence not resolved"
    exit 1
    ;;
esac
# @ inside a fence stays literal, never inlined
case "$out2" in *'@set/should-not-resolve.md'*) ;; *)
    echo "FAIL: fence ref not literal"
    exit 1
    ;;
esac
case "$out2" in *NOPE*)
    echo "FAIL: fence ref was resolved"
    exit 1
    ;;
esac
# code span preserved verbatim
case "$out2" in *'`@set/nope.md`'*) ;; *)
    echo "FAIL: code span altered"
    exit 1
    ;;
esac
# block comment stripped, surrounding text kept
case "$out2" in *'secret comment'*)
    echo "FAIL: comment not stripped"
    exit 1
    ;;
esac
case "$out2" in *visible*) ;; *)
    echo "FAIL: visible text lost"
    exit 1
    ;;
esac

# Hop limit: a chain of 6 includes at most MAXDEPTH=4 deep.
i=0
while [ "$i" -le 5 ]; do
    printf 'MARK%s\n@d%s.md\n' "$i" "$((i + 1))" >"$d/set/d$i.md"
    i=$((i + 1))
done
printf 'MARK6\n' >"$d/set/d6.md"

out3="$(INPUT="$d/set/d0.md" BASE="$d/set" SELF="$SCRIPT" MAXDEPTH=4 bash "$SCRIPT")"
case "$out3" in *MARK4*) ;; *)
    echo "FAIL: hop 4 not included"
    exit 1
    ;;
esac
case "$out3" in *MARK5*)
    echo "FAIL: exceeded hop limit"
    exit 1
    ;;
esac
case "$out3" in *MARK6*)
    echo "FAIL: exceeded hop limit (deep)"
    exit 1
    ;;
esac

echo PASS
touch "$out"
