# ==============================================================================
# FLEET ORCHESTRATOR & SYSTEM BLUEPRINT: flake.nix
# ==============================================================================
#
# PURPOSE & PHILOSOPHY:
#   This flake serves as the single source of truth for the entire multi-OS
#   infrastructure fleet. It defines, manages, and orchestrates configurations
#   across:
#     - NixOS Bare-Metal Workstations (x86_64-linux: 308-222242)
#     - NixOS Apple Silicon Virtual Machines (aarch64-linux: 308-225660NixOSVM)
#     - Apple Silicon MacBooks (aarch64-darwin: 308-225660 via nix-darwin)
#     - Bare-Metal Provisioning & Recovery Live Media (bootstrap-iso, recovery-iso)
#
# HANDOVER / SUCCESSION RUNBOOK:
#   To rebuild or switch the configuration on ANY host, simply run:
#     rebuild
#   (or explicitly: sudo nixos-rebuild switch --flake ~/src/infra#<hostname>
#    or on macOS:   sudo darwin-rebuild switch --flake ~/src/infra#<hostname>)
#
# ARCHITECTURAL CONVENTIONS:
#   1. System-level concerns (kernel, launchd/systemd, disk layouts, hardware)
#      live in ./hosts/<os>/<hostname>/ and ./modules/<os>/.
#   2. User-level concerns (shell, git, editor config, terminal) are managed
#      uniformly across all operating systems via Home Manager (./home/).
#   3. Secrets are encrypted with Age / SOPS and stored in ./secrets/.
# ==============================================================================

