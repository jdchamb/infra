{ pkgs, modulesPath, inputs, ... }:

{
  imports = [
    # Full graphical base profile
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"

    # Mirroring your dt01 workstation foundation
    "${inputs.self}/modules/core-user.nix"
    "${inputs.self}/modules/core-fonts.nix"
    "${inputs.self}/modules/de-plasma.nix"
    "${inputs.self}/modules/dev-git.nix"

    # Pull in sops-nix expressions if declared system-wide
    inputs.sops-nix.nixosModules.sops
  ];

  nixpkgs.config.allowUnfree = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Recovery & diagnostics suite matching your dt01 environment layout
  environment.systemPackages = with pkgs; [
    kate
    remmina         # Remote management for school fleet or cluster nodes
    sops            # Direct secret management auditing
    age             # For local key validation
    pciutils
    usbutils
    smartmontools
    cifs-utils      # Necessary for mounting remote school storage nodes
    nfs-utils
  ];

  # SOPS Configuration: Ensure your recovery key is searched on live boot
  sops = {
    defaultSopsFile = "${inputs.self}/secrets/secrets.yaml"; # Adjust path to match your repo
    age.keyFile = "/var/lib/sops-nix/key.txt";               # Path to look for your decryption key
  };

  # 308-Storage Mount point definition
  fileSystems."/mnt/308-storage" = {
    device = "//your-storage-server-ip/share-name"; # Replace with your actual server destination
    fsType = "cifs";
    options = let
      # Keeps the ISO from freezing at boot if the network storage is unreachable
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [ "${automount_opts},guest,uid=1000,gid=100" ];
  };

  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6xT65eiBe41ztk2UZ5/nSdcdYI/eRhRjfXoAdduxA jchambers-codeberg"
  ];
}
