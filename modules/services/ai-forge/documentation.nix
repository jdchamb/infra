{ config, lib, pkgs, ... }:

let
  # Create a static "Knowledge Hub" folder in the Nix Store
  aiLibrary = pkgs.runCommand "ai-forge-library" {} ''
    mkdir -p $out
    ln -s ${pkgs.fetchurl {
      url = "https://nixos.org/manual/nixos/stable/index.html";
      hash = "sha256-OE05ZgBkpk0EfjSFi8XTWIe/EGfssc/SYiOYer8jpv8==";
    }} $out/nixos-manual.html

    ln -s ${pkgs.fetchurl {
      url = "https://github.com/nix-darwin/nix-darwin/archive/master.tar.gz";
      hash = "sha256-y64fro2BQLlZfibVxJl3bRMQ3ln+83fRnU5Bu0LayXg=";
    }} $out/nix-darwin-manual.tar.gz

    ln -s ${pkgs.fetchurl {
      url = "https://nix-community.github.io/nix-on-droid/nix-on-droid-options.html";
      hash = "sha256-+QDuuJYVI31xhicy+nHfXxLOJmvDZLC9nmEZ2Uq3cyc=";
    }} $out/nix-on-droid-options.html
  '';
in {
  options.services.ai-forge.enable = lib.mkEnableOption "AI Forge";

  config = lib.mkIf config.services.ai-forge.enable {
    # We export the library path so we can use it in the other file
    _module.args.aiLibrary = aiLibrary;
  };
}