{
  description = "Declarative Multi-OS Fleet Infrastructure (NixOS, nix-darwin, Home Manager)";

  # ----------------------------------------------------------------------------
  # FLAKE INPUTS: External Dependencies & Modules
  # ----------------------------------------------------------------------------
  inputs = {
    # Nixpkgs: The upstream rolling package and NixOS module repository
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # nix-darwin: Declarative macOS system configuration engine
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager: Declarative user environment and dotfile manager (cross-platform)
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Disko: Declarative disk partitioning and filesystem formatting layout for NixOS
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # SOPS-Nix: Atomic, in-memory secret decryption at boot using Age keys
    sops-nix.url = "github:mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # nix-homebrew: Declarative management of Homebrew taps, brews, and casks on macOS
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # nix-flatpak: Declarative Flatpak application deployment for Linux desktops
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  # ----------------------------------------------------------------------------
  # FLAKE OUTPUTS: Host Generators & System Profiles
  # ----------------------------------------------------------------------------
  outputs = { self, nixpkgs, darwin, home-manager, nix-homebrew, ... }@inputs:
  let
    # --------------------------------------------------------------------------
    # HELPER: mkNixos
    # Standard generator for all Linux/NixOS nodes.
    # Automatically binds Home Manager to the primary user ('jchambers')
    # and passes all flake inputs down as 'specialArgs'.
    # --------------------------------------------------------------------------
    mkNixos = { system, modules }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = modules ++ [
        home-manager.nixosModules.home-manager
        {
          # Integrate user packages directly into system-level package tracking
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          # Create timestamped .backup files if an existing dotfile conflicts
          home-manager.backupFileExtension = "backup";
          home-manager.users.jchambers = import ./home;
        }
      ];
    };

    # --------------------------------------------------------------------------
    # HELPER: mkDarwin
    # Standard generator for all Apple Silicon macOS nodes running nix-darwin.
    # Pairs Home Manager with nix-homebrew for declarative Cask/Brew integration.
    # --------------------------------------------------------------------------
    mkDarwin = { system, modules }: darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = modules ++ [
        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew
        {
          # Mirror global package registry for consistency
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.backupFileExtension = "backup";
          home-manager.users.jchambers = import ./home;

          # Declarative Homebrew Management via nix-homebrew
          nix-homebrew = {
            enable = true;
            enableRosetta = true; # Allow running x86_64 Homebrew formulae via Rosetta 2
            user = "jchambers";
            autoMigrate = true;   # Migrate unmanaged brew installations into declarative control
          };
        }
      ];
    };
  in
  {
    # ==========================================================================
    # NIXOS HOST CONFIGURATIONS
    # ==========================================================================
    nixosConfigurations = {
      # ------------------------------------------------------------------------
      # NODE 1: 308-222242
      # Primary Bare-Metal Production Workstation (x86_64-linux)
      # Daily driver workstation running desktop environment, storage mounts,
      # and development services.
      # ------------------------------------------------------------------------
      "308-222242" = mkNixos {
        system = "x86_64-linux";
        modules = [ ./hosts/nixos/308-222242 ];
      };

      # ------------------------------------------------------------------------
      # NODE 2: bootstrap-iso
      # Minimal Bare-Metal Provisioning Live Media (x86_64-linux)
      # Used to boot bare metal hardware, partition with Disko, and bootstrap
      # new fleet nodes over SSH without a graphical desktop.
      # ------------------------------------------------------------------------
      "bootstrap-iso" = mkNixos {
        system = "x86_64-linux";
        modules = [ ./hosts/nixos/installer/bootstrap-iso.nix ];
      };

      # ------------------------------------------------------------------------
      # NODE 3: recovery-iso
      # Full-Featured Fleet Recovery Graphical Live Media (x86_64-linux)
      # Bootable live USB environment equipped with graphical partitioning tools,
      # disk repair utilities, and emergency diagnostics.
      # ------------------------------------------------------------------------
      "recovery-iso" = mkNixos {
        system = "x86_64-linux";
        modules = [ ./hosts/nixos/installer/recovery-iso.nix ];
      };

      # ------------------------------------------------------------------------
      # NODE 4: 308-225660NixOSVM
      # Apple Silicon UTM / VZ Paravirtualized Virtual Machine (aarch64-linux)
      # Fast, lightweight Linux sandbox running locally on the MacBook with
      # VirtIO block storage, QEMU guest agent, and SSH access.
      # ------------------------------------------------------------------------
      "308-225660NixOSVM" = mkNixos {
        system = "aarch64-linux";
        modules = [
          inputs.disko.nixosModules.disko
          ./hosts/nixos/308-225660NixOSVM
        ];
      };

      # ------------------------------------------------------------------------
      # NODES 5–9: lab-pb01 .. lab-pb05 (Personal Project 11)
      # 5-Node HP ProBook Physical Validation Lab Cluster (x86_64-linux)
      # ------------------------------------------------------------------------
      "lab-pb01" = mkNixos {
        system = "x86_64-linux";
        modules = [
          inputs.disko.nixosModules.disko
          (import ./hosts/nixos/lab-probook { hostName = "lab-pb01"; })
        ];
      };
      "lab-pb02" = mkNixos {
        system = "x86_64-linux";
        modules = [
          inputs.disko.nixosModules.disko
          (import ./hosts/nixos/lab-probook { hostName = "lab-pb02"; })
        ];
      };
      "lab-pb03" = mkNixos {
        system = "x86_64-linux";
        modules = [
          inputs.disko.nixosModules.disko
          (import ./hosts/nixos/lab-probook { hostName = "lab-pb03"; })
        ];
      };
      "lab-pb04" = mkNixos {
        system = "x86_64-linux";
        modules = [
          inputs.disko.nixosModules.disko
          (import ./hosts/nixos/lab-probook { hostName = "lab-pb04"; })
        ];
      };
      "lab-pb05" = mkNixos {
        system = "x86_64-linux";
        modules = [
          inputs.disko.nixosModules.disko
          (import ./hosts/nixos/lab-probook { hostName = "lab-pb05"; })
        ];
      };
    };

    # ==========================================================================
    # NIX-DARWIN HOST CONFIGURATIONS (macOS)
    # ==========================================================================
    darwinConfigurations = {
      # ------------------------------------------------------------------------
      # NODE 5: 308-225660
      # Primary Work Apple Silicon MacBook (aarch64-darwin)
      # Native macOS 27 environment with system defaults, declarative Homebrew,
      # and native Apple Virtualization.framework Linux builder.
      # ------------------------------------------------------------------------
      "308-225660" = mkDarwin {
        system = "aarch64-darwin";
        modules = [ ./hosts/darwin/308-225660 ];
      };
    };
  };
}
