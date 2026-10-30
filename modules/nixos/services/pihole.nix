# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/pihole.nix (Pi-hole DNS Sinkhole)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 4 — 1-to-1 Module for Pi-hole):
#   Deploys a containerized Pi-hole DNS sinkhole & Unbound/FTL query filter as
#   an alternative to AdGuard Home ('modules/nixos/services/adguard-home.nix').
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."pihole" = {
    image = "pihole/pihole:latest";
    ports = [
      "53:53/tcp"
      "53:53/udp"
      "8053:80/tcp"
    ];
    volumes = [
      "/var/lib/pihole/etc-pihole:/etc/pihole"
      "/var/lib/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
    ];
    environment = {
      TZ = "America/Chicago";
      FTLCONF_dns_listeningMode = "all";
    };
    autoStart = true;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/pihole/etc-pihole 0755 root root -"
    "d /var/lib/pihole/etc-dnsmasq.d 0755 root root -"
  ];

  networking.firewall = {
    allowedTCPPorts = [ 53 8053 ];
    allowedUDPPorts = [ 53 ];
  };
}
