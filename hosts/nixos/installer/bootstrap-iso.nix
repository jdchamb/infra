# ==============================================================================
# HOST CONFIGURATION: hosts/nixos/installer/bootstrap-iso.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 1 & 20):
#   Builds a lightweight, fast-compiling console installation ISO designed for
#   headless network provisioning. Imports 'modules/nixos/core/bootstrap.nix'
#   to embed SSH public keys, auto-clone the 'infra' repository on startup, and
#   provide 'bootstrap-age-key' and 'bootstrap-install'.
# ==============================================================================

{ pkgs, modulesPath, inputs, ... }:

{
  imports = [
    # 1. Base channel profile required to construct a bootable minimal console ISO
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    # 2. Inherit common, core, and zero-touch bootstrap configurations (Projects 1 & 20)
    "${inputs.self}/modules/common/cachix.nix"
    "${inputs.self}/modules/common/sops-tools.nix"
    "${inputs.self}/modules/shared/git.nix"
    "${inputs.self}/modules/shared/neovim.nix"
    "${inputs.self}/modules/nixos/core/system.nix"
    "${inputs.self}/modules/nixos/core/network.nix"
    "${inputs.self}/modules/nixos/core/user.nix"
    "${inputs.self}/modules/nixos/core/bootstrap.nix"
    "${inputs.self}/modules/nixos/hardware/hw-utils.nix"
  ];

  # Safely activate native NixOS Zsh
  programs.zsh.enable = true;

  # Force strict open-source package parameters for the live build environment
  nixpkgs.config.allowUnfree = false;

  # Fast zstd level-1 SquashFS compression for rapid local ISO build iterations
  isoImage.squashfsCompression = "zstd -Xcompression-level 1";
}
