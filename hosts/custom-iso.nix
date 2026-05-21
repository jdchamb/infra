{ pkgs, modulesPath, ... }:

{
  # Inject the official installation media hardware channel profiles
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # Enforce absolute 100% FLOSS package policy parameters (no unfree code)
  nixpkgs.config.allowUnfree = false;

  # Provision experimental features natively in the core media execution shell
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Mount production operational utilities directly inside the transient PATH
  environment.systemPackages = with pkgs; [
    vim
    git
    tmux
    pciutils      # Native bus scanners for hardware auditing
    usbutils      # Low-level serial and controller diagnostic tooling
    smartmontools # Block storage analysis and storage device inspection
  ];

  # Seed your actual public identity token into the live installer session user
  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOn6xT65eiBe41ztk2UZ5/nSdcdYI/eRhRjfXoAdduxA jchambers-codeberg"
  ];

  # Initialize automated background daemon adapters for network discovery
  networking.networkmanager.enable = true;
}
