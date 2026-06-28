{
  description = "Set and Setting -- deterministic agent mindset and environment";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";

    nix-lefthook = {
      url = "github:pr0d1r2/nix-lefthook";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-lefthook-changelog-touched-src = {
      url = "github:pr0d1r2/nix-lefthook-changelog-touched";
      flake = false;
    };
    nix-lefthook-commit-msg-lint-src = {
      url = "github:pr0d1r2/nix-lefthook-commit-msg-lint";
      flake = false;
    };
    nix-lefthook-ascii-only-src = {
      url = "github:pr0d1r2/nix-lefthook-ascii-only";
      flake = false;
    };
    nix-lefthook-deadnix-src = {
      url = "github:pr0d1r2/nix-lefthook-deadnix";
      flake = false;
    };
    nix-lefthook-editorconfig-checker-src = {
      url = "github:pr0d1r2/nix-lefthook-editorconfig-checker";
      flake = false;
    };
    nix-lefthook-execute-permissions-src = {
      url = "github:pr0d1r2/nix-lefthook-execute-permissions";
      flake = false;
    };
    nix-lefthook-file-size-check-src = {
      url = "github:pr0d1r2/nix-lefthook-file-size-check";
      flake = false;
    };
    nix-lefthook-git-conflict-markers-src = {
      url = "github:pr0d1r2/nix-lefthook-git-conflict-markers";
      flake = false;
    };
    nix-lefthook-git-no-local-paths-src = {
      url = "github:pr0d1r2/nix-lefthook-git-no-local-paths";
      flake = false;
    };
    nix-lefthook-gitleaks-src = {
      url = "github:pr0d1r2/nix-lefthook-gitleaks";
      flake = false;
    };
    nix-lefthook-markdownlint-src = {
      url = "github:pr0d1r2/nix-lefthook-markdownlint";
      flake = false;
    };
    nix-lefthook-markdownlint-agentic-src = {
      url = "github:pr0d1r2/nix-lefthook-markdownlint-agentic";
      flake = false;
    };
    nix-lefthook-missing-final-newline-src = {
      url = "github:pr0d1r2/nix-lefthook-missing-final-newline";
      flake = false;
    };
    nix-lefthook-narrow-language-src = {
      url = "github:pr0d1r2/nix-lefthook-narrow-language";
      flake = false;
    };
    nix-lefthook-nix-flake-check-src = {
      url = "github:pr0d1r2/nix-lefthook-nix-flake-check";
      flake = false;
    };
    nix-lefthook-nix-flake-eval-src = {
      url = "github:pr0d1r2/nix-lefthook-nix-flake-eval";
      flake = false;
    };
    nix-lefthook-no-shell-functions-src = {
      url = "github:pr0d1r2/nix-lefthook-no-shell-functions";
      flake = false;
    };
    nix-lefthook-shellcheck-src = {
      url = "github:pr0d1r2/nix-lefthook-shellcheck";
      flake = false;
    };
    nix-lefthook-shfmt-src = {
      url = "github:pr0d1r2/nix-lefthook-shfmt";
      flake = false;
    };
    nix-lefthook-nix-no-embedded-shell-src = {
      url = "github:pr0d1r2/nix-lefthook-nix-no-embedded-shell";
      flake = false;
    };
    nix-lefthook-nixfmt-src = {
      url = "github:pr0d1r2/nix-lefthook-nixfmt";
      flake = false;
    };
    nix-lefthook-statix-src = {
      url = "github:pr0d1r2/nix-lefthook-statix";
      flake = false;
    };
    nix-lefthook-trailing-whitespace-src = {
      url = "github:pr0d1r2/nix-lefthook-trailing-whitespace";
      flake = false;
    };
    nix-lefthook-unicode-lint-src = {
      url = "github:pr0d1r2/nix-lefthook-unicode-lint";
      flake = false;
    };
    nix-lefthook-typos-src = {
      url = "github:pr0d1r2/nix-lefthook-typos";
      flake = false;
    };
    nix-lefthook-yamllint-src = {
      url = "github:pr0d1r2/nix-lefthook-yamllint";
      flake = false;
    };
    nix-lefthook-bats-parse-src = {
      url = "github:pr0d1r2/nix-lefthook-bats-parse";
      flake = false;
    };
    nix-lefthook-bats-unit-src = {
      url = "github:pr0d1r2/nix-lefthook-bats-unit";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-lefthook,
      nix-lefthook-changelog-touched-src,
      nix-lefthook-commit-msg-lint-src,
      nix-lefthook-ascii-only-src,
      nix-lefthook-deadnix-src,
      nix-lefthook-editorconfig-checker-src,
      nix-lefthook-execute-permissions-src,
      nix-lefthook-file-size-check-src,
      nix-lefthook-git-conflict-markers-src,
      nix-lefthook-git-no-local-paths-src,
      nix-lefthook-gitleaks-src,
      nix-lefthook-markdownlint-src,
      nix-lefthook-markdownlint-agentic-src,
      nix-lefthook-missing-final-newline-src,
      nix-lefthook-narrow-language-src,
      nix-lefthook-nix-flake-check-src,
      nix-lefthook-nix-flake-eval-src,
      nix-lefthook-nix-no-embedded-shell-src,
      nix-lefthook-no-shell-functions-src,
      nix-lefthook-shellcheck-src,
      nix-lefthook-shfmt-src,
      nix-lefthook-nixfmt-src,
      nix-lefthook-statix-src,
      nix-lefthook-trailing-whitespace-src,
      nix-lefthook-typos-src,
      nix-lefthook-unicode-lint-src,
      nix-lefthook-yamllint-src,
      nix-lefthook-bats-parse-src,
      nix-lefthook-bats-unit-src,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});

      wrap =
        pkgs: name: src: extra:
        pkgs.writeShellApplication (
          {
            inherit name;
            text = builtins.readFile "${src}/${name}.sh";
          }
          // extra
        );

      lefthookWrappersFor =
        pkgs:
        let
          w = wrap pkgs;
        in
        [
          (w "lefthook-commit-msg-lint" nix-lefthook-commit-msg-lint-src {
            runtimeInputs = [ pkgs.coreutils ];
          })
          (w "lefthook-changelog-touched" nix-lefthook-changelog-touched-src {
            runtimeInputs = [
              pkgs.git
              pkgs.gnugrep
            ];
          })
          (w "lefthook-ascii-only" nix-lefthook-ascii-only-src {
            runtimeInputs = [ pkgs.gnugrep ];
          })
          (w "lefthook-deadnix" nix-lefthook-deadnix-src {
            runtimeInputs = [ pkgs.deadnix ];
          })
          (w "lefthook-editorconfig-checker" nix-lefthook-editorconfig-checker-src {
            runtimeInputs = [ pkgs.editorconfig-checker ];
          })
          (w "lefthook-execute-permissions" nix-lefthook-execute-permissions-src {
            runtimeInputs = [ pkgs.gnugrep ];
          })
          (
            let
              get-file-size-limit = pkgs.writeShellApplication {
                name = "get-file-size-limit";
                text = builtins.readFile "${nix-lefthook-file-size-check-src}/get-file-size-limit.sh";
                runtimeInputs = [
                  pkgs.gawk
                  pkgs.gnugrep
                ];
              };
            in
            w "lefthook-file-size-check" nix-lefthook-file-size-check-src {
              runtimeInputs = [
                get-file-size-limit
                pkgs.gawk
                pkgs.gnugrep
                pkgs.coreutils
              ];
            }
          )
          (w "lefthook-git-conflict-markers" nix-lefthook-git-conflict-markers-src {
            runtimeInputs = [ pkgs.gnugrep ];
          })
          (w "lefthook-git-no-local-paths" nix-lefthook-git-no-local-paths-src {
            runtimeInputs = [ pkgs.gnugrep ];
          })
          (w "lefthook-gitleaks" nix-lefthook-gitleaks-src {
            runtimeInputs = [
              pkgs.gitleaks
              pkgs.coreutils
            ];
          })
          (w "lefthook-markdownlint" nix-lefthook-markdownlint-src {
            runtimeInputs = [ pkgs.markdownlint-cli ];
          })
          (w "lefthook-markdownlint-agentic" nix-lefthook-markdownlint-agentic-src {
            runtimeInputs = [ pkgs.markdownlint-cli ];
          })
          (w "lefthook-missing-final-newline" nix-lefthook-missing-final-newline-src { })
          (w "lefthook-narrow-language" nix-lefthook-narrow-language-src {
            runtimeInputs = [
              pkgs.coreutils
              pkgs.gawk
              pkgs.gnugrep
              pkgs.gnused
            ];
          })
          (w "lefthook-narrow-language-add" nix-lefthook-narrow-language-src {
            runtimeInputs = [
              pkgs.coreutils
              pkgs.gawk
              pkgs.git
              pkgs.gnugrep
              pkgs.gnused
            ];
          })
          (w "lefthook-narrow-language-compact" nix-lefthook-narrow-language-src {
            runtimeInputs = [
              pkgs.coreutils
              pkgs.gawk
              pkgs.git
              pkgs.gnugrep
              pkgs.gnused
            ];
          })
          (w "lefthook-narrow-language-freeze" nix-lefthook-narrow-language-src {
            runtimeInputs = [
              pkgs.git
              pkgs.gnugrep
            ];
          })
          (w "lefthook-nix-flake-eval" nix-lefthook-nix-flake-eval-src {
            runtimeInputs = [ pkgs.nix ];
          })
          (w "lefthook-nix-flake-check" nix-lefthook-nix-flake-check-src {
            runtimeInputs = [ pkgs.nix ];
          })
          (pkgs.writeShellApplication {
            name = "lefthook-nix-no-embedded-shell";
            text = ''
              SCANNER="${nix-lefthook-nix-no-embedded-shell-src}/scan-nix-no-embedded-shell.sh"
            ''
            + builtins.readFile "${nix-lefthook-nix-no-embedded-shell-src}/lefthook-nix-no-embedded-shell.sh";
          })
          (w "lefthook-no-shell-functions" nix-lefthook-no-shell-functions-src { })
          (w "lefthook-shellcheck" nix-lefthook-shellcheck-src {
            runtimeInputs = [ pkgs.shellcheck ];
          })
          (w "lefthook-shfmt" nix-lefthook-shfmt-src {
            runtimeInputs = [ pkgs.shfmt ];
          })
          (w "lefthook-nixfmt" nix-lefthook-nixfmt-src {
            runtimeInputs = [ pkgs.nixfmt ];
          })
          (w "lefthook-statix" nix-lefthook-statix-src {
            runtimeInputs = [ pkgs.statix ];
          })
          (w "lefthook-trailing-whitespace" nix-lefthook-trailing-whitespace-src {
            runtimeInputs = [ pkgs.gnugrep ];
          })
          (w "lefthook-unicode-lint" nix-lefthook-unicode-lint-src {
            runtimeInputs = [
              pkgs.gnugrep
              pkgs.libiconv
            ];
          })
          (w "lefthook-typos" nix-lefthook-typos-src {
            runtimeInputs = [ pkgs.typos ];
          })
          (w "lefthook-yamllint" nix-lefthook-yamllint-src {
            runtimeInputs = [ pkgs.yamllint ];
          })
          (w "lefthook-bats-parse" nix-lefthook-bats-parse-src {
            runtimeInputs = [
              pkgs.bats
              pkgs.coreutils
            ];
          })
          (w "lefthook-bats-unit" nix-lefthook-bats-unit-src {
            runtimeInputs = [
              pkgs.bats
              pkgs.parallel
              pkgs.coreutils
            ];
          })
        ];
    in
    {
      # Set: skill categories (raw paths)
      sets = {
        generic = ./set/skills/generic;
        architecture = ./set/skills/architecture;
        ci = ./set/skills/ci;
        cli = ./set/skills/cli;
        git = ./set/skills/git;
        gnu = ./set/skills/gnu;
        integration = ./set/skills/integration;
        just = ./set/skills/just;
        language = ./set/skills/language;
        lefthook = ./set/skills/lefthook;
        nix = ./set/skills/nix;
        nixos = ./set/skills/nixos;
        opensource = ./set/skills/opensource;
        product = ./set/skills/product;
        security = ./set/skills/security;
        test = ./set/skills/test;
        update = ./set/skills/update;
      };

      # Drafts: incubating skills (opt-in, not loaded by default)
      drafts = {
        skill = ./set/drafts/skill;
        agent = ./set/drafts/agent;
        nix = ./set/drafts/nix;
        ops = ./set/drafts/ops;
        context = ./set/drafts/context;
      };

      # Setting: project infrastructure standards (raw paths)
      settings = {
        editorconfig = ./setting/standards/editorconfig;
        gitattributes = ./setting/standards/gitattributes;
        gitignore = ./setting/standards/gitignore;
      };

      lib = {
        mkSet = import ./set/lib/mk-set.nix { inherit (nixpkgs) lib; };
        mkSetting = import ./setting/lib/mk-setting.nix { inherit (nixpkgs) lib; };
        mkDriftCheck = import ./lib/mk-drift-check.nix;
        mkSettingDriftCheck = import ./lib/mk-setting-drift-check.nix;
        mkMaterializeCheck = import ./lib/mk-materialize-check.nix { inherit (nixpkgs) lib; };
      };

      packages = forAllSystems (pkgs: {
        set = import ./set/lib/mk-set.nix { inherit (nixpkgs) lib; } { inherit pkgs; };
        setting =
          (import ./setting/lib/mk-setting.nix { inherit (nixpkgs) lib; } { inherit pkgs; }).materialized;
      });

      devShells = forAllSystems (pkgs: {
        ci = pkgs.mkShell {
          packages = (lefthookWrappersFor pkgs) ++ [
            pkgs.coreutils
            pkgs.git
            pkgs.nix
            pkgs.bats
            nix-lefthook.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
          shellHook = ''
            export HOME="''${HOME:-/tmp/ci-home}"
            export GIT_OPTIONAL_LOCKS=0
            mkdir -p "$HOME"
          '';
        };
        default = pkgs.mkShell {
          packages = (lefthookWrappersFor pkgs) ++ [
            pkgs.coreutils
            pkgs.git
            pkgs.nix
            pkgs.gh
            pkgs.bats
            nix-lefthook.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
          shellHook = ''
            export NIX_CONFIG="experimental-features = nix-command flakes"
            [ -f .git/hooks/pre-commit ] || lefthook install
            ${self.packages.${pkgs.stdenv.hostPlatform.system}.set}/bin/sync-set .
          '';
        };
      });

      checks = forAllSystems (pkgs: {
        mkSet-generic = import ./set/lib/mk-set.nix { inherit (nixpkgs) lib; } {
          inherit pkgs;
          categories = [ "generic" ];
        };

        # meta-resolve -- V30: the sidecar map resolves each source path to
        # { channel, paths, keywords, always } via category fallback <-
        # subtree entry <- exact-file override (most specific wins).
        meta-resolve =
          let
            meta = import ./set/meta.nix { inherit (nixpkgs) lib; };
            r = meta.resolve;
            ok =
              # category fallback: domain category gets its narrow globs
              assert (r "nix/flake.md").channel == "domain";
              assert builtins.elem "**/*.nix" (r "nix/flake.md").paths;
              assert (r "nix/flake.md").keywords == [ "nix" ];
              assert !(r "nix/flake.md").always;
              # core fallback: core category is always-on
              assert (r "git/git.md").channel == "core";
              assert (r "git/git.md").always;
              # subtree inherit: language/* picks up the language subtree keywords
              assert builtins.elem "prose" (r "language/language.md").keywords;
              # per-file override beats subtree
              assert builtins.elem "narrow-language" (r "language/narrow.md").keywords;
              # deep path still resolves via category fallback (core + broad)
              assert (r "generic/skill/interchange.md").always;
              assert (r "generic/skill/interchange.md").paths == [ "**/*" ];
              true;
          in
          pkgs.runCommand "meta-resolve-check" { inherit ok; } ''
            echo PASS
            touch $out
          '';

        # agent-profiles -- V21/I.agentProfile: each profile carries all
        # channel mechanisms (always-on file+import, conditional, skill),
        # and the back-compat dir/condField seam derives from conditional.
        agent-profiles =
          let
            agents = import ./set/lib/agents.nix;
            c = agents.claude;
            o = agents.opencode;
            ok =
              # Claude profile mechanisms
              assert c.alwaysOn.file == "CLAUDE.md";
              assert c.alwaysOn.import == "@";
              assert c.conditional.field == "paths";
              assert c.skill.dir == ".claude/skills";
              assert c.skill.file == "SKILL.md";
              # opencode differs (agnosticism seam, V23)
              assert o.alwaysOn.file == "AGENTS.md";
              assert o.alwaysOn.import == "inline";
              assert o.conditional.field == "globs";
              # back-compat seam derives from conditional (single source)
              assert c.dir == c.conditional.dir;
              assert c.condField == c.conditional.field;
              assert o.dir == o.conditional.dir;
              assert o.condField == o.conditional.field;
              true;
          in
          pkgs.runCommand "agent-profiles-check" { inherit ok; } ''
            echo PASS
            touch $out
          '';

        # agents-md-compile -- V29: the @->AGENTS.md compiler resolves a
        # Claude @-manifest recursively, mirroring Claude @-parse rules.
        agents-md-compile =
          pkgs.runCommand "agents-md-compile-check"
            {
              SCRIPT = ./lib/agents-md-compile.sh;
            }
            ''
              bash ${./lib/agents-md-compile-check.sh}
            '';

        # agents-md -- V29 end-to-end: compile the real mkSet set.md
        # manifest via the nix wrapper; the always-on core inlines.
        agents-md =
          let
            mkSet = import ./set/lib/mk-set.nix { inherit (nixpkgs) lib; };
            full = mkSet { inherit pkgs; };
            compile = import ./lib/agents-md-compile.nix;
            compiled = compile {
              inherit pkgs;
              src = "${full}/.claude/rules";
              entry = "set.md";
            };
          in
          pkgs.runCommand "agents-md-check" { } ''
            f="${compiled}/AGENTS.md"
            [ -f "$f" ] || { echo "FAIL: no AGENTS.md"; exit 1; }
            grep -q 'Auto commit after successful prompt' "$f" \
              || { echo "FAIL: git core not inlined"; exit 1; }
            grep -q "behavioral rules" "$f" \
              || { echo "FAIL: generic core not inlined"; exit 1; }
            # always-on manifest had no domain refs, so none leak in
            if grep -q '^@set/nix' "$f"; then
              echo "FAIL: unexpected domain ref in AGENTS.md"; exit 1
            fi
            echo PASS
            touch $out
          '';

        compose-set =
          let
            mkSet = import ./set/lib/mk-set.nix { inherit (nixpkgs) lib; };
            full = mkSet { inherit pkgs; };
            excluded = mkSet {
              inherit pkgs;
              categories = [ "generic" ];
              exclude = [ "rtk.md" ];
            };
          in
          pkgs.runCommand "compose-set-check" { } ''
            setdir="${full}/.claude/rules/set"

            # CHANNEL b (conditional domain): rule carries the conditional-
            # load field + nix glob (V17/V19)
            grep -q '^paths:' "$setdir/nix/flake.md" \
              || { echo "FAIL: nix/flake.md missing paths"; exit 1; }
            grep -qF '"**/*.nix"' "$setdir/nix/flake.md" \
              || { echo "FAIL: nix glob"; exit 1; }

            # CHANNEL a (always-on core, V18/V32): core category emits
            # path-less rules -- NO frontmatter, body starts at line 1
            if grep -q '^paths:' "$setdir/generic/skill.md"; then
              echo "FAIL: core generic/skill.md must be path-less"; exit 1
            fi
            head -1 "$setdir/generic/skill.md" | grep -q '^# Skill' \
              || { echo "FAIL: core body not verbatim from line 1"; exit 1; }
            if grep -q '^paths:' "$setdir/git/git.md"; then
              echo "FAIL: core git/git.md must be path-less"; exit 1
            fi

            # per-file override (meta V30): generic/rtk.md flipped to domain
            grep -q '^paths:' "$setdir/generic/rtk.md" \
              || { echo "FAIL: rtk override should be domain (paths)"; exit 1; }

            # loose top-level cli.md emitted as a (domain) rule file
            grep -q 'justfile' "$setdir/cli.md" \
              || { echo "FAIL: cli core not emitted"; exit 1; }

            # agnostic body preserved verbatim (a known source line)
            grep -q 'The project starts with nix flake' "$setdir/nix/flake.md" \
              || { echo "FAIL: body"; exit 1; }

            # exclude omits the file from the emitted output (V8)
            exdir="${excluded}/.claude/rules/set"
            if [ -f "$exdir/generic/rtk.md" ]; then
              echo "FAIL: exclude did not drop rtk.md"; exit 1
            fi

            # source tree mirrored 1:1 (V19/V25)
            [ -f "$setdir/nix/develop.md" ] \
              || { echo "FAIL: nix/develop rule missing"; exit 1; }
            grep -q '^paths:' "$setdir/nix/develop.md" \
              || { echo "FAIL: nix/develop.md missing paths"; exit 1; }

            # nested files preserve path structure
            [ -f "$setdir/nix/infinity/gap.md" ] \
              || { echo "FAIL: nested rule missing"; exit 1; }

            # always-on @-manifest (channel a, V18/V29): sibling set.md
            # lists @-refs to concepts + core, omits domain rules
            manifest="${full}/.claude/rules/set.md"
            [ -f "$manifest" ] || { echo "FAIL: set.md manifest missing"; exit 1; }
            grep -q '^@set/concepts-user.md$' "$manifest" \
              || { echo "FAIL: set.md missing concept ref"; exit 1; }
            grep -q '^@set/generic/skill.md$' "$manifest" \
              || { echo "FAIL: set.md missing core ref"; exit 1; }
            if grep -q 'nix/flake.md' "$manifest"; then
              echo "FAIL: set.md must not list domain rules"; exit 1
            fi

            # CHANNEL c (portable SKILL.md, V20): per-category skill folder
            skill="${full}/.claude/skills/set-nix/SKILL.md"
            [ -f "$skill" ] || { echo "FAIL: set-nix SKILL.md missing"; exit 1; }
            grep -q '^name: set-nix$' "$skill" \
              || { echo "FAIL: SKILL.md missing name"; exit 1; }
            grep -q '^description:' "$skill" \
              || { echo "FAIL: SKILL.md missing description"; exit 1; }
            grep -qF '"**/*.nix"' "$skill" \
              || { echo "FAIL: SKILL.md missing nix glob"; exit 1; }
            grep -q 'The project starts with nix flake' "$skill" \
              || { echo "FAIL: SKILL.md missing inlined body"; exit 1; }

            # exclude propagates to the SKILL.md channel too (V8)
            exskill="${excluded}/.claude/skills/set-generic/SKILL.md"
            [ -f "$exskill" ] || { echo "FAIL: excluded set-generic SKILL.md missing"; exit 1; }
            if grep -qi 'rtk' "$exskill"; then
              echo "FAIL: excluded rtk leaked into SKILL.md"; exit 1
            fi

            echo PASS
            touch $out
          '';

        mkSetting-default =
          let
            mkSetting = import ./setting/lib/mk-setting.nix { inherit (nixpkgs) lib; };
          in
          mkSetting { inherit pkgs; };

        compose-setting =
          let
            mkSetting = import ./setting/lib/mk-setting.nix { inherit (nixpkgs) lib; };
            full = mkSetting { inherit pkgs; };
          in
          pkgs.runCommand "compose-setting-check" { } ''
            # materialized files present in full output
            [ -e "${full}/.markdownlint.yml" ] || { echo "FAIL: no .markdownlint.yml"; exit 1; }
            [ -e "${full}/.yamllint.yml" ] || { echo "FAIL: no .yamllint.yml"; exit 1; }

            # seed files present in full output
            [ -e "${full}/.editorconfig" ] || { echo "FAIL: no .editorconfig"; exit 1; }
            [ -e "${full}/.gitattributes" ] || { echo "FAIL: no .gitattributes"; exit 1; }
            [ -e "${full}/.gitignore" ] || { echo "FAIL: no .gitignore"; exit 1; }
            [ -e "${full}/config/lefthook/file_size_limits.yml" ] || { echo "FAIL: no file_size_limits.yml"; exit 1; }
            [ -e "${full}/.narrow-language-nix.dic" ] || { echo "FAIL: no nix.dic"; exit 1; }
            [ -e "${full}/.nix-embedded-shell-allowlist" ] || { echo "FAIL: no allowlist"; exit 1; }

            # sync scripts present and executable
            [ -x "${full}/bin/sync-setting" ] || { echo "FAIL: no sync-setting"; exit 1; }
            [ -x "${full}/bin/sync-setting-init" ] || { echo "FAIL: no sync-setting-init"; exit 1; }

            # packages.setting (materialized) has configs but not seeds
            [ -e "${full.materialized}/.markdownlint.yml" ] || { echo "FAIL: pkg no markdownlint"; exit 1; }
            [ -e "${full.materialized}/.yamllint.yml" ] || { echo "FAIL: pkg no yamllint"; exit 1; }
            if [ -e "${full.materialized}/.editorconfig" ]; then
              echo "FAIL: pkg has seed .editorconfig"; exit 1
            fi
            if [ -e "${full.materialized}/.gitignore" ]; then
              echo "FAIL: pkg has seed .gitignore"; exit 1
            fi

            # gitignore includes materialized file entries (setting fragment)
            grep -q '.markdownlint.yml' "${full}/.gitignore" \
              || { echo "FAIL: gitignore missing .markdownlint.yml"; exit 1; }
            grep -q '.yamllint.yml' "${full}/.gitignore" \
              || { echo "FAIL: gitignore missing .yamllint.yml"; exit 1; }

            echo PASS
            touch $out
          '';

        agent-seam-opencode =
          let
            mkSet = import ./set/lib/mk-set.nix { inherit (nixpkgs) lib; };
            agents = import ./set/lib/agents.nix;
            claude = mkSet { inherit pkgs; };
            opencode = mkSet {
              inherit pkgs;
              agent = agents.opencode;
            };
          in
          pkgs.runCommand "agent-seam-opencode-check" { } ''
            # V23: agnosticism proof -- opencode seam builds the same sources
            clset="${claude}/.claude/rules/set"
            ocset="${opencode}/.opencode/rules/set"

            # opencode domain rule uses globs (not paths)
            grep -q '^globs:' "$ocset/nix/flake.md" \
              || { echo "FAIL: opencode nix missing globs"; exit 1; }
            grep -qF '"**/*.nix"' "$ocset/nix/flake.md" \
              || { echo "FAIL: opencode nix glob value"; exit 1; }

            # always-on core is path-less in BOTH agents (channel a is
            # agent-independent: no conditional field either side, V18)
            if grep -q '^globs:' "$ocset/generic/skill.md"; then
              echo "FAIL: opencode core generic must be path-less"; exit 1
            fi
            if grep -q '^paths:' "$clset/generic/skill.md"; then
              echo "FAIL: claude core generic must be path-less"; exit 1
            fi

            # same agnostic body in both agents (strip domain frontmatter)
            clbody="$(sed '1,/^---$/d' "$clset/nix/flake.md")"
            ocbody="$(sed '1,/^---$/d' "$ocset/nix/flake.md")"
            [ "$clbody" = "$ocbody" ] \
              || { echo "FAIL: nix/flake body differs between agents"; exit 1; }

            # claude counterparts exist at their paths
            [ -f "$clset/nix/flake.md" ] \
              || { echo "FAIL: claude nix rule missing"; exit 1; }
            [ -f "$clset/generic/skill.md" ] \
              || { echo "FAIL: claude generic rule missing"; exit 1; }

            # core file body byte-identical across agents (path-less, no
            # frontmatter to strip)
            [ "$(cat "$clset/generic/skill.md")" = "$(cat "$ocset/generic/skill.md")" ] \
              || { echo "FAIL: generic body differs between agents"; exit 1; }

            echo PASS
            touch $out
          '';

        materialize-check = import ./lib/mk-materialize-check.nix { inherit (nixpkgs) lib; } {
          inherit pkgs;
          categories = [
            "nix"
            "test"
            "lefthook"
          ];
        };

        materialize-check-integration = import ./lib/mk-materialize-check.nix { inherit (nixpkgs) lib; } {
          inherit pkgs;
          categories = [ "integration" ];
        };

        materialize-check-exclude = import ./lib/mk-materialize-check.nix { inherit (nixpkgs) lib; } {
          inherit pkgs;
          categories = [ "nix" ];
          exclude = [ "rtk.md" ];
        };

        compose-scaffold =
          let
            scaffold = import ./setting/lib/mk-scaffold.nix { inherit pkgs; };
          in
          pkgs.runCommand "compose-scaffold-check" { } ''
            # scaffold produces all three files
            [ -f "${scaffold}/flake.nix" ] \
              || { echo "FAIL: no flake.nix"; exit 1; }
            [ -f "${scaffold}/lefthook.yml" ] \
              || { echo "FAIL: no lefthook.yml"; exit 1; }
            [ -f "${scaffold}/.github/workflows/ci.yml" ] \
              || { echo "FAIL: no ci.yml"; exit 1; }

            # flake.nix is a valid nix expression (has description)
            grep -q 'description' "${scaffold}/flake.nix" \
              || { echo "FAIL: flake.nix missing description"; exit 1; }
            grep -q 'devShells' "${scaffold}/flake.nix" \
              || { echo "FAIL: flake.nix missing devShells"; exit 1; }
            grep -q 'lefthookWrappersFor' "${scaffold}/flake.nix" \
              || { echo "FAIL: flake.nix missing lefthookWrappersFor"; exit 1; }

            # lefthook.yml has remotes from all fragments
            grep -q 'nix-lefthook-trailing-whitespace' "${scaffold}/lefthook.yml" \
              || { echo "FAIL: lefthook.yml missing base remote"; exit 1; }
            grep -q 'nix-lefthook-nixfmt' "${scaffold}/lefthook.yml" \
              || { echo "FAIL: lefthook.yml missing nix remote"; exit 1; }
            grep -q 'nix-lefthook-shellcheck' "${scaffold}/lefthook.yml" \
              || { echo "FAIL: lefthook.yml missing shell remote"; exit 1; }
            grep -q '^pre-commit:' "${scaffold}/lefthook.yml" \
              || { echo "FAIL: lefthook.yml missing pre-commit"; exit 1; }
            grep -q '^pre-push:' "${scaffold}/lefthook.yml" \
              || { echo "FAIL: lefthook.yml missing pre-push"; exit 1; }

            # ci.yml uses nix-lefthook-ci-action
            grep -q 'nix-lefthook-ci-action' "${scaffold}/.github/workflows/ci.yml" \
              || { echo "FAIL: ci.yml missing action ref"; exit 1; }
            grep -q 'skip-build' "${scaffold}/.github/workflows/ci.yml" \
              || { echo "FAIL: ci.yml missing skip-build"; exit 1; }

            # C6/T7: all flake inputs use github: URLs, no git+file:
            if grep -q 'git+file:' "${scaffold}/flake.nix"; then
              echo "FAIL: scaffold flake.nix contains git+file: URL (C6)"; exit 1
            fi
            grep -q 'github:' "${scaffold}/flake.nix" \
              || { echo "FAIL: scaffold flake.nix has no github: URLs"; exit 1; }

            echo PASS
            touch $out
          '';

        default = pkgs.runCommand "set-and-setting-checks" { } ''
          touch $out
        '';
      });

      apps = forAllSystems (
        pkgs:
        let
          inherit (nixpkgs) lib;
          cats = import ./set/lib/categories.nix;
          agents = import ./set/lib/agents.nix;
          meta = import ./set/meta.nix { inherit lib; };
          globsMap = lib.concatStringsSep ";" (
            lib.mapAttrsToList (c: globs: "${c}=${lib.concatStringsSep "," globs}") cats.globs
          );
          agentSeams = lib.concatStringsSep ";" (
            lib.mapAttrsToList (name: seam: "${name}=${seam.dir},${seam.condField}") agents
          );
          mkSettingFull = import ./setting/lib/mk-setting.nix { inherit lib; } { inherit pkgs; };

          mkSetApp = pkgs.writeShellApplication {
            name = "mkSet";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.findutils
            ];
            text = ''
              export SKILLS_DIR="${./set/skills}"
              export CONCEPTS_DIR="${./set/concepts}"
              export MK_SET_SCRIPT="${./set/lib/mk-set.sh}"
              export EMIT_SCRIPT="${./set/lib/emit-skill.sh}"
              export EMIT_RULE_SCRIPT="${./set/lib/emit-rule.sh}"
              export SYNC_SCRIPT="${./set/lib/sync-set.sh}"
              export RESOLVE_AGENT_SCRIPT="${./set/lib/resolve-agent.sh}"
              export ALL_CATEGORIES="${lib.concatStringsSep " " cats.all}"
              export CORE_CATEGORIES="${lib.concatStringsSep " " cats.core}"
              export GLOBS_MAP="${globsMap}"
              export CHANNEL_OVERRIDES=${lib.escapeShellArg meta.channelOverrides}
              export AGENT_SEAMS="${agentSeams}"
              export MKSET_REV="${self.rev or self.dirtyRev or "unknown"}"
            ''
            + builtins.readFile ./set/lib/app-mk-set.sh;
          };

          mkSettingApp = pkgs.writeShellApplication {
            name = "mkSetting";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.findutils
            ];
            text = ''
              export SETTING_SRC="${mkSettingFull.configFiles}"
            ''
            + builtins.readFile ./setting/lib/app-mk-setting.sh;
          };

          mkSettingInitApp = pkgs.writeShellApplication {
            name = "mkSetting-init";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.findutils
            ];
            text = ''
              export SEED_SRC="${mkSettingFull.seed}"
            ''
            + builtins.readFile ./setting/lib/app-mk-setting-init.sh;
          };

          mkScaffoldBundle = import ./setting/lib/mk-scaffold.nix { inherit pkgs; };
          mkScaffoldApp = pkgs.writeShellApplication {
            name = "mkScaffold";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.findutils
            ];
            text = ''
              export SCAFFOLD_SRC="${mkScaffoldBundle}"
            ''
            + builtins.readFile ./setting/lib/app-mk-scaffold.sh;
          };

          bootstrapApp = pkgs.writeShellApplication {
            name = "bootstrap";
            text = ''
              export MKSET_APP="${mkSetApp}/bin/mkSet"
              export MKSETTING_APP="${mkSettingApp}/bin/mkSetting"
              export MKSETTING_INIT_APP="${mkSettingInitApp}/bin/mkSetting-init"
              export MKSCAFFOLD_APP="${mkScaffoldApp}/bin/mkScaffold"
            ''
            + builtins.readFile ./set/lib/app-bootstrap.sh;
          };
        in
        {
          mkSet = {
            type = "app";
            program = "${mkSetApp}/bin/mkSet";
          };
          mkSetting = {
            type = "app";
            program = "${mkSettingApp}/bin/mkSetting";
          };
          "mkSetting-init" = {
            type = "app";
            program = "${mkSettingInitApp}/bin/mkSetting-init";
          };
          mkScaffold = {
            type = "app";
            program = "${mkScaffoldApp}/bin/mkScaffold";
          };
          bootstrap = {
            type = "app";
            program = "${bootstrapApp}/bin/bootstrap";
          };
        }
      );
    };
}
