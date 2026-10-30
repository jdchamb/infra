# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/paperless.nix (Paperless-ngx OCR)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 2 & Fleet Roadmap Phase 3 — 1-to-1 Module):
#   Deploys Paperless-ngx ('services.paperless'), an automated document scanner
#   and OCR archival server on port 28981 for indexing USD 308 equipment bills,
#   invoices, RMA receipts, and personal documents.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 28981;
    dataDir = "/var/lib/paperless";
    mediaDir = "/var/lib/paperless/media";
    consumptionDir = "/var/lib/paperless/consume";
    consumptionDirIsPublic = true;
  };

  networking.firewall.allowedTCPPorts = [ 28981 ];
}
