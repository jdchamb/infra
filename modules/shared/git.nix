# ==============================================================================
# SHARED MODULE: modules/shared/git.nix (Cross-Platform Version Control)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 5):
#   Provides global Git identity, SSH/GPG commit signing defaults, and Markdown
#   LSP tooling across all nodes in the fleet (macOS and NixOS).
#
# CROSS-PLATFORM COMPATIBILITY NOTE:
#   NixOS defines 'programs.git' at the system level. nix-darwin does not.
#   To prevent evaluation failures on macOS, we guard 'programs.git' with
#   'lib.optionalAttrs (options ? programs && options.programs ? git)'.
# ==============================================================================

{ pkgs, lib, options, ... }:

{
  config = lib.mkMerge [
    {
      # Core Global Packages
      environment.systemPackages = with pkgs; [
        git      # Version control engine
        marksman # Markdown Language Server Protocol (LSP) for editors & documentation
      ];
    }

    # System-level Git configuration (Active on NixOS nodes)
    (lib.optionalAttrs (options ? programs && options.programs ? git) {
      programs.git = {
        enable = true;
        config = {
          user.name = "Joshua Daniel Chambers";
          user.email = "joshua@chambers-net.org";
          init.defaultBranch = "master";
          pull.rebase = false;
          gpg.format = "ssh";
        };
      };
    })
  ];
}
