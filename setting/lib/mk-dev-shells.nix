{
  pkgs,
  basePackages,
  agenticPackages ? [ ],
  defaultShellHook ? "",
  agenticShellHook ? "",
}:

let
  baseShellHook = ''
    [ -f .git/hooks/pre-commit ] || lefthook install
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
}
