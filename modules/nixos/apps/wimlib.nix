# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/wimlib.nix (Windows WIM Image Optimizer)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 5 — 1-to-1 Module for wimlib):
#   Installs 'wimlib' ('wimlib-imagex'), an open-source cross-platform replacement
#   for Windows DISM capable of mounting, debloating, driver-injecting, and
#   re-compressing Windows 11 'install.wim' deployment images directly on Linux.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Windows installer ISOs store the whole OS inside one big archive file called
#   'install.wim'. Microsoft's own tool for editing it (DISM) only runs on
#   Windows. 'wimlib-imagex' lets a Linux workstation inspect and rebuild those
#   images too, which pairs with 'modules/windows/scripts/Optimize-Win11Image.ps1'.
#
# QUICK USAGE:
#   wimlib-imagex info install.wim                       # List editions/indexes
#   wimlib-imagex optimize install.wim --recompress      # Shrink the archive
# ==============================================================================

{ pkgs, ... }:

{
  # Install wimlib ('wimlib-imagex' and 'mkwinpeimg')
  environment.systemPackages = [
    pkgs.wimlib
  ];
}
