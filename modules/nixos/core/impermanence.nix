# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/impermanence.nix (Stateless Root Layer)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 3 — "Erase Your Darlings" Architecture):
#   Implements declarative ephemeral root persistence. On every system reboot,
#   the root filesystem ('/') is wiped completely clean (either by running entirely
#   in RAM via a tmpfs mount, or by rolling back a blank Btrfs subvolume snapshot).
#   Only files explicitly designated to live in '/persist' survive across reboots,
#   bound into place via Linux kernel bind-mounts and systemd-tmpfiles rules.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Over months or years of use, standard Linux installations accumulate hidden
#   configuration drift: leftover log files, forgotten test packages, modified
#   dotfiles in '/etc', and orphaned caches.
#   Impermanence solves this by wiping the operating system root ('/') back to
#   absolute zero on every reboot:
#     1. Guaranteed Reproducibility: If a service or configuration is not defined
#        in your Nix Flake code, it vanishes when the machine reboots. This guarantees
#        your code is the single source of truth.
#     2. Security: Malware, malicious temporary scripts, or compromised system
#        binaries cannot survive a reboot.
#     3. Explicit Persistence: Critical data that MUST survive (SSH host keys,
#        Wi-Fi credentials, SOPS Age keys, system logs) are bind-mounted from a
#        dedicated, permanent storage partition mounted at '/persist'.
#
# >>> CAUTION & USAGE WARNING <<<
#   When 'services.fleet.impermanence.enable = true' is active, any file written
#   to root paths (e.g., '/etc', '/var') that is NOT explicitly listed in '/persist'
#   will be PERMANENTLY DESTROYED upon reboot!
#
# HOW TO USE:
#   - Enable impermanence on a host:
#       services.fleet.impermanence.enable = true;
#       # Optional: mount root as tmpfs in RAM (otherwise uses Btrfs blank snapshot)
#       services.fleet.impermanence.useTmpfsRoot = false;
#   - Check what files have been written to the ephemeral root since boot:
#       impermanence-diff
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  # Shorthand alias to this module's configuration options
  cfg = config.services.fleet.impermanence;
in
{
  # --------------------------------------------------------------------------
  # Option Declarations
  # --------------------------------------------------------------------------
  options.services.fleet.impermanence = {
    # Toggle option to activate impermanence bind-mounts and tmpfiles
    enable = lib.mkEnableOption "Erase Your Darlings stateless root persistence bindings";

    # Whether to mount root as volatile RAM tmpfs (true) or use Btrfs rollback (false)
    useTmpfsRoot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        When enabled, mounts '/' directly as an in-memory tmpfs filesystem.
        Leave false if using Btrfs subvolume rollback in 'disko-impermanence.nix'.
      '';
    };

    # Maximum RAM allocated for tmpfs root when useTmpfsRoot is enabled
    tmpfsSize = lib.mkOption {
      type = lib.types.str;
      default = "4G";
      description = "Maximum RAM allocation for tmpfs root when useTmpfsRoot = true.";
    };
  };

  # --------------------------------------------------------------------------
  # Configuration Block (Evaluated only when cfg.enable = true)
  # --------------------------------------------------------------------------
  config = lib.mkIf cfg.enable {
    # 1. Kernel Filesystem Mounts
    # Uses lib.mkMerge to conditionally combine the tmpfs root with persistent bind mounts
    fileSystems = lib.mkMerge [
      # Conditional tmpfs root mount (only if useTmpfsRoot is true)
      (lib.mkIf cfg.useTmpfsRoot {
        "/" = lib.mkForce {
          device = "none";
          fsType = "tmpfs";
          # size=4G limits memory usage; mode=755 sets standard root permissions
          options = [ "defaults" "size=${cfg.tmpfsSize}" "mode=755" ];
        };
      })

      # Persistent Bind Mounts: links directories on /persist into standard /var and /etc paths
      {
        # System journal logs: essential for debugging historical issues across boots
        "/var/log" = {
          device = "/persist/var/log";
          fsType = "none";
          options = [ "bind" "X-mount.mkdir" ];
          neededForBoot = true;
        };

        # NixOS state tracking: UID/GID mappings, user database allocations
        "/var/lib/nixos" = {
          device = "/persist/var/lib/nixos";
          fsType = "none";
          options = [ "bind" "X-mount.mkdir" ];
          neededForBoot = true;
        };

        # SOPS-Nix master Age private key directory (must persist to decrypt secrets)
        "/var/lib/sops-nix" = {
          device = "/persist/var/lib/sops-nix";
          fsType = "none";
          options = [ "bind" "X-mount.mkdir" ];
          neededForBoot = true;
        };

        # Systemd crash core dumps for software diagnostic analysis
        "/var/lib/systemd/coredump" = {
          device = "/persist/var/lib/systemd/coredump";
          fsType = "none";
          options = [ "bind" "X-mount.mkdir" ];
        };

        # Saved Wi-Fi networks and passwords managed by NetworkManager
        "/etc/NetworkManager/system-connections" = {
          device = "/persist/etc/NetworkManager/system-connections";
          fsType = "none";
          options = [ "bind" "X-mount.mkdir" ];
        };
      }
    ];

    # --------------------------------------------------------------------------
    # 2. OpenSSH Host Key Persistence
    # Without this, the machine's SSH fingerprint changes every reboot, causing
    # "REMOTE HOST IDENTIFICATION HAS CHANGED!" security warnings when connecting.
    # --------------------------------------------------------------------------
    services.openssh.hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];

    # --------------------------------------------------------------------------
    # 3. Systemd-tmpfiles Structure
    # Ensures the physical directories exist on /persist with strict security bits
    # --------------------------------------------------------------------------
    systemd.tmpfiles.rules = [
      "d /persist/var/log 0755 root root -"
      "d /persist/var/lib/nixos 0755 root root -"
      "d /persist/var/lib/sops-nix 0700 root root -" # Restricted to root only
      "d /persist/var/lib/systemd/coredump 0755 root root -"
      "d /persist/etc/ssh 0755 root root -"
      "d /persist/etc/NetworkManager/system-connections 0700 root root -" # Restricted to root
      # Symlink machine-id so systemd identifiers and journal cursor pointers remain consistent
      "L+ /etc/machine-id - - - - /persist/etc/machine-id"
    ];

    # --------------------------------------------------------------------------
    # 4. Ephemeral Diff Audit Script
    # Provides 'impermanence-diff' to find any untracked mutable files on root
    # --------------------------------------------------------------------------
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "impermanence-diff" ''
        echo "==> Scanning top-level mutable paths on '/' not backed by '/nix' or '/persist'..."
        sudo ${pkgs.fd}/bin/fd --one-file-system --base-directory / --type f \
          --exclude tmp --exclude etc --exclude var/run --exclude proc --exclude sys --exclude dev
      '')
    ];
  };
}
