# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/system.nix (Locale, Store & GC Policy)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Defines universal OS parameters shared across every Linux workstation and VM:
#   timezone (America/Chicago), UTF-8 localization tables, XKB US keyboard layout,
#   experimental Nix Flake evaluation flags, hard-link store deduplication, and
#   automated weekly garbage collection so mobile/lab SSDs never run out of space.
# ==============================================================================

{ config, pkgs, ... }:

{
  # 1. Timezone & UTF-8 Localization Tables
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
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

  # 2. Base X11/Wayland Keyboard Layout Matrix
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # 3. Nix Daemon & Content-Addressable Store Optimization
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true; # Deduplicates identical files in /nix/store via hardlinks
  };

  # Permit proprietary firmware and enterprise packages where required by host profiles
  nixpkgs.config.allowUnfree = true;

  # 4. Automated Store Garbage Collection (Prunes generations older than 7 days)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
