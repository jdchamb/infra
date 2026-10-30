# ==============================================================================
# HOST CONFIGURATION: hosts/nixos/installer/recovery-iso.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 1 & 20 — Graphical Recovery & Rescue ISO):
#   Constructs a full KDE Plasma 6 graphical rescue and hardware maintenance live ISO
#   equipped with:
#     - Hardware diagnostic & wiping utilities ('nwipe', 'nvme-cli', 'sedutil', 'smartctl').
#     - Remote desktop assistance clients (Remmina RDP/VNC, KRDC).
#     - Graphical disk and filesystem managers (KDE Partition Manager, Filelight).
#     - Automatic systemd on-demand CIFS mounting of USD 308 district technician resources
#       at '/mnt/308-storage'.
#     - Headless OpenSSH daemon and repository bootstrap automation ('core/bootstrap.nix').
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   While 'bootstrap-iso.nix' is a minimal text-only console designed for fast automated
#   installs, field technicians often need a comprehensive graphical "Swiss Army Knife"
#   live USB when troubleshooting broken hardware in classrooms or server rooms:
#     1. Visual Disk Partitioning: KDE Partition Manager lets you inspect corrupted
#        partition tables and format drives with an intuitive mouse interface.
#     2. Disk Space Visualizer: Filelight displays interactive sunburst charts showing
#        which directories or logs are filling up a user's hard drive.
#     3. Remote Support: Remmina and KRDC allow technicians to establish RDP sessions
#        into Windows servers or VNC into Macs directly from the live USB.
#     4. District Resource Gateway: Automatically mounts district software and drivers
#        from '//cloud-storage.usd308.com/Resources/TSC' to '/mnt/308-storage' on demand.
#
# HOW TO USE:
#   - Build the ISO image derivation:
#       nix build .#nixosConfigurations.recovery-iso.config.system.build.isoImage
#   - Flash to USB drive (replace /dev/sdX carefully!):
#       sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress conv=fsync
#   - Boot from USB to enter the full KDE Plasma 6 desktop environment.
#   - Open Terminal, Partition Manager, or Filelight from the desktop menu.
# ==============================================================================

{ pkgs, modulesPath, inputs, ... }:

{
  imports = [
    # --------------------------------------------------------------------------
    # 1. Upstream Nixpkgs Graphical Plasma 6 Live Profile
    # Boots into an accelerated KDE Plasma 6 Wayland desktop session with Calamares.
    # --------------------------------------------------------------------------
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"

    # --------------------------------------------------------------------------
    # 2. Shared Base Platform & Zero-Touch Bootstrap Configurations
    # --------------------------------------------------------------------------
    "${inputs.self}/modules/common/fonts.nix"           # Developer typography (JetBrains Mono)
    "${inputs.self}/modules/common/cachix.nix"          # Binary cache mirrors
    "${inputs.self}/modules/common/sops-tools.nix"      # sops and age CLI packages
    "${inputs.self}/modules/shared/git.nix"              # Git version control
    "${inputs.self}/modules/shared/neovim.nix"           # Terminal text editor
    "${inputs.self}/modules/nixos/core/system.nix"       # Timezone, locale, flakes
    "${inputs.self}/modules/nixos/core/network.nix"      # NetworkManager & firewall
    "${inputs.self}/modules/nixos/core/user.nix"         # Primary 'jchambers' account
    "${inputs.self}/modules/nixos/core/bootstrap.nix"    # SSH server, keys, auto-clone
    "${inputs.self}/modules/nixos/hardware/hw-utils.nix" # Smartmontools, nwipe, nvme-cli

    # --------------------------------------------------------------------------
    # 3. Graphical Fleet Recovery & Remote Support Applications
    # --------------------------------------------------------------------------
    "${inputs.self}/modules/nixos/apps/remmina.nix"          # Multi-protocol RDP/VNC/SSH GUI client
    "${inputs.self}/modules/nixos/apps/krdc.nix"             # KDE Remote Desktop Client
    "${inputs.self}/modules/nixos/apps/partitionmanager.nix" # KDE Partition Manager GUI
    "${inputs.self}/modules/nixos/apps/filelight.nix"        # Visual disk space usage analyzer
  ];

  # --------------------------------------------------------------------------
  # Software License Policy
  # Enforce strict open-source package parameters for the live rescue environment
  # --------------------------------------------------------------------------
  nixpkgs.config.allowUnfree = false;

  # --------------------------------------------------------------------------
  # District Resource Share Automount
  # Mounts the USD 308 Technology Resource share on demand via systemd-automount.
  # If the network is unavailable, it times out in 5 seconds without freezing boot.
  # --------------------------------------------------------------------------
  fileSystems."/mnt/308-storage" = {
    device = "//cloud-storage.usd308.com/Resources/TSC";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [ "${automount_opts},guest,uid=1000,gid=100" ];
  };
}
