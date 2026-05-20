{ config, pkgs, ... }:

{
	imports = [
# The physical hardware scan
		./hardware-configuration.nix

# --- Core Bricks (Shared Brain) ---
			../../../modules/core/system.nix
			../../../modules/core/boot.nix
			../../../modules/core/network.nix
			../../../modules/core/user.nix
			../../../modules/core/vim.nix
			../../../modules/core/audio.nix
			../../../modules/core/printing.nix
			../../../modules/core/git.nix
			../../../modules/core/firefox.nix

# --- Desktop Bricks (Interchangeable) ---
			../../../modules/gui/plasma.nix
#			../../../modules/gui/hyprland.nix
#			../../../modules/gui/niri.nix

# --- Hardware Bricks (configure specifig hardware) ---
			../../../modules/hardware/graphics.nix

# --- Tooling Bricks (optional tools) ---
			../../../modules/tooling/remmina.nix
			../../../modules/tooling/hardware-utils.nix
			../../../modules/tooling/ghostty.nix
			../../../modules/tooling/zellij.nix
			../../../modules/tooling/ollama.nix
			../../../modules/tooling/anythingllm.nix

# --- Services bricks
];
# Host-Specific Identity (The "Body")
	networking.hostName = "nos-josh-work-desktop";

# Do NOT change this value.
	system.stateVersion = "24.11";
}
