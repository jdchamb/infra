{ config, pkgs, inputs, ... }:

{
  # System Shell & Nix Settings
  programs.zsh.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.hostPlatform = "aarch64-darwin";

  # macOS-Specific System Defaults
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.ApplePressAndHoldEnabled = false; # Enable key repeat for Vim
  };

  # Host Identification
  networking.hostName = "308-225660";

  # Darwin-Safe Module Imports
  imports = [
    "${inputs.self}/modules/common/sops-tools.nix"
    "${inputs.self}/modules/shared/git.nix"
    "${inputs.self}/modules/shared/vim.nix"
    "${inputs.self}/modules/shared/neovim.nix"
    "${inputs.self}/modules/shared/zellij.nix"
    "${inputs.self}/modules/shared/ghostty.nix"
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # Homebrew Casks & Formulae Management
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [
      "firefox"
      "1password"
      "ghostty"
      "google-drive"
      "adguard"
      "kdenlive"
      "utm"
      "windows-app"
      "anythingllm"
      "ollama"
      "lm-studio"
      "google-chrome"
      "spotify"
      "discord"
    ];
    brews = [
      "mas"
    ];
  };

  # System-Level Tooling
  environment.systemPackages = with pkgs; [
    vim
    git
    starship
    fastfetch
    cmake
    python311
    nodejs
    smartmontools
    xz
    zstd
    coreutils
  ];

  # User Account and State Version Tracking
  system.primaryUser = "jchambers";
  system.stateVersion = 6;
  users.users.jchambers = {
    name = "jchambers";
    home = "/Users/jchambers";
  };
}
