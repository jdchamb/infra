# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/impermanence.nix (Stateless Root Layer)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 3):
#   Implements the "Erase Your Darlings" stateless root paradigm. On every boot,
#   the root filesystem ('/') starts clean (either via a tmpfs mount or an
#   ephemeral Btrfs subvolume rollback), wiping away any undeclared state drift.
#   Only explicitly declared directories inside '/persist' survive across reboots
#   via bind mounts and systemd-tmpfiles rules.
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  cfg = config.services.fleet.impermanence;
in
{
  options.services.fleet.impermanence = {
    enable = lib.mkEnableOption "Erase Your Darlings stateless root persistence bindings";

    useTmpfsRoot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        When enabled, mounts '/' directly as an in-memory tmpfs filesystem.
        Leave false if using Btrfs subvolume rollback in 'disko-impermanence.nix'.
      '';
    };

    tmpfsSize = lib.mkOption {
      type = lib.types.str;
      default = "4G";
      description = "Maximum RAM allocation for tmpfs root when useTmpfsRoot = true.";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Optional volatile tmpfs root mount & Persistent Bind Mounts from /persist
    fileSystems = lib.mkMerge [
      (lib.mkIf cfg.useTmpfsRoot {
        "/" = lib.mkForce {
          device = "none";
          fsType = "tmpfs";
          options = [ "defaults" "size=${cfg.tmpfsSize}" "mode=755" ];
        };
      })

      {
        "/var/log" = {
          device = "/persist/var/log";
          fsType = "none";
          options = [ "bind" "X-mount.mkdir" ];
          neededForBoot = true;
        };
        "/var/lib/nixos" = {
          device = "/persist/var/lib/nixos";
          fsType = "none";
          options = [ "bind" "X-mount.mkdir" ];
          neededForBoot = true;
        };
        "/var/lib/sops-nix" = {
          device = "/persist/var/lib/sops-nix";
          fsType = "none";
          options = [ "bind" "X-mount.mkdir" ];
          neededForBoot = true;
        };
        "/var/lib/systemd/coredump" = {
          device = "/persist/var/lib/systemd/coredump";
          fsType = "none";
          options = [ "bind" "X-mount.mkdir" ];
        };
        "/etc/NetworkManager/system-connections" = {
          device = "/persist/etc/NetworkManager/system-connections";
          fsType = "none";
          options = [ "bind" "X-mount.mkdir" ];
        };
      }
    ];

    # 2. Persist SSH Host Keys across ephemeral root wipes
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

    # 3. Ensure persistent backing directories and machine-id symlink exist
    systemd.tmpfiles.rules = [
      "d /persist/var/log 0755 root root -"
      "d /persist/var/lib/nixos 0755 root root -"
      "d /persist/var/lib/sops-nix 0700 root root -"
      "d /persist/var/lib/systemd/coredump 0755 root root -"
      "d /persist/etc/ssh 0755 root root -"
      "d /persist/etc/NetworkManager/system-connections 0700 root root -"
      "L+ /etc/machine-id - - - - /persist/etc/machine-id"
    ];

    # 4. Audit CLI utility to inspect files written to the ephemeral root layer
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "impermanence-diff" ''
        echo "==> Scanning top-level mutable paths on '/' not backed by '/nix' or '/persist'..."
        sudo ${pkgs.fd}/bin/fd --one-file-system --base-directory / --type f \
          --exclude tmp --exclude etc --exclude var/run --exclude proc --exclude sys --exclude dev
      '')
    ];
  };
}
