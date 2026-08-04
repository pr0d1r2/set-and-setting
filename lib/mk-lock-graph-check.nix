{
  pkgs,
  projectRoot,
}:

pkgs.runCommand "lock-graph-check"
  {
    FLAKE_LOCK = "${projectRoot}/flake.lock";
    nativeBuildInputs = [ pkgs.jq ];
  }
  ''
    bash ${./lock-graph-check.sh}
    touch $out
  ''
