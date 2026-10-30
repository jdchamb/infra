# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/zammad.nix (Mock Ticketing System)
# ==============================================================================
#
# ROLE & ARCHITECTURE (USD 308 Project 7 — 1-to-1 Module for IT Ticketing):
#   Provisions a self-hosted IT helpdesk ticketing system alongside standardized
#   USD 308 SLA triage and internal documentation templates in
#   '/etc/308-templates/ticketing/README.md'.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."usd308-ticketing" = {
    image = "peppermintofficial/peppermint:latest";
    ports = [ "8085:3000" ];
    volumes = [
      "/var/lib/usd308-ticketing:/data"
    ];
    autoStart = true;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/usd308-ticketing 0750 root root -"
  ];

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

  networking.firewall.allowedTCPPorts = [ 8085 ];
}
