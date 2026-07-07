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
        mkDepGraphCheck = import ./lib/mk-dep-graph-check.nix;
        mkDevShells = import ./setting/lib/mk-dev-shells.nix;
      };

      packages = forAllSystems (pkgs: {
        set = import ./set/lib/mk-set.nix { inherit (nixpkgs) lib; } { inherit pkgs; };
        setting =
          (import ./setting/lib/mk-setting.nix { inherit (nixpkgs) lib; } { inherit pkgs; }).materialized;
      });

      devShells = forAllSystems (
        pkgs:
        let
          sys = pkgs.stdenv.hostPlatform.system;
        in
        import ./setting/lib/mk-dev-shells.nix {
          inherit pkgs;
          basePackages = (lefthookWrappersFor pkgs) ++ [
            pkgs.coreutils
            pkgs.git
            pkgs.jq
            pkgs.nix
            pkgs.gh
            pkgs.bats
            nix-lefthook.packages.${sys}.default
          ];
          agenticShellHook = ''
            ${self.packages.${sys}.set}/bin/sync-set .
          '';
        }
      );

      checks = forAllSystems (pkgs: {
        mkSet-generic = import ./set/lib/mk-set.nix { inherit (nixpkgs) lib; } {
          inherit pkgs;
          categories = [ "generic" ];
        };

        # T12/V11: drafts categories build without error.
        # Drafts live at set/drafts/ (V11), outside set/skills/ (the default
        # SKILLS_DIR). Merge both trees so the emitter finds drafts/ content.
        mkSet-drafts =
          let
            mergedSkills = pkgs.runCommand "merged-skills-with-drafts" { } ''
              cp -r ${./set/skills} $out
              chmod -R u+w $out
              cp -r ${./set/drafts} $out/drafts
            '';
          in
          import ./set/lib/mk-set.nix { inherit (nixpkgs) lib; } {
            inherit pkgs;
            skillsDir = mergedSkills;
            categories = [
              "drafts/skill"
              "drafts/agent"
              "drafts/nix"
              "drafts/ops"
              "drafts/context"
            ];
            concepts = false;
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
              # facet relevance signals (T41/V35): content + narrow paths
              assert builtins.elem "qemu" (r "test/qemu.md").content;
              assert builtins.elem "tests/integration/**" (r "test/qemu.md").paths;
              assert !(builtins.elem "**/*.bats" (r "test/qemu.md").paths);
              assert builtins.elem "buildPythonPackage" (r "nix/python-package.md").content;
              # unsigned facet -> no content, paths fall back to category
              assert (r "test/coverage.md").content == [ ];
              assert (r "test/coverage.md").paths == [ "**/*.bats" ];
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
            cv = agents.caveman-code;
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
              # caveman-code (Claude Code superset, .cave/ paths)
              assert cv.alwaysOn.file == "CAVE.md";
              assert cv.alwaysOn.import == "@";
              assert cv.conditional.dir == ".cave/rules/set";
              assert cv.conditional.field == "paths";
              assert cv.skill.dir == ".cave/skills";
              assert cv.skill.disableModelInvocation;
              # T34 extension agents (cursor, codex, gemini-cli, copilot, amp)
              assert agents.cursor.alwaysOn.file == "AGENTS.md";
              assert agents.cursor.alwaysOn.import == "inline";
              assert agents.cursor.conditional.dir == ".cursor/rules/set";
              assert agents.cursor.conditional.field == "globs";
              assert agents.cursor.conditional.mechanism == "cursor-rules";
              assert !agents.cursor.skill.disableModelInvocation;
              assert agents.codex.alwaysOn.import == "inline";
              assert agents.codex.conditional.dir == ".codex/rules/set";
              assert agents.codex.conditional.field == "globs";
              assert agents.gemini-cli.alwaysOn.import == "inline";
              assert agents.gemini-cli.conditional.dir == ".gemini/rules/set";
              assert agents.gemini-cli.conditional.field == "globs";
              assert agents.copilot.alwaysOn.import == "inline";
              assert agents.copilot.conditional.dir == ".copilot/rules/set";
              assert agents.copilot.conditional.field == "globs";
              assert agents.amp.alwaysOn.import == "inline";
              assert agents.amp.conditional.dir == ".amp/rules/set";
              assert agents.amp.conditional.field == "globs";
              # back-compat seam derives from conditional (single source)
              assert c.dir == c.conditional.dir;
              assert c.condField == c.conditional.field;
              assert o.dir == o.conditional.dir;
              assert o.condField == o.conditional.field;
              assert cv.dir == cv.conditional.dir;
              assert cv.condField == cv.conditional.field;
              assert agents.cursor.dir == agents.cursor.conditional.dir;
              assert agents.cursor.condField == agents.cursor.conditional.field;
              assert agents.codex.dir == agents.codex.conditional.dir;
              assert agents.codex.condField == agents.codex.conditional.field;
              assert agents.gemini-cli.dir == agents.gemini-cli.conditional.dir;
              assert agents.gemini-cli.condField == agents.gemini-cli.conditional.field;
              assert agents.copilot.dir == agents.copilot.conditional.dir;
              assert agents.copilot.condField == agents.copilot.conditional.field;
              assert agents.amp.dir == agents.amp.conditional.dir;
              assert agents.amp.condField == agents.amp.conditional.field;
              true;
          in
          pkgs.runCommand "agent-profiles-check" { inherit ok; } ''
            echo PASS
            touch $out
          '';

        # meta-applicability -- V34: the smart-materialization filter keeps
        # only skills with repo evidence (paths AND content), facet->core.
        meta-applicability = import ./set/lib/applicability.nix { inherit (nixpkgs) lib; } {
          inherit pkgs;
        };

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
            # Claude dedup (V20): SKILL.md is not model-invoked (rule loads)
            grep -q '^disable-model-invocation: true$' "$skill" \
              || { echo "FAIL: SKILL.md missing disable-model-invocation"; exit 1; }
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

        # T59: mkDevShells emits stacked default + agentic shells
        mkDevShells-check =
          let
            shells = import ./setting/lib/mk-dev-shells.nix {
              inherit pkgs;
              basePackages = [ pkgs.coreutils ];
              agenticPackages = [ pkgs.git ];
              agenticShellHook = ''
                echo agentic-marker
              '';
            };
            ok =
              # both shells exist and carry NIX_CONFIG
              assert shells.default.NIX_CONFIG == "experimental-features = nix-command flakes";
              assert shells.agentic.NIX_CONFIG == "experimental-features = nix-command flakes";
              # agentic inherits base packages via inputsFrom (nativeBuildInputs
              # includes coreutils from default + git from agenticPackages)
              assert builtins.length shells.agentic.nativeBuildInputs >= 2;
              true;
          in
          pkgs.runCommand "mk-dev-shells-check" { inherit ok; } ''
            echo PASS
            touch $out
          '';

        # T60: stacked-shell drift check -- shells named default/agentic
        # only, agentic >= default, CI != skip-lefthook
        devshells-drift-check =
          let
            sys = pkgs.stdenv.hostPlatform.system;
            shells = self.devShells.${sys};
            names = builtins.attrNames shells;
            ok =
              assert
                names == [
                  "agentic"
                  "default"
                ]
                || builtins.throw "devShells: expected 'default'+'agentic', got: ${builtins.concatStringsSep " " names}";
              assert
                builtins.all (p: builtins.elem p shells.agentic.nativeBuildInputs) shells.default.nativeBuildInputs
                || builtins.throw "agentic.packages must be a superset of default.packages";
              true;
          in
          pkgs.runCommand "devshells-drift-check"
            {
              nativeBuildInputs = [ pkgs.gnugrep ];
              ACTUAL = "${./.}";
              CHECK_CI_SKIP_LEFTHOOK = "1";
              inherit ok;
            }
            ''
              bash ${./lib/devshells-drift-check.sh}
              touch $out
            '';

        # T60: consumer-facing mkSettingDriftCheck with devShells param --
        # validates that the extended interface works (nix assertions +
        # CI skip-lefthook check) against a synthetic consumer setup
        mkSettingDriftCheck-devShells =
          let
            syntheticSetting = pkgs.runCommand "synthetic-setting" { } ''
              mkdir -p $out
              echo "extends: default" > $out/.markdownlint.yml
            '';
            syntheticProject = pkgs.runCommand "synthetic-project" { } ''
                    mkdir -p $out/.github/workflows
                    echo "extends: default" > $out/.markdownlint.yml
                    cat > $out/.github/workflows/ci.yml <<'YAML'
              jobs:
                build:
                  steps:
                    - uses: nix-lefthook-ci-action
                      with:
                        devshell: "default"
              YAML
            '';
            shells = import ./setting/lib/mk-dev-shells.nix {
              inherit pkgs;
              basePackages = [ pkgs.coreutils ];
              agenticPackages = [ pkgs.git ];
            };
          in
          import ./lib/mk-setting-drift-check.nix {
            inherit pkgs;
            settingSet = syntheticSetting;
            projectRoot = syntheticProject;
            devShells = shells;
          };

        # T59: mkSetting passthru exposes mkDevShells
        mkSetting-devShells =
          let
            mkSetting = import ./setting/lib/mk-setting.nix { inherit (nixpkgs) lib; };
            full = mkSetting { inherit pkgs; };
            shells = full.mkDevShells {
              inherit pkgs;
              basePackages = [ pkgs.coreutils ];
            };
          in
          pkgs.runCommand "mk-setting-devshells-check" { } ''
            [ -n "${shells.default}" ] \
              || { echo "FAIL: mkSetting.mkDevShells default missing"; exit 1; }
            [ -n "${shells.agentic}" ] \
              || { echo "FAIL: mkSetting.mkDevShells agentic missing"; exit 1; }
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

            # opencode SKILL.md stays model-invocable (no Claude dedup, V20)
            ocskill="${opencode}/set-nix/SKILL.md"
            [ -f "$ocskill" ] || { echo "FAIL: opencode SKILL.md missing"; exit 1; }
            if grep -q 'disable-model-invocation' "$ocskill"; then
              echo "FAIL: opencode SKILL.md must not disable invocation"; exit 1
            fi

            # opencode always-on: compiled AGENTS.md (V39), universal core
            # only (V38) -- no domain content leaks in.
            ocagents="${opencode}/AGENTS.md"
            [ -f "$ocagents" ] || { echo "FAIL: opencode AGENTS.md missing"; exit 1; }
            grep -q 'Auto commit after successful prompt' "$ocagents" \
              || { echo "FAIL: AGENTS.md missing git core"; exit 1; }
            if grep -q 'The project starts with nix flake' "$ocagents"; then
              echo "FAIL: domain content leaked into always-on AGENTS.md"; exit 1
            fi
            # manifest-level refs are fully inlined: no top-level "@set/<x>.md"
            # line survives (nested concept-bundle @refs to flattened
            # sub-concepts stay literal -- a known emission wart, their
            # content is inlined separately).
            if grep -qE '^@set/[^/]+\.md$' "$ocagents"; then
              echo "FAIL: AGENTS.md has an unresolved manifest @ref"; exit 1
            fi

            # opencode.json instructions list ONLY the always-on file (V39)
            ocjson="${opencode}/opencode.json"
            [ -f "$ocjson" ] || { echo "FAIL: opencode.json missing"; exit 1; }
            grep -q '"instructions": \["AGENTS.md"\]' "$ocjson" \
              || { echo "FAIL: opencode.json instructions wrong"; exit 1; }
            grep -q 'opencode.ai/config.json' "$ocjson" \
              || { echo "FAIL: opencode.json missing schema"; exit 1; }

            # Claude profile emits NEITHER (uses native @ + path-rules)
            if [ -e "${claude}/AGENTS.md" ] || [ -e "${claude}/opencode.json" ]; then
              echo "FAIL: claude must not emit AGENTS.md/opencode.json"; exit 1
            fi

            echo PASS
            touch $out
          '';

        agent-seam-caveman-code =
          let
            mkSet = import ./set/lib/mk-set.nix { inherit (nixpkgs) lib; };
            agents = import ./set/lib/agents.nix;
            claude = mkSet { inherit pkgs; };
            caveman = mkSet {
              inherit pkgs;
              agent = agents.caveman-code;
            };
          in
          pkgs.runCommand "agent-seam-caveman-code-check" { } ''
            # V23: agnosticism proof -- caveman-code seam builds the same sources
            clset="${claude}/.claude/rules/set"
            cvset="${caveman}/.cave/rules/set"

            # caveman-code domain rule uses paths (same field as Claude)
            grep -q '^paths:' "$cvset/nix/flake.md" \
              || { echo "FAIL: caveman nix missing paths"; exit 1; }
            grep -qF '"**/*.nix"' "$cvset/nix/flake.md" \
              || { echo "FAIL: caveman nix glob value"; exit 1; }

            # always-on core is path-less (channel a, V18)
            if grep -q '^paths:' "$cvset/generic/skill.md"; then
              echo "FAIL: caveman core generic must be path-less"; exit 1
            fi

            # same agnostic body in both agents (strip domain frontmatter)
            clbody="$(sed '1,/^---$/d' "$clset/nix/flake.md")"
            cvbody="$(sed '1,/^---$/d' "$cvset/nix/flake.md")"
            [ "$clbody" = "$cvbody" ] \
              || { echo "FAIL: nix/flake body differs between agents"; exit 1; }

            # core file body byte-identical across agents (path-less)
            [ "$(cat "$clset/generic/skill.md")" = "$(cat "$cvset/generic/skill.md")" ] \
              || { echo "FAIL: generic body differs between agents"; exit 1; }

            # caveman-code SKILL.md has Claude dedup (superset, same mechanism)
            cvskill="${caveman}/.cave/skills/set-nix/SKILL.md"
            [ -f "$cvskill" ] || { echo "FAIL: caveman SKILL.md missing"; exit 1; }
            grep -q 'disable-model-invocation: true' "$cvskill" \
              || { echo "FAIL: caveman SKILL.md missing disable-model-invocation"; exit 1; }

            # caveman-code uses @-import like Claude: no AGENTS.md, no config file
            if [ -e "${caveman}/AGENTS.md" ]; then
              echo "FAIL: caveman must not emit AGENTS.md"; exit 1
            fi
            if [ -e "${caveman}/opencode.json" ]; then
              echo "FAIL: caveman must not emit opencode.json"; exit 1
            fi

            # always-on @-manifest exists at .cave/rules/set.md
            [ -f "${caveman}/.cave/rules/set.md" ] \
              || { echo "FAIL: caveman set.md manifest missing"; exit 1; }
            grep -q '^@set/generic/skill.md$' "${caveman}/.cave/rules/set.md" \
              || { echo "FAIL: caveman set.md missing core ref"; exit 1; }

            echo PASS
            touch $out
          '';

        # T34: extension agent seams (cursor, codex, gemini-cli, copilot,
        # amp). All use inline import (compiled AGENTS.md, no @-import).
        # Proves V23/C2 agent-agnostic across 8 total seams.
        agent-seam-extensions =
          let
            mkSet = import ./set/lib/mk-set.nix { inherit (nixpkgs) lib; };
            agents = import ./set/lib/agents.nix;
            claude = mkSet { inherit pkgs; };
            cursor = mkSet {
              inherit pkgs;
              agent = agents.cursor;
            };
            codex = mkSet {
              inherit pkgs;
              agent = agents.codex;
            };
            gemini = mkSet {
              inherit pkgs;
              agent = agents.gemini-cli;
            };
            copilot = mkSet {
              inherit pkgs;
              agent = agents.copilot;
            };
            amp = mkSet {
              inherit pkgs;
              agent = agents.amp;
            };
          in
          pkgs.runCommand "agent-seam-extensions-check" { } ''
            clset="${claude}/.claude/rules/set"

            # --- cursor (globs/.cursor/rules, V23/T34) ---
            cuset="${cursor}/.cursor/rules/set"
            grep -q '^globs:' "$cuset/nix/flake.md" \
              || { echo "FAIL: cursor nix missing globs"; exit 1; }
            if grep -q '^globs:' "$cuset/generic/skill.md"; then
              echo "FAIL: cursor core generic must be path-less"; exit 1
            fi
            cubody="$(sed '1,/^---$/d' "$cuset/nix/flake.md")"
            clbody="$(sed '1,/^---$/d' "$clset/nix/flake.md")"
            [ "$cubody" = "$clbody" ] \
              || { echo "FAIL: cursor nix body differs from claude"; exit 1; }
            [ "$(cat "$clset/generic/skill.md")" = "$(cat "$cuset/generic/skill.md")" ] \
              || { echo "FAIL: cursor generic body differs"; exit 1; }
            [ -f "${cursor}/AGENTS.md" ] \
              || { echo "FAIL: cursor AGENTS.md missing (inline)"; exit 1; }
            if [ -e "${cursor}/opencode.json" ]; then
              echo "FAIL: cursor must not emit opencode.json"; exit 1
            fi
            cuskill="${cursor}/set-nix/SKILL.md"
            [ -f "$cuskill" ] || { echo "FAIL: cursor SKILL.md missing"; exit 1; }
            if grep -q 'disable-model-invocation' "$cuskill"; then
              echo "FAIL: cursor SKILL.md must not disable invocation"; exit 1
            fi

            # --- codex (.codex/rules, V23/T34) ---
            cdset="${codex}/.codex/rules/set"
            grep -q '^globs:' "$cdset/nix/flake.md" \
              || { echo "FAIL: codex nix missing globs"; exit 1; }
            cdbody="$(sed '1,/^---$/d' "$cdset/nix/flake.md")"
            [ "$cdbody" = "$clbody" ] \
              || { echo "FAIL: codex nix body differs from claude"; exit 1; }
            [ -f "${codex}/AGENTS.md" ] \
              || { echo "FAIL: codex AGENTS.md missing (inline)"; exit 1; }
            if [ -e "${codex}/opencode.json" ]; then
              echo "FAIL: codex must not emit opencode.json"; exit 1
            fi

            # --- gemini-cli (.gemini/rules, V23/T34) ---
            gmset="${gemini}/.gemini/rules/set"
            grep -q '^globs:' "$gmset/nix/flake.md" \
              || { echo "FAIL: gemini nix missing globs"; exit 1; }
            gmbody="$(sed '1,/^---$/d' "$gmset/nix/flake.md")"
            [ "$gmbody" = "$clbody" ] \
              || { echo "FAIL: gemini nix body differs from claude"; exit 1; }
            [ -f "${gemini}/AGENTS.md" ] \
              || { echo "FAIL: gemini AGENTS.md missing (inline)"; exit 1; }
            if [ -e "${gemini}/opencode.json" ]; then
              echo "FAIL: gemini must not emit opencode.json"; exit 1
            fi

            # --- copilot (.copilot/rules, V23/T34) ---
            cpset="${copilot}/.copilot/rules/set"
            grep -q '^globs:' "$cpset/nix/flake.md" \
              || { echo "FAIL: copilot nix missing globs"; exit 1; }
            cpbody="$(sed '1,/^---$/d' "$cpset/nix/flake.md")"
            [ "$cpbody" = "$clbody" ] \
              || { echo "FAIL: copilot nix body differs from claude"; exit 1; }
            [ -f "${copilot}/AGENTS.md" ] \
              || { echo "FAIL: copilot AGENTS.md missing (inline)"; exit 1; }
            if [ -e "${copilot}/opencode.json" ]; then
              echo "FAIL: copilot must not emit opencode.json"; exit 1
            fi

            # --- amp (.amp/rules, V23/T34) ---
            amset="${amp}/.amp/rules/set"
            grep -q '^globs:' "$amset/nix/flake.md" \
              || { echo "FAIL: amp nix missing globs"; exit 1; }
            ambody="$(sed '1,/^---$/d' "$amset/nix/flake.md")"
            [ "$ambody" = "$clbody" ] \
              || { echo "FAIL: amp nix body differs from claude"; exit 1; }
            [ -f "${amp}/AGENTS.md" ] \
              || { echo "FAIL: amp AGENTS.md missing (inline)"; exit 1; }
            if [ -e "${amp}/opencode.json" ]; then
              echo "FAIL: amp must not emit opencode.json"; exit 1
            fi

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

        # T31/V23: materialize-check with opencode agent -- proves the
        # consumer-facing mkMaterializeCheck API works agent-agnostically
        # (globs field, .opencode/rules/set dir).
        materialize-check-opencode =
          let
            agents = import ./set/lib/agents.nix;
          in
          import ./lib/mk-materialize-check.nix { inherit (nixpkgs) lib; } {
            inherit pkgs;
            categories = [ "nix" ];
            agent = agents.opencode;
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
            [ -f "${scaffold}/.github/workflows/auto-update.yml" ] \
              || { echo "FAIL: no auto-update.yml"; exit 1; }

            # flake.nix is a valid nix expression (has description)
            grep -q 'description' "${scaffold}/flake.nix" \
              || { echo "FAIL: flake.nix missing description"; exit 1; }
            grep -q 'devShells' "${scaffold}/flake.nix" \
              || { echo "FAIL: flake.nix missing devShells"; exit 1; }
            grep -q 'lefthookWrappersFor' "${scaffold}/flake.nix" \
              || { echo "FAIL: flake.nix missing lefthookWrappersFor"; exit 1; }

            # T59: stacked shells via mkDevShells -- default + agentic, no ci
            grep -q 'agentic' "${scaffold}/flake.nix" \
              || { echo "FAIL: flake.nix missing agentic shell"; exit 1; }
            grep -q 'mkDevShells' "${scaffold}/flake.nix" \
              || { echo "FAIL: flake.nix missing mkDevShells (stacked shell)"; exit 1; }
            if grep -qE '^\s+ci\s*=' "${scaffold}/flake.nix"; then
              echo "FAIL: scaffold still has ci devShell"; exit 1
            fi

            # T59/B17: scaffold ci.yml must specify devshell: "default"
            # (the CI action defaults to "ci" which no longer exists)
            grep -q 'devshell:.*"default"' "${scaffold}/.github/workflows/ci.yml" \
              || { echo "FAIL: ci.yml missing devshell: default (B17)"; exit 1; }

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

            # auto-update.yml uses the reusable workflow (T8)
            grep -q 'auto-update.yml@main' "${scaffold}/.github/workflows/auto-update.yml" \
              || { echo "FAIL: auto-update.yml missing reusable workflow ref"; exit 1; }
            grep -q 'workflow_dispatch' "${scaffold}/.github/workflows/auto-update.yml" \
              || { echo "FAIL: auto-update.yml missing workflow_dispatch"; exit 1; }

            # C6/T7: all flake inputs use github: URLs, no git+file:
            if grep -q 'git+file:' "${scaffold}/flake.nix"; then
              echo "FAIL: scaffold flake.nix contains git+file: URL (C6)"; exit 1
            fi
            grep -q 'github:' "${scaffold}/flake.nix" \
              || { echo "FAIL: scaffold flake.nix has no github: URLs"; exit 1; }

            # T33: consumer wiring -- set-and-setting input + packages
            grep -q 'set-and-setting' "${scaffold}/flake.nix" \
              || { echo "FAIL: scaffold flake.nix missing set-and-setting input (T33)"; exit 1; }
            grep -q 'packages' "${scaffold}/flake.nix" \
              || { echo "FAIL: scaffold flake.nix missing packages output (T33)"; exit 1; }
            grep -q 'mkDepGraphCheck' "${scaffold}/flake.nix" \
              || { echo "FAIL: scaffold flake.nix missing dep-graph check (T33)"; exit 1; }

            # T33: consumer wiring -- sync hooks in devShell
            grep -q 'sync-setting' "${scaffold}/flake.nix" \
              || { echo "FAIL: scaffold flake.nix missing sync-setting hook (T33)"; exit 1; }
            grep -q 'sync-set' "${scaffold}/flake.nix" \
              || { echo "FAIL: scaffold flake.nix missing sync-set hook (T33)"; exit 1; }

            # T33: CI sync pre-step -- materialized configs synced before hooks
            grep -q 'Sync materialized configs' "${scaffold}/.github/workflows/ci.yml" \
              || { echo "FAIL: ci.yml missing sync pre-step (T33)"; exit 1; }
            grep -q 'sync-setting' "${scaffold}/.github/workflows/ci.yml" \
              || { echo "FAIL: ci.yml missing sync-setting in pre-step (T33)"; exit 1; }
            grep -q 'nix build' "${scaffold}/.github/workflows/ci.yml" \
              || { echo "FAIL: ci.yml missing nix build in pre-step (T33)"; exit 1; }
            grep -q 'install-nix-action' "${scaffold}/.github/workflows/ci.yml" \
              || { echo "FAIL: ci.yml missing install-nix-action for pre-step (T33)"; exit 1; }

            echo PASS
            touch $out
          '';

        # dep-graph -- T9/C6: every flake input in flake.lock uses github:
        dep-graph = import ./lib/mk-dep-graph-check.nix {
          inherit pkgs;
          projectRoot = ./.;
        };

        # T13: graduation mechanism -- merge a draft into an existing
        # stable category. Validates graduated files appear as domain
        # rules with correct globs, and existing skills are preserved.
        graduate-draft =
          let
            graduatedSkills = pkgs.runCommand "graduated-skills-nix" { } ''
              cp -r ${./set/skills} $out
              chmod -R u+w $out
              cp -r ${./set/drafts/nix}/* $out/nix/
            '';
            graduated = import ./set/lib/mk-set.nix { inherit (nixpkgs) lib; } {
              inherit pkgs;
              skillsDir = graduatedSkills;
              categories = [ "nix" ];
              concepts = false;
            };
          in
          pkgs.runCommand "graduate-draft-check" { } ''
            setdir="${graduated}/.claude/rules/set"

            # Graduated files appear as domain rules
            [ -f "$setdir/nix/composability.md" ] \
              || { echo "FAIL: graduated composability.md missing"; exit 1; }
            [ -f "$setdir/nix/underlay.md" ] \
              || { echo "FAIL: graduated underlay.md missing"; exit 1; }

            # Carry the nix domain globs (V19)
            grep -q '^paths:' "$setdir/nix/composability.md" \
              || { echo "FAIL: composability.md missing paths"; exit 1; }
            grep -qF '"**/*.nix"' "$setdir/nix/composability.md" \
              || { echo "FAIL: composability.md missing nix glob"; exit 1; }

            # Existing stable nix skills preserved
            [ -f "$setdir/nix/flake.md" ] \
              || { echo "FAIL: existing flake.md missing"; exit 1; }
            [ -f "$setdir/nix/develop.md" ] \
              || { echo "FAIL: existing develop.md missing"; exit 1; }

            echo PASS
            touch $out
          '';

        # T13: graduation @-ref update -- validates that bundle files
        # referencing @set/drafts/<cat>/ are rewritten to @set/<cat>/
        # after graduation, and all files are present.
        graduate-draft-refs =
          let
            graduatedSkills =
              pkgs.runCommand "graduated-skills-ops"
                {
                  nativeBuildInputs = [
                    pkgs.findutils
                    pkgs.gnused
                  ];
                }
                ''
                  cp -r ${./set/skills} $out
                  chmod -R u+w $out
                  cp -r ${./set/drafts/ops} $out/ops
                  chmod -R u+w $out/ops
                  find $out/ops -name '*.md' -exec \
                    sed -i 's|@set/drafts/ops/|@set/ops/|g' {} \;
                '';
          in
          pkgs.runCommand "graduate-draft-refs-check" { } ''
            # @-refs updated in bundle file
            grep -q '@set/ops/slash.md' "${graduatedSkills}/ops/ops.md" \
              || { echo "FAIL: ops.md @-ref not updated"; exit 1; }
            grep -q '@set/ops/destructive.md' "${graduatedSkills}/ops/ops.md" \
              || { echo "FAIL: ops.md destructive @-ref not updated"; exit 1; }
            if grep -q '@set/drafts/' "${graduatedSkills}/ops/ops.md"; then
              echo "FAIL: ops.md still has drafts/ @-ref"; exit 1
            fi

            # All files present in graduated tree
            [ -f "${graduatedSkills}/ops/ops.md" ] \
              || { echo "FAIL: ops.md missing"; exit 1; }
            [ -f "${graduatedSkills}/ops/slash.md" ] \
              || { echo "FAIL: slash.md missing"; exit 1; }
            [ -f "${graduatedSkills}/ops/destructive.md" ] \
              || { echo "FAIL: destructive.md missing"; exit 1; }

            echo PASS
            touch $out
          '';

        # T33: home-manager example -- validates the example file is
        # syntactically valid nix and contains the expected wiring.
        home-manager-example =
          let
            parsed = import ./examples/home-manager.nix;
            ok =
              assert builtins.isFunction parsed;
              true;
          in
          pkgs.runCommand "home-manager-example-check"
            {
              nativeBuildInputs = [ pkgs.gnugrep ];
              inherit ok;
            }
            ''
              example="${./examples/home-manager.nix}"
              grep -q 'home.file' "$example" \
                || { echo "FAIL: home-manager.nix missing home.file"; exit 1; }
              grep -q 'rules/set' "$example" \
                || { echo "FAIL: home-manager.nix missing rules/set path"; exit 1; }
              grep -q 'set-and-setting' "$example" \
                || { echo "FAIL: home-manager.nix missing set-and-setting ref"; exit 1; }
              grep -q 'sync-setting' "$example" \
                || { echo "FAIL: home-manager.nix missing sync-setting"; exit 1; }
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
          renames = import ./set/renames.nix { inherit lib; };
          globsMap = lib.concatStringsSep ";" (
            lib.mapAttrsToList (c: globs: "${c}=${lib.concatStringsSep "," globs}") cats.globs
          );
          agentSeams = lib.concatStringsSep ";" (
            lib.mapAttrsToList (
              name: seam:
              "${name}=${seam.dir},${seam.condField},${seam.skill.dir},${
                if seam.skill.disableModelInvocation or false then "1" else "0"
              },${seam.alwaysOn.import},${seam.alwaysOn.file},${seam.conditional.mechanism}"
            ) agents
          );
          keywordsMap = lib.concatStringsSep ";" (
            map (c: "${c}=${lib.concatStringsSep "," (meta.resolve c).keywords}") cats.all
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
              export EMIT_SKILLMD_SCRIPT="${./set/lib/emit-skillmd.sh}"
              export APPLICABILITY_SCRIPT="${./set/lib/applicability.sh}"
              export AUTO_KEEP_SCRIPT="${./set/lib/app-auto-keep.sh}"
              export SYNC_SCRIPT="${./set/lib/sync-set.sh}"
              export RESOLVE_AGENT_SCRIPT="${./set/lib/resolve-agent.sh}"
              export ALL_CATEGORIES="${lib.concatStringsSep " " cats.all}"
              export CORE_CATEGORIES="${lib.concatStringsSep " " cats.core}"
              export GLOBS_MAP="${globsMap}"
              export CHANNEL_OVERRIDES=${lib.escapeShellArg meta.channelOverrides}
              export SIGNALS_MANIFEST=${lib.escapeShellArg meta.signals}
              export AGENT_SEAMS="${agentSeams}"
              export KEYWORDS_MAP="${keywordsMap}"
              export COMPILER_SCRIPT="${./lib/agents-md-compile.sh}"
              export RENAME_PROPAGATE_SCRIPT="${./set/lib/rename-propagate.sh}"
              export RENAMES_MAP=${lib.escapeShellArg renames.serialized}
              export MKSET_REV="${self.rev or self.dirtyRev or "unknown"}"
            ''
            + builtins.readFile ./set/lib/app-mk-set.sh;
          };

          mkSettingApp = pkgs.writeShellApplication {
            name = "mkSetting";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.findutils
              pkgs.gawk
              pkgs.git
              pkgs.gnugrep
            ];
            text = ''
              export SETTING_SRC="${mkSettingFull.configFiles}"
              export FRAGMENTS_DIR="${./setting/integrations/lefthook}"
              export ASSEMBLE_SCRIPT="${./setting/lib/assemble-lefthook.sh}"
              export DETECT_SCRIPT="${./setting/lib/detect-fragments.sh}"
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
              pkgs.gawk
              pkgs.git
              pkgs.gnugrep
            ];
            text = ''
              export SCAFFOLD_SRC="${mkScaffoldBundle}"
              export FRAGMENTS_DIR="${./setting/integrations/lefthook}"
              export ASSEMBLE_SCRIPT="${./setting/lib/assemble-lefthook.sh}"
              export DETECT_SCRIPT="${./setting/lib/detect-fragments.sh}"
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

          autoUpdateApp = pkgs.writeShellApplication {
            name = "auto-update";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.findutils
              pkgs.git
              pkgs.nix
              pkgs.gnugrep
            ];
            text = builtins.readFile ./lib/auto-update.sh;
          };

          graduateApp = pkgs.writeShellApplication {
            name = "graduate";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.findutils
              pkgs.gnugrep
              pkgs.gnused
            ];
            text = ''
              export ALL_CATEGORIES="${lib.concatStringsSep " " cats.all}"
            ''
            + builtins.readFile ./lib/graduate-draft.sh;
          };

          branchProtectionApp = pkgs.writeShellApplication {
            name = "branch-protection";
            runtimeInputs = [
              pkgs.git
              pkgs.gh
              pkgs.jq
              pkgs.gnused
              pkgs.gnugrep
            ];
            text = builtins.readFile ./lib/branch-protection.sh;
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
          "auto-update" = {
            type = "app";
            program = "${autoUpdateApp}/bin/auto-update";
          };
          graduate = {
            type = "app";
            program = "${graduateApp}/bin/graduate";
          };
          "branch-protection" = {
            type = "app";
            program = "${branchProtectionApp}/bin/branch-protection";
          };
        }
      );
    };
}
