# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/paperless.nix (Paperless-ngx OCR)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 2 & Fleet Roadmap Phase 3 — 1-to-1 Module):
#   Deploys Paperless-ngx ('services.paperless'), an automated document scanner
#   and OCR archival server on port 28981 for indexing USD 308 equipment bills,
#   invoices, RMA receipts, and personal documents.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Paperless-ngx is an intelligent digital filing cabinet. You drop PDFs or
#   scanned images into its "consume" folder, and Paperless automatically:
#     1. Runs Optical Character Recognition (OCR) to read all text.
#     2. Tags and categorizes the document using machine learning.
#     3. Stores the file in an indexed, searchable full-text database.
#   This allows instant retrieval of invoices, equipment serials, and tax receipts.
#
# HOW TO USE:
#   - Importing this module turns Paperless-ngx ON immediately.
#   - Web interface: http://<host-ip>:28981
#   - Drop files into '/var/lib/paperless/consume' to trigger auto-ingestion.
#   - To create the initial superuser account:
#       sudo paperless-ngx createsuperuser
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.paperless = {
    enable = true;
    address = "0.0.0.0";                 # Listen on all interfaces for LAN browser access
    port = 28981;                        # Dedicated high port to prevent port collisions
    dataDir = "/var/lib/paperless";      # Base directory for database, index, and cache
    mediaDir = "/var/lib/paperless/media"; # Storage location for archived PDF originals
    consumptionDir = "/var/lib/paperless/consume"; # Inbox folder: files placed here are auto-processed
    consumptionDirIsPublic = true;       # World-writable inbox permissions for network scanner shares
  };

  # Open TCP port 28981 in the firewall
  networking.firewall.allowedTCPPorts = [ 28981 ];
}
