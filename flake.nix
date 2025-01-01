{
  description = "Home Manager configuration";

  inputs = {
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-24.11"; # Update-worthy.
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11"; # Update-worthy.
  };

  outputs = {
    home-manager,
    nixpkgs-unstable,
    nixpkgs,
    ...
  }: let
    customization = import ./customization.nix;
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        (final: prev: {
          unstable = nixpkgs-unstable.legacyPackages.${prev.system};
        })
      ];
    };

    system = "x86_64-linux";
  in {
    homeConfigurations."${customization.identity.username}" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [./home.nix];
    };
  };
}
