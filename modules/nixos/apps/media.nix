# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/media.nix (Minimalist Media Players)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Provisions lightweight keyboard-driven media viewers ('mpv', 'imv') and
#   'pavucontrol'. For VLC, import 'modules/nixos/apps/vlc.nix'.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Tiling Wayland desktops (Hyprland, Niri, Sway) do not ship default media
#   apps the way KDE Plasma does. This small module gives every desktop a fast
#   video player, an image viewer, and a volume mixer. These three are grouped
#   because together they form the minimal "open a file and hear/see it" kit;
#   heavier players (VLC) stay in their own 1-to-1 module.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mpv           # High-performance, minimalist CLI/GUI media player
    imv           # Lightweight Wayland-native image viewer
    pavucontrol   # Graphical PulseAudio/PipeWire volume mixer control
  ];
}
