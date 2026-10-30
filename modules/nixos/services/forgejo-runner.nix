# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/forgejo-runner.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 24 — 1-to-1 Module for Forgejo Runner):
#   Configures a Codeberg / Forgejo Actions CI Runner ('services.gitea-actions-runner')
#   using 'pkgs.forgejo-runner' to donate CI build compute back to Codeberg.org
#   or execute CI pipelines for your self-hosted Forgejo instance.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Just as GitHub uses "GitHub Actions Runners" to run automated tests and
#   builds whenever code is pushed, Forgejo uses "Forgejo Runner". Running a
#   runner allows you to run your own CI jobs locally, or donate idle CPU
#   cycles to help the open-source community on Codeberg.
#
# HOW TO USE:
#   1. Generate or copy a runner registration token from your repository or
#      organization settings (Settings -> Actions -> Runners -> Create Runner).
#   2. Place the token into '/etc/nixos/secrets/codeberg-runner-token'
#      (chmod 0600, owned by root).
#   3. Change 'enable = false' below to 'enable = true' in
#      'instances.codeberg-donate'.
#   4. Run 'rebuild' to start and register the runner daemon.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.codeberg-donate = {
      # Set to true once /etc/nixos/secrets/codeberg-runner-token is populated
      enable = false;
      name = "${config.networking.hostName}-nix-runner";
      url = "https://codeberg.org";
      tokenFile = "/etc/nixos/secrets/codeberg-runner-token";
      # Supported labels: indicates to the forge what kinds of jobs this runner can execute
      labels = [
        "nixos-latest:host"                     # Native host execution inside NixOS
        "ubuntu-latest:docker://node:20-bookworm" # Containerized Ubuntu/Node environment
      ];
      # Essential toolchain provided to workflows running directly on the host
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

  # Make the forgejo-runner CLI utility available on the system PATH for diagnostics
  environment.systemPackages = [ pkgs.forgejo-runner ];
}
