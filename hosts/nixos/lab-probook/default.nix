# ==============================================================================
# HOST CONFIGURATION: hosts/nixos/lab-probook/default.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 11 — HP ProBook Lab Cluster Blueprint):
#   Parameterized host blueprint for the 5-node physical validation lab cluster
#   constructed from workspace HP ProBook laptops ('lab-pb01' through 'lab-pb05').
#   Each node receives:
#     - Declarative Disko GPT/Ext4 storage layout on the specified disk ('/dev/nvme0n1').
#     - Unified 'core/global.nix' baseline + 'hardware/hp-probook.nix' closed-lid clamshell mode.
#     - Network UPS Tools (NUT) follower client ('services/nut.nix') to shut down
#       cleanly during district or lab power outages.
#     - Cockpit web console ('services/cockpit.nix') on port 9090 for web monitoring.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   - Parameterized Host Function: Instead of copying and maintaining five nearly
#     identical configuration files for five lab laptops, this file is written as a
#     Nix function: '{ hostName ? "lab-pb01", diskDevice ? "/dev/nvme0n1" }'.
#     In 'flake.nix', you instantiate each node simply by passing its unique hostname
#     (e.g., 'lab-pb02', 'lab-pb03') into this template.
#   - Clamshell Lab Environment: These laptops sit on a dedicated shelf with lids
#     closed 24/7. They run full server workloads, act as test benches for new services,
#     and validate network throughput using iperf3 and nmap.
#   - NUT UPS Protection: Each lab node acts as a network client to the central UPS.
#     If the building loses electrical power, the master UPS alerts the ProBooks to
#     sync disk buffers and shut down gracefully before the batteries deplete.
#   - 'system.stateVersion = "24.11"': Tells NixOS which version of stateful defaults
#     were used on first install. NEVER change this value during routine upgrades,
#     as doing so can alter default data directory layouts or database formats.
#
# HOW TO USE:
#   - Build or deploy a specific lab node using Colmena or nixos-rebuild:
#       colmena apply --on lab-pb01
#   - Connect via SSH:
#       ssh jchambers@lab-pb01.local
#   - Web management dashboard:
#       https://<probook-ip>:9090 (Cockpit)
# ==============================================================================

{ hostName ? "lab-pb01", diskDevice ? "/dev/nvme0n1" }:

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # --------------------------------------------------------------------------
    # 1. Declarative Disko Storage Architecture
    # Partitions and formats the target NVMe/SATA SSD with ESP + Ext4 root.
    # CAUTION: Executing Disko wipes the target drive!
    # --------------------------------------------------------------------------
    (import ../../../modules/nixos/hardware/disko-standard.nix { device = diskDevice; })

    # --------------------------------------------------------------------------
    # 2. Unified Global Baseline & ProBook Hardware Profiles
    # --------------------------------------------------------------------------
    ../../../modules/nixos/core/global.nix             # Timezone, Flakes, user accounts, caches
    ../../../modules/nixos/core/boot.nix               # Mainline kernel & systemd-boot
    ../../../modules/nixos/core/impermanence.nix       # Stateless root option definitions
    ../../../modules/nixos/hardware/hp-probook.nix     # Closed-lid mode, Intel microcode, thermald

    # --------------------------------------------------------------------------
    # 3. Shared Cross-Platform Developer & Operations Tools
    # --------------------------------------------------------------------------
    ../../../modules/shared/git.nix                            # Git configuration and SSH signing
    ../../../modules/shared/git-bug.nix                        # Offline Git issue tracking
    ../../../modules/shared/lazygit.nix                        # Interactive terminal UI for Git
    ../../../modules/shared/vim.nix                            # Classic terminal editor
    ../../../modules/shared/neovim.nix                         # Modern Lua-based editor
    ../../../modules/shared/zellij.nix                         # Terminal multiplexer
    ../../../modules/shared/security/yubikey-nordic.nix        # Hardware security key support
    ../../../modules/shared/storage/file-integrity-monitor.nix # Bitrot detection utility

    # --------------------------------------------------------------------------
    # 4. Network Diagnostic & Throughput Testing Utilities
    # --------------------------------------------------------------------------
    ../../../modules/nixos/apps/iperf3.nix  # Network bandwidth benchmark client/server
    ../../../modules/nixos/apps/nmap.nix    # Network port and subnet security scanner

    # --------------------------------------------------------------------------
    # 5. Active Lab Services
    # Individual services can be toggled on or uncommented based on each node's role.
    # --------------------------------------------------------------------------
    ../../../modules/nixos/services/nut.nix      # Network UPS monitoring client
    ../../../modules/nixos/services/cockpit.nix  # Web-based server administration GUI (port 9090)

    # Optional Lab Services (Uncomment on designated service nodes):
    # ../../../modules/nixos/services/adguard-home.nix
    # ../../../modules/nixos/services/harmonia.nix
    # ../../../modules/nixos/services/forgejo-runner.nix
    # ../../../modules/nixos/services/forgejo.nix
    # ../../../modules/nixos/services/vaultwarden.nix
    # ../../../modules/nixos/services/snipeit.nix
    # ../../../modules/nixos/services/zammad.nix
    # ../../../modules/nixos/services/silverbullet.nix
    # ../../../modules/nixos/services/fog-pxe.nix
  ];

  # --------------------------------------------------------------------------
  # Node Networking Identity
  # --------------------------------------------------------------------------
  networking.hostName = hostName;

  # --------------------------------------------------------------------------
  # Service Defaults
  # --------------------------------------------------------------------------
  # Configure this node as a network client (follower) to the central UPS server
  services.fleet.nut.mode = lib.mkDefault "netclient";

  # --------------------------------------------------------------------------
  # NixOS State Version
  # Tracks initial state schema compatibility. Do NOT touch during system upgrades!
  # --------------------------------------------------------------------------
  system.stateVersion = "24.11";
}
