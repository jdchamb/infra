# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/user.nix (Primary System User Account)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Defines the system-level Linux user account ('jchambers'), login shell, and
#   kernel device-group memberships across all NixOS workstations, VMs, and labs.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   In NixOS, there are two levels of user configuration:
#     1. System-level ('modules/nixos/core/user.nix'): Creates the actual Linux
#        account in '/etc/passwd', sets the default login shell ('pkgs.zsh'),
#        and grants hardware/sudo permissions via 'extraGroups'.
#     2. User-level ('home/default.nix'): Managed by Home Manager to populate
#        dotfiles inside '/home/jchambers'.
#
#   Why each group in 'extraGroups' matters:
#     - 'wheel'          : Grants 'sudo' administrator privileges.
#     - 'networkmanager' : Allows switching Wi-Fi networks and VPNs without sudo.
#     - 'video'          : Grants direct access to GPU & screen backlight controls.
#     - 'audio'          : Grants direct access to sound hardware & PipeWire devices.
# ==============================================================================

{ config, pkgs, ... }:

{
  # 1. Provision the primary interactive user account in /etc/passwd
  users.users.jchambers = {
    # 'isNormalUser = true' automatically assigns a standard UID (>= 1000),
    # creates '/home/jchambers', and adds the user to the 'users' group.
    isNormalUser = true;
    description = "Joshua Daniel Chambers";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    shell = pkgs.zsh;
  };

  # 2. Register Zsh in /etc/shells at the system level (required when setting
  #    a user's login shell to pkgs.zsh on NixOS).
  programs.zsh.enable = true;
}
