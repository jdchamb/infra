# ==============================================================================
# USER PROGRAM: home/programs/git-sync.nix (Zsh Directory-Switch Git Sync Hook)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap — Phase 1):
#   Implements an intelligent Zsh 'chpwd' (change working directory) hook:
#     1. When entering a directory controlled by Git, performs a fast, silent
#        'git fetch --quiet' against the remote server.
#     2. Checks if the upstream tracking branch has new commits ahead of HEAD
#        while the local working tree is clean.
#     3. Prompts: "Upstream has changes. Rebase now? [y/N]" and runs
#        'git pull --rebase' upon confirmation.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When working across multiple machines (e.g., making a change on your Linux
#   workstation '308-222242', pushing it, and later opening your MacBook
#   'MBA-Chambers' or '308-225660'), it is very easy to 'cd ~/src/infra' and
#   start editing files before remembering to run 'git pull'. That leads to
#   painful merge conflicts!
#   In Zsh, 'chpwd' is a special event hook that fires automatically every time
#   you 'cd' (or jump with 'z') into a new folder. This module attaches our
#   '_fleet_git_chpwd_hook' function to that event so your shell automatically
#   checks for remote updates the moment you step into any Git repository.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  # 'lib.mkAfter' appends this script to the end of the generated ~/.zshrc file
  programs.zsh.initContent = lib.mkAfter ''
    # --- Automated Git Fetch & Rebase Prompt on Directory Change ---
    _fleet_git_chpwd_hook() {
      # 1. Safety Check: Only run in interactive human terminal sessions (not scripts)
      #    and only if the current directory is inside a valid Git repository.
      [[ -t 0 && -t 1 ]] || return 0
      git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

      # 2. Check if the current branch tracks a remote branch (e.g., origin/master).
      #    If it's a purely local branch with no remote, exit silently.
      local upstream
      upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || return 0

      # 3. Quietly fetch remote metadata without modifying local files.
      #    GIT_TERMINAL_PROMPT=0 prevents hanging on password prompts if offline.
      GIT_TERMINAL_PROMPT=0 command git fetch --quiet 2>/dev/null || return 0

      # 4. Count how many commits the remote branch is ahead of our local HEAD.
      local behind
      behind=$(git rev-list --count "HEAD..$upstream" 2>/dev/null || echo 0)
      if [[ "$behind" -gt 0 ]]; then
        # 5. If the working tree is clean (no uncommitted local edits), offer a 1-key rebase:
        if [[ -z "$(git status --porcelain 2>/dev/null)" ]]; then
          echo -ne "\033[1;33m==> [git-sync] Upstream ($upstream) is ahead by $behind commit(s). Rebase now? [y/N]: \033[0m"
          local reply
          read -r -k 1 reply
          echo ""
          if [[ "$reply" =~ ^[Yy]$ ]]; then
            command git pull --rebase
          fi
        else
          # If there are uncommitted local edits, warn the user instead of rebasing automatically
          echo -e "\033[1;33m==> [git-sync] Note: Upstream ($upstream) has $behind new commit(s), but working tree has local modifications.\033[0m"
        fi
      fi
    }

    # Register '_fleet_git_chpwd_hook' to run every time the working directory changes
    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd _fleet_git_chpwd_hook
  '';
}
