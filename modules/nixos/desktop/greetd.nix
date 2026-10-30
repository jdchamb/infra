# ==============================================================================
# NIXOS DESKTOP MODULE: modules/nixos/desktop/greetd.nix (Wayland Login Manager)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Configures the lightweight 'greetd' login daemon paired with 'regreet' running
#   inside a minimal 'cage' Wayland kiosk compositor. Allows seamless switching
#   between Hyprland, Niri, Sway, and KDE Plasma 6 sessions at login.
# ==============================================================================

{ pkgs, ... }:

{
  # 1. Enable the decoupled greetd authentication daemon
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.cage}/bin/cage -s -d -- ${pkgs.regreet}/bin/regreet";
        user = "greeter";
      };
    };
  };

  # 2. Declarative Visual Theme & Typography for ReGreet
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

  # 3. Underlying System Dependencies Required to Paint the Greeter Session
  environment.systemPackages = with pkgs; [
    cage
    regreet
  ];
}
