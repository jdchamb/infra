{ config, pkgs, ... }:

{
  # --- User-Space Zsh Configuration Layer ---
  # This configures your interactive Zsh shell environment inside Home Manager,
  # including auto-suggestions, tab-completions, and administrative safety wrappers.
  programs.zsh = {
    enable = true;                 # Activates Zsh management for the user profile
    enableCompletion = true;       # Enables the native Zsh completion system (compsys)
    autosuggestion.enable = true;  # Enables fish-like inline history auto-suggestions as you type
    syntaxHighlighting.enable = true; # Adds real-time visual color feedback for valid/invalid commands

    # --- Tab-Completion Engine Fine-Tuning ---
    # Configures the completion behavior, style matching, and localized caching
    completionInit = ''
      # Case-insensitive matching: allows lowercase inputs to map to uppercase completions
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

      # Menu selection: enables a clear, interactive visual grid selectable via arrow keys
      zstyle ':completion:*' menu select

      # Persistent Cache: Speeds up heavy tab-completions (like system commands/packages)
      # by saving evaluation states rather than rebuilding them on every single stroke
      zstyle ':completion:*' use-cache yes
      zstyle ':completion:*' cache-path "$HOME/.zcompcache"
    '';

    # --- Interactive Shell Aliases ---
    shellAliases = {
      # Infrastructure Flake Deployment Shorthand
      # Rebuilds and activates the 'wrk-dt01' workstation node directly from your local repository
      updatedt01 = "sudo nixos-rebuild switch --flake ~/src/infra#wrk-dt01";

      # System Administration Guardrails
      # Aliases destructive file manipulation commands to prompt for explicit confirmation (-i)
      rm = "rm -i"; # Intercepts random file deletions
      mv = "mv -i"; # Warns before overwriting an existing destination file during a move
      cp = "cp -i"; # Warns before overwriting an existing destination file during a copy
    };
  };
}
