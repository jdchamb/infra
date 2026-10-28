{ pkgs, lib, options, ... }:

{
  config = lib.mkMerge [
    {
      # Essential build tools Neovim plugins will need later for compiling treesitter/LSPs
      environment.systemPackages = with pkgs; [
        neovim
        git
        gnumake
        gcc
        unzip
        wget
        curl
      ];
    }
    (lib.optionalAttrs (options ? programs && options.programs ? neovim) {
      programs.neovim = {
        enable = true;
        defaultEditor = true; # Sets $EDITOR to nvim
        viAlias = true;       # Aliases 'vi' to nvim
        vimAlias = true;      # Aliases 'vim' to nvim

        # Optional: Safe, minimal fallback defaults built directly into Nix
        configure = {
          customRC = ''
            " A couple of sane defaults just in case your local config isn't pulled down yet
            set number
            set relativenumber
            set shiftwidth=2
            set tabstop=2
            set expandtab
          '';
        };
      };
    })
  ];
}

