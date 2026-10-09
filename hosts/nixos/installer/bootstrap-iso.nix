{ pkgs, modulesPath, inputs, ... }:

{
  imports = [
    # 1. Base channel profile required to construct a bootable minimal console ISO
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    # 2. Inherit common and core system configurations
    "${inputs.self}/modules/common/cachix.nix"
    "${inputs.self}/modules/common/sops-tools.nix"
    "${inputs.self}/modules/shared/git.nix"
    "${inputs.self}/modules/shared/neovim.nix"
    "${inputs.self}/modules/nixos/core/system.nix"
    "${inputs.self}/modules/nixos/core/network.nix"
    "${inputs.self}/modules/nixos/core/user.nix"
    "${inputs.self}/modules/nixos/hardware/hw-utils.nix"
  ];

  # Safely activate native NixOS Zsh without option conflicts so the shell environment initializes properly
  programs.zsh.enable = true;

  # Force strict open-source package parameters for the build environment
  nixpkgs.config.allowUnfree = false;

  # --- Remote Management Over Network ---
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes"; # Allows headless staging over SSH directly to root
  };

  # Embed your public key into both users for seamless headless management access
  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6xT65eiBe41ztk2UZ5/nSdcdYI/eRhRjfXoAdduxA jchambers-codeberg"
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6xT65eiBe41ztk2UZ5/nSdcdYI/eRhRjfXoAdduxA jchambers-codeberg"
  ];

  # --- Automated Git Repo Cloning Service ---
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
        ${pkgs.git}/bin/git clone https://codeberg.org/jchambers-codeberg/infra.git "$TARGET_DIR" || true
      fi
    '';
  };

  # Helper shorthand alias for manual intervention runs if needed
  environment.shellAliases = {
    bootstrap-fetch = "git clone https://codeberg.org/jchambers-codeberg/infra.git ~/src/infra";
  };

  # --- Image Construction Optimization ---
  isoImage.squashfsCompression = "zstd -Xcompression-level 1";
}
