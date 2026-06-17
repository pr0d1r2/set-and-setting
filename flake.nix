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
          '';
        };
      });

      checks = forAllSystems (pkgs: {
        mkSet-generic = import ./set/lib/mk-set.nix { inherit (nixpkgs) lib; } {
          inherit pkgs;
          categories = [ "generic" ];
        };

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
            nixskill="${full}/.claude/skills/set/nix/SKILL.md"
            gen="${full}/.claude/rules/generic.md"
            cli="${full}/.claude/skills/set/cli/SKILL.md"

            # domain skill carries the conditional-load field + nix glob
            grep -q '^paths:' "$nixskill" || { echo "FAIL: nix missing paths"; exit 1; }
            grep -qF '"**/*.nix"' "$nixskill" || { echo "FAIL: nix glob"; exit 1; }

            # cross-cutting category is an always-on rule (no paths)
            if grep -q '^paths:' "$gen"; then echo "FAIL: generic has paths"; exit 1; fi

            # loose top-level cli.md folded into the cli skill
            grep -q 'justfile' "$cli" || { echo "FAIL: cli core not folded"; exit 1; }

            # agnostic body preserved verbatim (a known source line)
            grep -q 'Flake entrypoint should be direnv' "$gen" || { echo "FAIL: body"; exit 1; }

            # exclude omits the file from the emitted output
            if grep -qi 'Rust Token Killer' "${excluded}/.claude/rules/generic.md"; then
              echo "FAIL: exclude did not drop rtk.md"; exit 1
            fi

            # domain SKILL.md links facets instead of concatenating (V25)
            grep -q '\[Nix: flake\](flake.md)' "$nixskill" \
              || { echo "FAIL: nix SKILL.md missing facet link"; exit 1; }

            # facet files exist alongside SKILL.md (V25)
            [ -f "${full}/.claude/skills/set/nix/flake.md" ] \
              || { echo "FAIL: nix facet file missing"; exit 1; }

            # facets are raw -- no frontmatter (V25)
            if head -1 "${full}/.claude/skills/set/nix/flake.md" | grep -q '^---'; then
              echo "FAIL: facet has frontmatter"; exit 1
            fi

            # nested facets preserve path structure
            [ -f "${full}/.claude/skills/set/nix/infinity/gap.md" ] \
              || { echo "FAIL: nested facet missing"; exit 1; }

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

        default = pkgs.runCommand "set-and-setting-checks" { } ''
          touch $out
        '';
      });

      apps = forAllSystems (
        pkgs:
        let
          inherit (nixpkgs) lib;
          cats = import ./set/lib/categories.nix;
          globsMap = lib.concatStringsSep ";" (
            lib.mapAttrsToList (c: globs: "${c}=${lib.concatStringsSep "," globs}") cats.globs
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
              export SYNC_SCRIPT="${./set/lib/sync-set.sh}"
              export ALL_CATEGORIES="${lib.concatStringsSep " " cats.all}"
              export CORE_CATEGORIES="${lib.concatStringsSep " " cats.core}"
              export GLOBS_MAP="${globsMap}"
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

          bootstrapApp = pkgs.writeShellApplication {
            name = "bootstrap";
            text = ''
              export MKSET_APP="${mkSetApp}/bin/mkSet"
              export MKSETTING_APP="${mkSettingApp}/bin/mkSetting"
              export MKSETTING_INIT_APP="${mkSettingInitApp}/bin/mkSetting-init"
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
          bootstrap = {
            type = "app";
            program = "${bootstrapApp}/bin/bootstrap";
          };
        }
      );
    };
}
