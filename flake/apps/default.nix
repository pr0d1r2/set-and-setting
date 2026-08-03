{
  self,
  nixpkgs,
  nix-lefthook,
  pkgs,
  checkFragmentMapStr,
  fragmentTriggersStr,
  migrateSeedFor,
  lefthookWrappersFor,
}:
let
  inherit (nixpkgs) lib;
  cats = import ../../set/lib/categories.nix;
  agents = import ../../set/lib/agents.nix;
  meta = import ../../set/meta.nix { inherit lib; };
  renames = import ../../set/renames.nix { inherit lib; };
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
  mkSettingFull = import ../../setting/lib/mk-setting.nix { inherit lib; } { inherit pkgs; };

  # Pinned checks in the referenced effective check-set.
  checksUniverse = builtins.attrNames (
    self.lib.checksFor {
      inherit pkgs;
      src = ../../.;
      fragments = [
        "base"
        "nix"
        "shell"
        "ruby"
        "rubocop"
        "rspec"
        "reek"
        "brakeman"
        "bundle-audit"
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
      export SKILLS_DIR="${../../set/skills}"
      export CONCEPTS_DIR="${../../set/concepts}"
      export MK_SET_SCRIPT="${../../set/lib/mk-set.sh}"
      export EMIT_SCRIPT="${../../set/lib/emit-skill.sh}"
      export EMIT_PRINCIPLES_SCRIPT="${../../set/lib/emit-principles.sh}"
      export EMIT_RULE_SCRIPT="${../../set/lib/emit-rule.sh}"
      export EMIT_SKILLMD_SCRIPT="${../../set/lib/emit-skillmd.sh}"
      export APPLICABILITY_SCRIPT="${../../set/lib/applicability.sh}"
      export AUTO_KEEP_SCRIPT="${../../set/lib/app-auto-keep.sh}"
      export SYNC_SCRIPT="${../../set/lib/sync-set.sh}"
      export RESOLVE_AGENT_SCRIPT="${../../set/lib/resolve-agent.sh}"
      export ALL_CATEGORIES="${lib.concatStringsSep " " cats.all}"
      export CORE_CATEGORIES="${lib.concatStringsSep " " cats.core}"
      export GLOBS_MAP="${globsMap}"
      export CHANNEL_OVERRIDES=${lib.escapeShellArg meta.channelOverrides}
      export SIGNALS_MANIFEST=${lib.escapeShellArg meta.signals}
      export AGENT_SEAMS="${agentSeams}"
      export KEYWORDS_MAP="${keywordsMap}"
      export COMPILER_SCRIPT="${../../lib/agents-md-compile.sh}"
      export RENAME_PROPAGATE_SCRIPT="${../../set/lib/rename-propagate.sh}"
      export RENAMES_MAP=${lib.escapeShellArg renames.serialized}
      export MKSET_REV="${self.rev or self.dirtyRev or "unknown"}"
    ''
    + builtins.readFile ../../set/lib/app-mk-set.sh;
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
      export FRAGMENTS_DIR="${../../setting/integrations/lefthook}"
      export ASSEMBLE_SCRIPT="${../../setting/lib/assemble-lefthook.sh}"
      export DETECT_SCRIPT="${../../setting/lib/detect-fragments.sh}"
      export COVERAGE_SCRIPT="${../../lib/check-coverage.sh}"
      export CHECKS_UNIVERSE="${lib.concatStringsSep " " checksUniverse}"
      export CHECK_FRAGMENT_MAP="${checkFragmentMapStr}"
    ''
    + builtins.readFile ../../setting/lib/app-mk-setting.sh;
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
    + builtins.readFile ../../setting/lib/app-mk-setting-init.sh;
  };

  mkScaffoldBundles = import ../../setting/lib/mk-scaffold.nix { inherit pkgs; };
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
      export SCAFFOLD_SRC="${mkScaffoldBundles.default}"
      export RUBY_SCAFFOLD_SRC="${mkScaffoldBundles.ruby}"
      export FRAGMENTS_DIR="${../../setting/integrations/lefthook}"
      export ASSEMBLE_SCRIPT="${../../setting/lib/assemble-lefthook.sh}"
      export DETECT_SCRIPT="${../../setting/lib/detect-fragments.sh}"
    ''
    + builtins.readFile ../../setting/lib/app-mk-scaffold.sh;
  };

  bootstrapApp = pkgs.writeShellApplication {
    name = "bootstrap";
    text = ''
      export MKSET_APP="${mkSetApp}/bin/mkSet"
      export MKSETTING_APP="${mkSettingApp}/bin/mkSetting"
      export MKSETTING_INIT_APP="${mkSettingInitApp}/bin/mkSetting-init"
      export MKSCAFFOLD_APP="${mkScaffoldApp}/bin/mkScaffold"
    ''
    + builtins.readFile ../../set/lib/app-bootstrap.sh;
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
    + builtins.readFile ../../lib/graduate-draft.sh;
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
    text = builtins.readFile ../../lib/branch-protection.sh;
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
      export FRAGMENTS_DIR="${../../setting/integrations/lefthook}"
      export ASSEMBLE_SCRIPT="${../../setting/lib/assemble-lefthook.sh}"
      export DETECT_SCRIPT="${../../setting/lib/detect-fragments.sh}"
      export SETTING_SRC="${mkSettingFull.configFiles}"
      export CONFIRM_SCRIPT="${../../lib/confirm.sh}"
      export CONFIRM_REV="${self.rev or self.dirtyRev or "unknown"}"
    ''
    + builtins.readFile ../../lib/app-confirm.sh;
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
      export SEED_SRC="${migrateSeedFor pkgs}"
      export SETTING_SRC="${mkSettingFull.configFiles}"
      export FRAGMENTS_DIR="${../../setting/integrations/lefthook}"
      export ASSEMBLE_SCRIPT="${../../setting/lib/assemble-lefthook.sh}"
      export DETECT_SCRIPT="${../../setting/lib/detect-fragments.sh}"
      export CONFIRM_SCRIPT="${../../lib/confirm.sh}"
      export CONFIRM_REV="${self.rev or self.dirtyRev or "unknown"}"
      export MIGRATE_SCRIPT="${../../lib/migrate.sh}"
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
            "ruby"
            "rubocop"
            "rspec"
            "reek"
            "brakeman"
            "bundle-audit"
            "ascii"
            "markdown"
            "yaml"
            "set"
          ];
        }).files
      }/lefthook.yml"
    ''
    + builtins.readFile ../../lib/app-migrate.sh;
  };

  mkCanonApp = pkgs.writeShellApplication {
    name = "mkCanon";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.git
      pkgs.gnused
      nix-lefthook.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    text = ''
      export SEED_SRC="${migrateSeedFor pkgs}"
      export CANON_APP_NAME="mkCanon"
      export CANON_APP_LABEL="canon"
      export CANON_INSTALL_HOOKS=1
    ''
    + builtins.readFile ../../lib/app-seed.sh;
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
  mkCanon = {
    type = "app";
    program = "${mkCanonApp}/bin/mkCanon";
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
        + builtins.readFile ../../lib/app-seed.sh;
      }
    }/bin/seed";
  };
}
