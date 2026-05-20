fonts.packages = with pkgs; [
    # This installs only the JetBrainsMono Nerd Font
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
