{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Matches your matcher-list 'm:{a-z}={A-Z}' and menu select
    completionInit = ''
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' use-cache yes
      zstyle ':completion:*' cache-path "$HOME/.zcompcache"
    '';

    shellAliases = {
      # Updated path to match your current flake location
      update = "sudo nixos-rebuild switch --flake ~/src/infra#308-221357";

      # Your requested aliases
      rm = "rm -i";
      mv = "mv -i";
      cp = "cp -i";
    };

    # For LM Studio path (matches your M4 Mac goal)
    initContent = ''
      export PATH="$PATH:$HOME/.lmstudio/bin"
    '';
  };
}
