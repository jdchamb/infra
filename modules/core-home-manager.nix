# core-home-manager.nix
# ROLE: Agnostic User-Space Shell & Environment Baseline Profile

{ config, pkgs, inputs, ... }:

{
  # --- User Profile Spatial Scope Definitions ---
  home = {
    username = "jchambers";
    homeDirectory = "/home/jchambers";

    # Automatically move conflicting unmanaged files out of the way
    backupFileExtension = "backup";

    # State Engine Version Lock
    stateVersion = "24.11";
  };

  # Direct Home Manager package manager hooks
  programs.home-manager.enable = true;

  # --- User-Space Component Injections ---
  imports = [
    "${inputs.self}/modules/core-zsh.nix"
    "${inputs.self}/modules/core-starship.nix"
  ];
}
