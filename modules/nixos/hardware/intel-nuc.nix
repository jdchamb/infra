# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/intel-nuc.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Intel NUC 7 Dawson Canyon — NUC7i7DNFE):
#   Provides the hardware, firmware, thermal, and low-power management profile
#   for the Intel NUC 7 Business Dawson Canyon mini-PC (NUC7i7DNFE).
#   Equipped with:
#     - Intel Core i7-8650U CPU (4 Cores / 8 Threads, Kaby Lake-R / 15W TDP)
#     - Intel UHD Graphics 620 (integrated VA-API hardware acceleration)
#     - Intel I219-LM Gigabit Ethernet NIC
#     - M.2 2280 PCIe NVMe SSD storage bus
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Mini-PCs like the Intel NUC are exceptional low-power 24/7 homelab and game
#   servers. However, out-of-the-box generic Linux distributions can suffer from
#   sub-optimal CPU throttling, heat spikes, and generic power states.
#   This module ensures:
#     1. Microcode & Security: Patches Intel CPU silicon bugs and security errata.
#     2. Thermal Daemon: Actively monitors temperatures and regulates fan curve
#        to maintain whisper-quiet operation during heavy game server loads.
#     3. Hardware Video Acceleration: Enables VA-API drivers for Intel UHD 620.
#     4. Headless Networking: Configures low-latency network tuning for game UDP
#        traffic (Palworld, Barotrauma, Terraria, Minecraft).
#
# HOW TO USE:
#   - Imported by NUC host profiles (e.g. 'hosts/nixos/nuc-game01/default.nix').
#   - Check thermal status:
#       systemctl status thermald
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  # ----------------------------------------------------------------------------
  # 1. Firmware & CPU Microcode
  # ----------------------------------------------------------------------------
  # Enables loading of proprietary firmware blobs for Intel wireless & network devices
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # Installs Intel CPU microcode updates at early boot to patch silicon errata
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  # ----------------------------------------------------------------------------
  # 2. Linux Kernel Modules for Dawson Canyon Hardware
  # ----------------------------------------------------------------------------
  boot.initrd.availableKernelModules = [
    "xhci_pci"  # USB 3.0 controller
    "nvme"      # M.2 NVMe SSD storage controller
    "ahci"      # 2.5-inch SATA controller
    "usbhid"    # USB keyboards and mice during emergency boot
    "e1000e"    # Intel I219-LM Gigabit Ethernet NIC
  ];

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # ----------------------------------------------------------------------------
  # 3. Thermal Management & Fan Regulation
  # ----------------------------------------------------------------------------
  # Runs Intel Thermal Daemon (thermald) to prevent thermal throttling spikes
  # when CPU-intensive game servers (like Minecraft modpacks) generate heavy loads.
  services.thermald.enable = lib.mkDefault true;

  # Power governor: 'performance' for low-latency game tick rates, or 'powersave'
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # ----------------------------------------------------------------------------
  # 4. Hardware Graphics Acceleration (Intel UHD Graphics 620)
  # ----------------------------------------------------------------------------
  hardware.graphics = {
    enable = lib.mkDefault true;
    extraPackages = with pkgs; [
      intel-media-driver # Modern VA-API driver for Intel Gen 9+ (i7-8650U UHD 620)
      intel-vaapi-driver # Classic libva driver fallback
    ];
  };

  # ----------------------------------------------------------------------------
  # 5. Network Buffer Tuning for Game Traffic (UDP / TCP)
  # ----------------------------------------------------------------------------
  # Increases network receive/send buffer sizes for smoother multiplayer packet handling
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.core.rmem_default" = 1048576;
    "net.core.wmem_default" = 1048576;
    "net.ipv4.udp_rmem_min" = 8192;
    "net.ipv4.udp_wmem_min" = 8192;
  };
}
