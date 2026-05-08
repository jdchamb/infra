{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.zellij ];


  # This makes Zellij feel more like a GUI with its UI-driven tabs
  # and layout management.
}
