# ==============================================================================
# HOST CONFIGURATION: hosts/nixos/lab-probook/default.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 11):
#   Parameterized blueprint for the 5-node physical validation lab constructed
#   out of workspace HP ProBooks ('lab-pb01' .. 'lab-pb05').
#   Each node receives:
#     - Declarative Disko GPT/Ext4 storage layout ('/dev/nvme0n1')
#     - Unified 'core/global.nix' baseline + 'hardware/hp-probook.nix' clamshell mode
#     - Optional Impermanence ('core/impermanence.nix') and NUT UPS follower client
#       ('services/nut.nix')
# ==============================================================================

{ hostName ? "lab-pb01", diskDevice ? "/dev/nvme0n1" }:

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # 1. Declarative Disko Partitioning Layout
    (import ../../../modules/nixos/hardware/disko-standard.nix { device = diskDevice; })

    # 2. Unified Global Baseline & HP ProBook Hardware Layer (Projects 11 & 19)
    ../../../modules/nixos/core/global.nix
    ../../../modules/nixos/core/boot.nix
    ../../../modules/nixos/core/impermanence.nix
    ../../../modules/nixos/hardware/hp-probook.nix

    # 3. Shared Cross-Platform Tools (1-to-1 Modules)
    ../../../modules/shared/git.nix
    ../../../modules/shared/git-bug.nix
    ../../../modules/shared/lazygit.nix
    ../../../modules/shared/vim.nix
    ../../../modules/shared/neovim.nix
    ../../../modules/shared/zellij.nix
    ../../../modules/shared/security/yubikey-nordic.nix
    ../../../modules/shared/storage/file-integrity-monitor.nix

    # 4. Network & Throughput Validation Tools (Projects 17 & 18)
    ../../../modules/nixos/apps/iperf3.nix
    ../../../modules/nixos/apps/nmap.nix

    # 5. Homelab & USD 308 Service Modules (Toggle or uncomment per lab node role)
    ../../../modules/nixos/services/nut.nix
    ../../../modules/nixos/services/cockpit.nix
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

  # Node Identity
  networking.hostName = hostName;

  # Configure Lab Nodes as NUT UPS Followers by default (Project 15)
  services.fleet.nut.mode = lib.mkDefault "netclient";

  # NixOS State Version
  system.stateVersion = "24.11";
}
