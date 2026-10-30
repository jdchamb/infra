# ==============================================================================
# HOST CONFIGURATION: hosts/nixos/308-222242/default.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Primary Physical Production Workstation):
#   Primary bare-metal Linux production workstation for Joshua Chambers.
#   - Architecture: x86_64-linux (Intel Core / KVM virtualization)
#   - Storage Layout: Declared in ./hardware.nix (Ext4 root + vfat EFI partition)
#   - Secrets Management: SOPS / Age decryption into volatile tmpfs (/run/secrets)
#   - Desktop Sessions: Hyprland, Niri, Sway, and KDE Plasma 6 (+ Krohnkite)
#   - Network Storage: Auto-mounting USD 308 CIFS/SMB storage shares via 308-storage.nix
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   In NixOS, a "host configuration" acts like the master blueprints of a building.
#   Instead of writing huge walls of code in one file, this configuration cleanly
#   imports specialized modules ("bricks") adhering to the strict "1 module = 1 software"
#   standard:
#     - Hardware layer ('hardware.nix', 'apple-keyboard.nix'): configures CPU, disks, and keys.
#     - Core layer ('global.nix', 'boot.nix', 'audio.nix'): handles bootloader, sound, users.
#     - Shared layer ('git.nix', 'neovim.nix', 'zellij.nix'): cross-platform developer CLI tools.
#     - Desktop layer ('plasma.nix', 'hyprland.nix', 'greetd.nix'): Wayland compositors and login.
#     - App layer: 27 dedicated application modules for technician and admin workflows.
#     - Service layer ('samba.nix', 'snipeit.nix', '308-storage.nix'): network shares and APIs.
#
# OPERATIONAL RUNBOOK FOR ADMINISTRATORS & SUCCESSORS:
#   - Rebuild and activate configuration changes:
#       rebuild
#     (Alias for: sudo nixos-rebuild switch --flake ~/src/infra#308-222242)
#   - Test changes temporarily without updating the bootloader:
#       rebuild test
#   - Safe Rollback: If an update ever fails or breaks graphics, reboot the PC and
#     select any previous generation in the systemd-boot menu to boot the known-good state.
# ==============================================================================

{ config, pkgs, inputs, ... }:

