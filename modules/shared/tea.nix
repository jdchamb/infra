# ==============================================================================
# SHARED MODULE: modules/shared/tea.nix (Codeberg / Forgejo / Gitea CLI)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 12 & 24):
#   Installs the official 'tea' CLI client for interacting with Codeberg and
#   self-hosted Forgejo instances (managing issues, pull requests, releases,
#   and repositories directly from the terminal).
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   This fleet repository is hosted on Codeberg (which runs Forgejo, a community
#   fork of Gitea). Just like GitHub has the 'gh' CLI tool, Codeberg/Forgejo has
#   'tea'. With 'tea', you can open pull requests, list open issues, or clone
#   your repositories without leaving the terminal.
#
# QUICK USAGE CHEAT SHEET:
#   - 'tea login add' : Authenticate with codeberg.org or your local Forgejo server
#   - 'tea pr list'   : List open Pull Requests for the current repository
#   - 'tea pr create' : Open a new Pull Request from your current branch
#   - 'tea issues'    : List open issues in the terminal
# ==============================================================================

{ pkgs, lib, ... }:

{
  # Install the 'tea' binary globally across all importing hosts
  environment.systemPackages = [
    pkgs.tea
  ];
}
