{
  pkgs,
  basePackages,
  agenticPackages ? [ ],
  defaultShellHook ? "",
  agenticShellHook ? "",
  settingHook ? "",
}:

let
  # settingHook materializes the gitignored configs (content-aware
  # lefthook.yml, .markdownlint.yml, .yamllint.yml) BEFORE `lefthook
  # install` -- otherwise lefthook finds no config and writes a default
  # example lefthook.yml (which then fails the confirmator's fidelity
  # check). Runs in BOTH shells (default + agentic) so either entry
  # materializes. Unconditional so stale remote caches are refreshed
  # (#280).
  baseShellHook = ''
    ${settingHook}
    lefthook install
  '';
  defaultShell = pkgs.mkShell {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    packages = basePackages;
    shellHook = baseShellHook + defaultShellHook;
  };
in
{
  default = defaultShell;
  agentic = pkgs.mkShell {
    inputsFrom = [ defaultShell ];
    NIX_CONFIG = "experimental-features = nix-command flakes";
    packages = agenticPackages;
    shellHook = baseShellHook + agenticShellHook;
  };
  ruby = pkgs.mkShell {
    inputsFrom = [ defaultShell ];
    NIX_CONFIG = "experimental-features = nix-command flakes";
    packages = [
      pkgs.ruby
      pkgs.bundler
    ];
    shellHook = baseShellHook + defaultShellHook;
  };
}
