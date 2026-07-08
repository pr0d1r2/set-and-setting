# Enforce per-file size limit on individual skill/draft markdown (T57).
# Single wc -c check. Independent of format or structure checks. Shell logic
# in ./skill-size-check.sh (nix/modularity). Args: pkgs, setRoot.
{
  pkgs,
  setRoot,
}:

pkgs.runCommand "set-skill-size-check"
  {
    nativeBuildInputs = [
      pkgs.findutils
      pkgs.coreutils
    ];
    SET_ROOT = setRoot;
  }
  ''
    bash ${./skill-size-check.sh}
    touch $out
  ''
