# ==============================================================================
# SHARED MODULE: modules/shared/git-bug.nix (Distributed Git Issue Tracker)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 12):
#   Installs 'git-bug', a distributed, offline-first bug and issue tracker that
#   stores issues, comments, and status boards directly inside internal Git
#   objects (refs/bugs/*) rather than external SQL databases or web portals.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Traditionally, project tasks live in markdown files (like docs/pprojects.md)
#   or on a web server (like GitHub/Codeberg Issues) that requires internet access.
#   'git-bug' embeds issues directly inside your '.git' folder as cryptographic
#   Git objects. You can view and edit issues offline in a terminal UI ('git bug termui')
#   and push/pull them to Codeberg just like normal code commits!
#
# QUICK USAGE CHEAT SHEET:
#   - 'git bug user create' : Create your local bug-tracker author identity
#   - 'git bug add'         : Open an interactive editor to create a new issue
#   - 'git bug termui'      : Launch the full interactive terminal issue board
#   - 'git bug push / pull' : Sync issues with your remote Git server
# ==============================================================================

{ pkgs, ... }:

{
  # Install the standalone 'git-bug' binary globally across Linux and macOS
  environment.systemPackages = [
    pkgs.git-bug
  ];
}
