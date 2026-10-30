# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/bootstrap.nix (Zero-Touch ISO Engine)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 1 & 20):
#   Provides headless SSH orchestration, automated Codeberg repository cloning,
#   and helper scripts ('bootstrap-age-key' and 'bootstrap-install') for live ISO
#   environments. Allows you to boot a bare-metal machine from USB, connect over
#   SSH, inject the runtime SOPS 'age' private key into the target disk's
#   '/var/lib/sops-nix/308-key.txt' before first boot, and execute a zero-touch
#   Disko + NixOS installation.
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  # Helper script to stage an Age private key onto a newly mounted target system
  # before running nixos-install, ensuring SOPS secrets decrypt cleanly on first boot.
  bootstrapAgeKey = pkgs.writeShellScriptBin "bootstrap-age-key" ''
    set -euo pipefail
    TARGET_MNT="''${1:-/mnt}"
    KEY_DEST="$TARGET_MNT/var/lib/sops-nix/308-key.txt"

    echo "==> Staging SOPS Age private key into $KEY_DEST"
    sudo mkdir -p "$(dirname "$KEY_DEST")"
    if [ -t 0 ]; then
      echo "Paste the Age private key (AGE-SECRET-KEY-1...) and press Ctrl+D:"
    fi
    sudo tee "$KEY_DEST" > /dev/null
    sudo chmod 0600 "$KEY_DEST"
    echo "==> Age key secured with mode 0600 at $KEY_DEST"
  '';

  # Helper script to partition via Disko, stage keys, and install a target host profile
  bootstrapInstall = pkgs.writeShellScriptBin "bootstrap-install" ''
    set -euo pipefail
    HOST_TARGET="''${1:-}"
    REPO_DIR="''${2:-/home/nixos/src/infra}"

    if [ -z "$HOST_TARGET" ]; then
      echo "Usage: bootstrap-install <hostname> [repo-path]"
      echo "Example: bootstrap-install 308-222242"
      exit 1
    fi

    echo "==> [1/3] Running Disko declarative partitioning for #$HOST_TARGET..."
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
      --mode disko --flake "$REPO_DIR#$HOST_TARGET"

    if [ ! -f "/mnt/var/lib/sops-nix/308-key.txt" ]; then
      echo "==> [2/3] Note: No Age key found at /mnt/var/lib/sops-nix/308-key.txt."
      echo "    Run 'bootstrap-age-key /mnt' now in another terminal if this host uses SOPS,"
      echo "    or press Enter to continue installation..."
      read -r _
    fi

    echo "==> [3/3] Installing NixOS configuration #$HOST_TARGET..."
    sudo nixos-install --no-root-passwd --flake "$REPO_DIR#$HOST_TARGET"
    echo "==> Installation complete! Safe to reboot."
  '';

  sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6xT65eiBe41ztk2UZ5/nSdcdYI/eRhRjfXoAdduxA jchambers-codeberg";
in
{
  # 1. Headless SSH Daemon for Remote Bootstrap Control (Project 1)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkDefault "yes";
      PasswordAuthentication = lib.mkDefault false;
    };
  };

  # 2. Bake Authorized SSH Keys into Live Session & Root Accounts
  users.users.nixos.openssh.authorizedKeys.keys = [ sshPubKey ];
  users.users.root.openssh.authorizedKeys.keys = [ sshPubKey ];
  users.users.jchambers.openssh.authorizedKeys.keys = [ sshPubKey ];

  # 3. Install Bootstrap Automation Scripts into System PATH
  environment.systemPackages = [
    bootstrapAgeKey
    bootstrapInstall
  ];

  # 4. Automated Git Repository Cloning Service on Startup (Project 20)
  systemd.services.clone-infra-repo = {
    description = "Auto-clone declarative infrastructure repository from Codeberg on startup";
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

  # 5. Interactive Bootstrap Shorthand Alias
  environment.shellAliases = {
    bootstrap-fetch = "git clone https://codeberg.org/jchambers-codeberg/infra.git ~/src/infra";
  };
}
