{ pkgs, lib, options, ... }:

{
  config = lib.mkMerge [
    {
      # Add marksman to systemPackages so it's globally visible in Kate's PATH
      environment.systemPackages = with pkgs; [
        git
        marksman
      ];
    }
    (lib.optionalAttrs (options ? programs && options.programs ? git) {
      programs.git = {
        enable = true;
        config = {
          user.name = "Joshua Daniel Chambers";
          user.email = "joshua@chambers-net.org";
          init.defaultBranch = "master";
          pull.rebase = false;
        };
      };
    })
  ];
}



