{ pkgs, modulesPath, ... }:

{
  # Imports the base configuration for making a bootable live CD
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # Force the installer to use pure open-source software kernels
  nixpkgs.config.allowUnfree = false;

  # Enable Flakes natively inside the live environment installer
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Pre-bake your key utilities directly into the live image system path
  environment.systemPackages = with pkgs; [
    vim
    git
    tmux
    pciutils  # Great for auditing host hardware on the fly
    usbutils
  ];

  # Force networking to start up automatically on boot
  networking.networkmanager.enable = true;
}
