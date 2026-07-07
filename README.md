# set-and-setting

[![CI](https://github.com/pr0d1r2/set-and-setting/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/set-and-setting/actions/workflows/ci.yml)
[![NixOS 25.11](https://img.shields.io/badge/NixOS-25.11-blue.svg?logo=nixos)](https://nixos.org)

Deterministic, agent-agnostic **set** (mindset: skills, principles,
concepts) and **setting** (environment: guardrails, standards,
infrastructure) for AI coding agent trips.

Psychedelic metaphor: **set + setting = trip**.

## Get started -- one command, zero deps

```bash
nix run github:pr0d1r2/set-and-setting#mkSet
```

That is it. One command materializes curated AI coding skills into
`.claude/skills/set/` in your current directory. The only prerequisite
is nix with flakes enabled.

Core categories (`generic` + `git`) install by default. Add more:

```bash
nix run github:pr0d1r2/set-and-setting#mkSet -- nix security opensource
```

Install everything:

```bash
nix run github:pr0d1r2/set-and-setting#mkSet -- --all
```

Want unified configs (`.markdownlint.yml`, `.yamllint.yml`) and repo
scaffolds (`.editorconfig`, `.gitattributes`, `.gitignore`) too?
Bootstrap sets up skills and standards in one shot:

```bash
nix run github:pr0d1r2/set-and-setting#bootstrap
```

Run with `--help`, `--list`, or `--dry-run` on any installer to see
what it does before writing files.

Re-running `mkSet` with no arguments refreshes whatever was previously
installed (tracked in `.claude/skills/set/.mkset.json`). When upstream
changes, the installer detects the update and shows a notice.

## Three delivery paths

All three paths share one emitter -- the same skill sources produce
identical output regardless of how you consume them.

### Path 1 -- nix run (zero-dependency, per-CWD)

Run from any directory. Nix is the only dependency.

```bash
nix run github:pr0d1r2/set-and-setting#mkSet -- --all
nix run github:pr0d1r2/set-and-setting#mkSetting
nix run github:pr0d1r2/set-and-setting#mkSetting-init
nix run github:pr0d1r2/set-and-setting#mkScaffold
```

| App | What it does |
| --- | ------------ |
| `mkSet` | Materialize skills into `.claude/skills/set/` |
| `mkSetting` | Materialize unified configs (always overwrites) |
| `mkSetting-init` | Scaffold repo starters (skips files that exist) |
| `mkScaffold` | Scaffold flake.nix, lefthook.yml, CI workflow (skips files that exist) |
| `bootstrap` | All four in one command |

Skills are emitted at run time -- the installer carries agnostic
source and emitter scripts, not a pre-built per-agent tree.

### Path 2 -- flake input (pinned, drift-checked)

Pin the version in your flake and sync after each update.

```nix
{
  inputs.set-and-setting.url = "github:pr0d1r2/set-and-setting";

  outputs = { self, nixpkgs, set-and-setting, ... }:
    let forAllSystems = ...; in
    {
      packages = forAllSystems (pkgs: {
        set = set-and-setting.lib.mkSet { inherit pkgs; };
        setting = (set-and-setting.lib.mkSetting { inherit pkgs; }).materialized;
      });

      devShells = forAllSystems (pkgs:
        let sys = pkgs.stdenv.hostPlatform.system; in
        set-and-setting.lib.mkDevShells {
          inherit pkgs;
          basePackages = [ ... ];
          defaultShellHook = ''
            ${self.packages.${sys}.setting}/bin/sync-setting .
          '';
          agenticShellHook = ''
            ${self.packages.${sys}.setting}/bin/sync-setting .
            ${self.packages.${sys}.set}/bin/sync-set .
          '';
        }
      );

      checks = forAllSystems (pkgs: {
        dep-graph = set-and-setting.lib.mkDepGraphCheck {
          inherit pkgs;
          projectRoot = ./.;
        };
      });
    };
}
```

The `defaultShellHook` syncs materialized configs so lefthook hooks
find them. The `agenticShellHook` additionally syncs skills for the
AI agent. Stacked shells (T59): `default` = CI + non-LLM tooling,
`agentic` = default + LLM.

See `setting/scaffold/component-flake.txt` for a complete consumer
flake template (scaffolded by `mkScaffold`).

#### CI sync pre-step

Materialized configs (`.markdownlint.yml`, `.yamllint.yml`) are
gitignored. CI must sync them before hooks run:

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: cachix/install-nix-action@v27
  - name: Sync materialized configs
    run: |
      setting_pkg="$(nix build .#setting --print-out-paths --no-link)"
      "$setting_pkg/bin/sync-setting" .
  - uses: pr0d1r2/nix-lefthook-ci-action@ce9a118b
    with:
      devshell: "default"
```

The sync step builds the pinned `packages.setting` and copies configs
into the workspace. The CI action re-checks-out tracked files but
preserves untracked (gitignored) files, so synced configs survive.

See `setting/scaffold/ci.yml` for the complete CI template.

#### Auto-update

Set up daily auto-updates with the reusable workflow:

```yaml
uses: pr0d1r2/set-and-setting/.github/workflows/auto-update.yml@main
```

See `setting/scaffold/auto-update.yml` for the complete template.

### Path 3 -- home-manager (user-level)

Install skills globally so every repo inherits them.

```nix
{ inputs, pkgs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  skillSet = inputs.set-and-setting.packages.${system}.set;
in
{
  home.file.".claude/rules/set" = {
    source = "${skillSet}/.claude/rules/set";
    recursive = true;
  };
  home.file.".claude/rules/set.md".source =
    "${skillSet}/.claude/rules/set.md";
}
```

This writes the skill rules into `~/.claude/rules/set/`. No per-repo
sync needed -- Claude Code reads rules from both the repo and the
home directory. See `examples/home-manager.nix` for a complete
home-manager module with setting sync.

## Architecture

```mermaid
graph LR
    subgraph "set-and-setting"
        S["set/skills/ (16 categories)"] --> mkSet[lib.mkSet]
        C[set/concepts/] --> mkSet
        E[setting/standards/] --> mkSetting[lib.mkSetting]
    end

    mkSet --> D1["packages.set (skills + rules)"]
    mkSetting --> D2["packages.setting (configs + scaffolds)"]
```

## Consumer dependency graph

```mermaid
graph BT
    SAS["set-and-setting\n(agent-agnostic)"]
    ADAPTER["agent adapter\n(vendor-specific:\nmodel, presets, tools)"]
    CONSUMER1["consumer repo A"]
    CONSUMER2["consumer repo B"]

    ADAPTER --> SAS
    CONSUMER1 --> ADAPTER
    CONSUMER2 --> ADAPTER
```

## Consumer workflow

```mermaid
sequenceDiagram
    participant U as upstream
    participant C as consumer repo

    U->>U: improve skills / standards
    C->>U: nix flake update set-and-setting
    C->>C: nix build -> sync-set + sync-setting
    C->>C: git commit synced files
    Note over C: deterministic, reproducible upgrade
```

## API

### `sets`

Attrset of raw paths to each of 16 skill category directories:

`generic` `architecture` `ci` `cli` `git` `gnu` `just` `language`
`lefthook` `nix` `nixos` `opensource` `product` `security` `test`
`update`

### `drafts`

Attrset of raw paths to draft category directories (opt-in via
`categories = [ "drafts/skill" ... ]`):

`skill` `agent` `nix` `ops` `context`

### `settings`

Attrset of raw paths to each standard directory:

`editorconfig` `gitattributes` `gitignore`

### `lib.mkSet`

Builds a skill-set derivation from selected categories. Emits the
Agent-Skills open-standard layout: one `SKILL.md` per category with
derived `name`/`description` frontmatter, plus raw facet files linked
from the body.

```nix
lib.mkSet {
  inherit pkgs;
  categories = [ "generic" "git" "nix" "security" ];
  concepts = true;   # include set/concepts/ (default: true)
  exclude = [ ];      # paths to exclude from output
}
```

Output layout:

- `.claude/skills/set/<category>/SKILL.md` -- domain skills
  (conditional-load `paths` field matching category globs)
- `.claude/skills/set/<category>/<facet>.md` -- raw facet files
- `.claude/rules/<category>.md` -- cross-cutting skills (always-on)
- `.claude/rules/concepts-<name>.md` -- concept files
- `bin/sync-set` -- copies emitted tree to a target directory

### `lib.mkSetting`

Builds infrastructure standards with two output kinds.

```nix
lib.mkSetting {
  inherit pkgs;
  editorconfig = true;
  gitattributes = true;
  gitignore = [ "nix" "claude" "setting" ];
  markdownlint = true;
  yamllint = true;
  fileSizeLimits = true;
}
```

**Materialized** (always synced, gitignored): `.markdownlint.yml`,
`.yamllint.yml`, `.claude/` commands and allowances.

**Seed/init** (scaffolded once, then repo-owned): `.editorconfig`,
`.gitattributes`, `.gitignore`,
`config/lefthook/file_size_limits.yml`, `.narrow-language-*.dic`,
`.nix-embedded-shell-allowlist`.

Two scripts: `bin/sync-setting` (materialize, always overwrites) and
`bin/sync-setting-init` (scaffold, skips files that exist).

### `lib.mkDriftCheck`

Compares synced project files against built derivation. Fails with
exit 1 on drift.

```nix
lib.mkDriftCheck {
  inherit pkgs skillSet;
  projectRoot = ./.;
  setPath = "agent/set";
}
```

### `checks`

`nix flake check` runs `mkSet-generic`, `compose-set`,
`mkSetting-default`, and `compose-setting` on all supported systems.

## Supported systems

- `aarch64-darwin`
- `x86_64-darwin`
- `x86_64-linux`
- `aarch64-linux`

## Agent-agnostic design

Skills in `set/` and standards in `setting/` contain no vendor-specific
content. The only agent-specific surface is a `{ dir, condField,
alwaysOnFile }` seam defaulting to Claude. The same agnostic sources
build for any agent given its seam values.

Any AI coding agent (Claude, Codex, Gemini CLI, Copilot, Amp, etc.)
can consume the output. See SPEC.md for the agnosticism proof targets.

## License

MIT
