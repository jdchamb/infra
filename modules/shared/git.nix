# ==============================================================================
# SHARED MODULE: modules/shared/git.nix (Cross-Platform Version Control)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 5):
#   Provides global Git identity, SSH/GPG commit signing defaults, and Markdown
#   LSP tooling across all nodes in the fleet (macOS and NixOS).
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Whenever you create a Git commit on any workstation, VM, or laptop, Git needs
#   to know your author name, email address, default branch name, and signing
#   format. Declaring this in a shared module guarantees you never get the
#   "Please tell me who you are" Git error on a newly provisioned machine.
#
# CROSS-PLATFORM COMPATIBILITY NOTE:
#   NixOS defines 'programs.git' at the system level, whereas nix-darwin (macOS)
#   does not have a top-level 'programs.git' module option.
#   To allow both NixOS and macOS hosts to import this exact same file without
#   errors, we wrap the 'programs.git' block in:
#     lib.optionalAttrs (options ? programs && options.programs ? git)
#   which tells Nix: "Only apply 'programs.git' if the target OS supports it."
# ==============================================================================

{ pkgs, lib, options, ... }:

{
  # 'lib.mkMerge' safely combines multiple configuration blocks into one module output
  config = lib.mkMerge [
    {
      # 1. Core Global Packages (Installed on both Linux and macOS)
      environment.systemPackages = with pkgs; [
        git      # Distributed version control engine
        marksman # Markdown Language Server Protocol (LSP) for broken-link & heading checks in editors
      ];
    }

    # 2. System-level Git configuration (/etc/gitconfig — Active on NixOS nodes)
    (lib.optionalAttrs (options ? programs && options.programs ? git) {
      programs.git = {
        enable = true;
        config = {
          # Default commit author identity across all repositories
          user.name = "Joshua Daniel Chambers";
          user.email = "joshua@chambers-net.org";

          # Default branch name when running 'git init' on a new project
          init.defaultBranch = "master";

          # Default pull strategy (false = merge by default unless --rebase is passed)
          pull.rebase = false;

          # Use modern SSH/Ed25519 keys for cryptographic commit verification
          gpg.format = "ssh";
        };
      };
    })
  ];
}
