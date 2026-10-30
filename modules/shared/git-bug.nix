# ==============================================================================
# SHARED MODULE: modules/shared/git-bug.nix (Distributed Git Issue Tracker)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 12):
#   Installs 'git-bug', a distributed, offline-first bug and issue tracker that
#   stores issues, comments, and status boards directly inside internal Git
#   objects (rather than external databases or proprietary web portals) and syncs
#   cleanly with Codeberg/Gitea/GitHub remotes.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.git-bug
  ];
}
