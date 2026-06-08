# shellcheck shell=bash
# shellcheck disable=SC2154  # $src is injected by mkSetting (the file-bundle path)
# Copy the standard files git must read as regular files (.editorconfig,
# .gitattributes, .gitignore) into the repo root. The lint configs are left in
# the bundle for out-link consumption.
for f in .editorconfig .gitattributes .gitignore; do
    [ -f "$src/$f" ] && cp "$src/$f" "./$f"
done
echo "synced setting -> ."
