{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    config = {
      user.name = "Joshua D Chambers";
      user.email = "truetenacity.jc@gmail.com"; # Or your work email
      init.defaultBranch = "master";
    };
  };
}
