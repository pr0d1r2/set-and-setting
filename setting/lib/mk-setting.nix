{ lib }:

{
  pkgs,
  editorconfig ? true,
  gitattributes ? true,
  gitignore ? [
    "nix"
    "claude"
    "setting"
  ],
  markdownlint ? true,
  yamllint ? true,
  fileSizeLimits ? true,
  flakeManifest ? true,
  narrowLanguageDics ? [
    "nix"
    "shell"
    "markdown"
    "other"
  ],
  nixEmbeddedShellAllowlist ? true,
  readme ? true,
  license ? "MIT",
}:

let
  std = ../standards;
  inherit (builtins) readFile;

  gitignoreText = lib.concatMapStrings (f: readFile "${std}/gitignore/${f}.gitignore") gitignore;

  materializedFiles =
    lib.optional markdownlint (
      pkgs.writeTextDir ".markdownlint.yml" (readFile "${std}/markdownlint.yml")
    )
    ++ lib.optional yamllint (pkgs.writeTextDir ".yamllint.yml" (readFile "${std}/yamllint.yml"));

  materializedBundle = pkgs.symlinkJoin {
    name = "agent-setting-materialized";
    paths = materializedFiles;
  };

  seedFiles =
    lib.optional editorconfig (pkgs.writeTextDir ".editorconfig" (readFile "${std}/editorconfig"))
    ++ lib.optional gitattributes (pkgs.writeTextDir ".gitattributes" (readFile "${std}/gitattributes"))
    ++ lib.optional (gitignore != [ ]) (pkgs.writeTextDir ".gitignore" gitignoreText)
    ++ lib.optional fileSizeLimits (
      pkgs.writeTextDir "config/lefthook/file_size_limits.yml" (
        readFile "${std}/lefthook/file_size_limits.yml"
      )
    )
    ++ lib.optional flakeManifest (
      pkgs.writeTextDir "config/lefthook/flake_manifest.yml" (
        readFile "${std}/lefthook/flake_manifest.yml"
      )
    )
    ++ map (lang: pkgs.writeTextDir ".narrow-language-${lang}.dic" "") narrowLanguageDics
    ++ lib.optional nixEmbeddedShellAllowlist (pkgs.writeTextDir ".nix-embedded-shell-allowlist" "")
    ++ lib.optional readme (pkgs.writeTextDir "README.md" (readFile ../scaffold/README.md))
    ++ lib.optional (license == "MIT") (pkgs.writeTextDir "LICENSE" (readFile ../scaffold/LICENSE));

  seedBundle = pkgs.symlinkJoin {
    name = "agent-setting-seed";
    paths = seedFiles;
  };

  sync-setting = pkgs.writeShellApplication {
    name = "sync-setting";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
    ];
    text = ''
      src=${materializedBundle}
    ''
    + readFile ./sync-setting.sh;
  };

  sync-setting-init = pkgs.writeShellApplication {
    name = "sync-setting-init";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.findutils
    ];
    text = ''
      src=${seedBundle}
    ''
    + readFile ./sync-setting-init.sh;
  };
in
assert lib.assertOneOf "mkSetting license" license [
  "MIT"
  null
];
pkgs.symlinkJoin {
  name = "agent-setting";
  paths = [
    materializedBundle
    seedBundle
    sync-setting
    sync-setting-init
  ];
  passthru = {
    materialized = pkgs.symlinkJoin {
      name = "agent-setting-pkg";
      paths = [
        materializedBundle
        sync-setting
      ];
    };
    configFiles = materializedBundle;
    seed = seedBundle;
    mkDevShells = import ./mk-dev-shells.nix;
  };
}
