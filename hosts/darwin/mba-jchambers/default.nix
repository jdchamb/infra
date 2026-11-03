# ==============================================================================
# HOST CONFIGURATION: mba-jchambers (Apple Silicon MacBook Air)
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
#     (which executes: sudo darwin-rebuild switch --flake ~/src/infra#mba-jchambers)
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

  # Remote Login (OpenSSH Server): Managed natively by macOS System Settings
  # (Avoids requiring Full Disk Access permissions during darwin-rebuild)
  services.openssh.enable = null;

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
  # Disabled at boot to prevent Apple Watchdog reboot loops (wdog) and high I/O stalls.
  # Can be started on demand when compiling Linux binaries.
  # ----------------------------------------------------------------------------
  nix.linux-builder = {
    enable = false;

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
      KeyRepeat = 4;                    # Snappy key repeat (60ms — faster than 6, step below max slider of 2)
      InitialKeyRepeat = 20;            # Responsive delay before key repeat kicks in (300ms — faster than 25)
      "com.apple.trackpad.scaling" = 3.0; # Fast cursor tracking speed
    };

    # Built-in Trackpad
    trackpad = {
      Clicking = true;           # Tap to click (avoids heavy physical clicks)
      TrackpadRightClick = true; # Two-finger tap for secondary/right click
    };

    # Global Preferences (Mouse tracking speed)
    ".GlobalPreferences" = {
      "com.apple.mouse.scaling" = 1.5;
    };

    # Custom Preferences (Disable pointer acceleration / linear mouse curve)
    CustomUserPreferences = {
      "NSGlobalDomain" = {
        "com.apple.mouse.linear" = true;
      };
    };
  };

  # ----------------------------------------------------------------------------
  # 4. HOST IDENTITY & SHARED MODULE IMPORTS
  # ----------------------------------------------------------------------------
  networking.hostName = "mba-jchambers";
  networking.computerName = "mba-jchambers";

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
  # SAFETY POLICY ON mba-jchambers:
  #   'cleanup = "none"' ensures that NO existing applications, games, or Homebrew
  #   packages installed on this Mac are ever uninstalled or zapped during rebuilds.
  # ----------------------------------------------------------------------------
  homebrew = {
    enable = true;
    onActivation.cleanup = "none"; # Never delete/zap existing casks, apps, or formulae

    # GUI Application Bundles (.app) — Union of mba-jchambers existing apps + 308-225660 suite
    casks = [
      # Core Desktop, Editors & Web Browsing (Installed on mba-jchambers & 308-225660)
      "1password"
      "1password-cli"
      "adguard"
      "antigravity-cli"
      "discord"
      "firefox"
      "ghostty"
      "google-chrome"
      "google-drive"
      "visual-studio-code"

      # Gaming & Entertainment (mba-jchambers Specific)
      "ea"
      "gog-galaxy"
      "steam"
      "spotify"

      # Remote Management, File Transfer & Diagnostics (308-225660 Suite)
      "cyberduck"
      "raspberry-pi-imager" # Kept in Homebrew (Nixpkgs marked badPlatform on aarch64-darwin)
      "teamviewer"
      "tigervnc"
      "windows-app"

      # Virtualization & Multimedia
      "utm"
      "kdenlive"

      # Local AI, LLM & Machine Learning Workbenches
      "anythingllm"
      "ollama-app"
      "lm-studio"
    ];

    # Command-Line Formulae (Preserves existing mba-jchambers brews; mas, wireshark, tea migrated to Nixpkgs)
    brews = [
      "dotnet@8"          # Installed on mba-jchambers (.NET 8 SDK/Runtime)
      "git"               # Installed on mba-jchambers
      "zsh-autocomplete"  # Installed on mba-jchambers
      "zsh-autopair"      # Installed on mba-jchambers
      "zsh-autosuggestions" # Installed on mba-jchambers
    ];
  };

  # ----------------------------------------------------------------------------
  # 6. SYSTEM-LEVEL CLI & DESKTOP TOOLING (Managed via Nix)
  # ----------------------------------------------------------------------------
  # Core toolchain available globally across all terminal sessions and users.
  # ----------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Core Editors, IDEs & Version Control
    vim
    git
    zed-editor  # Swapped from Homebrew cask to pure Nixpkgs

    # Desktop Utilities & Networking (Swapped from Homebrew to pure Nixpkgs)
    localsend
    mas
    wireshark

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
