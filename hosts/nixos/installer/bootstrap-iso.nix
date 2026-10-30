# ==============================================================================
# HOST CONFIGURATION: hosts/nixos/installer/bootstrap-iso.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 1 & 20 — Zero-Touch Bootstrap ISO):
#   Builds a bootable, minimal console installation ISO image designed for fast,
#   headless bare-metal provisioning:
#     - Inherits 'modules/nixos/core/bootstrap.nix' for automatic OpenSSH daemon
#       startup and pre-baked administrative SSH public key authentication.
#     - Automatically clones the 'infra' Git repository into '/home/nixos/src/infra'
#       upon acquiring network connectivity.
#     - Pre-loads 'bootstrap-install' and 'bootstrap-age-key' utilities for rapid
#       Disko partitioning and SOPS secret staging.
#     - Configured with zstd level-1 SquashFS compression for ultra-fast ISO build times.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   - Generic Linux live USBs require attaching a display, keyboard, and mouse to the
#     new machine, then manually setting up Wi-Fi, partitions, and users.
#   - This custom Bootstrap ISO turns any machine into an instantly manageable node:
#       1. Write this ISO to a USB flash drive.
#       2. Plug it into any target server or laptop and boot from USB.
#       3. Walk away. The machine boots headlessly, brings up NetworkManager,
#          starts SSH, and pulls the latest Nix infrastructure code from Codeberg.
#       4. You SSH into it from your laptop ('ssh nixos@<ip>') and run a single command
#          ('bootstrap-install <hostname>') to deploy the full machine profile.
#   - Fast Compression ('isoImage.squashfsCompression'): Building a live ISO normally
#     spends 15-20 minutes compressing data with maximum xz compression. By using
#     'zstd -Xcompression-level 1', Nix compiles the complete bootable ISO in under
#     two minutes while keeping the image compact enough for any standard USB drive.
#
# HOW TO USE:
#   - Build the ISO image derivation:
#       nix build .#nixosConfigurations.bootstrap-iso.config.system.build.isoImage
#   - Flash the generated ISO to a USB flash drive (replace /dev/sdX carefully!):
#       sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress conv=fsync
#   - Connect to the booted machine over the local network:
#       ssh nixos@<target-ip>
# ==============================================================================

{ pkgs, modulesPath, inputs, ... }:

{
  imports = [
    # --------------------------------------------------------------------------
    # 1. Upstream Nixpkgs Minimal CD Profile
    # Provides Linux kernel, busybox/systemd initrd, and bootable ISO filesystem glue.
    # --------------------------------------------------------------------------
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    # --------------------------------------------------------------------------
    # 2. Common Fleet Infrastructure & Tooling
    # --------------------------------------------------------------------------
    "${inputs.self}/modules/common/cachix.nix"           # Binary substituters
    "${inputs.self}/modules/common/sops-tools.nix"       # sops & age binaries
    "${inputs.self}/modules/shared/git.nix"               # Git version control
    "${inputs.self}/modules/shared/neovim.nix"            # Terminal text editor
    "${inputs.self}/modules/nixos/core/system.nix"        # Timezone, locale, flakes
    "${inputs.self}/modules/nixos/core/network.nix"       # NetworkManager & firewall
    "${inputs.self}/modules/nixos/core/user.nix"          # 'jchambers' admin account
    "${inputs.self}/modules/nixos/core/bootstrap.nix"     # Headless SSH, auto-clone, scripts
    "${inputs.self}/modules/nixos/hardware/hw-utils.nix"  # Partitioning and disk tools
  ];

  # --------------------------------------------------------------------------
  # Interactive Shell Environment
  # --------------------------------------------------------------------------
  # Activate interactive Zsh shell inside the live boot environment
  programs.zsh.enable = true;

  # Enforce strict open-source software license filtering for this installation medium
  nixpkgs.config.allowUnfree = false;

  # --------------------------------------------------------------------------
  # SquashFS ISO Compression Tuning
  # Level 1 zstd yields lightning-fast compilation times during build iterations
  # --------------------------------------------------------------------------
  isoImage.squashfsCompression = "zstd -Xcompression-level 1";
}
