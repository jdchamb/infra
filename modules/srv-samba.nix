{ pkgs, ... }:

{
  # Enable the core Samba client and utilities
  services.samba = {
    enable = true;
  };

  # CRITICAL FOR DOLPHIN: Enable GVfs to allow network browsing over smb://
  services.gvfs = {
    enable = true;
    package = pkgs.gvfs;
  };

  # Enable Web Services Dynamic Discovery for local network visibility
  services.samba-wsdd = {
    enable = true;
  };

  # Open the necessary ports in the local firewall for Samba discovery protocols
  networking.firewall = {
    allowedTCPPorts = [ 445 139 ];
    allowedUDPPorts = [ 137 138 ];
  };
}
