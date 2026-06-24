{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- Video & Audio Playback
    mpv           # High-performance, minimalist CLI/GUI media player
    imv           # Lightweight image viewer matching CLI/GUI parity

    # --- Audio Control
    pavucontrol   # Graphical pulse/pipewire volume mixer control
  ];
}
