{ pkgs, ... }:

{
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.xserver.enable = true; # Required for SDDM/Plasma compatibility
  environment.systemPackages = with pkgs; [
    # ... your other system tools ...
    kdePackages.partitionmanager
  ];
}
