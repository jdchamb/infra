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
					"kdeconnect"
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
			home-manager.users.jchambers = { pkgs, ... }: {
				home.stateVersion = "24.11";
				home.username = "jchambers";
				home.homeDirectory = "/Users/jchambers";

#zsh setup
				programs.zsh = {
					enable = true;
					enableCompletion = true;
					autosuggestion.enable = true;      
					syntaxHighlighting.enable = true;
				};

#vim setup
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
