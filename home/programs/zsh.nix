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

    # --- 1. History Configuration (50k lines, shared, de-duplicated) ---
    history = {
      size = 50000;
      save = 50000;
      extended = true;
      share = true;
      expireDuplicatesFirst = true;
      ignoreAllDups = true;
      ignoreSpace = true;
    };

    # --- 2. Tab-Completion Engine Fine-Tuning ---
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

    # --- 3. Interactive Shell Aliases ---
    shellAliases = {
      # Universal Fleet Rebuild Command (auto-detects OS and hostname)
      rebuild = "rebuild";
      update  = "rebuild";

      # Modern CLI replacements
      ls   = "eza --icons=auto --group-directories-first";
      ll   = "eza -la --icons=auto --group-directories-first";
      tree = "eza --tree --icons=auto";
      cat  = "bat --style=plain";

      # Run repomix quickly without installing
      repomix = "nix-shell -p repomix --run repomix";

      # System Administration Guardrails
      rm = "rm -i"; # Intercepts random file deletions
      mv = "mv -i"; # Warns before overwriting an existing destination file during a move
      cp = "cp -i"; # Warns before overwriting an existing destination file during a copy
    };

    # --- 4. Smart Multi-OS Fleet Rebuild Function ---
    initContent = ''
      rebuild() {
        local action="''${1:-switch}"
        local host="''${2:-$(scutil --get LocalHostName 2>/dev/null || hostname -s)}"
        local flake="''${FLAKE:-$HOME/src/infra}"

        if [[ "$OSTYPE" == "darwin"* ]]; then
          echo "==> Rebuilding Darwin system for '$host' ($action)..."
          sudo darwin-rebuild "$action" --flake "$flake#$host" "''${@:3}"
        else
          echo "==> Rebuilding NixOS system for '$host' ($action)..."
          sudo nixos-rebuild "$action" --flake "$flake#$host" "''${@:3}"
        fi
      }
    '';
  };

  # --- 5. Interactive Fuzzy Finder (fzf) ---
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];
  };

  # --- 6. Smart Directory Navigation (zoxide) ---
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
