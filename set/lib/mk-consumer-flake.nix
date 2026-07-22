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
  extraFragments ? [ ],
  extraPackages ? (_pkgs: { }),
  extraChecks ? (_pkgs: { }),
  extraApps ? (_pkgs: { }),
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
    // {
      setting = (set-and-setting.lib.mkSetting { inherit pkgs; }).materialized;
    }
  );

  devShells = forAllSystems (
    pkgs:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
      materialization = set-and-setting.lib.materializationFor {
        inherit pkgs;
        fragments = allFragments;
      };
    in
    set-and-setting.lib.mkDevShells {
      inherit pkgs;
      basePackages = materialization.packages;
      settingHook = ''
        ${self.packages.${system}.setting}/bin/sync-setting .
        _setting_lefthook_out="$(mktemp -d)"
        FRAGMENTS="${builtins.concatStringsSep " " allFragments}" \
          out="$_setting_lefthook_out" \
          FRAGMENTS_DIR="${set-and-setting}/setting/integrations/lefthook" \
          bash "${set-and-setting}/setting/lib/assemble-lefthook.sh"
        cp -f "$_setting_lefthook_out/lefthook.yml" lefthook.yml
        rm -rf "$_setting_lefthook_out"
      '';
    }
  );

  checks = forAllSystems (
    pkgs:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
      standardChecks =
        (set-and-setting.lib.checksFor {
          inherit pkgs src;
          fragments = allFragments;
        })
        // {
          dep-graph = set-and-setting.lib.mkDepGraphCheck {
            inherit pkgs;
            projectRoot = src;
          };
          setting-drift = set-and-setting.lib.mkSettingDriftCheck {
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
    (extraApps pkgs)
    // {
      confirm = {
        type = "app";
        program = "${
          pkgs.writeShellApplication {
            name = "confirm";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.diffutils
              pkgs.findutils
              pkgs.gawk
              pkgs.git
              pkgs.gnugrep
            ];
            text = ''
              export FRAGMENTS_DIR="${set-and-setting}/setting/integrations/lefthook"
              export ASSEMBLE_SCRIPT="${set-and-setting}/setting/lib/assemble-lefthook.sh"
              export DETECT_SCRIPT="${set-and-setting}/setting/lib/detect-fragments.sh"
              export SETTING_SRC="${self.packages.${pkgs.stdenv.hostPlatform.system}.setting}"
              export CONFIRM_SCRIPT="${set-and-setting}/lib/confirm.sh"
              export CONFIRM_REV="${set-and-setting.rev or "unknown"}"
              bash "$CONFIRM_SCRIPT"
            '';
          }
        }/bin/confirm";
      };
    }
  );
}
