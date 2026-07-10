{ config, pkgs, ... }:

{
  # 1. Guarantee the package is available on the host system
  environment.systemPackages = with pkgs; [
    kdePackages.kate
  ];

  # 2. Inject your shortcuts and snippets into the user configuration space
  home-manager.users.jchambers = { ... }: {

    # Declarative snippets pipeline (Project 26)
    home.file.".local/share/kate/snippets/nix_declarations.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <snippets namespace="NixOS Configurations" license="MIT" filetype="Nix" version="1">
        <item>
          <displayprefix>nix</displayprefix>
          <match>nix-mod</match>
          <displayafter>Standard Module template</displayafter>
          <text>{ config, pkgs, ... }:

      {
        %cursor%
      }</text>
        </item>
        <item>
          <displayprefix>nix</displayprefix>
          <match>pkgs-list</match>
          <displayafter>System package block</displayafter>
          <text>environment.systemPackages = with pkgs; [
        %cursor%
      ];</text>
        </item>
      </snippets>
    '';

    # Custom keybind configurations or styling adjustments can go here as well
    home.file.".config/katerc".text = ''
      [General]
      Show Welcome Page=false
    '';
  };
}
