{
  self,
  nixpkgs,
  pkgs,
}:

let
  consumer = self.lib.mkConsumerFlake {
    inherit self nixpkgs;
    set-and-setting = self;
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
    includeSet = true;
  };
  inherit (pkgs.stdenv.hostPlatform) system;
  names = output: builtins.attrNames output.${system};
  packageNames = names consumer.packages;
  checkNames = names consumer.checks;
  appNames = names consumer.apps;
  agenticShellHook = consumer.devShells.${system}.agentic.shellHook;
in
pkgs.runCommand "mkConsumerFlake-outputs" { } ''
  ${
    assert
      builtins.attrNames consumer == [
        "apps"
        "checks"
        "devShells"
        "packages"
      ];
    assert builtins.all (name: builtins.elem name packageNames) [
      "fixture"
      "set"
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
    assert pkgs.lib.hasInfix "/bin/sync-set ." agenticShellHook;
    ""
  }
  touch $out
''
