{ pkgs, ... }:

{
  # Enable the kernel/system level iOS USB multiplexer daemon
  services.usbmuxd.enable = true;

  environment.systemPackages = with pkgs; [
    libimobiledevice  # CLI toolset for device info, diagnostics, and backups
    ifuse             # Allows mounting the iPhone filesystem over USB
  ];
}
