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
      # Permanently fixed to match your new functional shorthand target
      update = "sudo nixos-rebuild switch --flake ~/src/infra#wrk-dt01";

      # Your requested aliases
      rm = "rm -i";
      mv = "mv -i";
      cp = "cp -i";
    };

    # Fixed syntax: Home Manager uses initExtra for custom path configurations
    initContent = ''
      export PATH="$PATH:$HOME/.lmstudio/bin"
    '';
  };
}
