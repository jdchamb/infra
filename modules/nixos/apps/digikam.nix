{ pkgs, ... }:

{
  # Install DigiKam and its core runtime dependencies globally for the system profile
  environment.systemPackages = with pkgs; [
    digikam

    # Optional companion tools for media handling and metadata extraction
    exiftool
    ffmpeg
  ];

  # Optional: Optimize the KDE/Qt runtime environment variables if needed
  # DigiKam integrates natively with your Plasma 6 desktop environment shell.
}
