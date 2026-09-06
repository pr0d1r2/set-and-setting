# Compose the standard outputs for a referenced set-and-setting consumer.
{
  supportedSystems,
}:

{
  self,
  nixpkgs,
  set-and-setting,
  fragments,
  src,
  lib ? set-and-setting.lib,
  extraFragments ? [ ],
  extraPackages ? (_pkgs: { }),
  extraChecks ? (_pkgs: { }),
  extraApps ? (_pkgs: { }),
  includeSet ? false,
  fileClassOverrides ? { },
}:

let
  # A fragment a repository FORGOT to declare (B92/B94). `guardrails.yml`
  # decides to run a suite from what git TRACKS, and `confirm` checks the
  # materialized config against `detect-fragments.sh`, which reads the same
  # thing -- so a repository with specs and no `bats` in its list gets a
  # workflow calling a runner its shell lacks, and a fidelity failure for the
  # config it did materialize. Both are the same omission.
  #
  # THE DETECTOR IS THE AUTHORITY, including for ORDER. Its output sequence is
  # the order it appends in, so that order is READ OUT OF IT here rather than
  # restated: a second copy is what made the first cut of this emit a config
  # `confirm` then rejected (B94). `src` is the flake source, so these walks
  # see what git tracks.
  detectorLines = nixpkgs.lib.splitString "\n" (
    builtins.readFile "${set-and-setting}/setting/lib/detect-fragments.sh"
  );
  detectorOrder = [
    "base"
  ]
  ++ builtins.filter (f: f != null) (
    map (
      line:
      let
        m = builtins.match ''.*result="\$result ([a-z-]+)".*'' line;
      in
      if m == null then null else builtins.head m
    ) detectorLines
  );

  workflowsDir = src + "/.github/workflows";
  hasWorkflows =
    builtins.pathExists workflowsDir
    && builtins.any (n: nixpkgs.lib.hasSuffix ".yml" n || nixpkgs.lib.hasSuffix ".yaml" n) (
      builtins.attrNames (builtins.readDir workflowsDir)
    );

  hasBats =
    dir:
    let
      entries = builtins.readDir dir;
      names = builtins.attrNames entries;
      isSpec = n: entries.${n} == "regular" && nixpkgs.lib.hasSuffix ".bats" n;
      subdirs = builtins.filter (n: entries.${n} == "directory" && n != ".git" && n != "result") names;
    in
    builtins.any isSpec names || builtins.any (n: hasBats (dir + "/${n}")) subdirs;

  declaredFragments = fragments ++ extraFragments;
  srcExists = builtins.pathExists src;
  autoFragments =
    nixpkgs.lib.optional (srcExists && hasWorkflows) "actions"
    ++ nixpkgs.lib.optional (srcExists && hasBats src) "bats";
  wantedFragments = nixpkgs.lib.unique (declaredFragments ++ autoFragments);

  # Canonical first, then anything the detector does not know about, so a
  # consumer's own extra fragment is never silently dropped.
  allFragments =
    builtins.filter (f: builtins.elem f wantedFragments) detectorOrder
    ++ builtins.filter (f: !(builtins.elem f detectorOrder)) wantedFragments;
  forAllSystems =
    f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
