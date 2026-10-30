# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/sops.nix (SOPS-Nix Secret Decryption)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 17):
#   Integrates 'sops-nix' into the host activation sequence. Uses the local master
#   Age private key ('/var/lib/sops-nix/308-key.txt') to decrypt encrypted YAML
#   credentials straight into an in-memory tmpfs filesystem ('/run/secrets/'),
#   exposing strict mode 0600 symlinks for systemd CIFS automounts and services.
# ==============================================================================

{ inputs, ... }:

{
  sops = {
    # 1. Default encrypted secrets payload inside the repository
    defaultSopsFile = "${inputs.self}/secrets/308-secrets.yaml";
    defaultSopsFormat = "yaml";

    # 2. Local Age private key path (provisioned via 'bootstrap-age-key' on install)
    age.keyFile = "/var/lib/sops-nix/308-key.txt";

    # 3. Runtime Secret Extraction Targets
    secrets = {
      "credentials-adminjc" = {
        path = "/etc/nixos/secrets/308-adminjc";
        mode = "0600";
      };
      "credentials-macos-admin308" = {
        path = "/etc/nixos/secrets/308-admin308";
        mode = "0600";
      };
    };
  };
}
