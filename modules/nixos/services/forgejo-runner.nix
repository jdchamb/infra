# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/forgejo-runner.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 24 — 1-to-1 Module for Forgejo Runner):
#   Configures a Codeberg / Forgejo Actions CI Runner ('services.gitea-actions-runner')
#   using 'pkgs.forgejo-runner' to donate CI build compute back to Codeberg.org
#   or execute CI pipelines for your self-hosted Forgejo instance.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.codeberg-donate = {
      enable = false; # Set to true once /etc/nixos/secrets/codeberg-runner-token is populated
      name = "${config.networking.hostName}-nix-runner";
      url = "https://codeberg.org";
      tokenFile = "/etc/nixos/secrets/codeberg-runner-token";
      labels = [
        "nixos-latest:host"
        "ubuntu-latest:docker://node:20-bookworm"
      ];
      hostPackages = with pkgs; [
        bash
        coreutils
        curl
        gawk
        gitFull
        gnused
        gnutar
        gzip
        jq
        nix
        nodejs
        wget
        xz
      ];
    };
  };

  environment.systemPackages = [ pkgs.forgejo-runner ];
}
