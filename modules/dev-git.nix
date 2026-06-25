{ pkgs, ... }:

{
  # Add marksman to systemPackages so it's globally visible in Kate's PATH
  environment.systemPackages = with pkgs; [
    marksman
  ];

  programs.git = {
    enable = true;
    config = {
      user.name = "Joshua D Chambers";
      user.email = "truetenacity.jc@gmail.com";
      init.defaultBranch = "master";
    };
  };
}
