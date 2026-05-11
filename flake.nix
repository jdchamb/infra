{
  description = "Main flake for desktop workstation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, ... }@inputs: {

    nixosConfigurations."308-221357" = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/308-221357/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # This passes 'inputs' (like nix-flatpak) into home.nix
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.jchambers = import ./modules/home/home.nix;
        }
      ];
    };

    nixosConfigurations."308-222222" = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/308-222222/configuration.nix ];
    };
  };
}
