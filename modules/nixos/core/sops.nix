# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/sops.nix (SOPS-Nix Secret Decryption)
# ==============================================================================
#
# ROLE & ARCHITECTURE (USD 308 Project 17 — Declarative Fleet Secrets):
#   Integrates 'sops-nix' into the host boot and activation sequence.
#   Uses the host's Age private key ('/var/lib/sops-nix/308-key.txt') to decrypt
#   Git-tracked encrypted YAML credentials directly into an in-memory tmpfs filesystem
#   ('/run/secrets/'), exposing strict mode 0600 symlinks for CIFS mounts, databases,
#   and systemd service daemons.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   - The Problem: Everything declared in NixOS configuration files is copied into
#     the '/nix/store', which is world-readable by any unprivileged user or process
#     on the machine. Furthermore, committing plain text passwords or API tokens
#     to Git is dangerous.
#   - The Solution (SOPS + Age): Mozilla SOPS encrypts secret values inside a YAML
#     file using public-key cryptography (Age). The encrypted file can be safely
#     committed to Git and pushed to public repositories like Codeberg or GitHub.
#   - Decryption at Boot: When the NixOS machine boots, the 'sops-nix' activation
#     hook reads the host's private Age key, decrypts the specific secrets into
#     RAM (never writing plain text to disk), and symlinks them to the requested
#     paths with permissions restricted to root (mode 0600).
#
# HOW TO USE:
#   - To edit the encrypted secrets file:
#       sops secrets/308-secrets.yaml
#   - When provisioning a new machine, install its Age private key at:
#       /var/lib/sops-nix/308-key.txt
#   - Services and CIFS mounts reference the decrypted paths:
#       /etc/nixos/secrets/308-adminjc
#       /etc/nixos/secrets/308-admin308
# ==============================================================================

{ pkgs, inputs, ... }:

{
  # --------------------------------------------------------------------------
  # sops-nix Declarative Configuration
  # --------------------------------------------------------------------------
  sops = {
    # Use modern sops package from nixpkgs (bypasses legacy sops-nix Go builder)
    package = pkgs.sops;

    # 1. Location of the encrypted secrets file relative to the Flake root
    defaultSopsFile = "${inputs.self}/secrets/308-secrets.yaml";

    # Format of the encrypted payload (YAML, JSON, or ENV)
    defaultSopsFormat = "yaml";

    # 2. Path to the local Age private key on the target machine
    # CAUTION: This private key file must never be committed to Git!
    age.keyFile = "/var/lib/sops-nix/308-key.txt";

    # 3. Target Paths for Decrypted Secrets
    # Each entry extracts a named key from '308-secrets.yaml' and links it into place.
    secrets = {
      # USD 308 administrative credentials for CIFS/SMB share access
      "credentials-adminjc" = {
        path = "/etc/nixos/secrets/308-adminjc";
        mode = "0600"; # Readable only by root (owner)
      };

      # macOS / USD 308 secondary administrative credentials
      "credentials-macos-admin308" = {
        path = "/etc/nixos/secrets/308-admin308";
        mode = "0600"; # Readable only by root (owner)
      };
    };
  };
}
