# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/samba.nix (Samba SMB2/3 & GVfs)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for Samba):
#   Configures the Samba client stack with hardened SMB2/SMB3 and NTLMv2 minimum
#   security policies, enables GVfs so Dolphin can browse 'smb://' URIs natively,
#   and runs 'samba-wsdd' (Web Services Dynamic Discovery) for LAN visibility.
# ==============================================================================

{ pkgs, ... }:

{
  # 1. Enable Core Samba Client Utilities with Hardened SMB2/SMB3 Protocol Bounds
  services.samba = {
    enable = true;
    settings = {
      global = {
        "client min protocol" = "SMB2_10";
        "client max protocol" = "SMB3";
        "client ntlmv2 auth" = "yes";
      };
    };
  };

  # 2. Enable GVfs Virtual Filesystem for Native 'smb://' Browsing inside Dolphin
  services.gvfs = {
    enable = true;
    package = pkgs.gvfs;
  };

  # 3. Enable Web Services Dynamic Discovery (WSDD) for Local Network Visibility
  services.samba-wsdd = {
    enable = true;
  };

  # 4. Open SMB/NetBIOS/WSDD Discovery Ports in Host Firewall
  networking.firewall = {
    allowedTCPPorts = [ 445 139 ];
    allowedUDPPorts = [ 137 138 ];
  };
}
