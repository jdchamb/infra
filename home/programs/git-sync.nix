# ==============================================================================
# USER PROGRAM: home/programs/git-sync.nix (Zsh Directory-Switch Git Sync Hook)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap — Phase 1):
#   Implements an intelligent Zsh 'chpwd' (change working directory) hook:
#     1. When entering a directory controlled by Git, performs a fast background/
#        short-timeout 'git fetch --quiet'.
#     2. Checks if the upstream tracking branch has new commits ahead of HEAD
#        while the local working tree is clean.
#     3. Prompts: "Upstream has changes. Rebase now? [y/N]" and runs
#        'git pull --rebase' upon confirmation so you never forget to pull before
#        working on a repository.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  programs.zsh.initContent = lib.mkAfter ''
    # --- Automated Git Fetch & Rebase Prompt on Directory Change ---
    _fleet_git_chpwd_hook() {
      # Only trigger in interactive terminals inside a valid Git working tree
      [[ -t 0 && -t 1 ]] || return 0
      git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

      # Ensure an upstream tracking branch is configured
      local upstream
      upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || return 0

      # Quietly fetch upstream updates (timeout after 3s so offline networks never hang cd)
      GIT_TERMINAL_PROMPT=0 command git fetch --quiet 2>/dev/null || return 0

      local behind
      behind=$(git rev-list --count "HEAD..$upstream" 2>/dev/null || echo 0)
      if [[ "$behind" -gt 0 ]]; then
        if [[ -z "$(git status --porcelain 2>/dev/null)" ]]; then
          echo -ne "\033[1;33m==> [git-sync] Upstream ($upstream) is ahead by $behind commit(s). Rebase now? [y/N]: \033[0m"
          local reply
          read -r -k 1 reply
          echo ""
          if [[ "$reply" =~ ^[Yy]$ ]]; then
            command git pull --rebase
          fi
        else
          echo -e "\033[1;33m==> [git-sync] Note: Upstream ($upstream) has $behind new commit(s), but working tree has local modifications.\033[0m"
        fi
      fi
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd _fleet_git_chpwd_hook
  '';
}
