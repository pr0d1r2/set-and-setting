{
  self,
  nixpkgs,
  pkgs,
}:

let
  consumer = self.lib.mkConsumerFlake {
    inherit self nixpkgs;
    set-and-setting = self;
    description = "consumer fixture";
    fragments = [ "base" ];
    extraFragments = [ "shell" ];
    src = ../.;
    extraPackages = _pkgs: { fixture = pkgs.hello; };
    extraChecks = _pkgs: { fixture = pkgs.hello; };
    extraApps = _pkgs: {
      fixture = {
        type = "app";
        program = "${pkgs.hello}/bin/hello";
      };
    };
  };
  inherit (pkgs.stdenv.hostPlatform) system;
  names = output: builtins.attrNames output.${system};
  packageNames = names consumer.packages;
  checkNames = names consumer.checks;
  appNames = names consumer.apps;
in
pkgs.runCommand "mkConsumerFlake-outputs" { } ''
  ${
    assert
      builtins.attrNames consumer == [
        "apps"
        "checks"
        "description"
        "devShells"
        "packages"
      ];
    assert builtins.all (name: builtins.elem name packageNames) [
      "fixture"
      "setting"
    ];
    assert builtins.all (name: builtins.elem name checkNames) [
      "default"
      "dep-graph"
      "fixture"
      "setting-drift"
      "shellcheck"
    ];
    assert builtins.all (name: builtins.elem name appNames) [
      "confirm"
      "fixture"
    ];
    ""
  }
  touch $out
''
