{
  self,
  nixpkgs,
  pkgs,
}:

let
  # A consumer library override from before these helpers were exposed must
  # remain compatible with mkConsumerFlake.
  consumerLib =
    builtins.removeAttrs self.lib [
      "mkCoverageDriftCheck"
      "mkLockGraphCheck"
    ]
    // {
      materializationFor =
        args:
        let
          materialization = self.lib.materializationFor args;
        in
        materialization // { packages = materialization.packages ++ [ pkgs.hello ]; };
    };
  consumer = self.lib.mkConsumerFlake {
    inherit self nixpkgs;
    set-and-setting = self;
    lib = consumerLib;
    fragments = [ "base" ];
    extraFragments = [
      "shell"
      "actions"
    ];
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
  # Attribute NAMES prove only that a check was DECLARED.  `coverage-drift` was
  # present by name while its derivation threw on every consumer, so force each
  # check's drvPath here: an eval-time defect in any check now fails this check.
  checkDrvPaths = map (name: consumer.checks.${system}.${name}.drvPath) checkNames;
  agenticShellHook = consumer.devShells.${system}.agentic.shellHook;
  confirmProgram = consumer.apps.${system}.confirm.program;
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
      "lock-graph"
      "actionlint"
      "coverage-drift"
      "setting-drift"
      "shellcheck"
    ];
    assert builtins.all (path: builtins.isString path) checkDrvPaths;
    assert builtins.all (name: builtins.elem name appNames) [
      "bootstrap-hooks"
      "confirm"
      "fixture"
    ];
    assert pkgs.lib.hasInfix "/bin/sync-set ." agenticShellHook;
    assert pkgs.lib.hasInfix "lefthook install" consumer.devShells.${system}.default.shellHook;
    ""
  }
  ${confirmProgram} --help > confirm-help
  grep -q "Usage: confirm" confirm-help
  grep -q "Post-materialization acceptance suite" confirm-help
  grep -q '${pkgs.hello}/bin' ${confirmProgram}
  touch $out
''
