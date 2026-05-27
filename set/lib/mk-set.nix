{ lib }:

{
  pkgs,
  categories ? [ "generic" ],
  concepts ? true,
  exclude ? [ ],
  extra ? { },
  extraPaths ? { },
}:

let
  categoryDirs = {
    generic = ../skills/generic;
    architecture = ../skills/architecture;
    ci = ../skills/ci;
    git = ../skills/git;
    gnu = ../skills/gnu;
    just = ../skills/just;
    language = ../skills/language;
    lefthook = ../skills/lefthook;
    nix = ../skills/nix;
    nixos = ../skills/nixos;
    opensource = ../skills/opensource;
    product = ../skills/product;
    security = ../skills/security;
    test = ../skills/test;
    update = ../skills/update;
    "drafts/skill" = ../drafts/skill;
    "drafts/agent" = ../drafts/agent;
    "drafts/nix" = ../drafts/nix;
    "drafts/ops" = ../drafts/ops;
    "drafts/context" = ../drafts/context;
  };

  conceptsDir = ../concepts;

  selectedCategories = lib.filterAttrs (n: _: builtins.elem n categories) categoryDirs;

  excludePattern = lib.concatMapStringsSep " " (e: "-not -path '*/${e}'") exclude;

  copyCategory =
    name: path:
    ''
      if [ -d "${path}" ]; then
        find "${path}" -type f -name '*.md' ${excludePattern} | while read -r f; do
          rel="''${f#${path}/}"
          mkdir -p "$(dirname "$out/skills/${name}/$rel")"
          cp "$f" "$out/skills/${name}/$rel"
        done
      fi
    '';

  copyExtra = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: content:
      ''
        mkdir -p "$(dirname "$out/skills/${name}")"
        cat > "$out/skills/${name}" <<'SKILL_EOF'
        ${content}
        SKILL_EOF
      ''
    ) extra
  );

  copyExtraPaths = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: path:
      ''
        mkdir -p "$(dirname "$out/skills/${name}")"
        cp "${path}" "$out/skills/${name}"
      ''
    ) extraPaths
  );

  generateSetMd = ''
    {
      if [ -d "$out/concepts" ]; then
        find "$out/concepts" -type f -name '*.md' | sort | while read -r f; do
          rel="''${f#$out/}"
          echo "@./set/$rel"
        done
      fi
      if [ -f "$out/skills/generic/skill.md" ]; then
        echo "@./set/skills/generic/skill.md"
      fi
      find "$out/skills" -type f -name '*.md' -not -name 'skill.md' | sort | while read -r f; do
        rel="''${f#$out/}"
        echo "@./set/$rel"
      done
    } > "$out/set.md"
  '';

  generateSyncScript = ''
    cat > "$out/bin/sync-set" <<'SYNC_EOF'
    #!/usr/bin/env bash
    set -euo pipefail
    target="''${1:-agent/set}"
    src="$(dirname "$(dirname "$(readlink -f "$0")")")"
    mkdir -p "$target/skills"
    rm -rf "$target/skills" "$target/concepts"
    cp -r "$src/skills" "$target/skills"
    [ -d "$src/concepts" ] && cp -r "$src/concepts" "$target/concepts"
    cp "$src/set.md" "$target/set.md"
    echo "synced $src → $target"
    SYNC_EOF
    chmod +x "$out/bin/sync-set"
  '';
in
pkgs.runCommand "agent-set" { } ''
  mkdir -p $out/skills $out/bin

  ${if concepts then "cp -r ${conceptsDir} $out/concepts" else ""}

  ${lib.concatStringsSep "\n" (lib.mapAttrsToList copyCategory selectedCategories)}

  ${copyExtraPaths}

  ${copyExtra}

  ${generateSetMd}

  ${generateSyncScript}
''
