{ config, pkgs, inputs, ... }:

{
  imports = [
    # --- Shared Hardware Base Layer ---
    "${inputs.self}/hardware/universal-baseline.nix"

    # --- Core Bricks (Shared Brain) ---
    "${inputs.self}/modules/core-system.nix"
    "${inputs.self}/modules/core-boot.nix"
    "${inputs.self}/modules/core-network.nix"
    "${inputs.self}/modules/core-user.nix"
    "${inputs.self}/modules/core-vim.nix"
    "${inputs.self}/modules/core-audio.nix"
    "${inputs.self}/modules/core-printing.nix"
    "${inputs.self}/modules/core-git.nix"
    "${inputs.self}/modules/core-firefox.nix"

    # --- Desktop Bricks (Interchangeable UI) ---
    "${inputs.self}/modules/gui-plasma.nix"
    # "${inputs.self}/modules/gui-hyprland.nix"
    # "${inputs.self}/modules/gui-niri.nix"

    # --- Hardware Specific Bricks ---
    "${inputs.self}/modules/hardware-graphics.nix"

    # --- Tooling Bricks (Optional Applications) ---
    "${inputs.self}/modules/tooling-remmina.nix"
    "${inputs.self}/modules/tooling-hardware-utils.nix"
    "${inputs.self}/modules/tooling-ghostty.nix"
    "${inputs.self}/modules/tooling-zellij.nix"
    "${inputs.self}/modules/tooling-ollama.nix"
    "${inputs.self}/modules/tooling-anythingllm.nix"
  ];

  # Host-Specific Identity (The "Body")
  networking.hostName = "wrk-dt01";

  # Do NOT change this value.
  system.stateVersion = "24.11";
}
