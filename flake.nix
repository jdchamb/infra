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
          "${self}/hosts/wrk-dt01.nix"

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.jchambers = import "${self}/modules/core-home-manager.nix";
          }
        ];
      };

      # 2. Your Work Laptop Node
      "wrk-lt01" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          "${self}/hosts/wrk-lt01.nix"

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.jchambers = import "${self}/modules/core-home-manager.nix";
          }
        ];
      };

      # 3. Your Custom Bootstrap ISO Pipeline
      "bootstrap-iso" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          # CRITICAL: Pull down the official installer environment framework
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"

          # Inject your host configuration choice
          "${self}/hosts/custom-iso.nix"
        ];
      };

    };
  };
}
