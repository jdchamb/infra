{ pkgs, modulesPath, inputs, ... }:

{
  imports = [
    # 1. Base channel profile required to construct a bootable graphical Plasma 6 ISO environment
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"

    # 2. Shared Base Platform Configurations
    "${inputs.self}/modules/core-system.nix"   # Sets Chicago timezone, locales, and experimental flags
    "${inputs.self}/modules/core-network.nix"  # Mandates your core connection protocols & NetworkManager backend
    "${inputs.self}/modules/core-user.nix"     # Configures your administrative user profile ('jchambers')
    "${inputs.self}/modules/core-zsh.nix"      # Loads your Zsh shell environment with safe interactive removal aliases
    "${inputs.self}/modules/core-fonts.nix"    # Provisions your customized system workspace typography definitions
    "${inputs.self}/modules/core-cachix.nix"   # Connects trusted upstream caching channels to speed up recovery compilations
    "${inputs.self}/modules/core-hw-utils.nix" # Delivers your hardware diagnostic suite (pciutils, nvme-cli, nwipe, storage layouts)

    # 3. Graphical Interface & Dedicated Application Layers
    "${inputs.self}/modules/de-plasma.nix"     # Pins your declarative Plasma 6 panels and hardware performance monitor sensors
    "${inputs.self}/modules/app-remmina.nix"   # Pulls in Remmina for RDP/VNC remote access to school district fleet systems

    # 4. Development & Secret Inspection Toolkits
    "${inputs.self}/modules/dev-git.nix"       # Deploys Git globally mapped to your author identity metrics
    "${inputs.self}/modules/dev-neovim.nix"    # Binds Neovim with foundational compiler chains for immediate terminal debugging
    "${inputs.self}/modules/sops-tools.nix"    # Places 'sops' and 'age' binaries on path without launching background daemons
  ];

  # Override global profile states to enforce strict open-source package parameters on live rescue media
  nixpkgs.config.allowUnfree = false;


  # Embed your public key into the temporary 'nixos' install session user account for headless ssh validation
  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6xT65eiBe41ztk2UZ5/nSdcdYI/eRhRjfXoAdduxA jchambers-codeberg"
  ];

  # --- Automated 308-Storage Mount point definition ---
  # Allows immediate access to file repositories straight from the boot session
  fileSystems."/mnt/308-storage" = {
    device = "//your-storage-server-ip/share-name"; # Replace with your target network share namespace
    fsType = "cifs";
    options = let
      # Ensures the recovery system boots instantly even if disconnected from the school district internal network
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [ "${automount_opts},guest,uid=1000,gid=100" ];
  };

  # --- PROJECT 20: Automated Git Repo Cloning Service ---
  systemd.services.clone-infra-repo = {
    description = "Auto-clone configuration repository on startup";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "nixos";
      RemainAfterExit = true;
    };

    script = ''
      sleep 5
      TARGET_DIR="/home/nixos/src/infra"
      if [ ! -d "$TARGET_DIR" ]; then
        mkdir -p "/home/nixos/src"
        # Firmly anchored to your personal FLOSS Codeberg repository instance
        ${pkgs.git}/bin/git clone https://codeberg.org/jchambers-codeberg/infra.git "$TARGET_DIR" || true
      fi
    '';
  };
  # --- Home Manager User Space Binding ---
  # This cleanly isolates your user-space dotfiles, stateVersion, and zsh settings
  # inside the home-manager evaluator scope where they belong!
  home-manager.users.jchambers = import "${inputs.self}/modules/core-home-manager.nix";
}
