# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/hp-probook.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 11):
#   Provides the shared hardware, firmware, thermal, and power management profile
#   for the 5-node HP ProBook physical validation lab ('lab-pb01' .. 'lab-pb05').
#   Configures clamshell lid-switch ignore rules (so all 5 laptops can run closed
#   on a lab shelf without suspending), Intel microcode, thermald, and SSH access.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  # 1. Enable Redistributable Firmware & Intel CPU Microcode Updates
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  # 2. Clamshell Lab Mode: Prevent ProBooks from sleeping when their lids are closed
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
  };

  # 3. Thermal & Power Management for Continuous Lab Operation
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = lib.mkDefault true;

  # 4. Headless Lab SSH Access & Firewall Allowance
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = lib.mkDefault false;
      PermitRootLogin = lib.mkDefault "prohibit-password";
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  # Authorize primary administrative SSH keys across all 5 ProBook lab nodes
  users.users.jchambers.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6xT65eiBe41ztk2UZ5/nSdcdYI/eRhRjfXoAdduxA jchambers-codeberg"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcOrpJmrhwkpgc1LB7dEkjDRFDthgbFra0XOqfAtAkL joshua@chambers-net.org"
  ];
}
