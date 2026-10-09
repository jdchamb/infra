{ pkgs, modulesPath, inputs, ... }:

{
  imports = [
    # 1. Base channel profile required to construct a bootable graphical Plasma 6 ISO environment
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"

    # 2. Shared Base Platform Configurations
    "${inputs.self}/modules/common/fonts.nix"
    "${inputs.self}/modules/common/cachix.nix"
    "${inputs.self}/modules/common/sops-tools.nix"
    "${inputs.self}/modules/shared/git.nix"
    "${inputs.self}/modules/shared/neovim.nix"
    "${inputs.self}/modules/nixos/core/system.nix"
    "${inputs.self}/modules/nixos/core/network.nix"
    "${inputs.self}/modules/nixos/core/user.nix"
    "${inputs.self}/modules/nixos/hardware/hw-utils.nix"
    "${inputs.self}/modules/nixos/apps/remmina.nix"
  ];

  # Override global profile states to enforce strict open-source package parameters on live rescue media
  nixpkgs.config.allowUnfree = false;

  # Embed your public key into the temporary 'nixos' install session user account for headless ssh validation
  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6xT65eiBe41ztk2UZ5/nSdcdYI/eRhRjfXoAdduxA jchambers-codeberg"
  ];

  # --- Automated 308-Storage Mount point definition ---
  fileSystems."/mnt/308-storage" = {
    device = "//cloud-storage.usd308.com/Resources/TSC";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [ "${automount_opts},guest,uid=1000,gid=100" ];
  };

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
}
