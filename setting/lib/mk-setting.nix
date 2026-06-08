{ lib }:

{
  pkgs,
  editorconfig ? true,
  gitattributes ? true,
  gitignore ? [
    "nix"
    "claude"
  ],
  markdownlint ? true,
  yamllint ? true,
  fileSizeLimits ? true,
}:

let
  std = ../standards;
  inherit (builtins) readFile;

  # Composed .gitignore content -- pure string concat, no shell.
  gitignoreText = lib.concatMapStrings (f: readFile "${std}/gitignore/${f}.gitignore") gitignore;

  # Each output file is a single-file derivation, gated by its toggle. No
  # imperative copy steps, no shell-string splicing.
  files =
    lib.optional editorconfig (pkgs.writeTextDir ".editorconfig" (readFile "${std}/editorconfig"))
    ++ lib.optional gitattributes (pkgs.writeTextDir ".gitattributes" (readFile "${std}/gitattributes"))
    ++ lib.optional (gitignore != [ ]) (pkgs.writeTextDir ".gitignore" gitignoreText)
    ++ lib.optional markdownlint (
      pkgs.writeTextDir ".markdownlint.yml" (readFile "${std}/markdownlint.yml")
    )
    ++ lib.optional yamllint (pkgs.writeTextDir ".yamllint.yml" (readFile "${std}/yamllint.yml"))
    ++ lib.optional fileSizeLimits (
      pkgs.writeTextDir "config/lefthook/file_size_limits.yml" (
        readFile "${std}/lefthook/file_size_limits.yml"
      )
    );

  fileBundle = pkgs.symlinkJoin {
    name = "agent-setting-files";
    paths = files;
  };

  # The only shell -- a runtime copy script, extracted and shellcheck-clean.
  # $src is baked to the file bundle so it copies the canonical store content.
  sync-setting = pkgs.writeShellApplication {
    name = "sync-setting";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      src=${fileBundle}
    ''
    + readFile ./sync-setting.sh;
  };
in
pkgs.symlinkJoin {
  name = "agent-setting";
  paths = [
    fileBundle
    sync-setting
  ];
}
