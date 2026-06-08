{ lib }:

{
  pkgs,
  editorconfig ? true,
  gitattributes ? true,
  gitignore ? [
    "nix"
    "claude"
  ],
  markdownlint ? true,
  yamllint ? true,
  fileSizeLimits ? true,
}:

let
  standardsDir = ../standards;

  composeGitignore = lib.concatMapStringsSep "\n" (
    f: "cat ${standardsDir}/gitignore/${f}.gitignore >> $out/.gitignore"
  ) gitignore;
in
pkgs.runCommand "agent-setting" { } ''
  mkdir -p $out $out/bin

  ${if editorconfig then "cp ${standardsDir}/editorconfig $out/.editorconfig" else ""}
  ${if gitattributes then "cp ${standardsDir}/gitattributes $out/.gitattributes" else ""}
  ${if gitignore != [ ] then composeGitignore else ""}

  ${if markdownlint then "cp ${standardsDir}/markdownlint.yml $out/.markdownlint.yml" else ""}
  ${if yamllint then "cp ${standardsDir}/yamllint.yml $out/.yamllint.yml" else ""}
  ${
    if fileSizeLimits then
      ''
        mkdir -p $out/config/lefthook
        cp ${standardsDir}/lefthook/file_size_limits.yml $out/config/lefthook/file_size_limits.yml
      ''
    else
      ""
  }

  cat > $out/bin/sync-setting <<'SYNC_EOF'
  #!/usr/bin/env bash
  set -euo pipefail
  src="$(dirname "$(dirname "$(readlink -f "$0")")")"
  for f in .editorconfig .gitattributes .gitignore; do
    [ -f "$src/$f" ] && cp "$src/$f" "./$f"
  done
  echo "synced setting -> ."
  SYNC_EOF
  chmod +x $out/bin/sync-setting
''
