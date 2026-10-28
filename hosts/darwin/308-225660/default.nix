{ config, pkgs, inputs, lib, ... }:

{
  # System Shell & Nix Settings
  programs.zsh.enable = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "@admin" "jchambers" ];
  };
  nixpkgs.hostPlatform = "aarch64-darwin";

  # --------------------------------------------------------------------------
  # 1. Apple Virtualization Framework Linux Builder (Metal / VZ Backend)
  # --------------------------------------------------------------------------
  nix.linux-builder = {
    enable = true;
    systems = [ "aarch64-linux" "x86_64-linux" ]; # Rosetta 2 for Intel Linux emulation
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;  # 40 GB storage
          memorySize = 8 * 1024; # 8 GB RAM
        };
        cores = 4; # Physical performance cores
      };
    };
  };

  # --------------------------------------------------------------------------
  # 2. macOS 27 System Preferences
  # --------------------------------------------------------------------------
  system.defaults = {
    dock = {
      autohide = true;
      tilesize = 64;
      show-recents = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXPreferredViewStyle = "Nlsv"; # Default to List View
      FXDefaultSearchScope = "SCcf"; # Search current folder by default
    };
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false; # Enable key repeat for Vim
      KeyRepeat = 2;                    # Fast repeat
      InitialKeyRepeat = 25;            # Short delay
      "com.apple.trackpad.scaling" = 3.0;
    };
    trackpad = {
      Clicking = true;                  # Tap to click
      TrackpadRightClick = true;        # Two-finger right click
    };
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

  # --------------------------------------------------------------------------
  # 3. Homebrew Management (Reconciled with live system)
  # --------------------------------------------------------------------------
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [
      # Core Desktop & Browsers
      "firefox"
      "google-chrome"
      "1password"
      "1password-cli"
      "ghostty"
      "zed"
      "google-drive"
      "adguard"
      # Utilities & Networking
      "cyberduck"
      "localsend"
      "raspberry-pi-imager"
      "teamviewer"
      "tigervnc"
      "wireshark-app"
      "windows-app"
      "antigravity-cli"
      # Virtualization & Media
      "utm"
      "kdenlive"
      "spotify"
      "discord"
      # AI & LLM Studio Workloads
      "anythingllm"
      "ollama"
      "lm-studio"
    ];
    brews = [
      "mas"
      "wireshark"
      "tea"
    ];
  };

  # --------------------------------------------------------------------------
  # 4. System-Level Tooling
  # --------------------------------------------------------------------------
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
    bat
    eza
    fd
    fzf
    ripgrep
    yazi
    zoxide
  ];

  # User Account and State Version Tracking
  system.primaryUser = "jchambers";
  system.stateVersion = 6;
  users.users.jchambers = {
    name = "jchambers";
    home = "/Users/jchambers";
  };
}
