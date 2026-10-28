# ==============================================================================
# USER PROGRAM: home/programs/zsh.nix (Interactive Zsh Shell Environment)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Configures the interactive Zsh shell environment identically across all
#   nodes in the fleet. This eliminates "dotfile drift" and ensures that:
#     - Up/Down history substring search behaves identically everywhere.
#     - 50,000 commands are remembered and shared across open tabs.
#     - Modern CLI replacements (eza, bat, fzf, zoxide) work out-of-the-box.
#     - The universal 'rebuild' command operates cleanly on any host.
#
# QUICK REFERENCE CHEAT SHEET:
#   - 'rebuild'          : Rebuilds the current machine's Nix configuration.
#   - 'rebuild test'     : Tests configuration without permanently switching.
#   - 'z <folder>'       : Teleports to a visited folder using frecency (zoxide).
#   - 'zi'               : Interactive fuzzy jump menu for directories.
#   - 'Ctrl + R'         : Interactive fuzzy search through 50,000 command history.
#   - 'Ctrl + T'         : Interactive fuzzy file picker (inserts path at cursor).
#   - 'Option + C'       : Interactive directory tree browser (cd into selection).
# ==============================================================================

{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;                 # Activates declarative Zsh profile management
    enableCompletion = true;       # Enables the native Zsh completion system (compsys)
    autosuggestion.enable = true;  # Fish-like inline history auto-suggestions as you type
    syntaxHighlighting.enable = true; # Real-time visual feedback (green = valid command, red = invalid)

    # --------------------------------------------------------------------------
    # 1. HISTORY CONFIGURATION (50,000 Entries, Shared & Deduplicated)
    # --------------------------------------------------------------------------
    history = {
      size = 50000;                  # Number of history lines kept in memory
      save = 50000;                  # Number of history lines persisted to disk
      extended = true;              # Save timestamp and duration of each command
      share = true;                 # Share command history in real-time across all open tabs
      expireDuplicatesFirst = true; # When trimming history, prune duplicates before unique commands
      ignoreAllDups = true;         # Do not record duplicate consecutive commands
      ignoreSpace = true;           # Commands starting with a space are omitted from history (for secrets)
    };

    # --------------------------------------------------------------------------
    # 2. TAB-COMPLETION ENGINE FINE-TUNING
    # --------------------------------------------------------------------------
    completionInit = ''
      # Case-insensitive tab-completion: typing 'doc' matches 'Documents'
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

      # Visual menu selection: interactive grid selectable via arrow keys
      zstyle ':completion:*' menu select

      # Persistent completion cache: drastically speeds up heavy evaluations
      zstyle ':completion:*' use-cache yes
      zstyle ':completion:*' cache-path "$HOME/.zcompcache"
    '';

    # --------------------------------------------------------------------------
    # 3. INTERACTIVE SHELL ALIASES
    # --------------------------------------------------------------------------
    shellAliases = {
      # Universal Fleet Rebuild Command (auto-detects OS and hostname)
      rebuild = "rebuild";
      update  = "rebuild";

      # Modern CLI replacements (eza for ls, bat for cat)
      ls   = "eza --icons=auto --group-directories-first";
      ll   = "eza -la --icons=auto --group-directories-first";
      tree = "eza --tree --icons=auto";
      cat  = "bat --style=plain";

      # Quick one-shot repomix execution without permanently installing it
      repomix = "nix-shell -p repomix --run repomix";

      # Administrative Guardrails: prompts for confirmation on destructive file operations
      rm = "rm -i";
      mv = "mv -i";
      cp = "cp -i";
    };

    # --------------------------------------------------------------------------
    # 4. SMART MULTI-OS FLEET REBUILD FUNCTION
    # --------------------------------------------------------------------------
    # How this works:
    #   1. Detects OS: On macOS ($OSTYPE == darwin), uses 'darwin-rebuild'.
    #                  On Linux, uses 'nixos-rebuild'.
    #   2. Detects Hostname: Uses 'scutil --get LocalHostName' on macOS or 'hostname -s'
    #                        on Linux, automatically targeting the active host.
    #   3. Allows action override: 'rebuild test' runs a dry/test build.
    # --------------------------------------------------------------------------
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

  # ----------------------------------------------------------------------------
  # 5. INTERACTIVE FUZZY FINDER (fzf)
  # ----------------------------------------------------------------------------
  # Provides visual fuzzy search over history (Ctrl+R), files (Ctrl+T), and folders (Alt+C)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height 40%"       # Compact bottom 40% window height
      "--layout=reverse"   # Display input prompt at top, results descending
      "--border"           # Clean rounded border
      "--inline-info"      # Compact hit counter on the prompt line
    ];
  };

  # ----------------------------------------------------------------------------
  # 6. SMART DIRECTORY NAVIGATION (zoxide)
  # ----------------------------------------------------------------------------
  # Replaces 'cd' with frecency-based navigation ('z <folder>' or 'zi' for interactive)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
