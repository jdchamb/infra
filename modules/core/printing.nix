{ pkgs, ... }:

{
  services.printing.enable = true;

  # Auto-discovery for network printers (Avahi)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
