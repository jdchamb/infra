# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/iperf3.nix (Network Throughput Benchmark)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 17 & 18 — 1-to-1 Module for iperf3):
#   Installs 'iperf3' to validate line-rate Gigabit/10GbE throughput across
#   freshly punched-down patch panels, PoE drops, and the homelab Brocade switch.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.iperf3
  ];
}
