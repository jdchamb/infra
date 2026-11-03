# ==============================================================================
# HOST CONFIGURATION: hosts/nixos/mba-jchambers/default.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Bare-metal NixOS configuration for Apple Silicon M1 MacBook Air (mba-jchambers)
#   using the nixos-apple-silicon / Asahi Linux hardware integration framework.
#   - Architecture: aarch64-linux (Apple Silicon M1 bare-metal)
#   - Kernel & Drivers: nixos-apple-silicon custom 16k page size kernel & GPU drivers
#   - Audio: PipeWire with Asahi UCM profiles & safety limits
#   - Desktop: KDE Plasma 6 Wayland with krohnkite tiling
# ==============================================================================

{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    # 1. Asahi / Apple Silicon Bare-Metal Hardware Support
    inputs.apple-silicon.nixosModules.apple-silicon-support

    # 2. Unified Global Baseline & Core Operating System Infrastructure
    ../../../modules/nixos/core/global.nix
    ../../../modules/nixos/core/audio.nix
    ../../../modules/nixos/hardware/apple-keyboard.nix

    # 3. Shared Developer & Operations Tools
    ../../../modules/shared/git.nix
    ../../../modules/shared/vim.nix
    ../../../modules/shared/neovim.nix
    ../../../modules/shared/zellij.nix
    ../../../modules/shared/ghostty.nix
    ../../../modules/shared/security/yubikey-nordic.nix

    # 4. Desktop Compositor & Login Manager
    ../../../modules/nixos/desktop/greetd.nix
    ../../../modules/nixos/desktop/plasma.nix
    ../../../modules/nixos/desktop/krohnkite.nix
  ];

  # ----------------------------------------------------------------------------
  # HOST IDENTITY & PLATFORM
  # ----------------------------------------------------------------------------
  networking.hostName = "mba-jchambers";
  nixpkgs.hostPlatform = "aarch64-linux";

  # Asahi Apple Silicon Package Overlay
  nixpkgs.overlays = [
    inputs.apple-silicon.overlays.apple-silicon-overlay
  ];

  # ----------------------------------------------------------------------------
  # ASAHI / APPLE SILICON HARDWARE CONFIGURATION
  # ----------------------------------------------------------------------------
  hardware.asahi = {
    enable = true;
    # Configures PipeWire/WirePlumber with speaker protection limits
    setupAsahiSound = true;
    # Path to vendor firmware extracted from macOS during Asahi installation
    peripheralFirmwareDirectory = "/boot/vendorfw";
  };

  # ----------------------------------------------------------------------------
  # STORAGE & FILE SYSTEMS
  # (Standard Asahi partition labels created by the official installer)
  # ----------------------------------------------------------------------------
  fileSystems."/" = {
    device = lib.mkDefault "/dev/disk/by-label/asahi-root";
    fsType = lib.mkDefault "ext4";
  };

  fileSystems."/boot" = {
    device = lib.mkDefault "/dev/disk/by-label/asahi-boot";
    fsType = lib.mkDefault "vfat";
  };

  # ----------------------------------------------------------------------------
  # BOOTLOADER (Apple Silicon UEFI / m1n1 chainloader)
  # ----------------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  # Apple Silicon firmware restricts runtime EFI variable mutation
  boot.loader.efi.canTouchEfiVariables = false;

  # ----------------------------------------------------------------------------
  # REMOTE SSH ACCESS & SECRETS
  # ----------------------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.jchambers.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG7l6ZZz1UQBiZ9Xlg0xdvNRJGaeWwhIPktBOcbhsVZw jchambers@308-225660"
  ];

  system.stateVersion = "24.11";
}
