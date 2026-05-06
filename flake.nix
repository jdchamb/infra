{
	description = "Main flake for desktop worstation";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = { self, nixpkgs, ... }@inputs: {

nixosConfigurations."308-221357" = nixpkgs.lib.nixosSystem {
			specialArgs = { inherit inputs; };
			modules = [ ./hosts/308-221357/configuration.nix ];
};
      nixosConfigurations."308-222222" = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/308-222222/configuration.nix ];
		};
	};
}
