# ==============================================================================
# NIXOS DESKTOP MODULE: modules/nixos/desktop/greetd.nix (Wayland Login Manager)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Configures the lightweight, modular 'greetd' login daemon paired with 'regreet'
#   (a GTK4 greeter interface) hosted inside 'cage' (a minimal Wayland kiosk compositor).
#   Provides a clean, hardware-accelerated login screen allowing seamless selection
#   between KDE Plasma 6, Hyprland, Niri, and Sway Wayland sessions.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When your computer boots, it needs a program to present a login screen, verify
#   your password, and launch your chosen desktop environment or window manager:
#   - Legacy display managers (like LightDM or GDM) are often bloated, tightly coupled
#     to X11, or pull in hundreds of megabytes of GNOME desktop dependencies.
#   - 'greetd' is a minimal, Unix-philosophy login daemon. It does not draw any graphics
#     itself; instead, it simply manages the authentication handshake via PAM (Pluggable
#     Authentication Modules).
#   - 'cage': Wayland applications cannot run without a compositor. 'cage' is a tiny
#     kiosk compositor that runs a single full-screen program (in this case, ReGreet).
#   - 'regreet': A modern, clean GTK4 login interface that reads available desktop
#     sessions from '/share/wayland-sessions' and provides user/password entry.
#   - 'dbus-run-session': Wraps the greeter in a D-Bus session message bus so it can
#     query session states and communicate with system services.
#
# HOW TO USE:
#   - Applied automatically to desktop workstations that use greetd.
#   - At boot: Select your user account, pick your session from the dropdown
#     (e.g., "Hyprland", "Plasma (Wayland)", "Niri"), enter password, and press Enter.
# ==============================================================================

{ pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. greetd Daemon Configuration
  # --------------------------------------------------------------------------
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # Launches Cage kiosk compositor which paints ReGreet inside a DBus user session
        command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.cage}/bin/cage -s -d -- ${pkgs.regreet}/bin/regreet";
        # Runs under the restricted, unprivileged 'greeter' system user account
        user = "greeter";
      };
    };
  };

  # --------------------------------------------------------------------------
  # 2. Visual Theme & Typography (ReGreet)
  # --------------------------------------------------------------------------
  programs.regreet = {
    enable = true;

    # GTK visual theme applied to login boxes and dropdowns
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    # Consistent typography matching our global fleet standard
    font = {
      name = "JetBrains Mono";
      size = 12;
    };
  };

  # --------------------------------------------------------------------------
  # 3. System Packages
  # --------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    cage     # Minimal Wayland kiosk compositor
    regreet  # Modern GTK4 greeter client
  ];
}
