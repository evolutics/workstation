{
  description = "Home Manager configuration";

  inputs = {
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-26.05"; # Update-worthy.
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05"; # Update-worthy.
  };

  outputs = {
    home-manager,
    nixpkgs,
    ...
  }: let
    customization = import ./customization.nix;
    pkgs = nixpkgs.legacyPackages.${system};

    system = "x86_64-linux";
  in {
    homeConfigurations."${customization.identity.username}" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [./home.nix];
    };
  };
}
