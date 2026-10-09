# lm-greetd.nix
# ROLE: Standalone Wayland Login Manager Configuration Layer

{ pkgs, ... }: {
  # Enable the decoupled greetd service
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Boots the rust-based front-end directly into a minimal container environment
        command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.cage}/bin/cage -s -d -- ${pkgs.regreet}/bin/regreet";
        user = "greeter";
      };
    };
  };

  # Direct declarative visual adjustments for the ReGreet menu workspace
  programs.regreet = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    font = {
      name = "JetBrains Mono";
      size = 12;
    };
  };

  # Underlying system dependencies required to paint the greeter environment safely
  environment.systemPackages = with pkgs; [
    cage
    regreet
  ];
}
