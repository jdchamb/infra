{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    config = {
      user.name = "Joshua D Chambers";
      user.email = "jdcambers@gmail.com"; # Or your work email
      init.defaultBranch = "master";
    };
  };
}
