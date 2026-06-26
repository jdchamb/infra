{ inputs, ... }:

{
  imports = [
    # Every machine on our fleet inherits the SOPS schema definition
    inputs.sops-nix.nixosModules.sops

    # Other things every single machine must have
    "${inputs.self}/modules/core-system.nix"
    "${inputs.self}/modules/core-network.nix"
  ];
}
