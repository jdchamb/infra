{ config, pkgs, inputs, ... }:

{
  # Darwin-native system settings
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System shell
  programs.zsh.enable = true;

  # macOS-specific system default tweaks (optional)
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.ApplePressAndHoldEnabled = false; # Enable key repeat for Vim bindings
  };

  # Host identification
  networking.hostName = "macbook-work";

  # Darwin-safe cross-platform modules
  imports = [
    "${inputs.self}/modules/dev-git.nix"
    "${inputs.self}/modules/dev-vim.nix"
    "${inputs.self}/modules/dev-neovim.nix"
    "${inputs.self}/modules/dev-zellij.nix"
    "${inputs.self}/modules/sops-tools.nix"
  ];

  # macOS-specific system packages
  environment.systemPackages = with pkgs; [
    ghostty
    coreutils # Standard GNU userland utilities
  ];

  # Set state version for nix-darwin tracking
  system.stateVersion = 5;
}
