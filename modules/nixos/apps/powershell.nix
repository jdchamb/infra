# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/powershell.nix (PowerShell Core CLI)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Projects 1, 9, 14, 16 — 1-to-1 Module for PowerShell):
#   Installs Microsoft PowerShell Core ('pwsh') on NixOS workstations to author,
#   lint, and test USD 308 PDQ Deploy and Windows 11 automation scripts locally.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   The scripts in 'modules/windows/scripts/' run on Windows, but they are
#   written and reviewed on Linux. PowerShell Core is the open-source,
#   cross-platform edition of PowerShell. Having 'pwsh' on Linux lets you check
#   script syntax ('pwsh -NoProfile -Command { Get-Command -Syntax ... }'),
#   test string/logic functions, and catch typos BEFORE pushing a script to
#   PDQ Deploy where a mistake could hit hundreds of school PCs.
#   (Windows-only cmdlets like Mount-WindowsImage will not run on Linux.)
# ==============================================================================

{ pkgs, ... }:

{
  # Install PowerShell Core ('pwsh')
  environment.systemPackages = [
    pkgs.powershell
  ];
}
