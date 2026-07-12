# Consumer-side post-materialization acceptance check (#94). Verifies that a
# materialized repo's lefthook.yml + configs are complete, faithful to the
# pinned standard rev, coherent (tools on PATH), idempotent, and drift-free.
# Shell logic in ./confirm.sh (nix/modularity: no embedded shell).
{
  pkgs,
  projectRoot,
  settingConfigFiles,
  fragmentsDir,
  assembleScript,
  detectScript,
  confirmScript,
  confirmRev,
  wrapperPackages ? [ ],
}:

pkgs.runCommand "confirm"
  {
    nativeBuildInputs = [
      pkgs.diffutils
      pkgs.gnugrep
      pkgs.git
      pkgs.coreutils
      pkgs.gawk
    ]
    ++ wrapperPackages;
    FRAGMENTS_DIR = fragmentsDir;
    ASSEMBLE_SCRIPT = assembleScript;
    DETECT_SCRIPT = detectScript;
    SETTING_SRC = settingConfigFiles;
    CONFIRM_SCRIPT = confirmScript;
    CONFIRM_REV = confirmRev;
  }
  ''
    cp -r ${projectRoot} workdir
    chmod -R u+w workdir
    cd workdir
    git init -q
    git add .
    bash "$CONFIRM_SCRIPT"
    touch $out
  ''
