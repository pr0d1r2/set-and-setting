{
  pkgs,
  settingSet,
  projectRoot,
}:

pkgs.runCommand "setting-drift-check" {
  nativeBuildInputs = [ pkgs.diffutils ];
  src = projectRoot;
} ''
  expected="${settingSet}"
  actual="$src"

  drift=0

  for f in .editorconfig .gitattributes .gitignore; do
    if [ -f "$expected/$f" ]; then
      if [ ! -f "$actual/$f" ]; then
        echo "MISSING: $f — run sync-setting first"
        drift=1
      else
        diff -q "$expected/$f" "$actual/$f" || drift=1
      fi
    fi
  done

  if [ "$drift" -ne 0 ]; then
    echo "DRIFT DETECTED — run: nix run .#sync-setting"
    exit 1
  fi

  echo "no drift"
  touch $out
''
