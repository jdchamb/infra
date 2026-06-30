{ pkgs, modulesPath, inputs, ... }:

{
  imports = [
    # 1. Base channel profile required to construct a bootable minimal console ISO
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    # 2. Inherit your exact declarative core system configurations
    "${inputs.self}/modules/core-system.nix"   # Sets locales, auto-optimizations, and experimental flags
    "${inputs.self}/modules/core-network.nix"  # Connects connection protocols & NetworkManager backend
    "${inputs.self}/modules/core-user.nix"     # Configures your administrative user skeleton ('jchambers')
    "${inputs.self}/modules/core-cachix.nix"   # Configures trusted binary substitution pools to speed up builds
    "${inputs.self}/modules/core-hw-utils.nix" # Installs hardware diagnostics & disk partitioning layouts

    # 3. Development, Secrets, and Tooling Layers
    "${inputs.self}/modules/dev-git.nix"       # Adds git and global user metrics
    "${inputs.self}/modules/dev-neovim.nix"    # Deploys text editor configuration and building tools
    "${inputs.self}/modules/sops-tools.nix"    # Drops in raw age and sops binaries for runtime secret auditing
  ];

  # --- Bypassing Core Module Option Collision ---
  # Intercepts and blocks core-zsh.nix from polluting the native NixOS option tree
  # if it gets implicitly inherited down your module dependency chain.
  disabledModules = [ "${inputs.self}/modules/core-zsh.nix" ];

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
        ${pkgs.git}/bin/git clone https://codeberg.org/jchambers-codeberg/infra.git "$TARGET_DIR" || true
      fi
    '';
  };

  # Helper shorthand alias for manual intervention runs if needed
  environment.shellAliases = {
    bootstrap-fetch = "git clone https://codeberg.org/jchambers-codeberg/infra.git ~/src/infra";
  };

  # --- Image Construction Optimization ---
  # Forces zstd compression at level 1 to ensure lightning-fast compile iterations locally.
  isoImage.squashfsCompression = "zstd -Xcompression-level 1";
}
