# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/snipeit.nix (Snipe-IT Asset System)
# ==============================================================================
#
# ROLE & ARCHITECTURE (USD 308 Projects 3, 11, 25 — 1-to-1 Module for Snipe-IT):
#   Addresses all three Snipe-IT initiatives:
#     - Project 3: Toggleable declarative Snipe-IT + MariaDB container stack
#       ('services.fleet.snipeitServer.enable') to replace the legacy Debian VM.
#     - Project 11: Installs 'snipeit-export-macs', a CLI script that queries the
#       Snipe-IT REST API for every hardware asset's Wi-Fi MAC address and outputs
#       a normalized CSV for RADIUS 'macauth' validation.
#     - Project 25: Installs 'snipeit-add-ct-mac' to batch-register ClearTouch
#       wireless module MAC addresses into Snipe-IT asset records.
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  snipeitExportMacs = pkgs.writeShellScriptBin "snipeit-export-macs" ''
    set -euo pipefail
    SNIPE_URL="''${SNIPE_URL:-https://assets.usd308.com}"
    SNIPE_TOKEN_FILE="''${SNIPE_TOKEN_FILE:-/etc/nixos/secrets/snipeit-api-token}"
    OUTPUT_CSV="''${1:-./usd308-macauth-export.csv}"

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
      RESPONSE=$(${pkgs.curl}/bin/curl -sS -H "Authorization: Bearer $TOKEN" \
        -H "Accept: application/json" \
        "$SNIPE_URL/api/v1/hardware?limit=$LIMIT&offset=$OFFSET")

      COUNT=$(echo "$RESPONSE" | ${pkgs.jq}/bin/jq '.rows | length')
      if [ "$COUNT" -eq 0 ]; then
        break
      fi

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
  options.services.fleet.snipeitServer.enable = lib.mkEnableOption "Self-hosted Snipe-IT OCI container stack (308 Project 3)";

  config = {
    environment.systemPackages = [
      pkgs.curl
      pkgs.jq
      snipeitExportMacs
      snipeitAddCtMac
    ];

    virtualisation.oci-containers.containers = lib.mkIf config.services.fleet.snipeitServer.enable {
      "snipeit-db" = {
        image = "mariadb:11.4";
        volumes = [ "/var/lib/snipeit/db:/var/lib/mysql" ];
        environment = {
          MYSQL_DATABASE = "snipeit";
          MYSQL_USER = "snipeit";
        };
        environmentFiles = [ "/etc/nixos/secrets/snipeit-env" ];
        autoStart = true;
      };

      "snipeit-app" = {
        image = "snipe/snipe-it:latest";
        dependsOn = [ "snipeit-db" ];
        ports = [ "8081:80" ];
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
        environmentFiles = [ "/etc/nixos/secrets/snipeit-env" ];
        extraOptions = [ "--network=host" ];
        autoStart = true;
      };
    };

    systemd.tmpfiles.rules = lib.mkIf config.services.fleet.snipeitServer.enable [
      "d /var/lib/snipeit/db 0750 root root -"
      "d /var/lib/snipeit/storage 0750 root root -"
    ];
  };
}
