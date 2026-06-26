{ pkgs, modulesPath, inputs, ... }:

{
  imports = [
    # 1. Base channel profile required to construct a bootable graphical Plasma 6 ISO
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"

    # 2. Re-use your exact declarative repository modules
    "${inputs.self}/modules/core-system.nix"   # Sets Chicago timezone, locales, garbage collection, and experimental flakes flags
    "${inputs.self}/modules/core-user.nix"     # Sets up your administrative user session 'jchambers'
    "${inputs.self}/modules/core-zsh.nix"      # Loads your Zsh shell config, autocomplete rules, and safe interactive aliases
    "${inputs.self}/modules/core-fonts.nix"    # Provisions your system workspace typography
    "${inputs.self}/modules/core-cachix.nix"   # Connects nix-community binary cache hubs to accelerate local builds
    "${inputs.self}/modules/core-hw-utils.nix" # Full diagnostic array (lspci, lsusb, nvme-cli, nwipe, parted, gptfdisk)
    "${inputs.self}/modules/dev-git.nix"       # Provisions git configured with your author name and email info
    "${inputs.self}/modules/dev-neovim.nix"    # Binds nvim with full compiler toolchains (gcc, gnumake, unzip)
    "${inputs.self}/modules/sops-tools.nix"    # Places 'sops' and 'age' utilities in the shell PATH for manual decryption
    "${inputs.self}/modules/de-plasma.nix"     # Spins up your precise declarative Plasma 6 workspace panels & task manager
  ];

  # Override global profile state to enforce strict open-source software standards
  nixpkgs.config.allowUnfree = false;

  # Additional interactive utilities unique to this full graphical rescue desktop environment
  environment.systemPackages = with pkgs; [
    kate            # Full editor suite for modifying live configurations or scripts
    remmina         # Remote desktop client to access school district machines or hypervisors
    cifs-utils      # Windows SMB/CIFS filesystem support for reaching shared network nodes
    nfs-utils       # Network File System support
  ];

  # --- Automated 308-Storage Mount point definition ---
  # Allows immediate access to file repositories straight from the recovery medium
  fileSystems."/mnt/308-storage" = {
    device = "//your-storage-server-ip/share-name"; # Replace with your actual target production IP and share namespace
    fsType = "cifs";
    options = let
      # Keeps the live ISO from stalling at boot if the network connection or target network share isn't reachable
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [ "${automount_opts},guest,uid=1000,gid=100" ];
  };

  # Append your remote authentication vector to the live session user config
  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6xT65eiBe41ztk2UZ5/nSdcdYI/eRhRjfXoAdduxA jchambers-codeberg"
  ];
}
