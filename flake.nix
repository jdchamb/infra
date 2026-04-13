{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager config
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
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

	  # For your Nerd Fonts
            fonts.packages = [
              pkgs.nerd-fonts.fira-code
              pkgs.nerd-fonts.jetbrains-mono
            ];

         #home manager configurations
         home-manager.useGlobalPkgs = true;
         home-manager.useUserPackages = true;
         home-manager.users.jchambers = { pkgs, ... }: {
           # This tells Home Manager which version of its internal rules to use.
           home.stateVersion = "24.11"; 
         
           # This is the "User Level" equivalent of environment.systemPackages.
           home.packages = [
             # We can move user-specific tools here later!
           ];
         };
           # This is where your Zsh and Starship settings will live!
         };

	homebrew = {
	  enable = true;
	  onActivation.cleanup = "zap"; # This UNINSTALLS anything not in this list!
	  
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
             "mas" # Mac App Store CLI if you need it
          ]; 
	};

	programs.zsh = {
	  enable = true;
	  enableCompletion = true;
     # This tells Nix to manage your Zsh configuration files
       programs.zsh = {
         enable = true;
         enableCompletion = true;
         autosuggestion.enable = true;      
         syntaxHighlighting.enable = true;
     	};

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Setting primary user for nix
      system.primaryUser = "jchambers";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."308-225660" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration 
	
        # home manager module for nix-darwin flake
        inputs.home-manager.darwinModules.home-manager
      ];
    };
  };
}
