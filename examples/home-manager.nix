# nix-home-manager-claude-code -- install set-and-setting skills
# globally via home-manager so every repo inherits them.
#
# Usage in your home-manager flake:
#
#   inputs.set-and-setting.url = "github:pr0d1r2/set-and-setting";
#
#   homeConfigurations."user" = home-manager.lib.homeManagerConfiguration {
#     extraSpecialArgs = { inherit inputs; };
#     modules = [ ./home.nix ];
#   };
#
# Then import this module (or inline the home.file entries below).
{ inputs, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) system;
  skillSet = inputs.set-and-setting.packages.${system}.set;
  settingPkg = inputs.set-and-setting.packages.${system}.setting;
in
{
  home.file = {
    ".claude/rules/set" = {
      source = "${skillSet}/.claude/rules/set";
      recursive = true;
    };

    ".claude/rules/set.md".source = "${skillSet}/.claude/rules/set.md";
  };

  home.activation.syncSetting = inputs.home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${settingPkg}/bin/sync-setting "$HOME"
  '';
}
