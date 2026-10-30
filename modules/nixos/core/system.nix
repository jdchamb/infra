# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/system.nix (Locale, Store & GC Policy)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Defines universal operating system settings shared across every Linux workstation,
#   laptop, and virtual machine in the fleet:
#     - Timezone and UTF-8 internationalization (America/Chicago).
#     - Standard US keyboard layout mapping.
#     - Nix Flake evaluation flags and hard-link store deduplication.
#     - Proprietary package license filtering ('allowUnfree = true').
#     - Automated weekly Nix garbage collection to preserve SSD disk space.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   - Timezone & Locales: Ensures system clocks, terminal logs, and timestamps
#     align with USD 308 central time, and guarantees UTF-8 support for special characters.
#   - Nix Flakes ('experimental-features'): Flakes are the modern standard for
#     declarative, reproducible Nix systems with pinned dependency lockfiles ('flake.lock').
#     Nix still classifies them as "experimental", so this setting enables them system-wide.
#   - Store Optimization ('auto-optimise-store'): When new packages are built or
#     downloaded, Nix scans for identical binary files and replaces duplicates with
#     filesystem hardlinks, saving gigabytes of disk space automatically.
#   - Unfree Packages ('allowUnfree'): By default, Nixpkgs only allows pure open-source
#     software. Turning this on allows installing proprietary packages like Steam,
#     Discord, Google Chrome, VS Code, and Intel/Nvidia microcode drivers.
#   - Garbage Collection ('nix.gc'): Because Nix preserves previous generations so
#     you can roll back, the '/nix/store' will slowly grow over time. This policy
#     automatically deletes unused package versions older than 7 days every week.
#
# HOW TO USE:
#   - Included automatically by all NixOS host configurations.
#   - Manually trigger store deduplication: 'nix-store --optimise'
#   - Manually run garbage collection right now: 'nix-collect-garbage -d'
# ==============================================================================

{ config, pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. Timezone & Localization
  # --------------------------------------------------------------------------
  # Set system clock to US Central Time (Hutchinson, KS / USD 308)
  time.timeZone = "America/Chicago";

  # Primary system locale for terminal messages and interface translations
  i18n.defaultLocale = "en_US.UTF-8";

  # Explicit regional formatting settings for currency, dates, measurements, and addresses
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # --------------------------------------------------------------------------
  # 2. Keyboard Layout
  # Base XKB configuration applied across X11, Wayland compositors, and virtual consoles
  # --------------------------------------------------------------------------
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # --------------------------------------------------------------------------
  # 3. Nix Package Manager & Store Configuration
  # --------------------------------------------------------------------------
  nix.settings = {
    # Enable modern Flake subcommands ('nix build', 'nix flake check', 'nix develop')
    experimental-features = [ "nix-command" "flakes" ];

    # Automatically hard-link identical files in /nix/store to conserve disk space
    auto-optimise-store = true;
  };

  # Permit installation of packages with proprietary or unfree licenses (e.g. Chrome, Steam)
  nixpkgs.config.allowUnfree = true;

  # --------------------------------------------------------------------------
  # 4. Automated Garbage Collection
  # Deletes unreferenced derivations and builds older than 7 days every week
  # --------------------------------------------------------------------------
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
