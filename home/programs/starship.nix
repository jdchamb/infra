# ==============================================================================
# USER PROGRAM: home/programs/starship.nix (Cross-Shell Prompt Engine)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Starship is a minimal, fast, and customizable prompt engine.
#   - Visual Theme: Catppuccin Mocha (matching Ghostty and editor colors).
#   - Glyph System: Uses Powerline & Nerd Font glyphs (FiraCode / JetBrainsMono).
#   - Modules displayed: OS Icon, Username, Directory (truncated to 3 levels),
#     Git branch & status, language runtime versions (Rust, Python, Go, Node),
#     command execution duration, and timestamp.
# ==============================================================================

{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      # Powerline pill segment format:
      # (Red Pill: OS & User) -> (Peach: Directory) -> (Yellow: Git) -> (Green: Runtimes) -> (Lavender: Time)
      format = "[](red)$os$username[](bg:peach fg:red)$directory[](bg:yellow fg:peach)$git_branch$git_status[](fg:yellow bg:green)$c$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:green bg:sapphire)$conda[](fg:sapphire bg:lavender)$time[ ](fg:lavender)$cmd_duration$line_break$character";
      palette = "catppuccin_mocha";

      # OS Indicator (Shows distinct glyph per distribution/platform)
      os = {
        disabled = false;
        style = "bg:red fg:crust";
        symbols = {
          Windows = ""; Ubuntu = "󰕈"; SUSE = ""; Raspbian = "󰐿";
          Mint = "󰣭"; Macos = "󰀵"; Manjaro = ""; Linux = "󰌽";
          Gentoo = "󰣨"; Fedora = "󰣛"; Alpine = ""; Amazon = "";
          Android = ""; AOSC = ""; Arch = "󰣇"; Artix = "󰣇";
          CentOS = ""; Debian = "󰣚"; Redhat = "󱄛"; RedHatEnterprise = "󱄛";
        };
      };

      # Username segment
      username = {
        show_always = true;
        style_user = "bg:red fg:crust";
        style_root = "bg:red fg:crust";
        format = "[ $user]($style)";
      };

      # Directory segment (with custom icon substitutions for common developer directories)
      directory = {
        style = "bg:peach fg:crust";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = "󰝚 ";
          "Pictures" = " ";
          "Developer" = "󰲋 ";
        };
      };

      # Git branch indicator
      git_branch = {
        symbol = "";
        style = "bg:yellow";
        format = "[[ $symbol $branch ](fg:crust bg:yellow)]($style)";
      };

      # Git status indicator (shows dirty, ahead, behind glyphs)
      git_status = {
        style = "bg:yellow";
        format = "[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)";
      };

      # Timestamp segment
      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:lavender";
        format = "[[  $time ](fg:crust bg:lavender)]($style)";
      };

      # Prompt character indicator (turns red on error, green on success)
      character = {
        success_symbol = "[❯](bold fg:green)";
        error_symbol = "[❯](bold fg:red)";
        vimcmd_symbol = "[❮](bold fg:green)";
      };

      # Complete Catppuccin Mocha Color Palette
      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo  = "#f2cdcd";
        pink      = "#f5c2e7";
        mauve     = "#cba6f7";
        red       = "#f38ba8";
        maroon    = "#eba0ac";
        peach     = "#fab387";
        yellow    = "#f9e2af";
        green     = "#a6e3a1";
        teal      = "#94e2d5";
        sky       = "#89dceb";
        sapphire  = "#74c7ec";
        blue      = "#89b4fa";
        lavender  = "#b4befe";
        text      = "#cdd6f4";
        subtext1  = "#bac2de";
        subtext0  = "#a6adc8";
        overlay2  = "#9399b2";
        overlay1  = "#7f849c";
        overlay0  = "#6c7086";
        surface2  = "#585b70";
        surface1  = "#45475a";
        surface0  = "#313244";
        base      = "#1e1e2e";
        mantle    = "#181825";
        crust     = "#11111b";
      };
    };
  };
}
