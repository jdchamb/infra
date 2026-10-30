# ==============================================================================
# COMMON MODULE: modules/common/sops-tools.nix (SOPS & Age Cryptographic CLI)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Installs the 'sops' and 'age' binaries onto the system PATH without activating
#   background decryption daemons. Ideal for live recovery ISOs, macOS hosts, and
#   VMs where you need to author, rotate, or inspect encrypted YAML secrets files.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    age
    sops
  ];
}
