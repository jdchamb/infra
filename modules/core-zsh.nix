{ config, pkgs, ... }:

{
  # --- System-Wide Zsh Shell Configuration ---
  programs.zsh = {
    # Activates the Zsh infrastructure globally so the skeleton can allocate it to users
    enable = true;

    # Enables native system-wide command completion tracking
    enableCompletion = true;

    # --- System vs. Home-Manager Compatibility Layer ---
    # We declare both the singular and plural paths. NixOS natively reads the plural 'autosuggestions',
    # while this safeguards compatibility if elements assess the config downstream.
    autosuggestions.enable = true;
    autosuggestion.enable = true;

    # Deploys safe, visual terminal syntax highlighting for interactive commands
    syntaxHighlighting.enable = true;

    # --- Case-Insensitive Smart Tab Completion Engine ---
    # Matches your precise completion preferences: lower case matches upper case,
    # activates visual menu selection dropdowns, and caches results locally to prevent terminal stutter.
    completionInit = ''
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' use-cache yes
      zstyle ':completion:*' cache-path "$HOME/.zcompcache"
    '';

    # --- Core Administrative & Safety Command Shorthand Aliases ---
    shellAliases = {
      # Infrastructure deployment triggers mapped strictly to your home repository tree namespace
      updatedt01 = "sudo nixos-rebuild switch --flake ~/src/infra#wrk-dt01";
      updatelt01 = "sudo nixos-rebuild switch --flake ~/src/infra#wrk-lt01";

      # Safety overrides: Prompts for confirmation before destroying or overwriting targets
      rm = "rm -i";
      mv = "mv -i";
      cp = "cp -i";
    };
  };
}
