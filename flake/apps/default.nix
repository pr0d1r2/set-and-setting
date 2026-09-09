{
  self,
  nixpkgs,
  pkgs,
  checkFragmentMapStr,
  fragmentTriggersStr,
  requiredStatusContextsStr,
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
  mkSettingInitSeed = pkgs.symlinkJoin {
    name = "mk-setting-init-seed";
    paths = [
      (migrateSeedFor pkgs)
      # Retain the setting-specific starters that predate canon composition.
      # Canon comes first so its README and LICENSE win path collisions.
      mkSettingFull.seed
    ];
  };

  # Pinned checks in the referenced effective check-set.
  checksUniverse = builtins.attrNames (
    self.lib.checksFor {
      inherit pkgs;
      src = ../../.;
      fragments = [
        "base"
        "actions"
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
    runtimeEnv = {
      SKILLS_DIR = "${../../set/skills}";
      CONCEPTS_DIR = "${../../set/concepts}";
      MK_SET_SCRIPT = "${../../set/lib/mk-set.sh}";
      EMIT_SCRIPT = "${../../set/lib/emit-skill.sh}";
      EMIT_PRINCIPLES_SCRIPT = "${../../set/lib/emit-principles.sh}";
      EMIT_RULE_SCRIPT = "${../../set/lib/emit-rule.sh}";
      EMIT_SKILLMD_SCRIPT = "${../../set/lib/emit-skillmd.sh}";
      APPLICABILITY_SCRIPT = "${../../set/lib/applicability.sh}";
      AUTO_KEEP_SCRIPT = "${../../set/lib/app-auto-keep.sh}";
      SYNC_SCRIPT = "${../../set/lib/sync-set.sh}";
      RESOLVE_AGENT_SCRIPT = "${../../set/lib/resolve-agent.sh}";
      ALL_CATEGORIES = "${lib.concatStringsSep " " cats.all}";
      CORE_CATEGORIES = "${lib.concatStringsSep " " cats.core}";
      GLOBS_MAP = "${globsMap}";
      CHANNEL_OVERRIDES = meta.channelOverrides;
      SIGNALS_MANIFEST = meta.signals;
      AGENT_SEAMS = "${agentSeams}";
      KEYWORDS_MAP = "${keywordsMap}";
      COMPILER_SCRIPT = "${../../lib/agents-md-compile.sh}";
      RENAME_PROPAGATE_SCRIPT = "${../../set/lib/rename-propagate.sh}";
      RENAMES_MAP = renames.serialized;
      MKSET_REV = "${self.rev or self.dirtyRev or "unknown"}";
    };
    text = builtins.readFile ../../set/lib/app-mk-set.sh;
  };

  migrations = import ../../setting/lib/migrations.nix;
  migrationSkips = lib.concatStringsSep " " (builtins.concatMap (m: m.skip) migrations);

  mkSettingApp = pkgs.writeShellApplication {
    name = "mkSetting";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.gawk
      pkgs.git
      pkgs.gnugrep
    ];
    runtimeEnv = {
      SETTING_SRC = "${mkSettingFull.configFiles}";
      FRAGMENTS_DIR = "${../../setting/integrations/lefthook}";
      ASSEMBLE_SCRIPT = "${../../setting/lib/assemble-lefthook.sh}";
      DETECT_SCRIPT = "${../../setting/lib/detect-fragments.sh}";
      COVERAGE_SCRIPT = "${../../lib/check-coverage.sh}";
      CHECKS_UNIVERSE = "${lib.concatStringsSep " " checksUniverse}";
      CHECK_FRAGMENT_MAP = "${checkFragmentMapStr}";
      MIGRATION_OVERLAY_DIR = "${../../setting/integrations/lefthook/migrations}";
      MIGRATION_OVERLAY_SCRIPT = "${../../setting/lib/assemble-migration-overlay.sh}";
      MIGRATION_SKIPS = "${migrationSkips}";
    };
    text = builtins.readFile ../../setting/lib/app-mk-setting.sh;
  };

  mkSettingInitApp = pkgs.writeShellApplication {
    name = "mkSetting-init";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
    ];
    runtimeEnv = {
      SEED_SRC = "${mkSettingInitSeed}";
    };
    text = builtins.readFile ../../setting/lib/app-mk-setting-init.sh;
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
    runtimeEnv = {
      SCAFFOLD_SRC = "${mkScaffoldBundles.default}";
      RUBY_SCAFFOLD_SRC = "${mkScaffoldBundles.ruby}";
      FRAGMENTS_DIR = "${../../setting/integrations/lefthook}";
      ASSEMBLE_SCRIPT = "${../../setting/lib/assemble-lefthook.sh}";
      DETECT_SCRIPT = "${../../setting/lib/detect-fragments.sh}";
    };
    text = builtins.readFile ../../setting/lib/app-mk-scaffold.sh;
  };

  bootstrapHooksApp = pkgs.writeShellApplication {
    name = "bootstrap-hooks";
    runtimeInputs = [
      pkgs.git
      pkgs.lefthook
    ];
    text = builtins.readFile ../../setting/lib/app-bootstrap-hooks.sh;
  };

  bootstrapApp = pkgs.writeShellApplication {
    name = "bootstrap";
    runtimeEnv = {
      MKSET_APP = "${mkSetApp}/bin/mkSet";
      MKSETTING_APP = "${mkSettingApp}/bin/mkSetting";
      MKSETTING_INIT_APP = "${mkSettingInitApp}/bin/mkSetting-init";
      MKSCAFFOLD_APP = "${mkScaffoldApp}/bin/mkScaffold";
      BOOTSTRAP_HOOKS_APP = "${bootstrapHooksApp}/bin/bootstrap-hooks";
    };
    text = builtins.readFile ../../set/lib/app-bootstrap.sh;
  };

  graduateApp = pkgs.writeShellApplication {
    name = "graduate";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.gnugrep
      pkgs.gnused
    ];
    runtimeEnv = {
      ALL_CATEGORIES = "${lib.concatStringsSep " " cats.all}";
    };
    text = builtins.readFile ../../lib/graduate-draft.sh;
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
    runtimeEnv = {
      REQUIRED_STATUS_CONTEXTS = "${requiredStatusContextsStr}";
    };
    text = builtins.readFile ../../lib/branch-protection.sh;
  };

  chainReadyApp = pkgs.writeShellApplication {
    name = "chain-ready";
    runtimeInputs = [
      pkgs.git
      pkgs.gh
      pkgs.jq
      pkgs.gnused
      pkgs.gnugrep
    ];
    text = builtins.readFile ../../lib/chain-ready.sh;
  };

  confirmApp = self.lib.mkConfirmApp {
    inherit pkgs;
    standard = ../..;
    setting = mkSettingFull.configFiles;
    materialization.packages = lefthookWrappersFor pkgs;
    confirmRev = self.rev or self.dirtyRev or "unknown";
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
    runtimeEnv = {
      SEED_SRC = "${migrateSeedFor pkgs}";
      SETTING_SRC = "${mkSettingFull.configFiles}";
      FRAGMENTS_DIR = "${../../setting/integrations/lefthook}";
      ASSEMBLE_SCRIPT = "${../../setting/lib/assemble-lefthook.sh}";
      DETECT_SCRIPT = "${../../setting/lib/detect-fragments.sh}";
      CONFIRM_SCRIPT = "${../../lib/confirm.sh}";
      CONFIRM_REV = "${self.rev or self.dirtyRev or "unknown"}";
      MIGRATE_SCRIPT = "${../../lib/migrate.sh}";
      CHECKS_UNIVERSE = "${lib.concatStringsSep " " checksUniverse}";
      CHECK_FRAGMENT_MAP = "${checkFragmentMapStr}";
      FRAGMENT_TRIGGERS = "${fragmentTriggersStr}";
      REQUIRED_STATUS_CONTEXTS = "${requiredStatusContextsStr}";
      FULL_LEFTHOOK = "${
        (self.lib.materializationFor {
          inherit pkgs;
          fragments = [
            "base"
            "actions"
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
      }/lefthook.yml";
    };
    text = builtins.readFile ../../lib/app-migrate.sh;
  };

  mkCanonApp = pkgs.writeShellApplication {
    name = "mkCanon";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
      pkgs.git
      pkgs.gnused
      pkgs.lefthook
    ];
    runtimeEnv = {
      SEED_SRC = "${migrateSeedFor pkgs}";
      CANON_APP_NAME = "mkCanon";
      CANON_APP_LABEL = "canon";
      CANON_INSTALL_HOOKS = 1;
    };
    text = builtins.readFile ../../lib/app-seed.sh;
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
  "bootstrap-hooks" = {
    type = "app";
    program = "${bootstrapHooksApp}/bin/bootstrap-hooks";
  };
  graduate = {
    type = "app";
    program = "${graduateApp}/bin/graduate";
  };
  "branch-protection" = {
    type = "app";
    program = "${branchProtectionApp}/bin/branch-protection";
  };
  "chain-ready" = {
    type = "app";
    program = "${chainReadyApp}/bin/chain-ready";
  };
  confirm = {
    inherit (confirmApp) type program;
  };
  migrate = {
    type = "app";
    program = "${migrateApp}/bin/migrate";
  };
  seed = {
    type = "app";
    # Deliberately thin: repair tooling needs the three pinned infrastructure
    # files without backfilling repo-owned canon documents.
    program = "${
      pkgs.writeShellApplication {
        name = "seed";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.findutils
          pkgs.git
          pkgs.gnused
        ];
        runtimeEnv = {
          SEED_SRC = "${self.lib.mkSeed { inherit pkgs; }}";
        };
        text = builtins.readFile ../../lib/app-seed.sh;
      }
    }/bin/seed";
  };
}