in
{
  packages = forAllSystems (
    pkgs:
    (extraPackages pkgs)
    // nixpkgs.lib.optionalAttrs includeSet {
      set = lib.mkSet { inherit pkgs; };
    }
    // {
      setting = (lib.mkSetting { inherit pkgs; }).materialized;
    }
  );

  devShells = forAllSystems (
    pkgs:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
      materialization = lib.materializationFor {
        inherit pkgs fileClassOverrides;
        fragments = allFragments;
      };
    in
    lib.mkDevShells {
      inherit pkgs;
      basePackages = materialization.packages;
      settingHook =
        let
          migrations = import ../../setting/lib/migrations.nix;
          migrationSkips = builtins.concatStringsSep " " (builtins.concatMap (m: m.skip) migrations);
          hasMigrations = migrations != [ ];
        in
        ''
          ${self.packages.${system}.setting}/bin/sync-setting .
          _setting_lefthook_out="$(mktemp -d)"
          FRAGMENTS="${builtins.concatStringsSep " " allFragments}" \
            MIGRATION_SKIPS="${migrationSkips}" \
            MIGRATION_HAS_OVERLAY="${if hasMigrations then "1" else ""}" \
            out="$_setting_lefthook_out" \
            FRAGMENTS_DIR="${set-and-setting}/setting/integrations/lefthook" \
            bash "${set-and-setting}/setting/lib/assemble-lefthook.sh"
          cp -f "$_setting_lefthook_out/lefthook.yml" lefthook.yml
          ${
            if hasMigrations then
              ''
                MIGRATION_OVERLAY_DIR="${set-and-setting}/setting/integrations/lefthook/migrations" \
                  FRAGMENTS="${builtins.concatStringsSep " " allFragments}" \
                  out="$_setting_lefthook_out" \
                  bash "${set-and-setting}/setting/lib/assemble-migration-overlay.sh"
                cp -f "$_setting_lefthook_out/lefthook-migration.yml" lefthook-migration.yml
              ''
            else
              ""
          }
          rm -rf "$_setting_lefthook_out"
        '';
      agenticShellHook = nixpkgs.lib.optionalString includeSet ''
        ${self.packages.${system}.set}/bin/sync-set .
      '';
    }
  );

  checks = forAllSystems (
    pkgs:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
      standardChecks =
        (lib.checksFor {
          inherit pkgs src;
          fragments = allFragments;
        })
        // {
          dep-graph = lib.mkDepGraphCheck {
            inherit pkgs;
            projectRoot = src;
          };
          lock-graph = (lib.mkLockGraphCheck or set-and-setting.lib.mkLockGraphCheck) {
            inherit pkgs;
            projectRoot = src;
          };
          setting-drift = lib.mkSettingDriftCheck {
            inherit pkgs;
            settingSet = self.packages.${system}.setting;
            projectRoot = src;
            devShells = self.devShells.${system};
          };
          default = pkgs.runCommand "checks" { } "touch $out";
        };
      coverageMaterialization = lib.materializationFor {
        inherit pkgs fileClassOverrides;
        fragments = allFragments;
      };
      standardMaterialization = lib.materializationFor {
        inherit pkgs;
        fragments = allFragments;
      };
      coverageDrift = (lib.mkCoverageDriftCheck or set-and-setting.lib.mkCoverageDriftCheck) {
        inherit pkgs;
        fragments = allFragments;
        checks = lib.checksFor {
          inherit pkgs src;
          fragments = allFragments;
        };
        consumerChecks = (extraChecks pkgs) // standardChecks;
        materialization = coverageMaterialization;
        expectedMaterialization = standardMaterialization;
      };
    in
    (extraChecks pkgs) // standardChecks // { coverage-drift = coverageDrift; }
  );

  apps = forAllSystems (
    pkgs:
    let
      inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) setting;
      materialization = lib.materializationFor {
        inherit pkgs fileClassOverrides;
        fragments = allFragments;
      };
    in
    (extraApps pkgs)
    // {
      bootstrap-hooks = {
        type = "app";
        program = "${
          pkgs.writeShellApplication {
            name = "bootstrap-hooks";
            runtimeInputs = materialization.packages;
            text = ''
              ${setting}/bin/sync-setting .
              _setting_lefthook_out="$(mktemp -d)"
              trap 'rm -rf "$_setting_lefthook_out"' EXIT
              FRAGMENTS="${builtins.concatStringsSep " " allFragments}" \
                out="$_setting_lefthook_out" \
                FRAGMENTS_DIR="${set-and-setting}/setting/integrations/lefthook" \
                bash "${set-and-setting}/setting/lib/assemble-lefthook.sh"
              cp -f "$_setting_lefthook_out/lefthook.yml" lefthook.yml
              bash "${set-and-setting}/setting/lib/app-bootstrap-hooks.sh"
            '';
          }
        }/bin/bootstrap-hooks";
      };
      confirm = set-and-setting.lib.mkConfirmApp {
        inherit pkgs setting materialization;
        standard = set-and-setting;
        confirmRev = set-and-setting.rev or set-and-setting.dirtyRev or "unknown";
      };
    }
  );
}
