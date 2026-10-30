# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/hp-probook.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 11 — HP ProBook Lab Cluster):
#   Provides the shared hardware, firmware, thermal, and power management profile
#   for the 5-node HP ProBook physical validation lab ('lab-pb01' through 'lab-pb05').
#   Configures clamshell lid-switch ignore rules (so all 5 laptops can run 24/7
#   with closed lids on a server shelf without suspending), enables Intel CPU
#   microcode patches, runs Intel thermald, and ensures secure SSH accessibility.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Laptops make fantastic, energy-efficient homelab servers because they come
#   with a built-in battery backup (UPS), low power consumption, and compact form factor.
#   However, default laptop Linux settings will suspend (sleep) the computer the
#   moment you close the display lid.
#   - 'services.logind' Lid Overrides: Instructs systemd-logind to completely IGNORE
#     the lid switch sensor, allowing the laptops to run continuously on a shelf.
#   - Intel Microcode & Firmware: Applies Intel CPU hardware bug fixes, security patches
#     (Spectre/Meltdown mitigations), and proprietary Wi-Fi/Ethernet firmware blobs.
#   - 'thermald': Intel Thermal Daemon actively monitors hardware sensors and controls
#     fan speeds to keep temperatures within safe operating thresholds in closed-lid mode.
#   - SSH Hardening: Disables insecure password login, enforcing SSH Ed25519 public
#     key authentication exclusively.
#
# HOW TO USE:
#   - Imported by any HP ProBook host profile (e.g. 'hosts/nixos/lab-probook/default.nix').
#   - Inspect active CPU thermal status:
#       systemctl status thermald
#   - Connect to any lab node remotely:
#       ssh jchambers@<probook-ip>
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. Firmware & CPU Microcode
  # --------------------------------------------------------------------------
  # Enables loading of proprietary firmware blobs for Intel wireless cards & Realtek NICs
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # Installs Intel CPU microcode updates at early boot to patch silicon errata
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  # --------------------------------------------------------------------------
  # 2. Clamshell Lab Mode (systemd-logind)
  # Prevents the laptops from entering sleep/suspend mode when their lids are shut.
  # --------------------------------------------------------------------------
  services.logind = {
    lidSwitch = "ignore";               # Ignore lid close on battery
    lidSwitchDocked = "ignore";         # Ignore lid close when attached to dock/monitors
    lidSwitchExternalPower = "ignore";  # Ignore lid close when plugged into AC wall power
  };

  # --------------------------------------------------------------------------
  # 3. Thermal & Power Daemon Management
  # --------------------------------------------------------------------------
  # Intel Open Source Technology Center Thermal Daemon (prevents thermal runaway)
  services.thermald.enable = true;

  # DBus daemon that lets desktop and system services adjust power profiles
  services.power-profiles-daemon.enable = lib.mkDefault true;

  # --------------------------------------------------------------------------
  # 4. OpenSSH Daemon & Firewall
  # --------------------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      # Require cryptographic SSH keypairs; reject password brute-force attacks
      PasswordAuthentication = lib.mkDefault false;
      # Disallow password-based root logins
      PermitRootLogin = lib.mkDefault "prohibit-password";
    };
  };

  # Allow inbound SSH traffic on TCP port 22 through the Linux firewall
  networking.firewall.allowedTCPPorts = [ 22 ];

  # --------------------------------------------------------------------------
  # 5. Pre-Authorized Administrator Public SSH Keys
  # Note: Public keys are safe to commit to Git.
  # --------------------------------------------------------------------------
  users.users.jchambers.openssh.authorizedKeys.keys = [
    # Primary administrative laptop SSH key (Codeberg identity)
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6xT65eiBe41ztk2UZ5/nSdcdYI/eRhRjfXoAdduxA jchambers-codeberg"
    # Secondary personal workstation key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcOrpJmrhwkpgc1LB7dEkjDRFDthgbFra0XOqfAtAkL joshua@chambers-net.org"
  ];
}
