{ pkgs, ... }:

{
  # Install the core secrets management utilities globally
  environment.systemPackages = with pkgs; [
    age
    sops
  ];
}
