{
  pkgs,
  skillSet,
  projectRoot,
  setPath ? "agent/set",
}:

pkgs.runCommand "skill-drift-check" {
  nativeBuildInputs = [ pkgs.diffutils ];
  src = projectRoot;
} ''
  expected="${skillSet}"
  actual="$src/${setPath}"

  if [ ! -d "$actual/skills" ]; then
    echo "ERROR: $actual/skills not found — run sync-set first"
    exit 1
  fi

  drift=0

  # Check skills
  diff -rq "$expected/skills" "$actual/skills" || drift=1

  # Check concepts if present
  if [ -d "$expected/concepts" ]; then
    if [ ! -d "$actual/concepts" ]; then
      echo "ERROR: concepts directory missing"
      drift=1
    else
      diff -rq "$expected/concepts" "$actual/concepts" || drift=1
    fi
  fi

  # Check set.md
  diff -q "$expected/set.md" "$actual/set.md" || drift=1

  if [ "$drift" -ne 0 ]; then
    echo "DRIFT DETECTED — run: nix run .#sync-set"
    exit 1
  fi

  echo "no drift"
  touch $out
''
