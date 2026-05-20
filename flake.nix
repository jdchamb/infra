{
  description = "Declarative Infrastructure Flake - Shorthand Fleet Architecture";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = { self, nixpkgs, home-manager, nix-flatpak, ... }@inputs: {

    nixosConfigurations = {

      # 1. Your Work Station Desktop Node
      "wrk-dt01" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          # Target your newly flattened, clean host definition
          ./hosts/wrk-dt01.nix

          # Wire up home-manager cleanly at the system entry point
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            # Points instantly to your new prefix-sorted home manager configuration
            home-manager.users.jchambers = import ./modules/core-home-manager.nix;
          }
        ];
      };

      # 2. Your Work Laptop Node
      "wrk-lt01" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          # Target your newly flattened laptop configuration
          ./hosts/wrk-lt01.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.jchambers = import ./modules/core-home-manager.nix;
          }
        ];
      };

    };
  };
}
