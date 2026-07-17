# ==============================================================================
# ROLE: System Infrastructure Orchestrator / Glue Layer
# WHAT GOES HERE AND WHY:
#   This file functions as the entry point for your entire deployment. It tracks
#   upstream channels (nixpkgs, home-manager) and defines the hosts.
#   We hoist the Home Manager framework engine registration *here* globally across
#   all profiles. This ensures that every node—whether it is a full desktop,
#   a heavy graphical recovery ISO, or a headless minimal bootstrap live media—
#   instantly understands 'home-manager.users.jchambers' options without relying
#   on specific desktop environment modules to do it down the chain.
# ==============================================================================

{
  description = "Declarative Infrastructure Flake - Shorthand Fleet Architecture";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    sops-nix.url = "github:mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {

    nixosConfigurations = {

      # --- 1. Main Production Workstation Node ---
      "wrk-dt01" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          "${self}/hosts/wrk-dt01.nix"

          # Global Home Manager Engine Injection
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            # Standard, platform-agnostic baseline user workspace
            home-manager.users.jchambers = import "${self}/modules/core-home-manager.nix";
          }
        ];
      };

      # --- 2. Minimal Provisioning Bootstrap Live Media ---
      "bootstrap-iso" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          "${self}/hosts/iso-bootstrap.nix"

          # Hoisted Home Manager Engine (Provides shell tool configuration even without Plasma)
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.jchambers = import "${self}/modules/core-home-manager.nix";
          }
        ];
      };

      # --- 3. Heavy Fleet Recovery Graphical Live Media ---
      "recovery-iso" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          "${self}/hosts/iso-recovery.nix"

          # Hoisted Home Manager Engine
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.jchambers = import "${self}/modules/core-home-manager.nix";
          }
        ];
      };

    };
  };
}
