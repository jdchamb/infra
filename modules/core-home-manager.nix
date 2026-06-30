# ==============================================================================
# ROLE: Agnostic User-Space Shell & Environment Baseline Profile
# WHAT GOES HERE AND WHY:
#   This is the pure user-space configuration module managed via Home Manager.
#   It handles everything inside your /home/jchambers context without root permissions.
#   It tracks text-editor baselines, system path utilities, and user environments.
#   It does NOT include desktop layouts, making it lightweight and cross-compatible
#   with headless deployments or live ISO media.
# ==============================================================================

{ config, pkgs, inputs, ... }:

{
  # --- User Profile Spatial Scope Definitions ---
  home = {
    username = "jchambers";
    homeDirectory = "/home/jchambers";

    # State Engine Version Lock
    # This prevents upgrades from automatically altering database schemas and formats
    # inside your user profile. Match it to the release version the setup was initialized on.
    stateVersion = "24.11";
  };

  # Direct Home Manager package manager hooks
  programs.home-manager.enable = true;

  # --- User-Space Component Injections ---
  # Modular lego blocks mapping shell tools, configurations, and themes
  imports = [
    "${inputs.self}/modules/core-zsh.nix"       # User aliases and execution pathways
    "${inputs.self}/modules/core-starship.nix"  # Declarative prompt styling engine
  ];
}
