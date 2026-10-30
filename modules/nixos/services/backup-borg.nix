# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/backup-borg.nix (BorgBackup)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 2 — 1-to-1 Module):
#   Configures automated, deduplicated, authenticated-encryption daily BorgBackup
#   jobs ('services.borgbackup.jobs') with retention pruning (7 daily, 4 weekly,
#   6 monthly) targeting local NAS storage or remote SSH repositories.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.borgbackup.jobs."fleet-state-backup" = {
    paths = [
      "/home/jchambers"
      "/var/lib"
    ];
    exclude = [
      "/home/jchambers/.cache"
      "/home/jchambers/Shares"
      "/var/lib/docker"
      "/var/lib/containers"
    ];
    repo = "/var/backup/borg-fleet";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /etc/nixos/secrets/borg-passphrase";
    };
    compression = "auto,zstd";
    startAt = "daily";
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 6;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/backup/borg-fleet 0700 root root -"
    "f /etc/nixos/secrets/borg-passphrase 0600 root root - changeme-borg-local"
  ];
}
