# mkSet -- the skill-set emitter (single source of truth for skills).
# Transforms agnostic set/skills/ markdown into the Agent-Skills
# open-standard layout: one skill folder per category. Domain categories
# get a SKILL.md with the conditional-load field (paths) so the body
# loads when matching files are edited; cross-cutting categories emit to
# the always-on rules dir (no globs, always loaded). The agent format
# lives only here (C2/V17). The `agent` seam is the only agent-specific
# surface.
{ lib }:

{
  pkgs,
  categories ? [
    "generic"
    "architecture"
    "ci"
    "cli"
    "git"
    "gnu"
    "just"
    "language"
    "lefthook"
    "nix"
    "nixos"
    "opensource"
    "product"
    "security"
    "test"
    "update"
  ],
  concepts ? true,
  # Skill filenames to omit from the emitted output (e.g. "rtk.md").
  exclude ? [ ],
  # Per-agent seam. Default: Claude.
  agent ? { },
}:

let
  ag = {
    skillPath = ".claude/skills/set";
    rulePath = ".claude/rules";
    condField = "paths";
  }
  // agent;

  skillsDir = ../skills;
  conceptsDir = ../concepts;

  # category -> conditional-load globs. Absent/empty => cross-cutting,
  # emitted as an always-on rule (no globs). Tunable.
  categoryGlobs = {
    nix = [
      "**/*.nix"
      "flake.lock"
    ];
    nixos = [ "**/*.nix" ];
    gnu = [
      "**/*.sh"
      "**/*.bats"
    ];
    test = [ "**/*.bats" ];
    lefthook = [ "lefthook.yml" ];
    just = [
      "**/justfile"
      "**/*.just"
    ];
    cli = [ "**/justfile" ];
    ci = [
      ".github/**/*.yml"
      ".github/**/*.yaml"
    ];
  };

  globsFor = c: categoryGlobs.${c} or [ ];

  excludeFind = lib.concatMapStringsSep " " (e: "! -name ${lib.escapeShellArg e}") exclude;
  excludeList = lib.concatStringsSep " " exclude;

  yamlGlobs =
    c:
    let
      globs = globsFor c;
    in
    lib.optionalString (globs != [ ]) (
      "${ag.condField}:\n" + lib.concatMapStrings (g: "  - \"${g}\"\n") globs
    );

  emitCategory =
    c:
    let
      globs = globsFor c;
      isCond = globs != [ ];
      dest = if isCond then "${ag.skillPath}/${c}/SKILL.md" else "${ag.rulePath}/${c}.md";
    in
    ''
      emit_skill "${c}" "$out/${dest}" ${if isCond then "1" else "0"} <<'GLOBS_EOF'
      ${yamlGlobs c}GLOBS_EOF
    '';

  emitAll = lib.concatMapStrings emitCategory categories;
in
pkgs.runCommand "agent-set" { } ''
  set -euo pipefail
  skills="${skillsDir}"

  emit_skill() {
    cat="$1"; dest="$2"; iscond="$3"
    globs="$(cat)"
    catdir="$skills/$cat"
    core="$skills/$cat.md"
    case " ${excludeList} " in *" $cat.md "*) core="" ;; esac
    descsrc="$core"
    [ -n "$descsrc" ] && [ -f "$descsrc" ] || descsrc="$(find "$catdir" -name '*.md' ${excludeFind} | sort | head -1)"
    title="$(grep -m1 '^# ' "$descsrc" 2>/dev/null | sed 's/^# *//' || true)"
    [ -n "$title" ] || title="$cat"
    purpose="$(grep -m1 -E '^[^#[:space:]]' "$descsrc" 2>/dev/null | tr -d '"' || true)"
    desc="$title"
    [ -n "$purpose" ] && desc="$title -- $purpose"
    mkdir -p "$(dirname "$dest")"
    {
      echo "---"
      echo "name: $cat"
      echo "description: \"$desc\""
      [ -n "$globs" ] && printf '%s\n' "$globs"
      echo "---"
      echo
      [ -n "$core" ] && [ -f "$core" ] && { cat "$core"; echo; }
      find "$catdir" -name '*.md' ${excludeFind} | sort | while read -r f; do
        cat "$f"; echo
      done
    } > "$dest"
  }

  mkdir -p $out
  ${emitAll}

  ${lib.optionalString concepts ''
    mkdir -p "$out/${ag.rulePath}"
    find "${conceptsDir}" -name '*.md' | sort | while read -r f; do
      rel="''${f#${conceptsDir}/}"
      out_f="$out/${ag.rulePath}/concepts-''${rel//\//-}"
      mkdir -p "$(dirname "$out_f")"
      cp "$f" "$out_f"
    done
  ''}

  mkdir -p "$out/bin"
  cat > "$out/bin/sync-set" <<'SYNC_EOF'
  #!/usr/bin/env bash
  set -euo pipefail
  target="''${1:-.}"
  src="$(dirname "$(dirname "$(readlink -f "$0")")")"
  mkdir -p "$target"
  cp -r "$src/.claude" "$target/" 2>/dev/null || true
  echo "synced set -> $target"
  SYNC_EOF
  chmod +x "$out/bin/sync-set"
''
