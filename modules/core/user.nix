{ config, pkgs, ... }:

{
  users.users.jchambers = {
    isNormalUser = true;
    description = "Joshua Chambers"; # Putting your full name in the metadata
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    # Using the standard Zsh shell we'll configure later
    shell = pkgs.zsh;
  };

  # Enable zsh globally so the user can actually use it
  programs.zsh.enable = true;
}
