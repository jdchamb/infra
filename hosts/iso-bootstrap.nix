{ pkgs, modulesPath, inputs, ... }:

{
  imports = [
    # 1. Base channel profile required to construct a bootable minimal console ISO
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    # 2. Inherit your exact declarative configuration modules
    "${inputs.self}/modules/core-system.nix"   # Sets locales, auto-optimizations, and experimental flags
    "${inputs.self}/modules/core-user.nix"     # Configures your administrative user skeleton (jchambers)
    "${inputs.self}/modules/core-zsh.nix"      # Provisions Zsh with completions, syntax highlighting, and secure aliases
    "${inputs.self}/modules/core-cachix.nix"   # Configures trusted upstream binary substitution pools to speed up builds
    "${inputs.self}/modules/core-hw-utils.nix" # Installs your full hardware diagnostics & disk partitioning suite
    "${inputs.self}/modules/dev-git.nix"       # Adds git and global user metrics (Joshua D Chambers)
    "${inputs.self}/modules/dev-neovim.nix"    # Deploys your text editor configuration and building tools
    "${inputs.self}/modules/sops-tools.nix"    # Drops in raw age and sops binaries for runtime secret auditing
  ];

  # Force strict open-source package parameters for the build environment
  nixpkgs.config.allowUnfree = false;

  # Embed your public key into the live session installer user for headless management
  users.users.nixos.openssh.authorizedKeys.keys = [
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
        ${pkgs.git}/bin/git clone https://github.com/truetenacity/infra.git "$TARGET_DIR" || true
      fi
    '';
  };
}
