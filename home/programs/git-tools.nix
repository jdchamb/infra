# ==============================================================================
# USER PROGRAM: home/programs/git-tools.nix (Git Diff & Merge Tool Selection)
# ==============================================================================
#
# WHY THIS LIVES IN HOME MANAGER (NOT modules/shared/git.nix):
#   modules/shared/git.nix writes the system-wide gitconfig, which only exists on
#   NixOS. nix-darwin has no 'programs.git', so that block is skipped on the Macs.
#   Home Manager runs on every host, so per-user Git preferences go here.
#
# WHY NEOVIM (nvimdiff):
#   - Declared on every host already (modules/shared/neovim.nix), so no extra
#     cask or package is needed on macOS or Linux.
#   - Works over SSH and inside Zellij; no GUI required.
#   - Git ships a built-in 'nvimdiff' tool definition, so no custom command.
#
# USAGE:
#   git difftool -d master...feat/fleet-services-expansion   # whole tree, one view
#   git difftool <file>                                        # single file
#   git mergetool                                              # resolve conflicts
#   (In nvim: ]c / [c jump between changes, :qa quits, :cq aborts with an error.)
# ==============================================================================

{ ... }:

{
  # Home Manager writes this to ~/.config/git/config. It coexists with the
  # system gitconfig on NixOS and any existing ~/.gitconfig.
  programs.git = {
    enable = true;
    settings = {
      diff.tool = "nvimdiff";
      difftool.prompt = false; # Don't ask "Launch nvimdiff? [Y/n]" for every file
      merge.tool = "nvimdiff";
      mergetool.prompt = false;
      mergetool.keepBackup = false; # Don't leave *.orig files after resolving
    };
  };
}
