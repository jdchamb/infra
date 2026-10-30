# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/planka.nix (Kanban Project Board)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 4 — 1-to-1 Module for Planka):
#   Deploys Planka (self-hosted Kanban project board) via OCI containers on
#   port 3003 for visual tracking of personal and USD 308 infrastructure queues.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."planka" = {
    image = "ghcr.io/plankanban/planka:latest";
    ports = [ "3003:1337" ];
    volumes = [
      "/var/lib/planka:/app/public/user-avatars"
    ];
    environment = {
      BASE_URL = "http://localhost:3003";
      TRUST_PROXY = "0";
    };
    autoStart = true;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/planka 0755 root root -"
  ];

  networking.firewall.allowedTCPPorts = [ 3003 ];
}
