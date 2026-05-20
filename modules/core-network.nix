{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;
  

  # Since you're often on the road with the ProBook, 
  # keeping the firewall on but manageable is key.
  networking.firewall = {
    enable = true;
    # allowedTCPPorts = [ 22 ]; # Enable if you need SSH into the machines
  };

  # Optional: Add common network tools here so they follow the network module
  environment.systemPackages = with pkgs; [
    networkmanagerapplet # GUI for the tray
    wireguard-tools      # For future VPN work
  ];
}
