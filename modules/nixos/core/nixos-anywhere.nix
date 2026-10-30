# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/nixos-anywhere.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 2 — 1-to-1 Module for nixos-anywhere):
#   Installs 'nixos-anywhere' and provides the 'remote-nixos-anywhere' wrapper
#   script to partition (via Disko) and install NixOS onto any bare-metal or VM
#   target over SSH in a single unattended pass.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Normally, installing Linux on a new computer requires plugging in a monitor
#   and keyboard, booting an installer USB, partitioning the disk by hand, and
#   running 'nixos-install'.
#   With 'nixos-anywhere', you only need to plug our 'bootstrap-iso' USB stick
#   into the target machine (or boot any Linux live environment with SSH). Then,
#   from your main desk, you run:
#     remote-nixos-anywhere lab-pb01 root@10.14.5.101
#   It connects over SSH, uses Linux 'kexec' to load a fresh installer in RAM,
#   formats the hard drive using our Disko layout, copies the compiled NixOS
#   system over the network, and reboots into the finished machine—zero hands-on
#   typing required!
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  # Compile a convenient helper command ('remote-nixos-anywhere') into /nix/store
  remoteNixosAnywhere = pkgs.writeShellScriptBin "remote-nixos-anywhere" ''
    set -euo pipefail
    HOST_FLAKE="''${1:-}"
    TARGET_IP="''${2:-}"

    if [ -z "$HOST_FLAKE" ] || [ -z "$TARGET_IP" ]; then
      echo "Usage: remote-nixos-anywhere <flake-host> <root@ip-or-hostname>"
      echo "Example: remote-nixos-anywhere lab-pb01 root@10.14.5.101"
      exit 1
    fi

    echo "==> Executing zero-touch network installation of #$HOST_FLAKE onto $TARGET_IP..."
    ${pkgs.nixos-anywhere}/bin/nixos-anywhere \
      --flake "$HOME/src/infra#$HOST_FLAKE" \
      "$TARGET_IP"
  '';
in
{
  # 1. Install both upstream 'nixos-anywhere' and our 'remote-nixos-anywhere' wrapper
  environment.systemPackages = [
    pkgs.nixos-anywhere
    remoteNixosAnywhere
  ];

  # 2. Allow this workstation to coordinate distributed remote Nix builds
  nix.distributedBuilds = lib.mkDefault true;

  # 3. Instruct remote build targets to download pre-built binaries directly from
  #    cache.nixos.org instead of forcing our workstation to upload every dependency
  nix.settings.builders-use-substitutes = true;
}
