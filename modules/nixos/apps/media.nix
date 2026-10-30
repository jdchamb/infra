# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/media.nix (Minimalist Media Players)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Provisions lightweight keyboard-driven media viewers ('mpv', 'imv') and
#   'pavucontrol'. For VLC, import 'modules/nixos/apps/vlc.nix'.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mpv           # High-performance, minimalist CLI/GUI media player
    imv           # Lightweight Wayland-native image viewer
    pavucontrol   # Graphical PulseAudio/PipeWire volume mixer control
  ];
}
