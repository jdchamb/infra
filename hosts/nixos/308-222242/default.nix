# ==============================================================================
# HOST CONFIGURATION: 308-222242 (Primary Workstation Node)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Primary bare-metal Linux production workstation for Joshua Chambers.
#   - Architecture: x86_64-linux (Intel Core / KVM)
#   - Operating System: NixOS Unstable
#   - Storage Layout: Managed in ./hardware.nix (ext4 root + vfat EFI)
#   - Secrets Management: SOPS / Age decryption into volatile tmpfs (/run/secrets)
#   - Desktop Environments: Hyprland, Niri, Sway, and KDE Plasma 6 (+ Krohnkite)
#   - Network Storage: Auto-mounting USD 308 CIFS/SMB storage shares
#
# OPERATIONAL RUNBOOK FOR SUCCESSORS:
#   - To apply changes on this workstation:
#       rebuild
#     (which executes: sudo nixos-rebuild switch --flake ~/src/infra#308-222242)
#   - To test changes before committing:
#       rebuild test
#   - To roll back a broken generation: Reboot and select a prior generation in systemd-boot.
# ==============================================================================

{ config, pkgs, inputs, ... }:

{
  # ----------------------------------------------------------------------------
  # MODULE COMPOSITION (1 Module = 1 Software or Service)
  # ----------------------------------------------------------------------------
  imports = [
    # 1. Machine Hardware & Apple Keyboard Layer (Projects 6 & 8)
    ./hardware.nix
    ../../../modules/nixos/hardware/apple-keyboard.nix

    # 2. Unified Global Baseline & Core NixOS Foundation (Project 19)
    ../../../modules/nixos/core/global.nix
    ../../../modules/nixos/core/boot.nix
    ../../../modules/nixos/core/audio.nix
    ../../../modules/nixos/core/printing.nix
    ../../../modules/nixos/core/sops.nix
    ../../../modules/nixos/core/nixos-anywhere.nix
    ../../../modules/nixos/core/deploy-rs.nix
    ../../../modules/nixos/core/colmena.nix

    # 3. Shared User, Developer & Security Tools (1-to-1 Cross-Platform Modules)
    ../../../modules/shared/git.nix
    ../../../modules/shared/git-bug.nix
    ../../../modules/shared/tea.nix
    ../../../modules/shared/lazygit.nix
    ../../../modules/shared/vim.nix
    ../../../modules/shared/neovim.nix
    ../../../modules/shared/zellij.nix
    ../../../modules/shared/ghostty.nix
    ../../../modules/shared/security/yubikey-nordic.nix
    ../../../modules/shared/security/gpg.nix
    ../../../modules/shared/security/vaultwarden-client.nix
    ../../../modules/shared/security/keepassxc.nix
    ../../../modules/shared/remote/rustdesk.nix
    ../../../modules/shared/storage/file-integrity-monitor.nix

    # 4. Login Manager, Wayland Compositors & Tiling Plugins
    ../../../modules/nixos/desktop/greetd.nix
    ../../../modules/nixos/desktop/hyprland.nix
    ../../../modules/nixos/desktop/niri.nix
    ../../../modules/nixos/desktop/sway.nix
    ../../../modules/nixos/desktop/plasma.nix
    ../../../modules/nixos/desktop/krohnkite.nix

    # 5. Production Workstation Applications (1-to-1 Modules)
    ../../../modules/nixos/apps/firefox.nix
    ../../../modules/nixos/apps/remmina.nix
    ../../../modules/nixos/apps/krdc.nix
    ../../../modules/nixos/apps/tigervnc.nix
    ../../../modules/nixos/apps/digikam.nix
    ../../../modules/nixos/apps/apple-tools.nix
    ../../../modules/nixos/apps/adb.nix
    ../../../modules/nixos/apps/scrcpy.nix
    ../../../modules/nixos/apps/dymo.nix
    ../../../modules/nixos/apps/glabels.nix
    ../../../modules/nixos/apps/1password.nix
    ../../../modules/nixos/apps/bitwarden.nix
    ../../../modules/nixos/apps/vlc.nix
    ../../../modules/nixos/apps/media.nix
    ../../../modules/nixos/apps/kate.nix
    ../../../modules/nixos/apps/dolphin.nix
    ../../../modules/nixos/apps/partitionmanager.nix
    ../../../modules/nixos/apps/filelight.nix
    ../../../modules/nixos/apps/kdf.nix
    ../../../modules/nixos/apps/isoimagewriter.nix
    ../../../modules/nixos/apps/gimagereader.nix
    ../../../modules/nixos/apps/normcap.nix
    ../../../modules/nixos/apps/tesseract.nix
    ../../../modules/nixos/apps/wireshark.nix
    ../../../modules/nixos/apps/minicom.nix
    ../../../modules/nixos/apps/iperf3.nix
    ../../../modules/nixos/apps/nmap.nix
    ../../../modules/nixos/apps/powershell.nix
    ../../../modules/nixos/apps/wimlib.nix
    ../../../modules/nixos/apps/kernel-lfs-tools.nix

    # 6. Infrastructure Services & Network Shares
    ../../../modules/nixos/services/samba.nix
    ../../../modules/nixos/services/snipeit.nix
    ../../../modules/nixos/services/308-storage.nix
  ];

  # ----------------------------------------------------------------------------
  # HOST IDENTITY
  # ----------------------------------------------------------------------------
  networking.hostName = "308-222242";

  # NixOS State Version: Determines backward compatibility defaults for stateful data.
  # Do NOT change this value without reading the release notes.
  system.stateVersion = "24.11";
}
