# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/iperf3.nix (Network Throughput Benchmark)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 17 & 18 — 1-to-1 Module for iperf3):
#   Installs 'iperf3' to validate line-rate Gigabit/10GbE throughput across
#   freshly punched-down patch panels, PoE drops, and the homelab Brocade switch.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When you punch down new Cat6 Ethernet cables or configure a managed network
#   switch, a basic cable tester only tells you if the wires are connected—it
#   doesn't tell you if a bad termination is causing packet loss or dropping a
#   1 Gbps link down to 100 Mbps.
#   Running 'iperf3 -s' on one machine and 'iperf3 -c <server-ip>' on another
#   floods the link with test traffic and measures the exact real-world Mbps/Gbps
#   speed and packet jitter.
# ==============================================================================

{ pkgs, ... }:

{
  # Install the 'iperf3' network bandwidth measurement tool
  environment.systemPackages = [
    pkgs.iperf3
  ];
}
