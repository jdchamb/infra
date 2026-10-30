# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/samba.nix (Samba SMB2/3 & GVfs)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Storage & Interoperability — 1-to-1 Module for Samba):
#   Configures the Samba client stack with hardened SMB2/SMB3 and NTLMv2 minimum
#   security policies, enables GVfs so KDE Dolphin and other file managers can
#   browse 'smb://' URIs seamlessly, and runs 'samba-wsdd' (Web Services Dynamic
#   Discovery) for native Windows LAN visibility.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Linux and Windows handle file sharing differently. Samba is the open-source suite
#   that allows Linux systems to talk to Windows file servers and Active Directory
#   networks.
#   - Legacy SMB1 protocols have severe security vulnerabilities (e.g. WannaCry exploits).
#     This module enforces modern SMB2.10 and SMB3 protocols with NTLMv2 authentication.
#   - GVfs (GNOME Virtual File System) allows desktop applications like Dolphin
#     to open network files directly by typing 'smb://server/share' into the address bar.
#   - WSDD (Web Services Dynamic Discovery) advertises this machine to modern Windows 10
#     and Windows 11 computers so it shows up automatically in their File Explorer "Network" tab.
#
# HOW TO USE:
#   - Importing this module enables Samba, GVfs, and WSDD automatically.
#   - Browse network shares in Dolphin or Nautilus:
#       smb://<server-ip>/<share-name>
#   - Query remote SMB shares from the command line:
#       smbclient -L //<server-ip> -U <username>
# ==============================================================================

{ pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. Core Samba Service & Client Hardening
  # --------------------------------------------------------------------------
  services.samba = {
    # Importing this module turns the Samba client and daemon suite ON
    enable = true;

    # Global smb.conf configuration parameters
    settings = {
      global = {
        # Prohibit ancient, insecure SMBv1 connections; require at least SMB 2.10
        "client min protocol" = "SMB2_10";
        # Allow negotiation up to the newest SMB 3 protocol
        "client max protocol" = "SMB3";
        # Require secure NTLMv2 challenge-response hashing instead of plain NTLM
        "client ntlmv2 auth" = "yes";
      };
    };
  };

  # --------------------------------------------------------------------------
  # 2. GVfs Virtual Filesystem Integration
  # Enables user-space mounting so desktop file managers (Dolphin, Thunar, Nautilus)
  # can mount and stream files from SMB shares without needing root privileges.
  # --------------------------------------------------------------------------
  services.gvfs = {
    enable = true;
    package = pkgs.gvfs;
  };

  # --------------------------------------------------------------------------
  # 3. Web Services Dynamic Discovery (WSDD)
  # Modern Windows versions disabled NetBIOS/SMB1 network browsing by default.
  # WSDD implements the WSD protocol so Windows 10/11 machines automatically
  # see this Linux host under "Network" in Windows File Explorer.
  # --------------------------------------------------------------------------
  services.samba-wsdd = {
    enable = true;
  };

  # --------------------------------------------------------------------------
  # 4. Firewall Ports
  # Open standard SMB and NetBIOS ports in the Linux firewall:
  #   - TCP 445: Direct SMB over TCP (modern Windows file sharing)
  #   - TCP 139: NetBIOS Session Service
  #   - UDP 137: NetBIOS Name Service
  #   - UDP 138: NetBIOS Datagram Service
  # --------------------------------------------------------------------------
  networking.firewall = {
    allowedTCPPorts = [ 445 139 ];
    allowedUDPPorts = [ 137 138 ];
  };
}
