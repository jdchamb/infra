# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/adguard-home.nix (AdGuard Home)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 21 & Fleet Roadmap Phase 4 — 1-to-1 Module):
#   Deploys AdGuard Home natively on NixOS to provide network-wide DNS filtering,
#   tracker blocking, custom homelab split-horizon DNS rewrites, and encrypted
#   upstream DNS-over-HTTPS (DoH) resolution (Quad9 & Cloudflare).
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   AdGuard Home functions as a local DNS server for your network. Whenever a
#   device looks up a domain name, AdGuard Home checks its blocklists. If the
#   domain is an ad or telemetry tracker, AdGuard blocks it before the connection
#   ever starts. It also encrypts outbound DNS queries using DNS-over-HTTPS,
#   preventing upstream ISPs from snooping on your browsing traffic.
#
# HOW TO USE:
#   - Importing this module turns AdGuard Home ON immediately.
#   - Web Admin UI: http://<host-ip>:3000
#   - Configure your home/lab DHCP router to distribute this machine's IP as
#     the primary DNS server for LAN clients.
#
# PORT & CONFLICT WARNINGS:
#   - Port 53 (DNS): Conflicts with Pi-hole ('modules/nixos/services/pihole.nix').
#     Do not enable both on the same host.
#   - Port 3000 (HTTP UI): Standard Forgejo/Gitea instances also default to
#     port 3000. Ensure you do not bind both to 0.0.0.0 on the same machine.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.adguardhome = {
    enable = true;
    openFirewall = true; # Open DNS (53) and HTTP (3000) in the firewall
    port = 3000;         # Initial setup / web admin listening port
    mutableSettings = true; # Allows editing filters and settings from the Web UI

    settings = {
      http = {
        address = "0.0.0.0:3000"; # Bind web interface to all network interfaces
      };
      dns = {
        bind_hosts = [ "0.0.0.0" ]; # Listen for DNS queries on all interfaces
        port = 53;                  # Standard DNS port
        # Upstream DNS-over-HTTPS (DoH) resolvers for secure, encrypted lookup
        upstream_dns = [
          "https://dns.quad9.net/dns-query"
          "https://cloudflare-dns.com/dns-query"
        ];
        # Plain IP bootstrap servers to resolve upstream DoH hostnames initially
        bootstrap_dns = [
          "9.9.9.9"
          "1.1.1.1"
        ];
        cache_size = 4194304; # 4MB in-memory DNS query cache
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
      };
      # Default baseline blocklists for ad and malware filtering
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
          name = "AdAway Default Blocklist";
          id = 2;
        }
      ];
    };
  };

  # Prevent systemd-resolved stub listener from colliding with AdGuard Home on port 53.
  # By default, systemd-resolved binds 127.0.0.53:53; disabling the stub listener frees port 53.
  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';

  networking.firewall = {
    allowedTCPPorts = [ 53 3000 ];
    allowedUDPPorts = [ 53 ];
  };
}
