{
  description = "JChambers MacOS System Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager}:
  let
    configuration = { pkgs, ... }: {

# 1. The engine
nix.settings.experimental-features = "nix-command flakes";

# 2. The Platform
nixpkgs.hostPlatform = "aarch64-darwin";

# 3. System Packages
environment.systemPackages = [
  pkgs.vim
  pkgs.git
  pkgs.starship
  pkgs.fastfetch
  pkgs.cmake
  pkgs.python311
  pkgs.nodejs
  pkgs.smartmontools
  pkgs.xz
  pkgs.zstd
];

# 4. Nerd Fonts
fonts.packages = [
  pkgs.nerd-fonts.fira-code
  pkgs.nerd-fonts.jetbrains-mono
];

# 5. Homebrew (Better for GUI/KDE Connect on Mac)
homebrew = {
  enable = true;
  onActivation.cleanup = "zap";
  casks = [
    "firefox"
    "1password"
    "ghostty"
    "google-drive"
    "adguard"
    "kdenlive"
    "utm"
    "windows-app"
  ];
  brews = [
    "mas"
  ];
};

# 6. Home Manager (For your user settings)
home-manager.useGlobalPkgs = true;
home-manager.useUserPackages = true;
home-manager.users.jchambers = {
  home.username = "jchambers";
  home.stateVersion = "24.11";
  home.homeDirectory = "/Users/jchambers";
  programs.starship.enable = true;
  home.file.".config/starship.toml".source = ./starship/starship.toml;

# zsh setup
programs.zsh = {
  enable = true;
  enableCompletion = true;
  autosuggestion.enable = true;      
  syntaxHighlighting.enable = true;

  # style and completion config zsh
  completionInit = ''
            zstyle ':completion:*' use-cache yes
            zstyle ':completion:*' cache-path "$HOME/.zcompcache"
            zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
            zstyle ':completion:*' menu select
          '';

          # alias config
          shellAliases = {
            update-install = "~/src/dotfiles/scripts/update-install";
            update-check   = "brew update && brew outdated; mas outdated; softwareupdate -l";
            update-logs    = "sudo log stream --predicate 'process == \"softwareupdated\"' --level debug";
            rm             = "rm -i";
            mv             = "mv -i";
            cp             = "cp -i";
            zsh-reload     = "source ~/.zshrc && echo 'Zsh config reloaded!'";
            sys            = "fastfetch";
          };

          # custom functions and logic
          initContent = ''
            # Brew completion FPATH logic
            if type brew &>/dev/null; then
              FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
            fi

            # Custom AI start function
            aistart() {
              local model_name="''${1:-Qwen2.5.1-Coder-7B-Instruct-Q4_K_L.gguf}"
              local model_path="$HOME/ai-lab/ai_models/$model_name"

              if [ ! -f "$model_path" ]; then
                echo "❌ Error: Model file not found at $model_path"
                return 1
              fi

              echo "🧠 Loading model: $model_name"
              cd ~/ai-lab/koboldcpp
              python3 koboldcpp.py --model "$model_path" --gpulayers 99 --smartcontext
              cd -
            }
            compdef '_path_files -W ~/ai-lab/ai_models' aistart
          '';
        }; # closes programs.zsh

# vim setup
programs.vim = {
  enable = true;
  plugins = [ pkgs.vimPlugins.vim-nix ];
  extraConfig = ''
            set tabstop=2
            set shiftwidth=2
            set expandtab
  '';
};
      };

# 7. macOS specific state
system.stateVersion = 6;
system.primaryUser = "jchambers";
users.users.jchambers = {
  name = "jchambers";
  home = "/Users/jchambers";
};
    };
  in
  {
    darwinConfigurations."308-225660" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration 
        home-manager.darwinModules.home-manager
      ];
    };
  };
}
