# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/krdc.nix (KDE Remote Desktop Client)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 10 — 1-to-1 Module for KRDC):
#   Installs KDE's KRDC remote desktop client for connecting to VNC (UltraVNC)
#   and RDP Windows 11 endpoints across USD 308 buildings.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   USD 308 Windows PCs run UltraVNC (deployed by
#   'modules/windows/scripts/Deploy-UltraVNC.ps1') and Windows RDP. KRDC speaks
#   BOTH protocols in one KDE-native app, so a technician on a Linux workstation
#   can remotely help a teacher without walking to the classroom.
#   (For a lighter, VNC-only viewer, see 'tigervnc.nix'.)
# ==============================================================================

{ pkgs, ... }:

{
  # Install KRDC (VNC + RDP client integrated with KDE Plasma)
  environment.systemPackages = [
    pkgs.kdePackages.krdc
  ];
}
