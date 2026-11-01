# ==============================================================================
# HOST CONFIGURATION: hosts/nixos/nuc-game01/default.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Dedicated Sandboxed Game Server Host — NUC7i7DNFE):
#   Host configuration for the Intel NUC 7 Business (Dawson Canyon NUC7i7DNFE)
#   dedicated game server appliance.
#   - Hardware Profile: Intel Core i7-8650U, thermald fan control, UHD 620 VAAPI
#   - Storage Layout: Declarative Disko GPT / Ext4 NVMe layout (/dev/nvme0n1)
#   - Sandboxing: 100% containerized with Podman (pure FOSS, no subscriptions)
#   - Mutual Exclusion: Enforces "one game at a time" to dedicate 100% of CPU
#     cores and RAM to the active player session
#   - On-Demand Control: All game servers are configured with 'autoStart = false'
#     so your son can launch them on-demand via the OliveTin Web Dashboard (:1337)
#   - Save Persistence: All worlds, player data, and configurations persist in
#     '/var/lib/game-servers/<game>' across rebuilds and updates
#
# HOW TO USE:
#   - Rebuild or switch to this host:
#       sudo nixos-rebuild switch --flake ~/src/infra#nuc-game01
#   - Web Dashboard for kids (iPad/phone/laptop):
#       http://<nuc-ip>:1337 (OliveTin)
#   - CLI Admin:
#       game-ctl list
#       game-ctl switch minecraft
#       game-ctl backup minecraft
# ==============================================================================

{ hostName ? "nuc-game01", diskDevice ? "/dev/nvme0n1" }:

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # --------------------------------------------------------------------------
    # 1. Declarative Disko Storage Architecture (NVMe SSD)
    # --------------------------------------------------------------------------
    (import ../../../modules/nixos/hardware/disko-standard.nix { device = diskDevice; })

    # --------------------------------------------------------------------------
    # 2. Hardware Profile: Intel NUC 7 Dawson Canyon (NUC7i7DNFE)
    # --------------------------------------------------------------------------
    ../../../modules/nixos/hardware/intel-nuc.nix

    # --------------------------------------------------------------------------
    # 3. Unified Global Baseline & Core Operating System Infrastructure
    # --------------------------------------------------------------------------
    ../../../modules/nixos/core/global.nix
    ../../../modules/nixos/core/boot.nix
    ../../../modules/nixos/core/impermanence.nix

    # --------------------------------------------------------------------------
    # 4. Shared Developer & Operations Tools
    # --------------------------------------------------------------------------
    ../../../modules/shared/git.nix
    ../../../modules/shared/vim.nix
    ../../../modules/shared/neovim.nix
    ../../../modules/shared/zellij.nix

    # --------------------------------------------------------------------------
    # 5. Sandboxed Fleet Game Servers Orchestration Suite
    # --------------------------------------------------------------------------
    ../../../modules/nixos/services/game-servers
  ];

  # ----------------------------------------------------------------------------
  # HOST IDENTITY
  # ----------------------------------------------------------------------------
  networking.hostName = hostName;

  # ----------------------------------------------------------------------------
  # GAME SERVERS DECLARATION
  # ----------------------------------------------------------------------------
  services.fleet.game-servers = {
    enable = true;
    mutualExclusion = true; # One game at a time to maximize NUC performance

    # 1. Minecraft (Paper/Vanilla out of the box; modpack-ready)
    minecraft = {
      enable = true;
      autoStart = false; # On-demand: started by your son via OliveTin or game-ctl
      memory = "4G";
      motd = "Homelab Sandboxed Minecraft (NUC7i7DNFE)";
      # To add a Modrinth modpack later, simply uncomment:
      # modpack = {
      #   platform = "modrinth";
      #   slug = "cobblemon"; # or your favorite modpack
      # };
    };

    # 2. Terraria Dedicated Server
    terraria = {
      enable = true;
      autoStart = false;
      worldName = "HomelabWorld";
      autoCreateWorldSize = "medium";
    };

    # 3. Palworld Dedicated Server
    palworld = {
      enable = true;
      autoStart = false;
      serverName = "Homelab Sandboxed Palworld";
      multithreading = true;
    };

    # 4. Barotrauma Dedicated Submarine Server
    barotrauma = {
      enable = true;
      autoStart = false;
      serverName = "Homelab Sandboxed Barotrauma";
      public = false;
    };

    # 5. Kid-Friendly Web Dashboard (OliveTin on port 1337)
    gui.olivetin = {
      enable = true;
      port = 1337;
    };

    # 6. Pelican Management Panel (Optional on port 8084)
    gui.pelican = {
      enable = false;
    };
  };

  # ----------------------------------------------------------------------------
  # STATE VERSION
  # ----------------------------------------------------------------------------
  system.stateVersion = "24.11";
}
