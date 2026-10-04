{
  description = "Set-and-setting skill-set library";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs =
    { nixpkgs, ... }:
    {
      lib.mkSet = import ./lib/mk-set.nix { inherit (nixpkgs) lib; };
    };
}
