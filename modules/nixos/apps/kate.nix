# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/kate.nix (KDE Kate Text Editor)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 26 — 1-to-1 Module for Kate):
#   Installs KDE Kate alongside 'nixd' and 'nixfmt-rfc-style'. Provisions
#   declarative XML code snippets for rapid NixOS module authoring ('nix-mod',
#   'pkgs-list', 'systemd-svc', 'sops-secret', 'hm-file') and binds 'Ctrl+Alt+N'
#   inside 'kateshortcutsrc' to trigger the snippets selector.
# ==============================================================================

{ config, pkgs, ... }:

{
  # 1. Install Kate and Nix LSP/Formatting Companions
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    nixd
    nixfmt-rfc-style
  ];

  # 2. Inject Declarative Snippets & Shortcut Bindings into Home Manager (Project 26)
  home-manager.users.jchambers = { ... }: {

    # Declarative NixOS Snippets Pipeline
    home.file.".local/share/kate/snippets/nix_declarations.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <snippets namespace="NixOS Configurations" license="MIT" filetype="Nix" authors="Joshua Chambers" version="1">
        <item>
          <displayprefix>nix</displayprefix>
          <match>nix-mod</match>
          <displayafter>Standard documented NixOS module template</displayafter>
          <text># ==============================================================================
      # ROLE & ARCHITECTURE: %cursor%
      # ==============================================================================

      { config, lib, pkgs, ... }:

      {
        
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
        <item>
          <displayprefix>nix</displayprefix>
          <match>systemd-svc</match>
          <displayafter>Declarative systemd oneshot service</displayafter>
          <text>systemd.services.%cursor% = {
        description = "Custom declarative service";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = '''
          echo "Service running"
        ''';
      };</text>
        </item>
        <item>
          <displayprefix>nix</displayprefix>
          <match>hm-file</match>
          <displayafter>Home Manager dotfile injection block</displayafter>
          <text>home-manager.users.jchambers = { ... }: {
        home.file."%cursor%".text = '''
          
        ''';
      };</text>
        </item>
        <item>
          <displayprefix>nix</displayprefix>
          <match>sops-secret</match>
          <displayafter>SOPS secret extraction definition</displayafter>
          <text>sops.secrets."%cursor%" = {
        mode = "0600";
        owner = "jchambers";
      };</text>
        </item>
      </snippets>
    '';

    # Enable Snippets Plugin, Dark Theme & Compact Editor Defaults in Kate
    home.file.".config/katerc".text = ''
      [General]
      Show Welcome Page=false
      Startup Session=last

      [KTextEditor Document]
      Indentation Width=2
      ReplaceTabsDyn=true
      Show Spaces=1
      Tab Handling=2
      Tab Width=2
      Word Wrap=false

      [KTextEditor Renderer]
      Animate Bracket Matching=false
      Color Theme=Breeze Dark
      Font=JetBrains Mono,10,-1,5,50,0,0,0,0,0
      Show Indentation Lines=true

      [KTextEditor View]
      Dynamic Word Wrap=true
      Line Numbers=true
      Scroll Bar Mini Map=false
      Vi Input Mode=false

      [Kate Plugins]
      katesnippetsplugin=true
      lspclientplugin=true
      kateprojectplugin=true
    '';

    # Bind Ctrl+Alt+N to trigger the Snippets completion popup in Kate (Project 26)
    home.file.".config/kateshortcutsrc".text = ''
      [Shortcuts]
      tools_snippets=Ctrl+Alt+N
      file_save=Ctrl+S
      view_quick_open=Ctrl+P
    '';
  };
}
