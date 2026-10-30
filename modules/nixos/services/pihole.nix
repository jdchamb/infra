# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/pihole.nix (Pi-hole DNS Sinkhole)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 4 — 1-to-1 Module for Pi-hole):
#   Deploys a containerized Pi-hole DNS sinkhole & FTL query filter as an
#   alternative to AdGuard Home ('modules/nixos/services/adguard-home.nix').
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Every time a device visits a website, it first asks a DNS server "what is
#   the IP address of ads.example.com?". Pi-hole is a DNS server that answers
#   "nothing" for known ad/tracker domains, blocking ads for EVERY device on the
#   network (phones, TVs, ClearTouch boards) without installing anything on them.
#
# !! DO NOT ENABLE ALONGSIDE AdGuard Home !!
#   Both Pi-hole and AdGuard Home want to own port 53 (the DNS port). Only one
#   program can listen on a port at a time, so import ONE of the two modules
#   per host, never both.
#
# HOW TO USE:
#   - Importing this module starts the container immediately.
#   - Admin web UI: http://<host-ip>:8053/admin
#   - Point your router's DHCP "DNS server" setting at this host's IP.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."pihole" = {
    image = "pihole/pihole:latest";
    ports = [
      "53:53/tcp"   # DNS over TCP (large responses, zone transfers)
      "53:53/udp"   # DNS over UDP (the vast majority of DNS queries)
      "8053:80/tcp" # Web admin UI (host 8053 -> container 80, avoids clashing with nginx)
    ];
    volumes = [
      # Persist blocklists, settings, and query history across container rebuilds
      "/var/lib/pihole/etc-pihole:/etc/pihole"
      "/var/lib/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
    ];
    environment = {
      TZ = "America/Chicago";            # Correct timestamps in query logs
      FTLCONF_dns_listeningMode = "all"; # Answer queries from any subnet (not just local)
    };
    autoStart = true;
  };

  # Create persistent data directories before the container starts
  systemd.tmpfiles.rules = [
    "d /var/lib/pihole/etc-pihole 0755 root root -"
    "d /var/lib/pihole/etc-dnsmasq.d 0755 root root -"
  ];

  # Open DNS (53 TCP/UDP) and the admin UI (8053) to the LAN
  networking.firewall = {
    allowedTCPPorts = [ 53 8053 ];
    allowedUDPPorts = [ 53 ];
  };
}
