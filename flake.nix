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

      # check-fragment-map.nix: single source of truth for check-to-fragment.
      cfm = import ./lib/check-fragment-map.nix;
      checkFragmentMapStr = builtins.concatStringsSep " " (
        builtins.concatLists (
          map (frag: map (check: "${check}=${frag}") cfm.checksPerFragment.${frag}) cfm.validFragments
        )
      );
      fragmentTriggersStr = builtins.concatStringsSep "|" (
        map (frag: "${frag}=${cfm.fragmentTriggers.${frag}}") cfm.validFragments
      );

      # --- apps.migrate fixtures (#96): shared derivation environment ---
      # Every migrate state fixture runs the same migrator over a fixture
      # git repo, so they share one env + toolset. The migrator runs on
      # markdown/awk/git only (the confirmator step is a dry-run, tools are
      # never executed), so no wrapper packages are needed.
      migrateSeedFor = pkgs: self.lib.mkSeed { inherit pkgs; };
      migrateFixtureEnv =
        pkgs:
        let
          allFragments = [
            "base"
            "nix"
            "shell"
            "ascii"
            "markdown"
            "yaml"
            "set"
          ];
          # Names of every pinned flake check the referenced architecture
          # provides (checksFor over all fragments) -- the equivalence gate
          # treats these as part of the referenced check-set.
          checksUniverseChecks = builtins.attrNames (
            self.lib.checksFor {
              inherit pkgs;
              src = ./.;
              fragments = allFragments;
            }
          );
          # lefthook.yml from ALL fragments -- its command names complete the
          # universe of architecture-provided guardrails.
          fullLefthookFiles =
            (self.lib.materializationFor {
              inherit pkgs;
              fragments = allFragments;
            }).files;
          migrateSetting = import ./setting/lib/mk-setting.nix { inherit (nixpkgs) lib; } { inherit pkgs; };
        in
        {
          nativeBuildInputs = [
            pkgs.coreutils
            pkgs.diffutils
            pkgs.findutils
            pkgs.gawk
            pkgs.git
            pkgs.gnugrep
          ];
          # The nix build sandbox has no $HOME and no git identity. Point git
          # at empty config files (so it never consults $HOME) and supply the
          # author/committer identity via env, matching the bats fixtures
          # (B22). Without this `git commit` fails "$HOME not set" /
          # "Author identity unknown" (exit 128).
          GIT_CONFIG_GLOBAL = "/dev/null";
          GIT_CONFIG_SYSTEM = "/dev/null";
          GIT_AUTHOR_NAME = "Test";
          GIT_AUTHOR_EMAIL = "test@test.com";
          GIT_COMMITTER_NAME = "Test";
          GIT_COMMITTER_EMAIL = "test@test.com";
          SEED_SRC = migrateSeedFor pkgs;
          SETTING_SRC = migrateSetting.configFiles;
          FRAGMENTS_DIR = ./setting/integrations/lefthook;
          ASSEMBLE_SCRIPT = ./setting/lib/assemble-lefthook.sh;
          DETECT_SCRIPT = ./setting/lib/detect-fragments.sh;
          CONFIRM_SCRIPT = ./lib/confirm.sh;
          CONFIRM_REV = self.rev or self.dirtyRev or "unknown";
          MIGRATE_SCRIPT = ./lib/migrate.sh;
          CHECKS_UNIVERSE = builtins.concatStringsSep " " checksUniverseChecks;
          CHECK_FRAGMENT_MAP = checkFragmentMapStr;
          FRAGMENT_TRIGGERS = fragmentTriggersStr;
          FULL_LEFTHOOK = "${fullLefthookFiles}/lefthook.yml";
        };

      wrap =
        pkgs: name: src: extra:
        pkgs.writeShellApplication (
          {
            inherit name;
            text = builtins.readFile "${src}/${name}.sh";
          }
          // extra
        );

      # #97: the pinned nixfmt wrapper, built from the pinned
      # `nix-lefthook-nixfmt-src` flake input. Shared by the devShell wrapper
      # list and the hermetic `checks.<sys>.nixfmt` derivation so both resolve
      # the exact same pinned lint logic (no runtime `remotes:` git_url).
      nixfmtWrapperFor =
        pkgs:
        wrap pkgs "lefthook-nixfmt" nix-lefthook-nixfmt-src {
          runtimeInputs = [ pkgs.nixfmt ];
        };

      # #98 (part of #93): the formatter tier's pinned wrappers, each built
      # from its own pinned flake input. Shared, like nixfmtWrapperFor, by the
      # devShell wrapper list and the hermetic `checks.<sys>.<tool>` derivation
      # so both resolve the exact same pinned lint logic (no runtime git_url).
      shfmtWrapperFor =
        pkgs:
        wrap pkgs "lefthook-shfmt" nix-lefthook-shfmt-src {
          runtimeInputs = [ pkgs.shfmt ];
        };
      trailingWhitespaceWrapperFor =
        pkgs:
        wrap pkgs "lefthook-trailing-whitespace" nix-lefthook-trailing-whitespace-src {
          runtimeInputs = [ pkgs.gnugrep ];
        };
      missingFinalNewlineWrapperFor =
        pkgs: wrap pkgs "lefthook-missing-final-newline" nix-lefthook-missing-final-newline-src { };
      editorconfigCheckerWrapperFor =
        pkgs:
        wrap pkgs "lefthook-editorconfig-checker" nix-lefthook-editorconfig-checker-src {
          runtimeInputs = [ pkgs.editorconfig-checker ];
        };

      # #100 (part of #93): the shell/content tier's pinned wrappers, each
      # built from its own pinned flake input. Shared, like nixfmtWrapperFor,
      # by the devShell wrapper list and the hermetic `checks.<sys>.<tool>`
      # derivation so both resolve the exact same pinned lint logic (no
      # runtime git_url).
      shellcheckWrapperFor =
        pkgs:
        wrap pkgs "lefthook-shellcheck" nix-lefthook-shellcheck-src {
          runtimeInputs = [ pkgs.shellcheck ];
        };
      noShellFunctionsWrapperFor =
        pkgs: wrap pkgs "lefthook-no-shell-functions" nix-lefthook-no-shell-functions-src { };
      asciiOnlyWrapperFor =
        pkgs:
        wrap pkgs "lefthook-ascii-only" nix-lefthook-ascii-only-src {
          runtimeInputs = [ pkgs.gnugrep ];
        };
      typosWrapperFor =
        pkgs:
        wrap pkgs "lefthook-typos" nix-lefthook-typos-src {
          runtimeInputs = [ pkgs.typos ];
        };

      # #99 (part of #93): the nix linters tier's pinned wrappers, each built
      # from its own pinned flake input. Shared, like nixfmtWrapperFor, by the
      # devShell wrapper list and the hermetic `checks.<sys>.<tool>` derivation
      # so both resolve the exact same pinned lint logic (no runtime git_url).
      statixWrapperFor =
        pkgs:
        wrap pkgs "lefthook-statix" nix-lefthook-statix-src {
          runtimeInputs = [ pkgs.statix ];
        };
      deadnixWrapperFor =
        pkgs:
        wrap pkgs "lefthook-deadnix" nix-lefthook-deadnix-src {
          runtimeInputs = [ pkgs.deadnix ];
        };
      nixNoEmbeddedShellWrapperFor =
        pkgs:
        pkgs.writeShellApplication {
          name = "lefthook-nix-no-embedded-shell";
          text = ''
            SCANNER="${nix-lefthook-nix-no-embedded-shell-src}/scan-nix-no-embedded-shell.sh"
          ''
          + builtins.readFile "${nix-lefthook-nix-no-embedded-shell-src}/lefthook-nix-no-embedded-shell.sh";
        };

      # #101 (part of #93): the git/security tier's pinned wrappers, each
      # built from its own pinned flake input. Shared, like nixfmtWrapperFor,
      # by the devShell wrapper list and the hermetic `checks.<sys>.<tool>`
      # derivation so both resolve the exact same pinned lint logic (no
      # runtime git_url).
      gitleaksWrapperFor =
        pkgs:
        wrap pkgs "lefthook-gitleaks" nix-lefthook-gitleaks-src {
          runtimeInputs = [
            pkgs.gitleaks
            pkgs.coreutils
          ];
        };
      gitConflictMarkersWrapperFor =
        pkgs:
        wrap pkgs "lefthook-git-conflict-markers" nix-lefthook-git-conflict-markers-src {
          runtimeInputs = [ pkgs.gnugrep ];
        };
      gitNoLocalPathsWrapperFor =
        pkgs:
        wrap pkgs "lefthook-git-no-local-paths" nix-lefthook-git-no-local-paths-src {
          runtimeInputs = [ pkgs.gnugrep ];
        };
      executePermissionsWrapperFor =
        pkgs:
        wrap pkgs "lefthook-execute-permissions" nix-lefthook-execute-permissions-src {
          runtimeInputs = [ pkgs.gnugrep ];
        };
      fileSizeCheckWrapperFor =
        pkgs:
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
        wrap pkgs "lefthook-file-size-check" nix-lefthook-file-size-check-src {
          runtimeInputs = [
            get-file-size-limit
            pkgs.gawk
            pkgs.gnugrep
            pkgs.coreutils
          ];
        };

      wrappersForFragment =
        pkgs:
        let
          w = wrap pkgs;
        in
        {
          base = [
            (w "lefthook-commit-msg-lint" nix-lefthook-commit-msg-lint-src {
              runtimeInputs = [ pkgs.coreutils ];
            })
            (w "lefthook-changelog-touched" nix-lefthook-changelog-touched-src {
              runtimeInputs = [
                pkgs.git
                pkgs.gnugrep
              ];
            })
            (gitleaksWrapperFor pkgs)
            (gitConflictMarkersWrapperFor pkgs)
            (gitNoLocalPathsWrapperFor pkgs)
            (executePermissionsWrapperFor pkgs)
            (fileSizeCheckWrapperFor pkgs)
            (trailingWhitespaceWrapperFor pkgs)
            (missingFinalNewlineWrapperFor pkgs)
            (editorconfigCheckerWrapperFor pkgs)
            (typosWrapperFor pkgs)
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
          nix = [
            (nixfmtWrapperFor pkgs)
            (statixWrapperFor pkgs)
            (deadnixWrapperFor pkgs)
            (nixNoEmbeddedShellWrapperFor pkgs)
            (w "lefthook-nix-flake-check" nix-lefthook-nix-flake-check-src {
              runtimeInputs = [ pkgs.nix ];
            })
            (w "lefthook-nix-flake-eval" nix-lefthook-nix-flake-eval-src {
              runtimeInputs = [ pkgs.nix ];
            })
          ];
          shell = [
            (shellcheckWrapperFor pkgs)
            (shfmtWrapperFor pkgs)
            (noShellFunctionsWrapperFor pkgs)
          ];
          ascii = [
            (asciiOnlyWrapperFor pkgs)
            (w "lefthook-unicode-lint" nix-lefthook-unicode-lint-src {
              runtimeInputs = [
                pkgs.gnugrep
                pkgs.libiconv
              ];
            })
          ];
          markdown = [
            (w "lefthook-markdownlint" nix-lefthook-markdownlint-src {
              runtimeInputs = [ pkgs.markdownlint-cli ];
            })
            (w "lefthook-markdownlint-agentic" nix-lefthook-markdownlint-agentic-src {
              runtimeInputs = [ pkgs.markdownlint-cli ];
            })
          ];
          yaml = [
            (w "lefthook-yamllint" nix-lefthook-yamllint-src {
              runtimeInputs = [ pkgs.yamllint ];
            })
          ];
          set = [ ];
        };

      lefthookWrappersFor =
        pkgs:
        let
          wff = wrappersForFragment pkgs;
        in
        builtins.concatMap (f: wff.${f}) [
          "base"
          "nix"
          "shell"
          "ascii"
          "markdown"
          "yaml"
          "set"
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
        principles = ./set/skills/principles;
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
        mkConfirm = import ./lib/mk-confirm.nix;
        mkSeed =
          { pkgs }:
          import ./lib/mk-seed.nix {
            inherit pkgs;
            scaffoldDir = ./setting/scaffold;
          };
        mkDevShells = import ./setting/lib/mk-dev-shells.nix;

        # #97: the framework seam -- wrap any pinned lefthook-* wrapper into a
        # hermetic flake check. Consumers repeat this per tier to replace a
        # runtime `remotes:` git_url with a pinned `checks.<name>` derivation.
        mkLefthookCheck = import ./lib/mk-lefthook-check.nix;

        # #97: convenience over mkLefthookCheck for the nixfmt tier. Closes
        # over set-and-setting's OWN pinned `nix-lefthook-nixfmt-src`, so a
        # consumer's `nixfmt` check tracks the upstream nixfmt rev via
        # `nix flake update set-and-setting` (C7) -- no local wrapper wiring.
        # Args: pkgs, src (repo root to lint), name ? "nixfmt".
        mkNixfmtCheck =
          {
            pkgs,
            src,
            name ? "nixfmt",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = nixfmtWrapperFor pkgs;
            suffices = [ ".nix" ];
          };

        # #98 (part of #93): the formatter tier's convenience helpers, each
        # closing over set-and-setting's OWN pinned wrapper input (like
        # mkNixfmtCheck). A consumer's check tracks the upstream tool rev via
        # `nix flake update set-and-setting` (C7). shfmt gates `*.sh` in
        # `--check` mode; the remaining three are glob-less whole-tree tools
        # (suffices = null, no check flag -- their only mode is read-only),
        # mirroring their glob-less lefthook `remotes:` entries.
        # Args: pkgs, src (repo root to lint), name ? "<tool>".
        mkShfmtCheck =
          {
            pkgs,
            src,
            name ? "shfmt",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = shfmtWrapperFor pkgs;
            suffices = [ ".sh" ];
          };
        mkTrailingWhitespaceCheck =
          {
            pkgs,
            src,
            name ? "trailing-whitespace",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = trailingWhitespaceWrapperFor pkgs;
            checkFlag = "";
          };
        mkMissingFinalNewlineCheck =
          {
            pkgs,
            src,
            name ? "missing-final-newline",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = missingFinalNewlineWrapperFor pkgs;
            checkFlag = "";
          };
        mkEditorconfigCheckerCheck =
          {
            pkgs,
            src,
            name ? "editorconfig-checker",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = editorconfigCheckerWrapperFor pkgs;
            checkFlag = "";
          };

        # #100 (part of #93): the shell/content tier's convenience helpers,
        # each closing over set-and-setting's OWN pinned wrapper input (like
        # mkNixfmtCheck). A consumer's check tracks the upstream tool rev via
        # `nix flake update set-and-setting` (C7). shellcheck and
        # no-shell-functions gate `*.sh` files with no check flag (wrappers
        # are read-only checkers). ascii-only gates `*.nix`, `*.yml`, `*.json`
        # with no check flag. typos is a glob-less whole-tree tool
        # (suffices = null, no check flag).
        # Args: pkgs, src (repo root to lint), name ? "<tool>".
        mkShellcheckCheck =
          {
            pkgs,
            src,
            name ? "shellcheck",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = shellcheckWrapperFor pkgs;
            suffices = [ ".sh" ];
            checkFlag = "";
          };
        mkNoShellFunctionsCheck =
          {
            pkgs,
            src,
            name ? "no-shell-functions",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = noShellFunctionsWrapperFor pkgs;
            suffices = [ ".sh" ];
            checkFlag = "";
          };
        mkAsciiOnlyCheck =
          {
            pkgs,
            src,
            name ? "ascii-only",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = asciiOnlyWrapperFor pkgs;
            suffices = [
              ".nix"
              ".yml"
              ".json"
            ];
            checkFlag = "";
          };
        mkTyposCheck =
          {
            pkgs,
            src,
            name ? "typos",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = typosWrapperFor pkgs;
            checkFlag = "";
          };

        # #99 (part of #93): the nix linters tier's convenience helpers, each
        # closing over set-and-setting's OWN pinned wrapper input (like
        # mkNixfmtCheck). A consumer's check tracks the upstream tool rev via
        # `nix flake update set-and-setting` (C7). statix and deadnix gate
        # `*.nix` files with no check flag (wrappers are read-only checkers).
        # nix-no-embedded-shell uses a custom derivation (not mkLefthookCheck)
        # to include the `.nix-embedded-shell-allowlist` in the source filter
        # and set NIX_NO_EMBEDDED_SHELL_ROOT for correct path matching.
        # Args: pkgs, src (repo root to lint), name ? "<tool>".
        mkStatixCheck =
          {
            pkgs,
            src,
            name ? "statix",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = statixWrapperFor pkgs;
            suffices = [ ".nix" ];
            checkFlag = "";
          };
        mkDeadnixCheck =
          {
            pkgs,
            src,
            name ? "deadnix",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = deadnixWrapperFor pkgs;
            suffices = [ ".nix" ];
            checkFlag = "";
          };
        mkNixNoEmbeddedShellCheck =
          {
            pkgs,
            src,
            name ? "nix-no-embedded-shell",
          }:
          let
            inherit (pkgs) lib;
            wrapper = nixNoEmbeddedShellWrapperFor pkgs;
            filteredSrc = lib.sources.cleanSourceWith {
              inherit src;
              filter =
                path: _type:
                (lib.hasSuffix ".nix" path) || (builtins.baseNameOf path == ".nix-embedded-shell-allowlist");
            };
          in
          pkgs.runCommand "${name}-check" { nativeBuildInputs = [ pkgs.findutils ]; } ''
            cd ${filteredSrc}
            export NIX_NO_EMBEDDED_SHELL_ROOT="."
            mapfile -t matches < <(find . -name '*.nix' -type f | sort)
            if [ ''${#matches[@]} -eq 0 ]; then
              echo "${name}: no .nix files, nothing to check"
              touch $out
              exit 0
            fi
            ${lib.getExe wrapper} "''${matches[@]}"
            echo "${name}: PASS (''${#matches[@]} files)"
            touch $out
          '';

        # #101 (part of #93): the git/security tier's convenience helpers,
        # each closing over set-and-setting's OWN pinned wrapper input (like
        # mkNixfmtCheck). A consumer's check tracks the upstream tool rev via
        # `nix flake update set-and-setting` (C7). gitleaks, git-conflict-
        # markers, execute-permissions, and file-size-check are glob-less
        # whole-tree tools (suffices = null, no check flag). git-no-local-
        # paths uses a custom derivation to exclude flake.nix and flake.lock
        # (which legitimately contain local path references).
        # Args: pkgs, src (repo root to lint), name ? "<tool>".
        mkGitleaksCheck =
          {
            pkgs,
            src,
            name ? "gitleaks",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = gitleaksWrapperFor pkgs;
            checkFlag = "";
          };
        mkGitConflictMarkersCheck =
          {
            pkgs,
            src,
            name ? "git-conflict-markers",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = gitConflictMarkersWrapperFor pkgs;
            checkFlag = "";
          };
        mkGitNoLocalPathsCheck =
          {
            pkgs,
            src,
            name ? "git-no-local-paths",
          }:
          let
            inherit (pkgs) lib;
            wrapper = gitNoLocalPathsWrapperFor pkgs;
            filteredSrc = lib.sources.cleanSourceWith {
              inherit src;
              filter =
                path: _type:
                let
                  base = builtins.baseNameOf path;
                in
                base != "flake.nix" && base != "flake.lock";
            };
          in
          pkgs.runCommand "${name}-check" { nativeBuildInputs = [ pkgs.findutils ]; } ''
            cd ${filteredSrc}
            mapfile -t matches < <(find . -type f | sort)
            if [ ''${#matches[@]} -eq 0 ]; then
              echo "${name}: no matching files, nothing to check"
              touch $out
              exit 0
            fi
            ${lib.getExe wrapper} "''${matches[@]}"
            echo "${name}: PASS (''${#matches[@]} files)"
            touch $out
          '';
        mkExecutePermissionsCheck =
          {
            pkgs,
            src,
            name ? "execute-permissions",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = executePermissionsWrapperFor pkgs;
            checkFlag = "";
          };
        mkFileSizeCheckCheck =
          {
            pkgs,
            src,
            name ? "file-size-check",
          }:
          import ./lib/mk-lefthook-check.nix {
            inherit pkgs src name;
            wrapper = fileSizeCheckWrapperFor pkgs;
            checkFlag = "";
          };

        materializationFor =
          {
            pkgs,
            fragments,
          }:
          import ./setting/lib/mk-materialization.nix {
            inherit pkgs fragments;
            fragmentsDir = ./setting/integrations/lefthook;
            assembleScript = ./setting/lib/assemble-lefthook.sh;
            corePackages = [
              pkgs.coreutils
              pkgs.git
              nix-lefthook.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];
            wrappersForFragment = wrappersForFragment pkgs;
          };

        # #93: fragment-driven check selection -- the CI-gate counterpart to
        # materializationFor. A consumer declares fragments once and gets both
        # the local convenience (materializationFor -> lefthook.yml + packages)
        # and CI gate (checksFor -> flake checks). Only tools with pinned-check
        # equivalents are included; hooks needing git context, test runners, and
        # `nix-flake-check` (which IS this mechanism) stay lefthook-local-only.
        checksFor =
          {
            pkgs,
            src,
            fragments,
          }:
          import ./lib/checks-for.nix {
            inherit pkgs src fragments;
            inherit (self.lib)
              mkNixfmtCheck
              mkShfmtCheck
              mkTrailingWhitespaceCheck
              mkMissingFinalNewlineCheck
              mkEditorconfigCheckerCheck
              mkShellcheckCheck
              mkNoShellFunctionsCheck
              mkAsciiOnlyCheck
              mkTyposCheck
              mkStatixCheck
              mkDeadnixCheck
              mkNixNoEmbeddedShellCheck
              mkGitleaksCheck
              mkGitConflictMarkersCheck
              mkGitNoLocalPathsCheck
              mkExecutePermissionsCheck
              mkFileSizeCheckCheck
              ;
          };
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
          # Materialize the gitignored configs (content-aware lefthook.yml,
          # .markdownlint.yml, .yamllint.yml) on devShell entry. Post-migration
          # (vendored -> referenced) lefthook.yml is no longer tracked, so it
          # MUST be materialized before `lefthook install` runs -- else lefthook
          # writes a default stub that fails the confirmator's fidelity check.
          settingHook = ''
            ${self.apps.${sys}.mkSetting.program} >/dev/null
          '';
          agenticShellHook = ''
            ${self.packages.${sys}.set}/bin/sync-set .
          '';
        }
      );

      checks = forAllSystems (pkgs: {
        # #97 (part of #93): nixfmt as a PINNED hermetic check, replacing the
        # runtime `remotes:` git_url in lefthook. Resolves the lint via the
        # pinned `nix-lefthook-nixfmt-src` input (nixfmtWrapperFor) -- offline-
        # runnable on a warm cache. A nixfmt violation fails `nix flake check`.
        # This is the framework proof; the next #93 tiers repeat the pattern.
        nixfmt = self.lib.mkNixfmtCheck {
          inherit pkgs;
          src = ./.;
        };

        # #97: prove the pinned check REJECTS a violation (acceptance:
        # "a nixfmt violation fails it"). Runs the same pinned wrapper path
        # the framework uses over a known-malformed file and asserts non-zero.
        nixfmt-catches-violation =
          let
            wrapper = nixfmtWrapperFor pkgs;
          in
          pkgs.runCommand "nixfmt-catches-violation" { } ''
            printf '{ x =    1 ;}\n' > bad.nix
            if ${pkgs.lib.getExe wrapper} --check bad.nix; then
              echo "FAIL: nixfmt --check accepted a malformed file"; exit 1
            fi
            echo "PASS: pinned nixfmt rejects a violation"
            touch $out
          '';

        # #98 (part of #93): the formatter tier as PINNED hermetic checks,
        # each replacing its runtime lefthook `remotes:` git_url. shfmt gates
        # `*.sh`; trailing-whitespace / missing-final-newline / editorconfig-
        # checker are glob-less whole-tree tools (every tracked file), matching
        # their glob-less `remotes:` entries. All offline-runnable on a warm
        # cache; a violation fails `nix flake check`.
        shfmt = self.lib.mkShfmtCheck {
          inherit pkgs;
          src = ./.;
        };
        trailing-whitespace = self.lib.mkTrailingWhitespaceCheck {
          inherit pkgs;
          src = ./.;
        };
        missing-final-newline = self.lib.mkMissingFinalNewlineCheck {
          inherit pkgs;
          src = ./.;
        };
        editorconfig-checker = self.lib.mkEditorconfigCheckerCheck {
          inherit pkgs;
          src = ./.;
        };

        # #98: prove each pinned formatter REJECTS a violation (acceptance:
        # a violation fails the check). Runs the same pinned wrapper path the
        # framework uses over a known-bad fixture and asserts non-zero.
        shfmt-catches-violation =
          let
            wrapper = shfmtWrapperFor pkgs;
          in
          pkgs.runCommand "shfmt-catches-violation" { } ''
            printf 'if true; then\necho bad\nfi\n' > bad.sh
            if ${pkgs.lib.getExe wrapper} --check bad.sh; then
              echo "FAIL: shfmt --check accepted a misindented file"; exit 1
            fi
            echo "PASS: pinned shfmt rejects a violation"
            touch $out
          '';
        trailing-whitespace-catches-violation =
          let
            wrapper = trailingWhitespaceWrapperFor pkgs;
          in
          pkgs.runCommand "trailing-whitespace-catches-violation" { } ''
            printf 'clean line\ntrailing   \n' > bad.txt
            if ${pkgs.lib.getExe wrapper} bad.txt; then
              echo "FAIL: accepted trailing whitespace"; exit 1
            fi
            echo "PASS: pinned trailing-whitespace rejects a violation"
            touch $out
          '';
        missing-final-newline-catches-violation =
          let
            wrapper = missingFinalNewlineWrapperFor pkgs;
          in
          pkgs.runCommand "missing-final-newline-catches-violation" { } ''
            printf 'no newline at end' > bad.txt
            if ${pkgs.lib.getExe wrapper} bad.txt; then
              echo "FAIL: accepted a missing final newline"; exit 1
            fi
            echo "PASS: pinned missing-final-newline rejects a violation"
            touch $out
          '';
        editorconfig-checker-catches-violation =
          let
            wrapper = editorconfigCheckerWrapperFor pkgs;
          in
          pkgs.runCommand "editorconfig-checker-catches-violation" { } ''
            printf '[*]\nindent_style = space\nindent_size = 2\n' > .editorconfig
            printf 'ok:\n\thard tab indent\n' > bad.yml
            if ${pkgs.lib.getExe wrapper} bad.yml; then
              echo "FAIL: editorconfig-checker accepted a violation"; exit 1
            fi
            echo "PASS: pinned editorconfig-checker rejects a violation"
            touch $out
          '';

        # #100 (part of #93): the shell/content tier as PINNED hermetic checks,
        # each replacing its runtime lefthook `remotes:` git_url. shellcheck
        # and no-shell-functions gate `*.sh` files; ascii-only gates
        # `*.{nix,yml,json}`; typos is a glob-less whole-tree tool (every
        # file). All offline-runnable on a warm cache; a violation fails
        # `nix flake check`.
        shellcheck = self.lib.mkShellcheckCheck {
          inherit pkgs;
          src = ./.;
        };
        no-shell-functions = self.lib.mkNoShellFunctionsCheck {
          inherit pkgs;
          src = ./.;
        };
        ascii-only = self.lib.mkAsciiOnlyCheck {
          inherit pkgs;
          src = ./.;
        };
        typos = self.lib.mkTyposCheck {
          inherit pkgs;
          src = ./.;
        };

        # #100: prove each pinned shell/content check REJECTS a violation
        # (acceptance: a violation fails the check). Runs the same pinned
        # wrapper path the framework uses over a known-bad fixture and asserts
        # non-zero.
        shellcheck-catches-violation =
          let
            wrapper = shellcheckWrapperFor pkgs;
          in
          pkgs.runCommand "shellcheck-catches-violation" { } ''
            printf '#!/bin/bash\necho $UNDEFINED_VAR\n' > bad.sh
            if ${pkgs.lib.getExe wrapper} bad.sh; then
              echo "FAIL: shellcheck accepted an unquoted variable"; exit 1
            fi
            echo "PASS: pinned shellcheck rejects a violation"
            touch $out
          '';
        no-shell-functions-catches-violation =
          let
            wrapper = noShellFunctionsWrapperFor pkgs;
          in
          pkgs.runCommand "no-shell-functions-catches-violation" { } ''
            printf '#!/bin/bash\nmy_func() { echo hi; }\n' > bad.sh
            if ${pkgs.lib.getExe wrapper} bad.sh; then
              echo "FAIL: no-shell-functions accepted a function definition"; exit 1
            fi
            echo "PASS: pinned no-shell-functions rejects a violation"
            touch $out
          '';
        ascii-only-catches-violation =
          let
            wrapper = asciiOnlyWrapperFor pkgs;
          in
          pkgs.runCommand "ascii-only-catches-violation" { } ''
            printf '{ key = "%b"; }\n' '\xc3\xa9' > bad.nix
            if ${pkgs.lib.getExe wrapper} bad.nix; then
              echo "FAIL: ascii-only accepted non-ASCII content"; exit 1
            fi
            echo "PASS: pinned ascii-only rejects a violation"
            touch $out
          '';
        typos-catches-violation =
          let
            wrapper = typosWrapperFor pkgs;
            # Build the misspelled word outside the nix source so typos
            # scanning flake.nix does not flag this fixture.
            fixture = pkgs.runCommand "typos-fixture" { } ''
              printf 'The %b quick brown fox\n' '\x74\x65\x68' > $out
            '';
          in
          pkgs.runCommand "typos-catches-violation" { } ''
            cp ${fixture} bad.txt
            if ${pkgs.lib.getExe wrapper} bad.txt; then
              echo "FAIL: typos accepted a misspelling"; exit 1
            fi
            echo "PASS: pinned typos rejects a violation"
            touch $out
          '';

        # #99 (part of #93): the nix linters tier as PINNED hermetic checks,
        # each replacing its runtime lefthook `remotes:` git_url. statix and
        # deadnix gate `*.nix` files; nix-no-embedded-shell scans `*.nix` for
        # embedded shell inside '' blocks (with allowlist support).
        # nix-flake-check is a sentinel: the old remote ran `nix flake check`,
        # which IS the CI mechanism that evaluates all `checks.*` derivations;
        # a separate derivation would recurse, so its presence documents the
        # migration. All offline-runnable on a warm cache; a violation fails
        # `nix flake check`.
        statix = self.lib.mkStatixCheck {
          inherit pkgs;
          src = ./.;
        };
        deadnix = self.lib.mkDeadnixCheck {
          inherit pkgs;
          src = ./.;
        };
        nix-no-embedded-shell = self.lib.mkNixNoEmbeddedShellCheck {
          inherit pkgs;
          src = ./.;
        };
        nix-flake-check = pkgs.runCommand "nix-flake-check" { } ''
          echo "nix-flake-check: the old remote ran nix flake check --"
          echo "which IS this CI mechanism. All individual checks are"
          echo "pinned derivations; this sentinel documents the migration."
          touch $out
        '';

        # #99: prove each pinned nix linter REJECTS a violation (acceptance:
        # a violation fails the check). Runs the same pinned wrapper path the
        # framework uses over a known-bad fixture and asserts non-zero.
        statix-catches-violation =
          let
            wrapper = statixWrapperFor pkgs;
          in
          pkgs.runCommand "statix-catches-violation" { } ''
            printf 'let { x = 1; body = x; }\n' > bad.nix
            if ${pkgs.lib.getExe wrapper} bad.nix; then
              echo "FAIL: statix accepted undocumented let syntax"; exit 1
            fi
            echo "PASS: pinned statix rejects a violation"
            touch $out
          '';
        deadnix-catches-violation =
          let
            wrapper = deadnixWrapperFor pkgs;
          in
          pkgs.runCommand "deadnix-catches-violation" { } ''
            printf '{ unused }: 42\n' > bad.nix
            if ${pkgs.lib.getExe wrapper} bad.nix; then
              echo "FAIL: deadnix accepted dead code"; exit 1
            fi
            echo "PASS: pinned deadnix rejects a violation"
            touch $out
          '';
        nix-no-embedded-shell-catches-violation =
          let
            wrapper = nixNoEmbeddedShellWrapperFor pkgs;
          in
          pkgs.runCommand "nix-no-embedded-shell-catches-violation" { } ''
            cat > bad.nix <<'NIXEOF'
            pkgs.runCommand "test" {} ''''
              set -euo pipefail
              echo hello
            ''''
            NIXEOF
            if ${pkgs.lib.getExe wrapper} bad.nix; then
              echo "FAIL: nix-no-embedded-shell accepted embedded shell"; exit 1
            fi
            echo "PASS: pinned nix-no-embedded-shell rejects a violation"
            touch $out
          '';

        # #101 (part of #93): the git/security tier as PINNED hermetic
        # checks, each replacing its runtime lefthook `remotes:` git_url.
        # gitleaks, git-conflict-markers, execute-permissions, and
        # file-size-check are glob-less whole-tree tools (every file).
        # git-no-local-paths excludes flake.nix and flake.lock (which
        # legitimately contain local path references). All offline-runnable
        # on a warm cache; a violation fails `nix flake check`.
        gitleaks = self.lib.mkGitleaksCheck {
          inherit pkgs;
          src = ./.;
        };
        git-conflict-markers = self.lib.mkGitConflictMarkersCheck {
          inherit pkgs;
          src = ./.;
        };
        git-no-local-paths = self.lib.mkGitNoLocalPathsCheck {
          inherit pkgs;
          src = ./.;
        };
        execute-permissions = self.lib.mkExecutePermissionsCheck {
          inherit pkgs;
          src = ./.;
        };
        file-size-check = self.lib.mkFileSizeCheckCheck {
          inherit pkgs;
          src = ./.;
        };

        # #101: prove each pinned git/security check REJECTS a violation
        # (acceptance: a violation fails the check). Runs the same pinned
        # wrapper path the framework uses over a known-bad fixture and
        # asserts non-zero.
        gitleaks-catches-violation =
          let
            wrapper = gitleaksWrapperFor pkgs;
            # Build an RSA private key fixture outside the nix source so
            # gitleaks scanning flake.nix does not flag it. Key markers
            # and body are hex-encoded to avoid detection in this file.
            fixture = pkgs.runCommand "gitleaks-fixture" { } ''
              {
                printf '%b\n' '\x2d\x2d\x2d\x2d\x2dBEGIN RSA PRIVATE KEY\x2d\x2d\x2d\x2d\x2d'
                printf '%s\n' 'MIIEowIBAAKCAQEA2Z3qX2BTLS4eMJTM59MZ1IUk2VBrpEHxb4L6I3gINJi2A'
                printf '%s\n' 'nBQJiENxUwpzEsGFgNUQZsLCNGfuB5wDNeF9N7MwwJgPLCYh3U8bqGNzrFnBR'
                printf '%s\n' 'yv75OfkKFqPGFEkPPQQBJUfSE6Hf8aOBbAqJBKm9dUthHq6CsDGbMBEZMTBVg'
                printf '%b\n' '\x2d\x2d\x2d\x2d\x2dEND RSA PRIVATE KEY\x2d\x2d\x2d\x2d\x2d'
              } > $out
            '';
          in
          pkgs.runCommand "gitleaks-catches-violation" { } ''
            cp ${fixture} bad.txt
            if ${pkgs.lib.getExe wrapper} bad.txt; then
              echo "FAIL: gitleaks accepted a secret"; exit 1
            fi
            echo "PASS: pinned gitleaks rejects a violation"
            touch $out
          '';
        git-conflict-markers-catches-violation =
          let
            wrapper = gitConflictMarkersWrapperFor pkgs;
          in
          pkgs.runCommand "git-conflict-markers-catches-violation" { } ''
            printf '<<<<<<< HEAD\nours\n=======\ntheirs\n>>>>>>> branch\n' > bad.txt
            if ${pkgs.lib.getExe wrapper} bad.txt; then
              echo "FAIL: git-conflict-markers accepted conflict markers"; exit 1
            fi
            echo "PASS: pinned git-conflict-markers rejects a violation"
            touch $out
          '';
        git-no-local-paths-catches-violation =
          let
            wrapper = gitNoLocalPathsWrapperFor pkgs;
          in
          pkgs.runCommand "git-no-local-paths-catches-violation" { } ''
            printf 'url = "git+file:///home/user/repo"\n' > bad.txt # nolocalpath
            if ${pkgs.lib.getExe wrapper} bad.txt; then
              echo "FAIL: git-no-local-paths accepted a local path"; exit 1
            fi
            echo "PASS: pinned git-no-local-paths rejects a violation"
            touch $out
          '';
        execute-permissions-catches-violation =
          let
            wrapper = executePermissionsWrapperFor pkgs;
          in
          pkgs.runCommand "execute-permissions-catches-violation" { } ''
            printf 'not a script\n' > bad.txt
            chmod +x bad.txt
            if ${pkgs.lib.getExe wrapper} bad.txt; then
              echo "FAIL: execute-permissions accepted a non-script executable"; exit 1
            fi
            echo "PASS: pinned execute-permissions rejects a violation"
            touch $out
          '';
        file-size-check-catches-violation =
          let
            wrapper = fileSizeCheckWrapperFor pkgs;
          in
          pkgs.runCommand "file-size-check-catches-violation" { } ''
            mkdir -p config/lefthook
            printf '%s\n' '---' 'default: 10' > config/lefthook/file_size_limits.yml
            dd if=/dev/zero of=big.txt bs=1 count=100 2>/dev/null
            if ${pkgs.lib.getExe wrapper} big.txt; then
              echo "FAIL: file-size-check accepted an oversized file"; exit 1
            fi
            echo "PASS: pinned file-size-check rejects a violation"
            touch $out
          '';

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

        # #154: autonomous-loop consumers opt into drafts/ops once and get
        # the paired HOOTL authority + HITL escalation skills and anchors.
        ops-loop-skills =
          let
            mergedSkills = pkgs.runCommand "merged-skills-for-ops-loop-check" { } ''
              cp -r ${./set/skills} $out
              chmod -R u+w $out
              cp -r ${./set/drafts} $out/drafts
            '';
            emitted = import ./set/lib/mk-set.nix { inherit (nixpkgs) lib; } {
              inherit pkgs;
              skillsDir = mergedSkills;
              categories = [ "drafts/ops" ];
              concepts = false;
            };
            rules = "${emitted}/.claude/rules/set/drafts/ops";
          in
          pkgs.runCommand "ops-loop-skills-check" { } ''
            test -f "${rules}/hitl.md"
            test -f "${rules}/hootl.md"
            grep -q 'HOOTL-ELIGIBLE' "${rules}/hootl.md"
            grep -q 'HUMAN-GATED' "${rules}/hootl.md"
            grep -q '@set/drafts/ops/hitl.md' "${./set/drafts/ops/ops.md}"
            grep -q '@set/drafts/ops/hootl.md' "${./set/drafts/ops/ops.md}"
            touch $out
          '';

        # meta-resolve -- V30: the sidecar map resolves each source path to
        # { channel, paths, keywords, always } via category fallback <-
        # subtree entry <- exact-file override (most specific wins).
        meta-resolve =
          let
            meta = import ./set/meta.nix { inherit (nixpkgs) lib; };
            r = meta.resolve;
            evolve = builtins.readFile ./set/skills/principles/evolve.md;
            meritocracy = builtins.readFile ./set/skills/principles/meritocracy.md;
            ownership = builtins.readFile ./set/skills/principles/ownership.md;
            process = builtins.readFile ./set/skills/principles/process.md;
            sync = builtins.readFile ./set/skills/principles/sync.md;
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
              # stable principles expose topic-specific discovery metadata
              assert builtins.elem "evolve" (r "principles/evolve.md").keywords;
              assert builtins.elem "introspect-flywheel" (r "principles/evolve.md").keywords;
              assert (r "principles/evolve.md").paths == [ "**/*" ];
              assert nixpkgs.lib.hasInfix "Everything improves through continuous adaptation" evolve;
              assert nixpkgs.lib.hasInfix "See also [[machine]] and" evolve;
              assert nixpkgs.lib.hasInfix "[[progress]]" evolve;
              assert builtins.elem "meritocracy" (r "principles/meritocracy.md").keywords;
              assert builtins.elem "best-of-n" (r "principles/meritocracy.md").keywords;
              assert builtins.elem "judge-panel" (r "principles/meritocracy.md").keywords;
              assert (r "principles/meritocracy.md").paths == [ "**/*" ];
              assert nixpkgs.lib.hasInfix "let the best idea win regardless of who holds it" meritocracy;
              assert nixpkgs.lib.hasInfix "junior brain's better-verified idea" meritocracy;
              assert nixpkgs.lib.hasInfix "Use judge panels or best-of-N synthesis" meritocracy;
              assert nixpkgs.lib.hasInfix "Apply this principle to everything the agent does" meritocracy;
              assert nixpkgs.lib.hasInfix "radical [[truth]], radical [[transparency]]" meritocracy;
              assert nixpkgs.lib.hasInfix "[[believability]]-weighted" meritocracy;
              assert nixpkgs.lib.hasInfix "[[openness]]" meritocracy;
              assert builtins.elem "ownership" (r "principles/ownership.md").keywords;
              assert builtins.elem "end-to-end" (r "principles/ownership.md").keywords;
              assert (r "principles/ownership.md").paths == [ "**/*" ];
              assert nixpkgs.lib.hasInfix "opening it through green checks, accord, and merge" ownership;
              assert nixpkgs.lib.hasInfix "explicitly marked blocked" ownership;
              assert nixpkgs.lib.hasInfix "See also [[reality]] and [[truth]]" ownership;
              assert builtins.elem "process" (r "principles/process.md").keywords;
              assert builtins.elem "five-step-process" (r "principles/process.md").keywords;
              assert builtins.elem "spec-driven-development" (r "principles/process.md").keywords;
              assert (r "principles/process.md").paths == [ "**/*" ];
              assert nixpkgs.lib.hasInfix "1. Set goals." process;
              assert nixpkgs.lib.hasInfix "5. Do." process;
              assert nixpkgs.lib.hasInfix "The process is a loop, not a one-way checklist" process;
              assert nixpkgs.lib.hasInfix "[[rootcause]], [[reality]], and [[ownership]]" process;
              assert builtins.elem "sync" (r "principles/sync.md").keywords;
              assert builtins.elem "accord-review" (r "principles/sync.md").keywords;
              assert builtins.elem "consumer-compatibility" (r "principles/sync.md").keywords;
              assert (r "principles/sync.md").paths == [ "**/*" ];
              assert nixpkgs.lib.hasInfix "A persistent disagreement left unresolved is a hidden defect" sync;
              assert nixpkgs.lib.hasInfix "Check stability, maintainability, and" sync;
              assert nixpkgs.lib.hasInfix "consumer compatibility independently" sync;
              assert nixpkgs.lib.hasInfix "Reconcile consumer needs with the shared standard explicitly" sync;
              assert nixpkgs.lib.hasInfix "See also [[openness]]" sync;
              assert nixpkgs.lib.hasInfix "and [[believability]]" sync;
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
            grep -q "Keep solutions as simple as possible" "$f" \
              || { echo "FAIL: KISS principle not inlined"; exit 1; }
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
            [ -f "$setdir/generic/kiss.md" ] \
              || { echo "FAIL: KISS principle missing from core"; exit 1; }
            if grep -q '^paths:' "$setdir/generic/kiss.md"; then
              echo "FAIL: KISS principle must be always-on"; exit 1
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
            grep -q '^@set/generic/kiss.md$' "$manifest" \
              || { echo "FAIL: set.md missing KISS principle"; exit 1; }
            if grep -q 'nix/flake.md' "$manifest"; then
              echo "FAIL: set.md must not list domain rules"; exit 1
            fi

            # store-root-correct index.md (#167): $out-relative @-imports
            idx="${full}/index.md"
            [ -f "$idx" ] || { echo "FAIL: index.md missing"; exit 1; }
            grep -q '^@\./.claude/rules/set/concepts-user.md$' "$idx" \
              || { echo "FAIL: index.md missing concept ref"; exit 1; }
            grep -q '^@\./.claude/rules/set/generic/skill.md$' "$idx" \
              || { echo "FAIL: index.md missing core ref"; exit 1; }
            if grep -q 'nix/flake.md' "$idx"; then
              echo "FAIL: index.md must not list domain rules"; exit 1
            fi
            # every @-import in index.md resolves under $out
            while IFS= read -r line; do
              case "$line" in @*) ;; *) continue ;; esac
              ref="''${line#@./}"
              [ -f "${full}/$ref" ] \
                || { echo "FAIL: index.md ref $ref not found under derivation"; exit 1; }
            done <"$idx"

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
            grep -q 'Keep solutions as simple as possible' "$exskill" \
              || { echo "FAIL: KISS principle missing from SKILL.md"; exit 1; }

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
            noDocs = mkSetting {
              inherit pkgs;
              readme = false;
              license = null;
            };
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
            [ -e "${full}/README.md" ] || { echo "FAIL: no README.md"; exit 1; }
            [ -e "${full}/LICENSE" ] || { echo "FAIL: no LICENSE"; exit 1; }
            grep -q '__OWNER__/__REPO__' "${full}/README.md" \
              || { echo "FAIL: README badge placeholders missing"; exit 1; }
            grep -q '__YEAR__ __HOLDER__' "${full}/LICENSE" \
              || { echo "FAIL: license placeholders missing"; exit 1; }
            [ ! -e "${noDocs}/README.md" ] || { echo "FAIL: opted-out README present"; exit 1; }
            [ ! -e "${noDocs}/LICENSE" ] || { echo "FAIL: opted-out LICENSE present"; exit 1; }

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
            if [ -e "${full.materialized}/README.md" ] || [ -e "${full.materialized}/LICENSE" ]; then
              echo "FAIL: pkg has documentation seeds"; exit 1
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
              basePackages = [
                pkgs.coreutils
                pkgs.asciinema
              ];
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
              # #116: non-LLM tools (asciinema) in basePackages are available
              # in both default AND agentic (inherited via inputsFrom)
              assert builtins.elem pkgs.asciinema shells.default.nativeBuildInputs;
              assert builtins.elem pkgs.asciinema shells.agentic.nativeBuildInputs;
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
            # scaffold produces the repo flake, lefthook config, and CI workflow
            [ -f "${scaffold}/flake.nix" ] \
              || { echo "FAIL: no flake.nix"; exit 1; }
            [ -f "${scaffold}/lefthook.yml" ] \
              || { echo "FAIL: no lefthook.yml"; exit 1; }
            [ -f "${scaffold}/.github/workflows/ci.yml" ] \
              || { echo "FAIL: no ci.yml"; exit 1; }
            [ ! -f "${scaffold}/.github/workflows/auto-update.yml" ] \
              || { echo "FAIL: obsolete auto-update.yml present"; exit 1; }

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

            # #93: scaffold uses checksFor for fragment-driven pinned checks
            grep -q 'checksFor' "${scaffold}/flake.nix" \
              || { echo "FAIL: scaffold flake.nix missing checksFor"; exit 1; }

            # T59/B17: scaffold ci.yml must specify devshell: "default"
            # (the CI action defaults to "ci" which no longer exists)
            grep -q 'devshell:.*"default"' "${scaffold}/.github/workflows/ci.yml" \
              || { echo "FAIL: ci.yml missing devshell: default (B17)"; exit 1; }

            # #97-#101: all base + nix + shell + ascii + content linters are
            # pinned checks now, not remotes; none must survive in the
            # assembled scaffold lefthook.yml.
            for t in nixfmt shfmt trailing-whitespace missing-final-newline editorconfig-checker statix deadnix nix-no-embedded-shell nix-flake-check shellcheck no-shell-functions ascii-only typos gitleaks git-conflict-markers git-no-local-paths execute-permissions file-size-check; do
              if grep -q "nix-lefthook-$t" "${scaffold}/lefthook.yml"; then
                echo "FAIL: lefthook.yml still has $t remote (#97-#101)"; exit 1
              fi
            done
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

            # T62/#69: scaffold CI must NOT skip lefthook -- the lint gate
            # runs in the default devShell, same as local hooks.
            if grep -qE 'skip-lefthook:\s*"?true"?' "${scaffold}/.github/workflows/ci.yml"; then
              echo "FAIL: ci.yml has skip-lefthook: true -- CI must run lefthook (#69/T62)"
              exit 1
            fi

            echo PASS
            touch $out
          '';

        # dep-graph -- T9/C6: every flake input in flake.lock uses github:
        dep-graph = import ./lib/mk-dep-graph-check.nix {
          inherit pkgs;
          projectRoot = ./.;
        };

        # set-skill-extension -- T56/V6/V13: only *.md files in set/skills/
        # and set/drafts/. Pure find + exit-on-non-md.
        set-skill-extension = import ./lib/mk-skill-extension-check.nix {
          inherit pkgs;
          setRoot = ./set;
        };

        # set-skill-size -- T57: per-file size limit on individual
        # skill/draft markdown. Single wc -c check.
        set-skill-size = import ./lib/mk-skill-size-check.nix {
          inherit pkgs;
          setRoot = ./set;
        };

        # set-ref-resolution -- T64/V12/V29: every real @-reference in the
        # set/ tree (per the T63 matcher) resolves to an existing source
        # path. Exit 1 only on a truly-missing target.
        set-ref-resolution = import ./lib/mk-ref-resolution-check.nix {
          inherit pkgs;
          setRoot = ./set;
        };

        # set-bundle-content -- T65/V12: each bundle file (composes via @,
        # per the T63 matcher) limits its own content to one heading + a
        # purpose statement + the @ refs. Structural markdown fails. Ships
        # independent of the ref-resolution check.
        set-bundle-content = import ./lib/mk-bundle-content-check.nix {
          inherit pkgs;
          setRoot = ./set;
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

        materializationFor-check =
          let
            mat = self.lib.materializationFor {
              inherit pkgs;
              fragments = [
                "base"
                "markdown"
                "yaml"
              ];
            };
            allBins = pkgs.symlinkJoin {
              name = "materialization-bins";
              paths = mat.packages;
            };
          in
          pkgs.runCommand "materializationFor-check" { } ''
            [ -f "${mat.files}/lefthook.yml" ] \
              || { echo "FAIL: no lefthook.yml in files"; exit 1; }
            grep -q 'markdownlint' "${mat.files}/lefthook.yml" \
              || { echo "FAIL: lefthook.yml missing markdownlint"; exit 1; }
            grep -q 'yamllint' "${mat.files}/lefthook.yml" \
              || { echo "FAIL: lefthook.yml missing yamllint"; exit 1; }
            [ -x "${allBins}/bin/lefthook-markdownlint" ] \
              || { echo "FAIL: packages missing lefthook-markdownlint"; exit 1; }
            [ -x "${allBins}/bin/lefthook-yamllint" ] \
              || { echo "FAIL: packages missing lefthook-yamllint"; exit 1; }
            echo "PASS"
            touch $out
          '';

        materializationFor-coherence =
          let
            mat = self.lib.materializationFor {
              inherit pkgs;
              fragments = [
                "base"
                "nix"
                "shell"
                "ascii"
                "markdown"
                "yaml"
                "set"
              ];
            };
            allBins = pkgs.symlinkJoin {
              name = "materialization-coherence-bins";
              paths = mat.packages;
            };
          in
          pkgs.runCommand "materializationFor-coherence" { } ''
            [ -f "${mat.files}/lefthook.yml" ] \
              || { echo "FAIL: no lefthook.yml"; exit 1; }
            for wrapper in $(grep -oE 'lefthook-[a-z][-a-z]*' "${mat.files}/lefthook.yml" | sort -u); do
              [ -x "${allBins}/bin/$wrapper" ] \
                || { echo "FAIL: $wrapper in lefthook.yml but missing from packages"; exit 1; }
            done
            echo "PASS: all lefthook.yml tool references found in packages"
            touch $out
          '';

        materializationFor-idempotent =
          let
            mat = self.lib.materializationFor {
              inherit pkgs;
              fragments = [
                "base"
                "nix"
                "shell"
                "ascii"
                "markdown"
                "yaml"
              ];
            };
            mat2 = self.lib.materializationFor {
              inherit pkgs;
              fragments = [
                "base"
                "nix"
                "shell"
                "ascii"
                "markdown"
                "yaml"
              ];
            };
          in
          pkgs.runCommand "materializationFor-idempotent" { } ''
            diff "${mat.files}/lefthook.yml" "${mat2.files}/lefthook.yml" \
              || { echo "FAIL: same fragments produce different lefthook.yml"; exit 1; }
            echo "PASS: idempotent"
            touch $out
          '';

        materializationFor-subset =
          let
            full = self.lib.materializationFor {
              inherit pkgs;
              fragments = [
                "base"
                "nix"
                "shell"
                "ascii"
                "markdown"
                "yaml"
                "set"
              ];
            };
            minimal = self.lib.materializationFor {
              inherit pkgs;
              fragments = [ "base" ];
            };
          in
          pkgs.runCommand "materializationFor-subset" { } ''
            full_count=${toString (builtins.length full.packages)}
            minimal_count=${toString (builtins.length minimal.packages)}
            [ "$full_count" -gt "$minimal_count" ] \
              || { echo "FAIL: full ($full_count) should have more packages than minimal ($minimal_count)"; exit 1; }
            if grep -q 'markdownlint' "${minimal.files}/lefthook.yml"; then
              echo "FAIL: minimal lefthook.yml should not have markdownlint"; exit 1
            fi
            echo "PASS: fragment subset produces fewer packages"
            touch $out
          '';

        # #93: checksFor returns fragment-filtered checks -- the CI-gate
        # counterpart to materializationFor. Verify it returns the expected
        # check attrset for a given fragment list.
        checksFor-base =
          let
            result = self.lib.checksFor {
              inherit pkgs;
              src = ./.;
              fragments = [ "base" ];
            };
          in
          pkgs.runCommand "checksFor-base" { } ''
            # base fragment should produce these checks
            ${builtins.concatStringsSep "\n" (
              map (name: ''[ -e "${result.${name}}" ] || { echo "FAIL: missing ${name}"; exit 1; }'') [
                "gitleaks"
                "git-conflict-markers"
                "git-no-local-paths"
                "execute-permissions"
                "file-size-check"
                "trailing-whitespace"
                "missing-final-newline"
                "editorconfig-checker"
                "typos"
              ]
            )}
            echo "PASS: base fragment returns all expected checks"
            touch $out
          '';

        checksFor-nix =
          let
            result = self.lib.checksFor {
              inherit pkgs;
              src = ./.;
              fragments = [ "nix" ];
            };
          in
          pkgs.runCommand "checksFor-nix" { } ''
            ${builtins.concatStringsSep "\n" (
              map (name: ''[ -e "${result.${name}}" ] || { echo "FAIL: missing ${name}"; exit 1; }'') [
                "nixfmt"
                "statix"
                "deadnix"
                "nix-no-embedded-shell"
              ]
            )}
            echo "PASS: nix fragment returns all expected checks"
            touch $out
          '';

        checksFor-shell =
          let
            result = self.lib.checksFor {
              inherit pkgs;
              src = ./.;
              fragments = [ "shell" ];
            };
          in
          pkgs.runCommand "checksFor-shell" { } ''
            ${builtins.concatStringsSep "\n" (
              map (name: ''[ -e "${result.${name}}" ] || { echo "FAIL: missing ${name}"; exit 1; }'') [
                "shellcheck"
                "shfmt"
                "no-shell-functions"
              ]
            )}
            echo "PASS: shell fragment returns all expected checks"
            touch $out
          '';

        checksFor-subset =
          let
            full = self.lib.checksFor {
              inherit pkgs;
              src = ./.;
              fragments = [
                "base"
                "nix"
                "shell"
                "ascii"
              ];
            };
            minimal = self.lib.checksFor {
              inherit pkgs;
              src = ./.;
              fragments = [ "base" ];
            };
          in
          pkgs.runCommand "checksFor-subset" { } ''
            full_count=${toString (builtins.length (builtins.attrNames full))}
            minimal_count=${toString (builtins.length (builtins.attrNames minimal))}
            [ "$full_count" -gt "$minimal_count" ] \
              || { echo "FAIL: full ($full_count) should have more checks than minimal ($minimal_count)"; exit 1; }
            echo "PASS: fragment subset produces fewer checks ($minimal_count < $full_count)"
            touch $out
          '';

        checksFor-empty-fragments =
          let
            result = self.lib.checksFor {
              inherit pkgs;
              src = ./.;
              fragments = [
                "markdown"
                "yaml"
                "set"
              ];
            };
          in
          pkgs.runCommand "checksFor-empty-fragments" { } ''
            count=${toString (builtins.length (builtins.attrNames result))}
            [ "$count" -eq 0 ] \
              || { echo "FAIL: markdown/yaml/set should produce 0 checks, got $count"; exit 1; }
            echo "PASS: fragments with no pinned checks return empty attrset"
            touch $out
          '';

        # #168: check-fragment-map completeness -- every check name produced by
        # checksFor (over all fragments) must appear in the map, and every
        # command in lefthook integration fragments must appear too.
        check-fragment-map-complete =
          let
            allChecks = builtins.attrNames (
              self.lib.checksFor {
                inherit pkgs;
                src = ./.;
                fragments = cfm.validFragments;
              }
            );
            mapChecks = builtins.concatLists (map (f: cfm.checksPerFragment.${f}) cfm.validFragments);
            pinnedMissing = builtins.filter (c: !(builtins.elem c mapChecks)) allChecks;
            mapPinned = builtins.concatLists (map (f: cfm.pinnedChecks.${f}) cfm.validFragments);
            extraPinned = builtins.filter (c: !(builtins.elem c allChecks)) mapPinned;
          in
          pkgs.runCommand "check-fragment-map-complete"
            {
              nativeBuildInputs = [
                pkgs.gawk
                pkgs.gnugrep
              ];
              FRAGMENTS_DIR = ./setting/integrations/lefthook;
              MAP_CHECKS = builtins.concatStringsSep "\n" mapChecks;
            }
            ''
              # 1. Every checksFor name must be in the map
              ${
                if pinnedMissing != [ ] then
                  ''
                    echo "FAIL: checksFor names missing from check-fragment-map.nix:"
                    echo "  ${builtins.concatStringsSep ", " pinnedMissing}"
                    exit 1
                  ''
                else
                  ""
              }
              # 2. Every map pinnedChecks name must be in checksFor
              ${
                if extraPinned != [ ] then
                  ''
                    echo "FAIL: check-fragment-map.nix pinnedChecks has names not in checksFor:"
                    echo "  ${builtins.concatStringsSep ", " extraPinned}"
                    exit 1
                  ''
                else
                  ""
              }
              # 3. Every command in lefthook fragments must be in the map
              fail=0
              for frag in $FRAGMENTS_DIR/*.yml; do
                fname="$(basename "$frag" .yml)"
                cmds="$(awk '
                  /^  commands:[[:space:]]*$/ { c=1; next }
                  c && /^    [A-Za-z][A-Za-z0-9_-]*:/ { k=$1; sub(/:.*/, "", k); print k }
                  /^[a-z]/ && !/^    / { c=0 }
                ' "$frag" | sort -u)"
                for cmd in $cmds; do
                  if ! echo "$MAP_CHECKS" | grep -qx "$cmd"; then
                    echo "FAIL: lefthook fragment $fname has command '$cmd' not in check-fragment-map.nix"
                    fail=1
                  fi
                done
              done
              [ "$fail" -eq 0 ] || exit 1
              echo "PASS: check-fragment-map.nix is complete (all checksFor + fragment commands covered)"
              touch $out
            '';

        confirm-self-test =
          let
            mkSettingFull = import ./setting/lib/mk-setting.nix { inherit (nixpkgs) lib; } { inherit pkgs; };
            mat = self.lib.materializationFor {
              inherit pkgs;
              fragments = [
                "base"
                "nix"
                "shell"
                "ascii"
                "markdown"
                "yaml"
              ];
            };
            fixture = pkgs.runCommand "confirm-fixture" { } ''
              mkdir -p $out
              cp ${mat.files}/lefthook.yml $out/lefthook.yml
              cp ${mkSettingFull.configFiles}/.markdownlint.yml $out/.markdownlint.yml
              cp ${mkSettingFull.configFiles}/.yamllint.yml $out/.yamllint.yml
              # create files for each fragment to trigger detection
              touch $out/dummy.nix $out/dummy.sh $out/dummy.md $out/dummy.yml
              printf '{}' > $out/flake.lock
            '';
          in
          pkgs.runCommand "confirm-self-test"
            {
              nativeBuildInputs = [
                pkgs.diffutils
                pkgs.gnugrep
                pkgs.git
                pkgs.coreutils
                pkgs.gawk
                pkgs.findutils
              ]
              ++ mat.packages;
              FRAGMENTS_DIR = ./setting/integrations/lefthook;
              ASSEMBLE_SCRIPT = ./setting/lib/assemble-lefthook.sh;
              DETECT_SCRIPT = ./setting/lib/detect-fragments.sh;
              SETTING_SRC = mkSettingFull.configFiles;
              CONFIRM_SCRIPT = ./lib/confirm.sh;
              CONFIRM_REV = self.rev or self.dirtyRev or "unknown";
            }
            ''
              cp -r ${fixture} workdir
              chmod -R u+w workdir
              cd workdir
              git init -q
              git add .
              bash "$CONFIRM_SCRIPT"
              touch $out
            '';

        confirm-rejects-broken =
          let
            mkSettingFull = import ./setting/lib/mk-setting.nix { inherit (nixpkgs) lib; } { inherit pkgs; };
          in
          pkgs.runCommand "confirm-rejects-broken"
            {
              nativeBuildInputs = [
                pkgs.diffutils
                pkgs.gnugrep
                pkgs.git
                pkgs.coreutils
                pkgs.gawk
                pkgs.findutils
              ];
              FRAGMENTS_DIR = ./setting/integrations/lefthook;
              ASSEMBLE_SCRIPT = ./setting/lib/assemble-lefthook.sh;
              DETECT_SCRIPT = ./setting/lib/detect-fragments.sh;
              SETTING_SRC = mkSettingFull.configFiles;
              CONFIRM_SCRIPT = ./lib/confirm.sh;
              CONFIRM_REV = "test-rev";
            }
            ''
              mkdir workdir && cd workdir
              touch dummy.nix
              printf '%s\n' '---' 'broken: true' > lefthook.yml
              printf '%s' '{}' > flake.lock
              git init -q
              git add .
              if bash "$CONFIRM_SCRIPT"; then
                echo "FAIL: confirmator should reject broken materialization"
                exit 1
              fi
              echo "PASS: confirmator rejects broken materialization"
              touch $out
            '';

        seed-layout =
          let
            seed = self.lib.mkSeed { inherit pkgs; };
          in
          pkgs.runCommand "seed-layout-check" { } ''
            # Verify the seed derivation contains expected files
            test -f ${seed}/flake.nix || { echo "FAIL: flake.nix missing"; exit 1; }
            test -f ${seed}/.gitignore || { echo "FAIL: .gitignore missing"; exit 1; }
            test -f ${seed}/.github/workflows/ci.yml || { echo "FAIL: ci.yml missing"; exit 1; }
            test -f ${seed}/README.md || { echo "FAIL: README.md missing"; exit 1; }
            test -f ${seed}/LICENSE || { echo "FAIL: LICENSE missing"; exit 1; }
            grep -q '__OWNER__/__REPO__' ${seed}/README.md || { echo "FAIL: README placeholders missing"; exit 1; }
            grep -q '__YEAR__ __HOLDER__' ${seed}/LICENSE || { echo "FAIL: LICENSE placeholders missing"; exit 1; }
            test ! -f ${seed}/.github/workflows/auto-update.yml || { echo "FAIL: obsolete auto-update.yml present"; exit 1; }
            # Verify .gitignore ignores materialized artifacts
            grep -q "lefthook.yml" ${seed}/.gitignore || { echo "FAIL: .gitignore should ignore lefthook.yml"; exit 1; }
            grep -q ".markdownlint.yml" ${seed}/.gitignore || { echo "FAIL: .gitignore should ignore .markdownlint.yml"; exit 1; }
            grep -q ".yamllint.yml" ${seed}/.gitignore || { echo "FAIL: .gitignore should ignore .yamllint.yml"; exit 1; }
            # Verify leaf CI uses reusable guardrails workflow
            grep -q "guardrails.yml@main" ${seed}/.github/workflows/ci.yml || { echo "FAIL: CI should use guardrails.yml"; exit 1; }
            # T62/#69: seed CI must NOT skip lefthook
            if grep -qE 'skip-lefthook:\s*"?true"?' ${seed}/.github/workflows/ci.yml; then
              echo "FAIL: seed ci.yml has skip-lefthook: true (#69/T62)"; exit 1
            fi
            # Verify leaf flake references set-and-setting
            grep -q "set-and-setting" ${seed}/flake.nix || { echo "FAIL: flake.nix should reference set-and-setting"; exit 1; }
            grep -q "checksFor" ${seed}/flake.nix || { echo "FAIL: flake.nix should use checksFor"; exit 1; }
            grep -q "assemble-lefthook.sh" ${seed}/flake.nix || { echo "FAIL: flake.nix should assemble lefthook.yml at runtime"; exit 1; }
            echo "PASS: seed layout verified"
            touch $out
          '';

        # --- apps.migrate: vendored->referenced transform (#96) ---
        # Fixture repos for each state; all share migrateFixtureEnv.
        migrate-vendored =
          let
            # Pre-FLIP style: every guardrail inline as a lefthook command.
            # Names are all covered by the referenced check-set (pinned checks
            # nixfmt/statix/shellcheck/gitleaks + materialized markdownlint/
            # yamllint), so the equivalence gate passes.
            vendoredLefthook = pkgs.writeText "vendored-lefthook.yml" ''
              ---
              pre-commit:
                commands:
                  nixfmt:
                    run: nixfmt --check {staged_files}
                  statix:
                    run: statix check
                  shellcheck:
                    run: shellcheck {staged_files}
                  gitleaks:
                    run: gitleaks protect
                  markdownlint:
                    run: markdownlint {staged_files}
                  yamllint:
                    run: yamllint {staged_files}
            '';
            fixture = pkgs.runCommand "migrate-vendored-fixture" { } ''
              mkdir -p $out/.github/workflows
              printf '%s\n' '{ outputs = { self }: { }; } # heavy vendored flake' > $out/flake.nix
              printf '%s\n' 'inline ci steps' > $out/.github/workflows/ci.yml
              echo "# demo" > $out/README.md
              cp ${vendoredLefthook} $out/lefthook.yml
            '';
          in
          pkgs.runCommand "migrate-vendored" (migrateFixtureEnv pkgs) ''
            cp -r ${fixture} workdir
            chmod -R u+w workdir
            cd workdir
            git init -q
            git add .
            git commit -q -m "initial" --allow-empty

            out1="$(bash "$MIGRATE_SCRIPT")"
            echo "$out1"
            echo "$out1" | grep -q 'state=vendored' || { echo "FAIL: not vendored"; exit 1; }
            echo "$out1" | grep -q 'PASS: equivalence' || { echo "FAIL: no equivalence"; exit 1; }

            # vendored flake replaced by the referenced (thin) seed flake
            grep -q 'set-and-setting' flake.nix || { echo "FAIL: flake not referenced"; exit 1; }
            grep -q 'checksFor' flake.nix || { echo "FAIL: flake missing checksFor"; exit 1; }
            grep -q 'guardrails.yml' .github/workflows/ci.yml || { echo "FAIL: ci not caller"; exit 1; }
            grep -qxF 'lefthook.yml' .gitignore || { echo "FAIL: lefthook not gitignored"; exit 1; }

            # #143: fragments customized to match detected content (README.md -> markdown)
            grep -q '"markdown"' flake.nix || { echo "FAIL: fragments missing markdown"; exit 1; }

            flake_hash="$(sha256sum flake.nix | cut -d' ' -f1)"

            # idempotent: a migrated repo re-migrates to a no-op, no changes
            git add -A
            git commit -q -m "migrated" --allow-empty
            out2="$(bash "$MIGRATE_SCRIPT")"
            echo "$out2"
            echo "$out2" | grep -q 'state=referenced' || { echo "FAIL: 2nd not referenced"; exit 1; }
            echo "$out2" | grep -q 'no-op' || { echo "FAIL: 2nd not no-op"; exit 1; }
            flake_hash2="$(sha256sum flake.nix | cut -d' ' -f1)"
            [ "$flake_hash" = "$flake_hash2" ] || { echo "FAIL: not idempotent"; exit 1; }

            echo "PASS: migrate vendored -> referenced, idempotent"
            touch $out
          '';

        migrate-already-referenced =
          pkgs.runCommand "migrate-already-referenced" (migrateFixtureEnv pkgs)
            ''
              # an already-referenced repo == the seed layout
              # -L: dereference the seed's store symlinks into real, writable
              # files so `chmod -R u+w` and `git add` work in the sandbox.
              cp -rL ${migrateSeedFor pkgs} workdir
              chmod -R u+w workdir
              cd workdir
              git init -q
              git add .
              git commit -q -m "initial" --allow-empty
              before="$(sha256sum flake.nix | cut -d' ' -f1)"
              result="$(bash "$MIGRATE_SCRIPT")"
              echo "$result"
              echo "$result" | grep -q 'state=referenced' || { echo "FAIL: not referenced"; exit 1; }
              echo "$result" | grep -q 'no-op' || { echo "FAIL: should be no-op"; exit 1; }
              after="$(sha256sum flake.nix | cut -d' ' -f1)"
              [ "$before" = "$after" ] || { echo "FAIL: no-op mutated flake.nix"; exit 1; }
              echo "PASS: already-referenced is a no-op"
              touch $out
            '';

        migrate-bare = pkgs.runCommand "migrate-bare" (migrateFixtureEnv pkgs) ''
          mkdir workdir && cd workdir
          echo "# bare repo" > README.md
          git init -q
          git add .
          git commit -q -m "initial" --allow-empty
          result="$(bash "$MIGRATE_SCRIPT")"
          echo "$result"
          echo "$result" | grep -q 'state=bare' || { echo "FAIL: not bare"; exit 1; }
          echo "$result" | grep -q 'PASS: equivalence' || { echo "FAIL: no equivalence"; exit 1; }
          grep -q 'set-and-setting' flake.nix || { echo "FAIL: seed not planted"; exit 1; }
          echo "PASS: migrate bare -> referenced"
          touch $out
        '';

        migrate-partial =
          let
            # a leftover vendored lefthook (covered checks) still tracked
            partialLefthook = pkgs.writeText "partial-lefthook.yml" ''
              ---
              pre-commit:
                commands:
                  nixfmt:
                    run: nixfmt --check {staged_files}
                  markdownlint:
                    run: markdownlint {staged_files}
            '';
          in
          pkgs.runCommand "migrate-partial" (migrateFixtureEnv pkgs) ''
            # partial-tracked-lefthook: references set-and-setting BUT still tracks lefthook.yml
            # -L: dereference the seed's store symlinks into real, writable files.
            cp -rL ${migrateSeedFor pkgs} workdir
            chmod -R u+w workdir
            cd workdir
            cp ${partialLefthook} lefthook.yml
            git init -q
            git add -f lefthook.yml
            git add .
            git commit -q -m "initial" --allow-empty
            result="$(bash "$MIGRATE_SCRIPT")"
            echo "$result"
            echo "$result" | grep -q 'state=partial' || { echo "FAIL: not partial"; exit 1; }
            echo "$result" | grep -q 'covers all 2 vendored checks' || { echo "FAIL: wrong count"; exit 1; }
            echo "$result" | grep -q 'PASS: equivalence' || { echo "FAIL: no equivalence"; exit 1; }
            # lefthook.yml no longer tracked after the transform
            git ls-files | grep -qxF 'lefthook.yml' && { echo "FAIL: lefthook still tracked"; exit 1; }
            echo "PASS: migrate partial -> referenced"
            touch $out
          '';

        migrate-rejects-dropped-check =
          let
            # A vendored lefthook with a standard-fragment check
            # (shellcheck) that the reduced universe does NOT cover.
            # Repo-local checks get carried through (#126), so we must
            # test with a standard-fragment check to exercise rejection.
            vendoredLefthook = pkgs.writeText "vendored-lefthook.yml" ''
              ---
              pre-commit:
                commands:
                  nixfmt:
                    run: nixfmt --check {staged_files}
                  shellcheck:
                    run: shellcheck {staged_files}
            '';
            # Exclude the shell fragment so shellcheck is genuinely
            # uncovered -- carry-through classifies it as standard (not
            # repo-local), so it stays dropped and triggers rejection.
            reducedFragments = [
              "base"
              "nix"
              "ascii"
              "markdown"
              "yaml"
              "set"
            ];
            reducedChecksUniverse = builtins.attrNames (
              self.lib.checksFor {
                inherit pkgs;
                src = ./.;
                fragments = reducedFragments;
              }
            );
            reducedLefthookFiles =
              (self.lib.materializationFor {
                inherit pkgs;
                fragments = reducedFragments;
              }).files;
          in
          pkgs.runCommand "migrate-rejects-dropped-check"
            (
              (migrateFixtureEnv pkgs)
              // {
                CHECKS_UNIVERSE = builtins.concatStringsSep " " reducedChecksUniverse;
                FULL_LEFTHOOK = "${reducedLefthookFiles}/lefthook.yml";
              }
            )
            ''
              mkdir -p workdir && cd workdir
              echo "{ outputs = { self }: { }; }" > flake.nix
              cp ${vendoredLefthook} lefthook.yml
              git init -q
              git add .
              git commit -q -m "initial" --allow-empty
              if bash "$MIGRATE_SCRIPT"; then
                echo "FAIL: migrate should reject a dropped-check transform"
                exit 1
              fi
              echo "PASS: migrate refuses to drop a vendored check"
              touch $out
            '';

        # --- apps.migrate: custom flake reconciliation (#127) ---
        migrate-custom-inputs =
          let
            vendoredLefthook = pkgs.writeText "vendored-lefthook.yml" ''
              ---
              pre-commit:
                commands:
                  nixfmt:
                    run: nixfmt --check {staged_files}
                  shellcheck:
                    run: shellcheck {staged_files}
            '';
            customFlake = pkgs.writeText "custom-flake.nix" ''
              {
                inputs.nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
                inputs.nixpkgs.follows = "nixpkgs-lock/nixpkgs";
                inputs.my-overlay.url = "github:example/overlay";
                inputs.my-overlay.inputs.nixpkgs.follows = "nixpkgs";
                outputs = { self, nixpkgs, my-overlay, ... }: { };
              }
            '';
          in
          pkgs.runCommand "migrate-custom-inputs" (migrateFixtureEnv pkgs) ''
            mkdir -p workdir && cd workdir
            cp ${customFlake} flake.nix
            cp ${vendoredLefthook} lefthook.yml
            git init -q
            git add .
            git commit -q -m "initial" --allow-empty
            result="$(bash "$MIGRATE_SCRIPT")"
            echo "$result"
            echo "$result" | grep -q 'reconcil' || { echo "FAIL: not reconciled"; exit 1; }
            echo "$result" | grep -q 'PASS: equivalence' || { echo "FAIL: no equivalence"; exit 1; }
            grep -q 'my-overlay.url' flake.nix || { echo "FAIL: custom input lost"; exit 1; }
            grep -q 'my-overlay,' flake.nix || { echo "FAIL: custom input not in args"; exit 1; }
            grep -q 'set-and-setting' flake.nix || { echo "FAIL: no set-and-setting"; exit 1; }
            grep -q 'checksFor' flake.nix || { echo "FAIL: no checksFor"; exit 1; }
            echo "PASS: migrate custom-inputs -> reconciled"
            touch $out
          '';

        migrate-unreconcilable =
          let
            vendoredLefthook = pkgs.writeText "vendored-lefthook.yml" ''
              ---
              pre-commit:
                commands:
                  nixfmt:
                    run: nixfmt --check {staged_files}
            '';
            unreconcilableFlake = pkgs.writeText "unreconcilable-flake.nix" ''
              {
                inputs.my-overlay.url = "github:example/overlay";
                outputs = { self, nixpkgs, my-overlay, ... }:
                let
                  pkgs = import nixpkgs {
                    system = "x86_64-linux";
                    overlays = [ my-overlay.overlays.default ];
                  };
                in { packages.x86_64-linux.default = pkgs.hello; };
              }
            '';
          in
          pkgs.runCommand "migrate-unreconcilable" (migrateFixtureEnv pkgs) ''
            mkdir -p workdir && cd workdir
            cp ${unreconcilableFlake} flake.nix
            cp ${vendoredLefthook} lefthook.yml
            git init -q
            git add .
            git commit -q -m "initial" --allow-empty
            if bash "$MIGRATE_SCRIPT"; then
              echo "FAIL: migrate should refuse an un-reconcilable flake"
              exit 1
            fi
            echo "PASS: migrate refuses un-reconcilable flake"
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

          # Pinned checks in the referenced effective check-set.
          checksUniverse = builtins.attrNames (
            self.lib.checksFor {
              inherit pkgs;
              src = ./.;
              fragments = [
                "base"
                "nix"
                "shell"
                "ascii"
                "markdown"
                "yaml"
                "set"
              ];
            }
          );

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
              export EMIT_PRINCIPLES_SCRIPT="${./set/lib/emit-principles.sh}"
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
              export COVERAGE_SCRIPT="${./lib/check-coverage.sh}"
              export CHECKS_UNIVERSE="${lib.concatStringsSep " " checksUniverse}"
              export CHECK_FRAGMENT_MAP="${checkFragmentMapStr}"
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

          confirmApp = pkgs.writeShellApplication {
            name = "confirm";
            # Include the lefthook wrappers so confirm.sh's coherence check
            # (every `lefthook-*` referenced in lefthook.yml is on PATH) can
            # resolve them -- this repo's fragments reference lefthook-
            # markdownlint / -yamllint, which are otherwise absent under
            # `nix run .#confirm` (fresh PATH, not inside `nix develop`).
            runtimeInputs = [
              pkgs.coreutils
              pkgs.diffutils
              pkgs.findutils
              pkgs.gawk
              pkgs.git
              pkgs.gnugrep
            ]
            ++ lefthookWrappersFor pkgs;
            text = ''
              export FRAGMENTS_DIR="${./setting/integrations/lefthook}"
              export ASSEMBLE_SCRIPT="${./setting/lib/assemble-lefthook.sh}"
              export DETECT_SCRIPT="${./setting/lib/detect-fragments.sh}"
              export SETTING_SRC="${mkSettingFull.configFiles}"
              export CONFIRM_SCRIPT="${./lib/confirm.sh}"
              export CONFIRM_REV="${self.rev or self.dirtyRev or "unknown"}"
            ''
            + builtins.readFile ./lib/app-confirm.sh;
          };

          migrateApp = pkgs.writeShellApplication {
            name = "migrate";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.diffutils
              pkgs.findutils
              pkgs.gawk
              pkgs.git
              pkgs.gnugrep
            ];
            text = ''
              export SEED_SRC="${self.lib.mkSeed { inherit pkgs; }}"
              export SETTING_SRC="${mkSettingFull.configFiles}"
              export FRAGMENTS_DIR="${./setting/integrations/lefthook}"
              export ASSEMBLE_SCRIPT="${./setting/lib/assemble-lefthook.sh}"
              export DETECT_SCRIPT="${./setting/lib/detect-fragments.sh}"
              export CONFIRM_SCRIPT="${./lib/confirm.sh}"
              export CONFIRM_REV="${self.rev or self.dirtyRev or "unknown"}"
              export MIGRATE_SCRIPT="${./lib/migrate.sh}"
              export CHECKS_UNIVERSE="${lib.concatStringsSep " " checksUniverse}"
              export CHECK_FRAGMENT_MAP="${checkFragmentMapStr}"
              export FRAGMENT_TRIGGERS="${fragmentTriggersStr}"
              export FULL_LEFTHOOK="${
                (self.lib.materializationFor {
                  inherit pkgs;
                  fragments = [
                    "base"
                    "nix"
                    "shell"
                    "ascii"
                    "markdown"
                    "yaml"
                    "set"
                  ];
                }).files
              }/lefthook.yml"
            ''
            + builtins.readFile ./lib/app-migrate.sh;
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
          graduate = {
            type = "app";
            program = "${graduateApp}/bin/graduate";
          };
          "branch-protection" = {
            type = "app";
            program = "${branchProtectionApp}/bin/branch-protection";
          };
          confirm = {
            type = "app";
            program = "${confirmApp}/bin/confirm";
          };
          migrate = {
            type = "app";
            program = "${migrateApp}/bin/migrate";
          };
          seed = {
            type = "app";
            program = "${
              pkgs.writeShellApplication {
                name = "seed";
                runtimeInputs = [
                  pkgs.coreutils
                  pkgs.findutils
                  pkgs.git
                  pkgs.gnused
                ];
                text = ''
                  export SEED_SRC="${self.lib.mkSeed { inherit pkgs; }}"
                ''
                + builtins.readFile ./lib/app-seed.sh;
              }
            }/bin/seed";
          };
        }
      );

      templates.leaf = {
        description = "Thin leaf consumer repo with reusable CI guardrails";
        path = ./templates/leaf;
      };
    };
}
