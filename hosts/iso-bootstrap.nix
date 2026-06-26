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

  # --- Remote Management Over Network ---
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes"; # Allows full administrative field staging over SSH
  };

  # Embed your public key into both users for seamless headless management access
  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6xT65eiBe41ztk2UZ5/nSdcdYI/eRhRjfXoAdduxA jchambers-codeberg"
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6xT65eiBe41ztk2UZ5/nSdcdYI/eRhRjfXoAdduxA jchambers-codeberg"
  ];

  # --- PROJECT 20: Automated Git Repo Cloning Service ---
  # Automatically clones your complete infrastructure flake repository straight to the
  # live environment's storage pool as soon as the system establishes a network handshake.
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
      mkdir -p /home/nixos/src
      if [ ! -d "/home/nixos/src/infra" ]; then
        ${pkgs.git}/bin/git clone https://codeberg.org/jchambers/infra.git /home/nixos/src/infra
      fi
    '';
  };

  # Helper shorthand alias for manual intervention runs if needed
  environment.shellAliases = {
    bootstrap-fetch = "git clone https://codeberg.org/jchambers/infra.git ~/src/infra";
  };

  # --- Image Construction Optimization ---
  # Forces zstd compression at level 6. This accelerates your local build velocity
  # significantly when compiling the ISO on wrk-dt01, keeping your development loop fast.
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";
}
