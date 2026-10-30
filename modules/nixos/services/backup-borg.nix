# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/backup-borg.nix (BorgBackup)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 2 — 1-to-1 Module):
#   Configures automated, deduplicated, authenticated-encryption daily BorgBackup
#   jobs ('services.borgbackup.jobs') with retention pruning (7 daily, 4 weekly,
#   6 monthly) targeting local storage or remote repositories.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   BorgBackup creates space-efficient backups by deduplicating data across
#   archives: if 10 daily backups share 99% of the same files, Borg only stores
#   the changed chunks once. Backups are cryptographically encrypted and
#   compressed with zstd before writing to disk.
#
# HOW TO USE:
#   - Importing this module turns the daily backup job ON immediately.
#   - Backups run on a systemd timer ('daily').
#   - Manual backup trigger:
#       sudo systemctl start borgbackup-job-fleet-state-backup.service
#   - Inspect status:
#       sudo systemctl status borgbackup-job-fleet-state-backup.service
#
# >>> SECURITY WARNING (READ BEFORE DEPLOYING) <<<
#   The systemd.tmpfiles rule below seeds a placeholder passphrase
#   ('changeme-borg-local') into '/etc/nixos/secrets/borg-passphrase'.
#   Because this file is created from Nix code, anyone reading this repository
#   can see the default key. Before backing up sensitive user data, replace
#   this passphrase with a real secret managed via SOPS-Nix ('modules/nixos/core/sops.nix').
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.borgbackup.jobs."fleet-state-backup" = {
    # File paths to include in the backup snapshot
    paths = [
      "/home/jchambers"
      "/var/lib"
    ];
    # Directories excluded from backup to save space and avoid volatile files
    exclude = [
      "/home/jchambers/.cache"
      "/home/jchambers/Shares" # Exclude remote network CIFS mounts
      "/var/lib/docker"        # Exclude ephemeral container overlays
      "/var/lib/containers"
    ];
    # Destination repository path (local disk path or user@remote:/path)
    repo = "/var/backup/borg-fleet";
    encryption = {
      mode = "repokey-blake2"; # Authenticated encryption using Blake2 + AES
      passCommand = "cat /etc/nixos/secrets/borg-passphrase";
    };
    compression = "auto,zstd"; # Automatically choose zstd compression if data compresses well
    startAt = "daily";         # Runs via systemd timer daily at midnight

    # Automated retention policy: clean up old snapshots while preserving key history
    prune.keep = {
      daily = 7;   # Keep the last 7 daily snapshots
      weekly = 4;  # Keep 4 weekly snapshots
      monthly = 6; # Keep 6 monthly snapshots
    };
  };

  # Ensure the backup directory exists and seed the passphrase file if absent
  systemd.tmpfiles.rules = [
    "d /var/backup/borg-fleet 0700 root root -"
    "f /etc/nixos/secrets/borg-passphrase 0600 root root - changeme-borg-local"
  ];
}
