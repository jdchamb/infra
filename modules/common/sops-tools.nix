# ==============================================================================
# COMMON MODULE: modules/common/sops-tools.nix (SOPS & Age Cryptographic CLI)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Installs the 'sops' and 'age' binaries onto the system PATH without activating
#   background decryption daemons. Ideal for live recovery ISOs, macOS hosts, and
#   VMs where you need to author, rotate, or inspect encrypted YAML secrets files.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   We never store plaintext passwords or API keys in Git. Instead, we use:
#     - 'age': A modern, simple file encryption tool (replacing legacy PGP keys
#              for file encryption).
#     - 'sops' (Secrets OPerationS): A tool that encrypts ONLY the values inside
#              YAML/JSON files (like 'secrets/308-secrets.yaml') while leaving
#              the key names readable in Git diffs.
#   Separating the CLI tools ('sops-tools.nix') from the boot-time decryption
#   daemon ('modules/nixos/core/sops.nix') lets any machine or live ISO edit
#   secrets without requiring the production server's private key at boot.
# ==============================================================================

{ pkgs, ... }:

{
  # Add 'age' (key generator & cipher) and 'sops' (structured file encryptor)
  # to the global system PATH for all users.
  environment.systemPackages = with pkgs; [
    age  # Provides 'age' and 'age-keygen' for generating master keypairs
    sops # Provides 'sops secrets/308-secrets.yaml' for interactive editing
  ];
}
