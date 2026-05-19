{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      format = "[](red)$os$username[](bg:peach fg:red)$directory[](bg:yellow fg:peach)$git_branch$git_status[](fg:yellow bg:green)$c$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:green bg:sapphire)$conda[](fg:sapphire bg:lavender)$time[ ](fg:lavender)$cmd_duration$line_break$character";
      palette = "catppuccin_mocha";

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

      username = {
        show_always = true;
        style_user = "bg:red fg:crust";
        style_root = "bg:red fg:crust";
        format = "[ $user]($style)";
      };

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

      git_branch = {
        symbol = "";
        style = "bg:yellow";
        format = "[[ $symbol $branch ](fg:crust bg:yellow)]($style)";
      };

      git_status = {
        style = "bg:yellow";
        format = "[[($all_status$ahead_behind )](fg:crust bg:yellow)]($style)";
      };

      # ... (Nix will convert the rest of your sections automatically if we use this format)
      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:lavender";
        format = "[[  $time ](fg:crust bg:lavender)]($style)";
      };

      character = {
        success_symbol = "[❯](bold fg:green)";
        error_symbol = "[❯](bold fg:red)";
        vimcmd_symbol = "[❮](bold fg:green)";
      };

      palettes.catppuccin_mocha = {
        red = "#f38ba8";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        sapphire = "#74c7ec";
        lavender = "#b4befe";
        crust = "#11111b";
        # ... add the rest of the colors from your toml here
      };
    };
  };
}
