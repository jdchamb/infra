{ config, pkgs, inputs, ... }:

{
  imports = [
    # --- Register Upstream Third-Party Blueprints ---
    inputs.sops-nix.nixosModules.sops


    # --- Machine Hardware Layer ---
    "${inputs.self}/hardware/wrk-dt01-hw.nix"

    # --- Core Bricks (Shared Brain) ---
    "${inputs.self}/modules/core-system.nix"
    "${inputs.self}/modules/core-boot.nix"
    "${inputs.self}/modules/core-network.nix"
    "${inputs.self}/modules/core-user.nix"
    "${inputs.self}/modules/core-audio.nix"
    "${inputs.self}/modules/core-printing.nix"
    "${inputs.self}/modules/core-fonts.nix"
    "${inputs.self}/modules/core-cachix.nix"
    "${inputs.self}/modules/core-hw-utils.nix"
    "${inputs.self}/modules/core-sops.nix"

    # --- Desktop Environment Bricks ---
    # "${inputs.self}/modules/de-hyprland.nix"
    # "${inputs.self}/modules/de-niri.nix"

    # --- Application Bricks ---
    "${inputs.self}/modules/app-firefox.nix"
    "${inputs.self}/modules/app-ghostty.nix"
    "${inputs.self}/modules/app-remmina.nix"
    "${inputs.self}/modules/app-kitty.nix"
    "${inputs.self}/modules/app-digikam.nix"
    "${inputs.self}/modules/app-apple-tools.nix"
    "${inputs.self}/modules/app-normcap.nix"
    "${inputs.self}/modules/app-gimagereader.nix"
    "${inputs.self}/modules/app-tesseract.nix"
    "${inputs.self}/modules/app-kate.nix"

    # --- Development & Terminal Bricks ---
    "${inputs.self}/modules/dev-git.nix"
    "${inputs.self}/modules/dev-vim.nix"
    "${inputs.self}/modules/dev-neovim.nix"
    "${inputs.self}/modules/dev-zellij.nix"

    # --- Local Infrastructure Services ---
#   "${inputs.self}/modules/srv-ollama.nix"
#   "${inputs.self}/modules/srv-anythingllm.nix"
    "${inputs.self}/modules/srv-samba.nix"
    "${inputs.self}/modules/308-storage.nix"
    "${inputs.self}/modules/sops-tools.nix"
  ];

  # Host-Specific Identity (The "Body")
  networking.hostName = "wrk-dt01";

  # Do NOT change this value.
  system.stateVersion = "24.11";
}
