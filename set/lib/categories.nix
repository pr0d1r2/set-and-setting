# categories.nix -- shared category metadata for mkSet and apps.
# Single source of truth for the category list, core selection (V27),
# and conditional-load globs map (V20). Imported by mk-set.nix and
# the apps section of flake.nix.
{
  all = [
    "generic"
    "adage"
    "architecture"
    "ci"
    "cli"
    "design"
    "git"
    "gnu"
    "integration"
    "just"
    "language"
    "lefthook"
    "nix"
    "nixos"
    "opensource"
    "principles"
    "product"
    "security"
    "test"
    "update"
  ];

  core = [
    "generic"
    "git"
  ];

  globs = {
    # Domain: narrow
    nix = [
      "**/*.nix"
      "flake.lock"
    ];
    nixos = [ "**/*.nix" ];
    gnu = [
      "**/*.sh"
      "**/*.bats"
    ];
    test = [ "**/*.bats" ];
    lefthook = [ "lefthook.yml" ];
    just = [
      "**/justfile"
      "**/*.just"
    ];
    cli = [ "**/justfile" ];
    ci = [
      ".github/**/*.yml"
      ".github/**/*.yaml"
    ];
    # Core/universal: broad (V20)
    adage = [ "**/*" ];
    design = [ "**/*" ];
    generic = [ "**/*" ];
    integration = [ "**/*" ];
    architecture = [ "**/*" ];
    git = [ "**/*" ];
    language = [
      "**/*"
      "**/.narrow-language-*.dic"
    ];
    opensource = [ "**/*" ];
    principles = [ "**/*" ];
    product = [ "**/*" ];
    security = [ "**/*" ];
    update = [ "**/*" ];
    "drafts/philosophy" = [ "**/*" ];
  };
}
