{
  description = "Home Manager configuration of ttake";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
  let
    system = "aarch64-darwin";
    pkgs = import nixpkgs { inherit system; };
  in
  {
    homeConfigurations = {
      mac-mini-m4-24 = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./hosts/mac-mini-m4-24.nix
        ];
      };

      mba-20-m1 = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./hosts/mba-20-m1.nix
        ];
      };
    };
  };
}
