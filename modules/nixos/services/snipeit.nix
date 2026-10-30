# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/snipeit.nix (Snipe-IT Asset System)
# ==============================================================================
#
# ROLE & ARCHITECTURE (USD 308 Projects 3, 11, 25 — 1-to-1 Module for Snipe-IT):
#   Addresses all three Snipe-IT initiatives:
#     - Project 3: Declarative Snipe-IT web application + MariaDB database container
#       stack running via Podman/OCI ('services.fleet.snipeitServer.enable') to
#       replace the legacy Debian VM.
#     - Project 11: Installs 'snipeit-export-macs', a CLI script that queries the
#       Snipe-IT REST API for every hardware asset's Wi-Fi MAC address and outputs
#       a normalized CSV for RADIUS 'macauth' validation.
#     - Project 25: Installs 'snipeit-add-ct-mac' to batch-register ClearTouch
#       wireless module MAC addresses into Snipe-IT asset records via REST API.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Snipe-IT is an IT asset management system used to track computers, monitors,
#   and hardware accessories. USD 308 uses Snipe-IT to maintain an inventory of
#   all district devices.
#   - This module provides two client CLI utility scripts directly to the system
#     PATH so administrators can automate inventory and RADIUS tasks from the terminal.
#   - It optionally provides a fully containerized local Snipe-IT server stack
#     (web UI + MariaDB database) managed declaratively by systemd and Podman.
#
# HOW TO USE:
#   - Client scripts ('snipeit-export-macs', 'snipeit-add-ct-mac') are available
#     on the command line whenever this module is imported.
#   - To enable the self-hosted container stack on a server host, set:
#       services.fleet.snipeitServer.enable = true;
#   - Web interface: http://<host-ip>:8081
#   - API Token: Store your API bearer token in /etc/nixos/secrets/snipeit-api-token
#     or supply via the SNIPE_TOKEN environment variable.
#   - DB Secrets: Create /etc/nixos/secrets/snipeit-env containing:
#       MYSQL_ROOT_PASSWORD=<secret>
#       MYSQL_PASSWORD=<secret>
#       APP_KEY=base64:<generated-32-byte-key>
#
# >>> SECURITY & CONFIGURATION NOTICE <<<
#   1. The container stack requires '/etc/nixos/secrets/snipeit-env' to exist
#      before starting, populated with strong passwords and an APP_KEY.
#   2. Notice: 'snipeit-app' declares both 'ports = [ "8081:80" ]' and
#      'extraOptions = [ "--network=host" ]'. In host networking mode, Docker/Podman
#      attaches directly to the host network stack, so internal port 80 would bind
#      directly to host port 80 unless configured otherwise.
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  # --------------------------------------------------------------------------
  # CLI Tool: snipeit-export-macs (Project 11)
  # Queries Snipe-IT hardware API in pages of 500, extracts Wi-Fi MAC addresses,
  # normalizes them to lowercase hex (no colons/dashes), and saves to CSV for
  # import into network switch / RADIUS MAC authentication tables.
  # --------------------------------------------------------------------------
  snipeitExportMacs = pkgs.writeShellScriptBin "snipeit-export-macs" ''
    set -euo pipefail
    SNIPE_URL="''${SNIPE_URL:-https://assets.usd308.com}"
    SNIPE_TOKEN_FILE="''${SNIPE_TOKEN_FILE:-/etc/nixos/secrets/snipeit-api-token}"
    OUTPUT_CSV="''${1:-./usd308-macauth-export.csv}"

    # Verify API token is present before executing HTTP requests
    if [ ! -f "$SNIPE_TOKEN_FILE" ] && [ -z "''${SNIPE_TOKEN:-}" ]; then
      echo "Error: Provide SNIPE_TOKEN env var or place API token in $SNIPE_TOKEN_FILE"
      exit 1
    fi
    TOKEN="''${SNIPE_TOKEN:-$(cat "$SNIPE_TOKEN_FILE")}"

    echo "==> Querying Snipe-IT hardware endpoint ($SNIPE_URL/api/v1/hardware)..."
    echo "asset_tag,device_name,serial,model,wifi_mac_raw,wifi_mac_normalized" > "$OUTPUT_CSV"

    OFFSET=0
    LIMIT=500
    while true; do
      # Fetch paginated JSON list of hardware assets
      RESPONSE=$(${pkgs.curl}/bin/curl -sS -H "Authorization: Bearer $TOKEN" \
        -H "Accept: application/json" \
        "$SNIPE_URL/api/v1/hardware?limit=$LIMIT&offset=$OFFSET")

      # Break when no more records are returned
      COUNT=$(echo "$RESPONSE" | ${pkgs.jq}/bin/jq '.rows | length')
      if [ "$COUNT" -eq 0 ]; then
        break
      fi

      # Parse custom MAC address fields, normalize format, and append to CSV
      echo "$RESPONSE" | ${pkgs.jq}/bin/jq -r '
        .rows[]
        | select(.custom_fields != null)
        | {
            tag: (.asset_tag // ""),
            name: (.name // ""),
            serial: (.serial // ""),
            model: (.model.name // ""),
            mac: (
              .custom_fields["MAC Address"].value //
              .custom_fields["Wi-Fi MAC"].value //
              .custom_fields["WiFi MAC Address"].value // ""
            )
          }
        | select(.mac != "")
        | [
            .tag,
            .name,
            .serial,
            .model,
            .mac,
            (.mac | ascii_downcase | gsub("[^0-9a-f]"; ""))
          ]
        | @csv
      ' >> "$OUTPUT_CSV"

      OFFSET=$((OFFSET + LIMIT))
    done

    echo "==> Export complete: $OUTPUT_CSV ($(wc -l < "$OUTPUT_CSV") lines)"
  '';

  # --------------------------------------------------------------------------
  # CLI Tool: snipeit-add-ct-mac (Project 25)
  # Looks up an asset by its USD 308 tag, resolves the Snipe-IT internal ID,
  # and issues a REST API PATCH request to update its wireless MAC custom field.
  # --------------------------------------------------------------------------
  snipeitAddCtMac = pkgs.writeShellScriptBin "snipeit-add-ct-mac" ''
    set -euo pipefail
    ASSET_TAG="''${1:-}"
    MAC_ADDR="''${2:-}"
    MAC_FIELD_DB="''${SNIPE_MAC_FIELD:-_snipeit_mac_address_1}"
    SNIPE_URL="''${SNIPE_URL:-https://assets.usd308.com}"
    SNIPE_TOKEN_FILE="''${SNIPE_TOKEN_FILE:-/etc/nixos/secrets/snipeit-api-token}"

    if [ -z "$ASSET_TAG" ] || [ -z "$MAC_ADDR" ]; then
      echo "Usage: snipeit-add-ct-mac <asset-tag> <XX:XX:XX:XX:XX:XX>"
      echo "Example: snipeit-add-ct-mac CT-HHS-A204 A4:B1:C2:D3:E4:F5"
      exit 1
    fi

    # Read token from file if not provided as environment variable
    TOKEN="''${SNIPE_TOKEN:-$(cat "$SNIPE_TOKEN_FILE")}"
    ASSET_ID=$(${pkgs.curl}/bin/curl -sS -H "Authorization: Bearer $TOKEN" \
      -H "Accept: application/json" \
      "$SNIPE_URL/api/v1/hardware/bytag/$ASSET_TAG" | ${pkgs.jq}/bin/jq -r '.id')

    if [ -z "$ASSET_ID" ] || [ "$ASSET_ID" = "null" ]; then
      echo "Error: Asset tag '$ASSET_TAG' not found in Snipe-IT."
      exit 1
    fi

    echo "==> Updating Asset #$ASSET_ID ($ASSET_TAG) wireless MAC -> $MAC_ADDR..."
    ${pkgs.curl}/bin/curl -sS -X PATCH "$SNIPE_URL/api/v1/hardware/$ASSET_ID" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -d "{\"$MAC_FIELD_DB\": \"$MAC_ADDR\"}" | ${pkgs.jq}/bin/jq '.status, .messages'
  '';
in
{
  # Declarative toggle option to turn the full container server stack ON or OFF
  options.services.fleet.snipeitServer.enable = lib.mkEnableOption "Self-hosted Snipe-IT OCI container stack (308 Project 3)";

  config = {
    # System packages installed on the host whenever this module is included
    environment.systemPackages = [
      pkgs.curl          # HTTP client for API queries
      pkgs.jq            # JSON processor for extracting API response fields
      snipeitExportMacs  # Custom CSV export CLI tool
      snipeitAddCtMac    # Custom MAC registration CLI tool
    ];

    # OCI container definition for running Snipe-IT under Podman / systemd
    virtualisation.oci-containers.containers = lib.mkIf config.services.fleet.snipeitServer.enable {
      # MariaDB database backend container
      "snipeit-db" = {
        image = "mariadb:11.4";
        # Persist database files to the host filesystem
        volumes = [ "/var/lib/snipeit/db:/var/lib/mysql" ];
        environment = {
          MYSQL_DATABASE = "snipeit";
          MYSQL_USER = "snipeit";
        };
        # External environment file containing MYSQL_PASSWORD and MYSQL_ROOT_PASSWORD
        environmentFiles = [ "/etc/nixos/secrets/snipeit-env" ];
        autoStart = true;
      };

      # Snipe-IT web application container
      "snipeit-app" = {
        image = "snipe/snipe-it:latest";
        # Wait for the database container to launch before starting Snipe-IT
        dependsOn = [ "snipeit-db" ];
        # Port mapping: host 8081 -> container 80
        ports = [ "8081:80" ];
        # Persist uploaded files, avatars, and application storage
        volumes = [ "/var/lib/snipeit/storage:/var/lib/snipeit" ];
        environment = {
          APP_ENV = "production";
          APP_DEBUG = "false";
          APP_URL = "http://localhost:8081";
          MYSQL_PORT_3306_TCP_ADDR = "127.0.0.1";
          MYSQL_PORT_3306_TCP_PORT = "3306";
          MYSQL_DATABASE = "snipeit";
          MYSQL_USER = "snipeit";
        };
        # External environment file containing APP_KEY and database secrets
        environmentFiles = [ "/etc/nixos/secrets/snipeit-env" ];
        extraOptions = [ "--network=host" ];
        autoStart = true;
      };
    };

    # Declarative directory creation with strict permissions (0750 = read/write for root/owner only)
    systemd.tmpfiles.rules = lib.mkIf config.services.fleet.snipeitServer.enable [
      "d /var/lib/snipeit/db 0750 root root -"
      "d /var/lib/snipeit/storage 0750 root root -"
    ];
  };
}
