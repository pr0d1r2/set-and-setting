# Build the consumer-facing `apps.confirm` entry from the standard's pinned
# implementation. Consumers only supply their materialized setting package and
# the materialization whose wrapper packages match their declared fragments.
{
  pkgs,
  standard,
  setting,
  materialization,
  confirmRev,
}:

let
  cfm = import ./check-fragment-map.nix;
  confirm = pkgs.writeShellApplication {
    name = "confirm";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.diffutils
      pkgs.findutils
      pkgs.gawk
      pkgs.git
      pkgs.gnugrep
    ]
    ++ materialization.packages;
    runtimeEnv = {
      FRAGMENTS_DIR = "${standard}/setting/integrations/lefthook";
      ASSEMBLE_SCRIPT = "${standard}/setting/lib/assemble-lefthook.sh";
      DETECT_SCRIPT = "${standard}/setting/lib/detect-fragments.sh";
      SETTING_SRC = "${setting}";
      CONFIRM_SCRIPT = "${standard}/lib/confirm.sh";
      CONFIRM_REV = confirmRev;
      REQUIRED_STATUS_CONTEXTS = builtins.concatStringsSep "|" cfm.requiredStatusContexts;
    };
    text = builtins.readFile ./app-confirm.sh;
  };
in
{
  type = "app";
  program = "${confirm}/bin/confirm";
}
