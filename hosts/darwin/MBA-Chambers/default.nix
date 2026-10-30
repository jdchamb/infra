# ==============================================================================
# HOST CONFIGURATION: MBA-Chambers (Apple Silicon MacBook Air)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Personal / secondary portable Apple Silicon MacBook Air for Joshua Chambers,
#   mimicking the declarative macOS environment of 308-225660.
#   - Architecture: aarch64-darwin (Apple Silicon)
#   - Operating System: macOS 27.0.1+
#   - System Manager: nix-darwin
#   - User-Space Manager: Home Manager (./home/default.nix)
#   - Package Channels: Nixpkgs (CLI / Dev) + Homebrew (GUI Casks / macOS Apps)
#
# OPERATIONAL RUNBOOK FOR SUCCESSORS:
#   - To apply changes on this MacBook:
#       rebuild
#     (which executes: sudo darwin-rebuild switch --flake ~/src/infra#MBA-Chambers)
#   - To test changes without permanently activating:
#       rebuild test
#   - To add a new GUI application: Add its cask name to `homebrew.casks`.
#   - To add a new CLI development tool: Add its package to `environment.systemPackages`.
# ==============================================================================

{ config, pkgs, inputs, lib, ... }:

{
  # ----------------------------------------------------------------------------
  # 1. CORE SYSTEM SHELL & NIX DAEMON CONFIGURATION
  # ----------------------------------------------------------------------------
  # Enable Zsh at the system level so /etc/shells and login hooks are registered
  programs.zsh.enable = true;

  # Nix Daemon Security & Feature Flags
  nix.settings = {
    # Activate modern Flakes engine and experimental CLI commands
    experimental-features = [ "nix-command" "flakes" ];

    # Trusted users: Required for remote building and daemon socket communication.
    # '@admin' grants the wheel/admin group root-level build privileges.
    trusted-users = [ "@admin" "jchambers" ];
  };

  # Target CPU architecture
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Disable system documentation builder (avoids upstream nixos-render-docs CLI flag incompatibility in nixpkgs)
  documentation.enable = false;
  documentation.doc.enable = false;
  documentation.man.enable = false;
  documentation.info.enable = false;

  # Disable darwin-uninstaller generation to avoid building uninstaller's internal documentation
  system.tools.darwin-uninstaller.enable = false;

  # ----------------------------------------------------------------------------
  # 2. APPLE VIRTUALIZATION FRAMEWORK LINUX BUILDER (Metal / VZ Paravirtualization)
  # ----------------------------------------------------------------------------
  # Why this exists:
  #   macOS cannot natively compile Linux binaries (e.g. for our NixOS fleet nodes).
  #   Instead of running slow user-space QEMU, this spins up an in-memory NixOS
  #   virtual machine directly using Apple's hardware-accelerated Virtualization.framework.
  #
  # Capabilities:
  #   - Runs at near-native CPU speeds (0% hypervisor overhead).
  #   - Automatically manages an SSH keypair (/etc/nix/builder_ed25519) and registers
  #     itself in /etc/nix/machines for transparent derivation offloading.
  #   - Uses Apple's paravirtualized Rosetta directory mount so this single ARM64
  #     Mac can build BOTH 'aarch64-linux' AND 'x86_64-linux' packages!
  # ----------------------------------------------------------------------------
  nix.linux-builder = {
    enable = true;

    # Supported build architectures (native ARM64 Linux + Rosetta 2 Intel Linux)
    systems = [ "aarch64-linux" "x86_64-linux" ];

    config = {
      virtualisation = {
        # VM Resource Allocation
        darwin-builder = {
          diskSize = 40 * 1024;  # 40 GB storage space for compilation caches
          memorySize = 8 * 1024; # 8 GB RAM allocated to the build machine
        };
        # Allocate 4 performance cores (leaves efficiency cores free for macOS)
        cores = 4;
      };
    };
  };

  # ----------------------------------------------------------------------------
  # 3. macOS SYSTEM PREFERENCES (Defaults Engine)
  # ----------------------------------------------------------------------------
  # Declaratively asserts macOS GUI preferences, eliminating manual clicks
  # in System Settings across fresh OS installs.
  # ----------------------------------------------------------------------------
  system.defaults = {
    # Dock Customization
    dock = {
      autohide = true;      # Automatically hide and reveal Dock on edge hover
      tilesize = 64;        # Balanced icon size for Retina displays
      show-recents = false; # Do not clutter the Dock with recently closed applications
    };

    # Finder Customization
    finder = {
      AppleShowAllExtensions = true; # Always reveal full file extensions (.tar.gz, .nix)
      ShowPathbar = true;            # Display interactive breadcrumb path bar at window bottom
      FXPreferredViewStyle = "Nlsv"; # Default to List View for developer ergonomics
      FXDefaultSearchScope = "SCcf"; # Search current folder by default (not entire Mac)
    };

    # Global System & Keyboard Preferences
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";     # Permanent Dark Mode theme
      AppleShowAllExtensions = true;    # System-wide file extension visibility
      ApplePressAndHoldEnabled = false; # Disable accent popup; enable fast key repeats for Vim
      KeyRepeat = 2;                    # Ultra-fast key repeat rate
      InitialKeyRepeat = 25;            # Short delay before key repeat kicks in
      "com.apple.trackpad.scaling" = 3.0; # Fast cursor tracking speed
    };

    # Built-in Trackpad
    trackpad = {
      Clicking = true;           # Tap to click (avoids heavy physical clicks)
      TrackpadRightClick = true; # Two-finger tap for secondary/right click
    };
  };

  # ----------------------------------------------------------------------------
  # 4. HOST IDENTITY & SHARED MODULE IMPORTS
  # ----------------------------------------------------------------------------
  networking.hostName = "MBA-Chambers";

  # Import reusable, multi-OS modules from the fleet library (1-to-1 Modules)
  imports = [
    "${inputs.self}/modules/common/sops-tools.nix"            # Age & SOPS secret tooling
    "${inputs.self}/modules/shared/git.nix"                   # Global Git author configuration
    "${inputs.self}/modules/shared/git-bug.nix"               # Distributed Git-native issue tracker
    "${inputs.self}/modules/shared/lazygit.nix"               # Terminal UI for Git
    "${inputs.self}/modules/shared/vim.nix"                   # System-level Vim editor fallback
    "${inputs.self}/modules/shared/neovim.nix"                # Neovim modern development editor
    "${inputs.self}/modules/shared/zellij.nix"                # Zellij terminal workspace manager
    "${inputs.self}/modules/shared/ghostty.nix"               # Ghostty terminal configuration
    "${inputs.self}/modules/shared/security/yubikey-nordic.nix" # FIDO2 / OpenSK hardware keys
    "${inputs.self}/modules/shared/security/gpg.nix"          # GnuPG cryptographic identity tools
    "${inputs.self}/modules/shared/security/vaultwarden-client.nix" # Bitwarden/Vaultwarden CLI
    "${inputs.self}/modules/shared/storage/file-integrity-monitor.nix" # Checksum bitrot verifier
  ];

  # System-wide Typography (Nerd Fonts with glyph support for Starship & terminal UI)
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # ----------------------------------------------------------------------------
  # 5. DECLARATIVE HOMEBREW MANAGEMENT (Casks & Formulae)
  # ----------------------------------------------------------------------------
  # While Nix handles CLI binaries, Homebrew provides native macOS GUI applications
  # packaged as .dmg / .app bundles.
  #
  # WARNING ON CLEANUP:
  #   'cleanup = "zap"' ensures strict idempotency: any application NOT listed
  #   in this block will be uninstalled. Always declare user applications here.
  # ----------------------------------------------------------------------------
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap"; # Removes unmanaged casks and formulae automatically

    # GUI Application Bundles (.app)
    casks = [
      # Core Desktop & Web Browsing
      "firefox"
      "google-chrome"
      "1password"
      "1password-cli"
      "ghostty"
      "zed"
      "google-drive"
      "adguard"

      # Remote Management, File Transfer & Diagnostics
      "cyberduck"
      "localsend"
      "raspberry-pi-imager"
      "teamviewer"
      "tigervnc"
      "wireshark-app"
      "windows-app"
      "antigravity-cli"

      # Virtualization & Multimedia
      "utm"
      "kdenlive"
      "spotify"
      "discord"

      # Local AI, LLM & Machine Learning Workbenches
      "anythingllm"
      "ollama"
      "lm-studio"
    ];

    # Command-Line Formulae (native Homebrew tools where Nix packages are impractical)
    brews = [
      "mas"       # Mac App Store command line interface
      "wireshark" # Packet dissection engine
      "tea"       # Gitea command line assistant
    ];
  };

  # ----------------------------------------------------------------------------
  # 6. SYSTEM-LEVEL CLI TOOLING (Managed via Nix)
  # ----------------------------------------------------------------------------
  # Core toolchain available globally across all terminal sessions and users.
  # ----------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Core Editors & Version Control
    vim
    git

    # System Status, Prompt & Information
    starship
    fastfetch
    smartmontools

    # Compilers & Runtime Environments
    cmake
    python311
    nodejs

    # Compression, Archive & Filesystem Utilities
    xz
    zstd
    coreutils

    # Modern CLI Replacements (eza=ls, bat=cat, fd=find, ripgrep=grep)
    bat
    eza
    fd
    fzf
    ripgrep
    yazi
    zoxide
  ];

  # ----------------------------------------------------------------------------
  # 7. PRIMARY USER ACCOUNT & STATE VERSION
  # ----------------------------------------------------------------------------
  system.primaryUser = "jchambers";

  # State version tracks the nix-darwin release defaults.
  # Do NOT change this value without reading the release migration notes.
  system.stateVersion = 6;

  users.users.jchambers = {
    name = "jchambers";
    home = "/Users/jchambers";
  };
}
