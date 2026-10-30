# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/zammad.nix (Mock Ticketing System)
# ==============================================================================
#
# ROLE & ARCHITECTURE (USD 308 Project 7 — 1-to-1 Module for IT Helpdesk Ticketing):
#   Provisions a self-hosted IT helpdesk ticketing system container (Peppermint)
#   alongside standardized USD 308 SLA triage rules and intake templates in
#   '/etc/308-templates/ticketing/README.md'.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   An IT helpdesk needs a central place where work orders, hardware repair requests,
#   and classroom technology tickets are logged, prioritized, and tracked through
#   to resolution.
#   - This module runs Peppermint (a lightweight open-source helpdesk ticketing system)
#     inside an OCI container managed by Podman / systemd.
#   - It also generates district SLA documentation directly onto the host filesystem
#     under '/etc/308-templates/ticketing/README.md' so technicians have a standard
#     matrix for P1 through P4 priority levels.
#
# HOW TO USE:
#   - Importing this module turns the ticketing container ON immediately.
#   - Web interface: http://<host-ip>:8085
#   - Data directory: /var/lib/usd308-ticketing
#   - Review the SLA matrix: cat /etc/308-templates/ticketing/README.md
#
# >>> ARCHITECTURAL NOTE & NAMING DISCREPANCY <<<
#   Although this module file is named 'zammad.nix' (referencing the enterprise
#   Ruby/Elasticsearch Zammad ticketing suite), it intentionally deploys the
#   lightweight 'peppermintofficial/peppermint' container to minimize memory usage
#   on resource-constrained homelab and school district servers.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # OCI Container Definition: Peppermint Ticketing Server
  # --------------------------------------------------------------------------
  virtualisation.oci-containers.containers."usd308-ticketing" = {
    # Lightweight Node.js/Prisma open-source helpdesk image
    image = "peppermintofficial/peppermint:latest";

    # Port mapping: host 8085 -> container internal port 3000
    ports = [ "8085:3000" ];

    # Persist database and ticket attachments to the host filesystem
    volumes = [
      "/var/lib/usd308-ticketing:/data"
    ];

    # Automatically start the container on system boot
    autoStart = true;
  };

  # --------------------------------------------------------------------------
  # Filesystem Directory Creation (systemd-tmpfiles)
  # 'd' rule: creates /var/lib/usd308-ticketing if it does not exist.
  # Mode 0750: read/write/execute for root, read/execute for group root.
  # --------------------------------------------------------------------------
  systemd.tmpfiles.rules = [
    "d /var/lib/usd308-ticketing 0750 root root -"
  ];

  # --------------------------------------------------------------------------
  # District SLA Matrix & Intake Guide
  # Written directly to /etc/308-templates/ticketing/README.md during system activation.
  # --------------------------------------------------------------------------
  environment.etc."308-templates/ticketing/README.md".text = ''
    # USD 308 Mock Ticketing System — Internal Workflow & Documentation

    ## 1. Ticket Severity & SLA Matrix
    | Priority | Scope | Target First Response | Target Resolution |
    | :--- | :--- | :--- | :--- |
    | **P1 - Critical** | Building-wide network outage, SIS/ClearTouch down during instruction | 15 mins | 2 hours |
    | **P2 - High** | Lab deployment failure (PDQ/Autodesk), staff workstation unbootable | 1 hour | 1 business day |
    | **P3 - Normal** | Single Chromebook/iPhone provisioning, DYMO label print request | 4 hours | 3 business days |
    | **P4 - Low** | Feature requests, inventory spreadsheet audit, RMA staging | 1 business day | 5 business days |

    ## 2. Required Intake Fields
    - **Building / Room Number** (e.g., `HHS A204`, `HMS8 414`, `Grandview`)
    - **Snipe-IT Asset Tag** (e.g., `308-225660`)
    - **Category** (`Hardware / RMA`, `PDQ Software`, `ClearTouch Board`, `Network / MACAuth`, `Account / Vault`)
    - **Reproduction & Resolution Notes** (Link directly to the internal USD 308 Technical Wiki runbook)
  '';

  # --------------------------------------------------------------------------
  # Firewall Configuration
  # Allow incoming TCP traffic on port 8085 so technicians can access the web UI.
  # --------------------------------------------------------------------------
  networking.firewall.allowedTCPPorts = [ 8085 ];
}
