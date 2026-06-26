{ config, pkgs, ... }:

{
  # --- System-Wide Zsh Shell Configuration ---
  programs.zsh = {
    # Activates the Zsh infrastructure globally so the skeleton can allocate it to users
    enable = true;

    # Enables native system-wide command completion tracking
    enableCompletion = true;

    # Native NixOS system-wide configuration for Zsh autosuggestions (requires the trailing 's')
    autosuggestions.enable = true;

    # Deploys safe, visual terminal syntax highlighting for interactive commands
    syntaxHighlighting.enable = true;

    # --- Case-Insensitive Smart Tab Completion Engine ---
    # Moved to interactiveShellInit so it is valid in native NixOS system configurations.
    # Matches lower case to upper case, activates dropdown menus, and caches results.
    interactiveShellInit = ''
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' use-cache yes
      zstyle ':completion:*' cache-path "$HOME/.zcompcache"
    '';

    # --- Core Administrative & Safety Command Shorthand Aliases ---
    shellAliases = {
      # Infrastructure deployment triggers mapped strictly to your home repository tree namespace
      updatedt01 = "sudo nixos-rebuild switch --flake ~/src/infra --target-host wrk-dt01";
      updatelt01 = "sudo nixos-rebuild switch --flake ~/src/infra --target-host wrk-lt01";

      # Safety overrides: Prompts for confirmation before destroying or overwriting targets
      rm = "rm -i";
      mv = "mv -i";
      cp = "cp -i";
    };
  };
}
