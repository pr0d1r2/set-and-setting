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
    text = ''
      export FRAGMENTS_DIR="${standard}/setting/integrations/lefthook"
      export ASSEMBLE_SCRIPT="${standard}/setting/lib/assemble-lefthook.sh"
      export DETECT_SCRIPT="${standard}/setting/lib/detect-fragments.sh"
      export SETTING_SRC="${setting}"
      export CONFIRM_SCRIPT="${standard}/lib/confirm.sh"
      export CONFIRM_REV="${confirmRev}"
    ''
    + builtins.readFile ./app-confirm.sh;
  };
in
{
  type = "app";
  program = "${confirm}/bin/confirm";
}
