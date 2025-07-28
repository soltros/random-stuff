{
  description = "Wrapper flake for nixpkgs with allowUnfree = true";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { nixpkgs, ... }:
    {
      legacyPackages.x86_64-linux = import nixpkgs {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
        };
      };
      legacyPackages.aarch64-linux = import nixpkgs {
        system = "aarch64-linux";
        config = {
          allowUnfree = true;
        };
      };
    };
}
