{
  pkgs,
  projectRoot,
  allowMissingSetAndSetting ? true,
}:

pkgs.runCommand "lock-graph-check"
  {
    FLAKE_LOCK = "${projectRoot}/flake.lock";
    ALLOW_MISSING_SET_AND_SETTING = if allowMissingSetAndSetting then "1" else "0";
    nativeBuildInputs = [ pkgs.jq ];
  }
  ''
    bash ${./lock-graph-check.sh}
    touch $out
  ''
