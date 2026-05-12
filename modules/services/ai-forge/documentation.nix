{ config, lib, pkgs, ... }:

let
  # The "Knowledge Sources"
  nixosManual = pkgs.fetchurl {
    url = "https://nixos.org/manual/nixos/stable/index.html";
    hash = "sha256-OE05ZgBkpk0EfjSFi8XTWIe/EGfssc/SYiOYer8jpv8==";
  };

  darwinManual = pkgs.fetchurl {
    url = "https://github.com/nix-darwin/nix-darwin/archive/master.tar.gz";
    hash = "sha256-y64fro2BQLlZfibVxJl3bRMQ3ln+83fRnU5Bu0LayXg=";
  };

  onDroidManual = pkgs.fetchurl {
    url = "https://nix-community.github.io/nix-on-droid/nix-on-droid-options.html";
    hash = "sha256-+QDuuJYVI31xhicy+nHfXxLOJmvDZLC9nmEZ2Uq3cyc=";
  };
in {
  # 1. DEFINE THE OPTION
  options.services.ai-forge = {
    enable = lib.mkEnableOption "AI Forge Knowledge Bridge";
  };

  # 2. THE CONFIGURATION (Only runs if enable = true)
  config = lib.mkIf config.services.ai-forge.enable {
    system.activationScripts.aiForgeLibrary = {
      text = ''
        DOC_PATH="/home/jchambers/anythingllm/documents/forge-context"
        mkdir -p "$DOC_PATH"

        ln -sfn ${nixosManual}   "$DOC_PATH/nixos-manual.html"
        ln -sfn ${darwinManual}  "$DOC_PATH/nix-darwin-manual.tar.gz"
        ln -sfn ${onDroidManual} "$DOC_PATH/nix-on-droid-options.html"

        ln -sfn /home/jchambers/src/dotfiles "$DOC_PATH/my-configs"
      '';
    };
  };
}
