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
  allFragments = fragments ++ extraFragments;
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
    in
    (extraChecks pkgs) // standardChecks
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
