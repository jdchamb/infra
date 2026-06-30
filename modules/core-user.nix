# ==============================================================================
# ROLE: NixOS System-Level Identity Account Module (Root Privileged)
# WHAT GOES HERE AND WHY:
#   This module handles system-level security and authentication configuration.
#   It interfaces directly with the Linux kernel and PAM to define who can log into
#   the hardware, what administrative system groups they inherit, and what their
#   default system shell execution binary is.
# ==============================================================================

{ config, pkgs, ... }:

{
  # --- System Account Provisioning Layer ---
  # Instructs the NixOS activation engine to create the user configuration entry
  # inside /etc/passwd and provision the required root directory nodes.
  users.users.jchambers = {
    isNormalUser = true;
    description = "Joshua Chambers";

    # Security and Hardware Authorization Matrix
    # wheel = grants password-authenticated sudo command execution permissions
    # networkmanager = allows control over network connections
    # video/audio = direct access to kernel device nodes without passing root contexts
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];

    # Assigns the interactive terminal entry shell binary at system level
    shell = pkgs.zsh;
  };

  # Global programmatic system validation for the zsh wrapper shell
  programs.zsh.enable = true;
}
