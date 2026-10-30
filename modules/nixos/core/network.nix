# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/network.nix (NetworkManager & Firewall)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Activates NetworkManager for dynamic wired and wireless connection management,
#   enforces a default-deny stateful Linux firewall across all network interfaces,
#   and provisions baseline network tray ('nm-applet') and WireGuard VPN tooling.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   - NetworkManager: Workstations and laptops travel between different networks
#     (home Wi-Fi, school district enterprise WPA2/WPA3 networks, wired Ethernet).
#     NetworkManager handles automatic interface switching, DHCP leasing, DNS
#     nameserver resolution, and captive portals without requiring manual config files.
#   - Stateful Firewall: Security requires blocking unexpected inbound connections.
#     NixOS enables a stateful Linux firewall (using iptables / nftables) by default.
#     Outbound connections (browsing the web, downloading updates) are permitted,
#     and their responses are tracked and accepted. Unsolicited inbound connections
#     are dropped unless a specific module explicitly declares 'networking.firewall.allowedTCPPorts'.
#   - WireGuard Tools: WireGuard is a modern, cryptographic VPN protocol.
#     Installing 'wireguard-tools' provides 'wg' and 'wg-quick' for setting up
#     encrypted point-to-point tunnels into the district homelab.
#   - NetworkManager Applet ('nm-applet'): Provides the system tray icon in desktop
#     environments (KDE Plasma, Hyprland, Sway) for selecting Wi-Fi networks.
#
# HOW TO USE:
#   - Connect to Wi-Fi via CLI:
#       nmcli device wifi list
#       nmcli device wifi connect "SSID_NAME" password "PASSPHRASE"
#   - Interactive terminal menu:
#       nmtui
#   - Check firewall status and open ports:
#       sudo iptables -L -n -v (or 'sudo nft list ruleset')
# ==============================================================================

{ config, pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. Dynamic Connection Management
  # Enables NetworkManager daemon for Wi-Fi roaming, Ethernet DHCP, and VPNs.
  # --------------------------------------------------------------------------
  networking.networkmanager.enable = true;

  # --------------------------------------------------------------------------
  # 2. Host Firewall Policy (Default-Deny)
  # Blocks all inbound unsolicited network traffic. Individual service modules
  # (e.g. Samba, Vaultwarden, Miniflux) explicitly add their required ports.
  # --------------------------------------------------------------------------
  networking.firewall = {
    enable = true;
    # Note: SSH (port 22) is opened selectively in server and bootstrap modules
    # allowedTCPPorts = [ 22 ];
  };

  # --------------------------------------------------------------------------
  # 3. System Utilities
  # --------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # System tray GUI for wireless connections and VPN toggling
    networkmanagerapplet
    # Fast, modern VPN configuration utilities ('wg', 'wg-quick')
    wireguard-tools
  ];

  # --------------------------------------------------------------------------
  # 4. SOPS Hostname Resolution Overlay
  # When decrypted by sops-nix, overlays decrypted LAN IP mappings into /etc/hosts
  # so services can resolve abstract hostnames (e.g. storage.internal, ai.internal)
  # without exposing internal LAN IPs in git-tracked Nix expressions.
  # --------------------------------------------------------------------------
  systemd.services.sops-hosts-mount = {
    description = "Overlay SOPS internal hosts into /etc/hosts";
    after = [ "sops-nix.service" ];
    before = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "apply-sops-hosts" ''
        if [ -f /run/secrets/hosts-internal ]; then
          cp /etc/static/hosts /run/hosts
          cat /run/secrets/hosts-internal >> /run/hosts
          mount --bind /run/hosts /etc/hosts
        fi
      '';
      ExecStop = pkgs.writeShellScript "restore-sops-hosts" ''
        umount /etc/hosts || true
      '';
    };
  };
}
