# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/bootstrap.nix (Zero-Touch ISO Engine)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 1 & 20 — Bare-Metal Automation Engine):
#   Provides headless SSH orchestration, automated Codeberg repository fetching,
#   and pre-baked installation CLI helpers ('bootstrap-age-key' and 'bootstrap-install')
#   for live installation and recovery ISO images.
#   Allows booting any physical x86_64 machine from a flash drive, connecting remotely
#   over SSH via public key authentication, staging the host's SOPS Age private key,
#   and executing automated Disko partitioning and NixOS system deployment.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Installing a traditional Linux distribution involves clicking through graphical
#   installers, manually partitioning disks, and typing usernames.
#   With NixOS and this bootstrap module:
#     - You plug a USB stick into a new laptop or server and power it on.
#     - The ISO boots headless and automatically starts an SSH server.
#     - Because your administrative SSH public key is pre-authorized, you can SSH
#       straight into the machine from your workstation without needing a monitor
#       or keyboard attached to the target machine.
#     - 'bootstrap-install' partitions the drive declaratively via Disko, installs
#       the target NixOS Flake profile, and preps the system for clean reboot.
#
# HOW TO USE:
#   1. Boot target machine from the custom installer ISO (see 'hosts/nixos/installer/').
#   2. Find its IP on the network (or via DHCP lease tables).
#   3. Connect over SSH:
#        ssh nixos@<target-ip>
#   4. Run the automated installer:
#        bootstrap-install 308-222242
#   5. When prompted, inject the host's Age private key using 'bootstrap-age-key /mnt'.
#   6. Reboot into your finished NixOS installation!
#
# >>> DISCREPANCY & REPOSITORY NOTICE <<<
#   Line 103 and 110 reference 'https://codeberg.org/jchambers-codeberg/infra.git'.
#   If your Codeberg username is 'jdchambers', verify whether the remote repository
#   is 'jdchambers/infra' or 'jchambers-codeberg/infra' before running offline clones.
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  # --------------------------------------------------------------------------
  # CLI Helper: bootstrap-age-key
  # Prompts the administrator to paste the host's Age private secret key and writes
  # it directly to the target filesystem with strict 0600 permissions so that
  # sops-nix can decrypt drive credentials and passwords on the first boot.
  # --------------------------------------------------------------------------
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

  # --------------------------------------------------------------------------
  # CLI Helper: bootstrap-install
  # Executes Disko to wipe and partition the drive according to declarative disk
  # specifications, checks for the presence of the SOPS Age key, and runs nixos-install.
  # --------------------------------------------------------------------------
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
    # CAUTION: Running Disko will erase all partition tables on the target drive!
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
      --mode disko --flake "$REPO_DIR#$HOST_TARGET"

    if [ ! -f "/mnt/var/lib/sops-nix/308-key.txt" ]; then
      echo "==> [2/3] Note: No Age key found at /mnt/var/lib/sops-nix/308-key.txt."
      echo "    Run 'bootstrap-age-key /mnt' now in another terminal if this host uses SOPS,"
      echo "    or press Enter to continue installation..."
      read -r _
    fi

    echo "==> [3/3] Installing NixOS configuration #$HOST_TARGET..."
    # nixos-install compiles the toplevel system derivation and copies store paths to /mnt
    sudo nixos-install --no-root-passwd --flake "$REPO_DIR#$HOST_TARGET"
    echo "==> Installation complete! Safe to reboot."
  '';

  # Administrative public key. Public keys are cryptographically safe to store in Git.
  sshPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6xT65eiBe41ztk2UZ5/nSdcdYI/eRhRjfXoAdduxA jchambers-codeberg";
in
{
  # --------------------------------------------------------------------------
  # 1. OpenSSH Remote Management Daemon
  # --------------------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      # Allow root login during initial ISO rescue/bootstrap operations
      PermitRootLogin = lib.mkDefault "yes";
      # Disallow insecure password logins; require SSH public key authentication
      PasswordAuthentication = lib.mkDefault false;
    };
  };

  # --------------------------------------------------------------------------
  # 2. Pre-Authorized SSH Public Keys
  # Bakes the administrative SSH public key into standard accounts in the ISO
  # --------------------------------------------------------------------------
  users.users.nixos.openssh.authorizedKeys.keys = [ sshPubKey ];
  users.users.root.openssh.authorizedKeys.keys = [ sshPubKey ];
  users.users.jchambers.openssh.authorizedKeys.keys = [ sshPubKey ];

  # --------------------------------------------------------------------------
  # 3. Automation Scripts
  # --------------------------------------------------------------------------
  environment.systemPackages = [
    bootstrapAgeKey
    bootstrapInstall
  ];

  # --------------------------------------------------------------------------
  # 4. Auto-Clone Service
  # Runs once network is online to clone the latest infrastructure code
  # --------------------------------------------------------------------------
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

  # --------------------------------------------------------------------------
  # 5. Shell Helper Alias
  # --------------------------------------------------------------------------
  environment.shellAliases = {
    bootstrap-fetch = "git clone https://codeberg.org/jchambers-codeberg/infra.git ~/src/infra";
  };
}
