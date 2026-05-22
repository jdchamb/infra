{ pkgs, ... }:

{
  # Enable the core Samba client utilities
  services.samba = {
    enable = true;

    # Correct way to pass global client-side protocol overrides in modern NixOS
    settings = {
      global = {
        "client min protocol" = "CORE";
        "client max protocol" = "SMB3";
        "client ntlmv2 auth" = "yes";
        "client lanman auth" = "yes";
        "client plaintext auth" = "yes";
      };
    };
  };

  # Enable GVfs to allow network browsing over smb:// inside Dolphin
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
