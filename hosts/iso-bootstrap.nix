{ pkgs, modulesPath, inputs, ... }:

{
  imports = [
    # Baseline for a minimal console installer
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "${inputs.self}/modules/dev-git.nix"
  ];

  nixpkgs.config.allowUnfree = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    vim
    git
    tmux
    parted
    gptfdisk
  ];

  # Authorized keys for headless deployment management
  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6xT65eiBe41ztk2UZ5/nSdcdYI/eRhRjfXoAdduxA jchambers-codeberg"
  ];

  # Project 20: Auto-clone core infrastructure repo for rapid provisioning
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