{
  # ----------------------------------------------------------------------------
  # MODULE COMPOSITION (Strict 1 Module = 1 Software or Service Mapping)
  # ----------------------------------------------------------------------------
  imports = [
    # --------------------------------------------------------------------------
    # 1. Machine Hardware & Peripheral Layer
    # --------------------------------------------------------------------------
    ./hardware.nix                                      # Physical CPU microcode, drives, initrd
    ../../../modules/nixos/hardware/apple-keyboard.nix  # Top-row F1-F12 Fn swap & NumLock fix

    # --------------------------------------------------------------------------
    # 2. Unified Global Baseline & Core Operating System Infrastructure
    # --------------------------------------------------------------------------
    ../../../modules/nixos/core/global.nix          # Unified baseline: timezone, locale, GC, user
    ../../../modules/nixos/core/boot.nix            # Mainline Linux kernel & systemd-boot
    ../../../modules/nixos/core/audio.nix           # PipeWire low-latency multimedia graph engine
    ../../../modules/nixos/core/printing.nix        # CUPS print spooler & Avahi mDNS discovery
    ../../../modules/nixos/core/sops.nix            # Runtime Age/SOPS secret decryption to RAM
    ../../../modules/nixos/core/nixos-anywhere.nix  # Remote kexec network installation tool
    ../../../modules/nixos/core/deploy-rs.nix       # Push-button remote fleet deployment engine
    ../../../modules/nixos/core/colmena.nix         # Parallel tag-based multi-host deployment

    # --------------------------------------------------------------------------
    # 3. Shared Cross-Platform Developer & Security Tools
    # --------------------------------------------------------------------------
    ../../../modules/shared/git.nix                             # Git version control & SSH signing
    ../../../modules/shared/git-bug.nix                         # Distributed Git issue tracker
    ../../../modules/shared/tea.nix                             # Codeberg / Gitea / Forgejo CLI client
    ../../../modules/shared/lazygit.nix                         # Interactive terminal Git interface
    ../../../modules/shared/vim.nix                             # Classic lightweight terminal editor
    ../../../modules/shared/neovim.nix                          # Modern Lua-based terminal IDE
    ../../../modules/shared/zellij.nix                          # Terminal workspace multiplexer
    ../../../modules/shared/ghostty.nix                         # GPU-accelerated terminal emulator
    ../../../modules/shared/security/yubikey-nordic.nix         # FIDO2 hardware security keys
    ../../../modules/shared/security/gpg.nix                    # GnuPG agent and smartcard daemon
    ../../../modules/shared/security/vaultwarden-client.nix     # CLI vault access (rbw, bitwarden-cli)
    ../../../modules/shared/security/keepassxc.nix              # Offline encrypted password database
    ../../../modules/shared/remote/rustdesk.nix                 # Open-source remote desktop client
    ../../../modules/shared/storage/file-integrity-monitor.nix  # Bitrot detection & hash audit

    # --------------------------------------------------------------------------
    # 4. Display Manager & Wayland Compositor Environments
    # --------------------------------------------------------------------------
    ../../../modules/nixos/desktop/greetd.nix     # ReGreet / Cage Wayland login screen
    ../../../modules/nixos/desktop/hyprland.nix   # Dynamic GPU-accelerated tiling compositor
    ../../../modules/nixos/desktop/niri.nix       # Horizontal scrollable ribbon compositor
    ../../../modules/nixos/desktop/sway.nix       # Deterministic i3-compatible Wayland compositor
    ../../../modules/nixos/desktop/plasma.nix     # KDE Plasma 6 full desktop environment
    ../../../modules/nixos/desktop/krohnkite.nix  # Automated KWin window tiling plugin

    # --------------------------------------------------------------------------
    # 5. Production Workstation Applications (1-to-1 Modules)
    # --------------------------------------------------------------------------
    ../../../modules/nixos/apps/firefox.nix           # Hardened web browser
    ../../../modules/nixos/apps/remmina.nix           # Remote Desktop (RDP/VNC/SSH) client
    ../../../modules/nixos/apps/krdc.nix              # KDE Remote Desktop viewer
    ../../../modules/nixos/apps/tigervnc.nix          # High-performance VNC viewer
    ../../../modules/nixos/apps/digikam.nix           # Photo management & EXIF metadata tagging
    ../../../modules/nixos/apps/apple-tools.nix       # ideviceinstaller, ifuse, iOS utilities
    ../../../modules/nixos/apps/adb.nix               # Android Debug Bridge & fastboot tools
    ../../../modules/nixos/apps/scrcpy.nix            # Low-latency Android screen mirroring
    ../../../modules/nixos/apps/dymo.nix              # DYMO LabelWriter drivers & CUPS filters
    ../../../modules/nixos/apps/glabels.nix           # Barcode & asset label design software
    ../../../modules/nixos/apps/1password.nix         # 1Password desktop GUI and CLI client
    ../../../modules/nixos/apps/bitwarden.nix         # Bitwarden desktop client
    ../../../modules/nixos/apps/vlc.nix               # VLC media player
    ../../../modules/nixos/apps/media.nix             # Handbrake, Audacity, multimedia toolchain
    ../../../modules/nixos/apps/kate.nix              # KDE Kate editor with Nix LSP and snippets
    ../../../modules/nixos/apps/dolphin.nix           # KDE Dolphin file manager (optimized for SMB)
    ../../../modules/nixos/apps/partitionmanager.nix  # KDE Partition Manager GUI
    ../../../modules/nixos/apps/filelight.nix         # Visual disk usage space analyzer
    ../../../modules/nixos/apps/kdf.nix               # Disk free space viewer
    ../../../modules/nixos/apps/isoimagewriter.nix    # ISO bootable flash drive writer
    ../../../modules/nixos/apps/gimagereader.nix      # Graphical frontend for Tesseract OCR
    ../../../modules/nixos/apps/normcap.nix           # Screen-capture OCR text extraction tool
    ../../../modules/nixos/apps/tesseract.nix         # Optical Character Recognition engine
    ../../../modules/nixos/apps/wireshark.nix         # Network packet inspection & pcap analyzer
    ../../../modules/nixos/apps/minicom.nix           # Serial console terminal (RS-232 / Cisco switches)
    ../../../modules/nixos/apps/iperf3.nix            # Network throughput benchmarking utility
    ../../../modules/nixos/apps/nmap.nix              # Network exploration & port scanner
    ../../../modules/nixos/apps/powershell.nix        # Microsoft PowerShell for Linux
    ../../../modules/nixos/apps/wimlib.nix            # Windows Imaging (.wim) creation & split tool
    ../../../modules/nixos/apps/kernel-lfs-tools.nix  # Silicon, LFS & Nix store debugging lab

    # --------------------------------------------------------------------------
    # 6. Infrastructure Services & Network Shares
    # --------------------------------------------------------------------------
    ../../../modules/nixos/services/samba.nix        # SMB client, GVfs Dolphin, and WSDD discovery
    ../../../modules/nixos/services/snipeit.nix      # Snipe-IT CSV export and MAC address scripts
    ../../../modules/nixos/services/308-storage.nix  # Auto-mounting USD 308 Windows network shares
  ];

  # ----------------------------------------------------------------------------
  # HOST IDENTITY
  # ----------------------------------------------------------------------------
  networking.hostName = "308-222242";

  # ----------------------------------------------------------------------------
  # STATE VERSION
  # Determines backward compatibility defaults for stateful data (e.g. databases,
  # user directories). Never change this value during routine NixOS upgrades.
  # ----------------------------------------------------------------------------
  system.stateVersion = "24.11";
}
