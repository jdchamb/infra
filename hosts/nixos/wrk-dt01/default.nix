{ config, pkgs, inputs, ... }:

{
  imports = [
    # --- Register Upstream Third-Party Blueprints ---
    inputs.sops-nix.nixosModules.sops

    # --- Machine Hardware Layer ---
    ./hardware.nix

    # --- Common Fleet Modules ---
    ../../../modules/common/fonts.nix
    ../../../modules/common/cachix.nix
    ../../../modules/common/sops-tools.nix

    # --- Shared User / Dev Modules ---
    ../../../modules/shared/git.nix
    ../../../modules/shared/vim.nix
    ../../../modules/shared/neovim.nix
    ../../../modules/shared/zellij.nix
    ../../../modules/shared/ghostty.nix

    # --- Core NixOS Foundation ---
    ../../../modules/nixos/core/system.nix
    ../../../modules/nixos/core/boot.nix
    ../../../modules/nixos/core/network.nix
    ../../../modules/nixos/core/user.nix
    ../../../modules/nixos/core/audio.nix
    ../../../modules/nixos/core/printing.nix
    ../../../modules/nixos/core/sops.nix
    ../../../modules/nixos/hardware/hw-utils.nix

    # --- Login Manager & Desktop Environments ---
    ../../../modules/nixos/desktop/greetd.nix
    ../../../modules/nixos/desktop/hyprland.nix
    ../../../modules/nixos/desktop/niri.nix
    ../../../modules/nixos/desktop/sway.nix

    # --- NixOS Applications ---
    ../../../modules/nixos/apps/firefox.nix
    ../../../modules/nixos/apps/remmina.nix
    ../../../modules/nixos/apps/digikam.nix
    ../../../modules/nixos/apps/apple-tools.nix
    ../../../modules/nixos/apps/kate.nix
    ../../../modules/nixos/apps/dolphin.nix
    ../../../modules/nixos/apps/partitionmanager.nix
    ../../../modules/nixos/apps/filelight.nix
    ../../../modules/nixos/apps/kdf.nix
    ../../../modules/nixos/apps/isoimagewriter.nix

    # --- NixOS Services & Network Mounts ---
    # ../../../modules/nixos/services/ollama.nix
    # ../../../modules/nixos/services/anythingllm.nix
    ../../../modules/nixos/services/samba.nix
    ../../../modules/nixos/services/308-storage.nix
  ];

  # Host-Specific Identity (The "Body")
  networking.hostName = "wrk-dt01";

  # Do NOT change this value.
  system.stateVersion = "24.11";
}
