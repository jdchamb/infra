{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pciutils    # lspci
    usbutils    # lsusb
    dmidecode   # BIOS/Hardware info
    hwinfo      # Detailed hardware probe
  ];
}
