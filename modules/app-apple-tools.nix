{ pkgs, ... }:

{
  # Enable the kernel/system level iOS USB multiplexer daemon
  services.usbmuxd.enable = true; [cite: 5]

  # Kernel layer instruction to allow physical APFS drive mounting
  boot.supportedFilesystems = [ "apfs" ];

  environment.systemPackages = with pkgs; [
    libimobiledevice  # CLI toolset for device info, diagnostics, and backups
    ifuse             # Allows mounting the iPhone filesystem over USB
    apfs-fuse         # APFS userspace tools and formatting
  ];
}
