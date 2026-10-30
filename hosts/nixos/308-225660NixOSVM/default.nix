# ==============================================================================
# HOST CONFIGURATION: hosts/nixos/308-225660NixOSVM/default.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Apple Silicon Paravirtualized ARM64 Linux VM):
#   Lightweight, paravirtualized NixOS guest machine running locally on Apple Silicon
#   macOS (via UTM or Apple Virtualization.framework):
#     - Architecture: aarch64-linux (runs native ARM64 instructions at near-bare-metal speed)
#     - Storage Layout: Declarative Disko partitioning on virtual disk ('/dev/vda')
#     - Hypervisor Integration: QEMU guest agent (clean shutdown/time sync) and
#       SPICE agent (shared clipboard between Mac and VM, automatic screen resizing)
#     - Remote Management: SSH server on port 22 with authorized public keys
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Developers on macOS frequently need a native Linux environment to compile Linux
#   binaries, test Docker containers, or experiment with NixOS configurations.
#   - Paravirtualization ('VirtIO'): Instead of emulating a slow physical hard disk,
#     VirtIO provides direct software channels between the macOS host and Linux guest,
#     giving the VM near-native disk read/write speeds.
#   - Native ARM64 ('aarch64-linux'): Because modern Macs run Apple Silicon (M1/M2/M3/M4)
#     chips, this VM runs native ARM64 Linux code without needing slow x86 Rosetta translation.
#   - SPICE Agent ('spice-vdagentd'): Makes the VM feel like a native Mac window by
#     synchronizing the clipboard (copy on Mac, paste in Linux) and automatically
#     adjusting the Linux desktop resolution when you resize the UTM window.
#
# OPERATIONAL RUNBOOK FOR ADMINISTRATORS:
#   - Rebuild and activate configuration changes inside the VM:
#       rebuild
#     (Alias for: sudo nixos-rebuild switch --flake ~/src/infra#308-225660NixOSVM)
#   - Connect via SSH from the host Mac terminal:
#       ssh jchambers@<vm-ip-or-hostname>
# ==============================================================================

{ config, pkgs, inputs, ... }:

{
  # ----------------------------------------------------------------------------
  # MODULE COMPOSITION (Strict 1 Module = 1 Software or Service Mapping)
  # ----------------------------------------------------------------------------
  imports = [
    # Declarative Disko Layout: Formats and mounts virtual drive /dev/vda
    # CAUTION: Executing Disko wipes /dev/vda!
    (import ../../../modules/nixos/hardware/disko-standard.nix { device = "/dev/vda"; })

    # Unified Core NixOS Foundation (Project 19)
    ../../../modules/nixos/core/global.nix               # Timezone, locale, flakes, user
    ../../../modules/nixos/core/boot.nix                 # Mainline kernel & systemd-boot
    ../../../modules/nixos/core/audio.nix                # PipeWire audio subsystem
    ../../../modules/nixos/hardware/apple-keyboard.nix   # Apple keyboard Fn and NumLock fixes

    # Shared User & Developer Tools (1-to-1 Cross-Platform Modules)
    ../../../modules/shared/git.nix                             # Git version control & signing
    ../../../modules/shared/git-bug.nix                         # Distributed Git issue tracker
    ../../../modules/shared/tea.nix                             # Codeberg / Gitea CLI client
    ../../../modules/shared/lazygit.nix                         # Interactive terminal Git interface
    ../../../modules/shared/vim.nix                             # Classic lightweight editor
    ../../../modules/shared/neovim.nix                          # Modern Lua terminal IDE
    ../../../modules/shared/zellij.nix                          # Terminal workspace multiplexer
    ../../../modules/shared/ghostty.nix                         # Terminal emulator
    ../../../modules/shared/security/yubikey-nordic.nix         # Security key support
    ../../../modules/shared/security/gpg.nix                    # GnuPG agent & smartcard support
    ../../../modules/shared/security/vaultwarden-client.nix     # CLI vault access (rbw)
    ../../../modules/shared/storage/file-integrity-monitor.nix  # Bitrot detection utility
  ];

  # ----------------------------------------------------------------------------
  # HOST IDENTITY & HARDWARE PLATFORM
  # ----------------------------------------------------------------------------
  networking.hostName = "308-225660NixOSVM";

  # Target architecture: 64-bit ARM for Apple Silicon virtualization
  nixpkgs.hostPlatform = "aarch64-linux";

  # Paravirtualized VirtIO Storage & Bus Drivers for Apple Virtualization / UTM
  boot.initrd.availableKernelModules = [
    "virtio_pci"   # VirtIO over PCI bus
    "virtio_blk"   # High-speed virtual block device (virtual hard disk)
    "virtio_scsi"  # Virtual SCSI controller
    "xhci_pci"     # USB 3.0 controller
    "usbhid"       # USB keyboard and mouse pass-through
  ];

  # ----------------------------------------------------------------------------
  # GUEST-HOST INTEGRATION UTILITIES
  # ----------------------------------------------------------------------------
  # QEMU Guest Agent: Enables host hypervisor to issue clean shutdowns and time-sync
  services.qemuGuest.enable = true;

  # SPICE Agent: Enables host-to-guest clipboard copy/paste and automatic display resizing
  services.spice-vdagentd.enable = true;

  # ----------------------------------------------------------------------------
  # REMOTE MANAGEMENT VIA OPENSSH
  # ----------------------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      # Prohibit password login for root
      PermitRootLogin = "prohibit-password";
      # Allow password authentication for development VM convenience
      PasswordAuthentication = true;
    };
  };

  # Open port 22 in Linux firewall for SSH connections
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Pre-authorize administrative SSH public key
  users.users.jchambers = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcOrpJmrhwkpgc1LB7dEkjDRFDthgbFra0XOqfAtAkL joshua@chambers-net.org"
    ];
  };

  # State version tracks initial system schema compatibility
  system.stateVersion = "24.11";
}
