# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/adguard-home.nix (AdGuard Home)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 21 & Fleet Roadmap Phase 4 — 1-to-1 Module):
#   Deploys AdGuard Home natively on NixOS to provide network-wide DNS filtering,
#   tracker blocking, custom homelab split-horizon DNS rewrites, and encrypted
#   upstream DNS-over-HTTPS (DoH) resolution (Quad9 & Cloudflare).
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    port = 3000;
    mutableSettings = true;

    settings = {
      http = {
        address = "0.0.0.0:3000";
      };
      dns = {
        bind_hosts = [ "0.0.0.0" ];
        port = 53;
        upstream_dns = [
          "https://dns.quad9.net/dns-query"
          "https://cloudflare-dns.com/dns-query"
        ];
        bootstrap_dns = [
          "9.9.9.9"
          "1.1.1.1"
        ];
        cache_size = 4194304;
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
      };
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

  # Prevent systemd-resolved stub listener from colliding with AdGuard Home on port 53
  services.resolved.extraConfig = ''
    DNSStubListener=no
  '';

  networking.firewall = {
    allowedTCPPorts = [ 53 3000 ];
    allowedUDPPorts = [ 53 ];
  };
}
