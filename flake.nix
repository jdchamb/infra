# ==============================================================================
# ROLE: System Infrastructure Orchestrator / Flake Entry Point
# Multi-OS fleet supporting NixOS, nix-darwin, and Windows declarative workflows
# ==============================================================================

{
  description = "Declarative Infrastructure Flake - Multi-OS Fleet Architecture";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = { self, nixpkgs, darwin, home-manager, nix-homebrew, ... }@inputs:
  let
    # Standard builder helper for NixOS configurations
    mkNixos = { system, modules }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = modules ++ [
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.backupFileExtension = "backup";
          home-manager.users.jchambers = import ./home;
        }
      ];
    };

    # Standard builder helper for macOS / Darwin configurations
    mkDarwin = { system, modules }: darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = modules ++ [
        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.backupFileExtension = "backup";
          home-manager.users.jchambers = import ./home;

          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "jchambers";
            autoMigrate = true;
          };
        }
      ];
    };
  in
  {
    nixosConfigurations = {
      # --- 1. Main Production Workstation Node ---
      "wrk-dt01" = mkNixos {
        system = "x86_64-linux";
        modules = [ ./hosts/nixos/wrk-dt01 ];
      };

      # --- 2. Minimal Provisioning Bootstrap Live Media ---
      "bootstrap-iso" = mkNixos {
        system = "x86_64-linux";
        modules = [ ./hosts/nixos/installer/bootstrap-iso.nix ];
      };

      # --- 3. Heavy Fleet Recovery Graphical Live Media ---
      "recovery-iso" = mkNixos {
        system = "x86_64-linux";
        modules = [ ./hosts/nixos/installer/recovery-iso.nix ];
      };

      # --- 4. UTM Apple Silicon Virtual Machine Node ---
      "vm-mac-utm01" = mkNixos {
        system = "aarch64-linux";
        modules = [
          inputs.disko.nixosModules.disko
          ./hosts/nixos/vm-mac-utm01
        ];
      };
    };

    darwinConfigurations = {
      # --- 5. Work Apple Silicon MacBook ---
      "308-225660" = mkDarwin {
        system = "aarch64-darwin";
        modules = [ ./hosts/darwin/308-225660 ];
      };
    };
  };
}
