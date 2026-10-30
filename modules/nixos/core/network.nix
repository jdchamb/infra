# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/network.nix (NetworkManager & Firewall)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Activates NetworkManager for seamless wired/wireless roaming, enforces a
#   stateful host firewall by default, and provisions baseline network tray and
#   WireGuard VPN utilities across all workstations and mobile nodes.
# ==============================================================================

{ config, pkgs, ... }:

{
  # 1. Dynamic Connection Management via NetworkManager
  networking.networkmanager.enable = true;

  # 2. Host Firewall Policy (Default-Deny Inbound unless explicitly opened by service modules)
  networking.firewall = {
    enable = true;
    # allowedTCPPorts = [ 22 ]; # Enabled selectively in bootstrap or server modules
  };

  # 3. Baseline Network Tray & Tunneling Utilities
  environment.systemPackages = with pkgs; [
    networkmanagerapplet # System tray applet for Wi-Fi/VPN management
    wireguard-tools      # CLI tools ('wg', 'wg-quick') for encrypted mesh/VPN tunnels
  ];
}
