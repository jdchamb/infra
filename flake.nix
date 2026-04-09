{
  description = "JChambers MacOS System Flake";

  # 1. INPUTS: The 'Blueprint' sources.
  # We use the nested style here to group URLs and their dependencies together.
  inputs = {
    # The primary source for all Nix packages (unstable branch for latest versions).
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Controls MacOS system-level settings (Dock, keyboard, etc.).
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs"; # Forces this to use our main nixpkgs.
    };

    # Manages files in your home directory (Zsh config, Starship, etc.).
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Keeps user and system packages in sync.
    };
  };

  # 2. OUTPUTS: The assembly line that builds your specific Mac.
  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    # The 'configuration' variable holds the actual system rules.
    configuration = { pkgs, ... }: {
      
      # Packages installed for every user on the system.
      environment.systemPackages = [
        pkgs.vim pkgs.git pkgs.starship pkgs.fastfetch 
        pkgs.cmake pkgs.python311 pkgs.nodejs 
        pkgs.smartmontools pkgs.xz pkgs.zstd
      ];

      # Tells MacOS to make these fonts available for use in Ghostty/Terminal.
      fonts.packages = [
        pkgs.nerd-fonts.fira-code
        pkgs.nerd-fonts.jetbrains-mono
      ];

      # --- HOME MANAGER: Your personal 'Apartment' settings ---
      home-manager.useGlobalPkgs = true;   # Shares the system's package registry.
      home-manager.useUserPackages = true; # Installs packages specifically for you.
      home-manager.users.jchambers = { pkgs, ... }: {
        home.stateVersion = "24.11"; # Match the nix-darwin state version.
        
        # Manages your Zsh shell settings and plugins automatically.
        programs.zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = true;     
          syntaxHighlighting.enable = true;
        };

        # Manages your terminal prompt style.
        programs.starship = {
          enable = true;
          enableZshIntegration = true;
        };
      };

      # --- HOMEBREW: The bridge for GUI apps and standard Mac tools ---
      homebrew = {
        enable = true;
        onActivation.cleanup = "zap"; # UNINSTALLS anything not in this list!
        casks = [
          "firefox" "1password" "ghostty" "google-drive"
          "adguard" "kdenlive" "utm" "windows-app"
        ];
        brews = [ "mas" ]; # CLI for Mac App Store.
      };

      # Essential Nix-Darwin boilerplate.
      nix.settings.experimental-features = "nix-command flakes";
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin"; # Specifically for your M4 chip.
      system.primaryUser = "jchambers";
    };
  in
  {
    # This defines your specific Mac by its hostname.
    darwinConfigurations."308-225660" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration 
        home-manager.darwinModules.home-manager # Activates the HM bridge.
      ];
    };
  };
}
