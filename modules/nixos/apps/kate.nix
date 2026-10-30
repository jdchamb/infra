# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/kate.nix (KDE Kate Text Editor & Nix IDE)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 26 — 1-to-1 Module for Kate):
#   Installs the KDE Kate advanced text editor alongside 'nixd' (Nix Language Server)
#   and 'nixfmt-rfc-style' (the official Nixpkgs formatting tool). Pre-provisions
#   declarative XML code templates for rapid NixOS module authoring ('nix-mod',
#   'pkgs-list', 'systemd-svc', 'sops-secret', 'hm-file') and binds 'Ctrl+Alt+N'
#   inside 'kateshortcutsrc' to trigger the snippets completion menu.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Writing Nix code can be daunting for beginners due to brackets, semicolons,
#   and attribute syntax. While heavy IDEs like VS Code require massive Electron
#   runtimes, KDE Kate is a lightweight, blazing-fast native Qt editor:
#   - 'nixd' LSP Server: Provides real-time syntax checking, auto-completion of Nixpkgs
#     package names, and documentation popups as you type.
#   - 'nixfmt-rfc-style': Formats your Nix code cleanly according to community standards.
#   - Declarative XML Snippets: Type 'nix-mod' and press Tab, and Kate instantly inserts
#     a boilerplate module header and skeleton. Type 'pkgs-list' or 'systemd-svc'
#     to generate pre-configured blocks in seconds.
#   - Breeze Dark & JetBrains Mono: Configured out of the box with 2-space indentation
#     and standard developer shortcuts (Ctrl+P for Quick Open, Ctrl+S for Save).
#
# HOW TO USE:
#   - Open a file in Kate: 'kate /home/jchambers/src/infra/flake.nix'
#   - Open file search palette: Press 'Ctrl + P'
#   - Insert a Nix code snippet: Press 'Ctrl + Alt + N' or type snippet keyword
#     ('nix-mod', 'pkgs-list', 'systemd-svc') and press Tab.
# ==============================================================================

{ config, pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. System Packages: Editor, Language Server & Formatter
  # --------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    kdePackages.kate   # Full KDE Kate graphical text editor
    nixd               # High-performance Nix language server protocol (LSP) engine
    nixfmt-rfc-style   # Official RFC-style Nix code formatter
  ];

  # --------------------------------------------------------------------------
  # 2. Declarative User Configuration (Home Manager for 'jchambers')
  # --------------------------------------------------------------------------
  home-manager.users.jchambers = { ... }: {

    # Declarative NixOS Snippets Library (Project 26)
    # Stored in Kate's local user snippets repository
    home.file.".local/share/kate/snippets/nix_declarations.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <snippets namespace="NixOS Configurations" license="MIT" filetype="Nix" authors="Joshua Chambers" version="1">
        <!-- Template: Standard NixOS Module Skeleton -->
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

        <!-- Template: System Packages Block -->
        <item>
          <displayprefix>nix</displayprefix>
          <match>pkgs-list</match>
          <displayafter>System package block</displayafter>
          <text>environment.systemPackages = with pkgs; [
        %cursor%
      ];</text>
        </item>

        <!-- Template: systemd Oneshot Service -->
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

        <!-- Template: Home Manager Dotfile Injection Block -->
        <item>
          <displayprefix>nix</displayprefix>
          <match>hm-file</match>
          <displayafter>Home Manager dotfile injection block</displayafter>
          <text>home-manager.users.jchambers = { ... }: {
        home.file."%cursor%".text = '''
          
        ''';
      };</text>
        </item>

        <!-- Template: sops-nix Secret Declaration -->
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

    # Core Editor Settings, Fonts, and Plugin Activation
    home.file.".config/katerc".text = ''
      [General]
      Show Welcome Page=false
      Startup Session=last

      [KTextEditor Document]
      # 2-space indentation (standard Nix convention)
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

    # Developer Keyboard Shortcuts
    home.file.".config/kateshortcutsrc".text = ''
      [Shortcuts]
      tools_snippets=Ctrl+Alt+N
      file_save=Ctrl+S
      view_quick_open=Ctrl+P
    '';
  };
}
