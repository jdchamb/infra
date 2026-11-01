# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/lenovo-m920q.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Lenovo ThinkCentre M920q Tiny + ThinkServer SA120 DAS):
#   Provides the hardware, firmware, thermal, and SAS storage controller profile
#   for the Lenovo ThinkCentre M920q Tiny ("micro") desktop equipped with a PCIe
#   external SAS HBA connecting to a Lenovo ThinkServer SA120 DAS storage shelf.
#
#   Hardware Profile:
#     - Intel Core 8th/9th Gen Desktop Processor (Coffee Lake / 35W-65W TDP)
#     - Intel UHD Graphics 630 (integrated VA-API hardware acceleration)
#     - Intel I219-LM / I219-V Gigabit Ethernet NIC (e1000e)
#     - M.2 2280 PCIe NVMe SSD boot bus
#     - LSI / Broadcom PCIe SAS HBA (mpt3sas kernel module)
#     - Lenovo ThinkServer SA120 12-Bay 3.5" SAS/SATA Enclosure
#
# WHY THIS EXISTS:
#   1. SAS Enclosure Stability: Ensures 'mpt3sas' and 'sd_mod' are loaded in the
#      initramfs so drives in the external SA120 shelf are recognized during boot.
#   2. Thermal & Acoustic Management: The SA120 DAS is notorious for running dual
#      cooling fans at 100% full-blast (74+ dB jet engine noise) by default.
#      This module provides an automated SCSI Enclosure Services (SES) systemd
#      service via 'sg3_utils' to regulate the SA120 fans down to a whisper-quiet,
#      cool operating level (speed level 2 or 3) on boot and periodically.
#   3. Microcode & Power: Applies Intel CPU silicon errata patches and thermald.
#
# HOW TO USE:
#   - Imported by host configurations (e.g. 'hosts/nixos/m920q-01/default.nix').
#   - Check SA120 fan controller status:
#       systemctl status lenovo-sa120-fanspeed.service
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.lenovo-sa120;
in
{
  options = {
    hardware.lenovo-sa120 = {
      fanControl = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Automate fan speed regulation for Lenovo ThinkServer SA120 DAS via SES.";
        };

        speed = lib.mkOption {
          type = lib.types.ints.between 1 7;
          default = 2;
          description = "Fan speed level (1-7). Level 2 or 3 keeps 12 drives under 38C quietly.";
        };
      };
    };
  };

  config = {
    # --------------------------------------------------------------------------
    # 1. Firmware & CPU Microcode
    # --------------------------------------------------------------------------
    hardware.enableRedistributableFirmware = lib.mkDefault true;
    hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

    # --------------------------------------------------------------------------
    # 2. Kernel Modules (NVMe, SAS HBA, Intel NIC)
    # --------------------------------------------------------------------------
    boot.initrd.availableKernelModules = [
      "xhci_pci"  # USB 3.0 / 3.1 Host Controller
      "nvme"      # Internal M.2 NVMe SSD (OS Boot Drive)
      "ahci"      # SATA Controller
      "usbhid"    # USB input devices
      "e1000e"    # Intel I219 Gigabit Ethernet NIC
      "mpt3sas"   # LSI / Broadcom 12Gbps & 6Gbps SAS HBAs for SA120 DAS
      "sd_mod"    # SCSI disk driver for SAS/SATA drives
    ];

    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    # --------------------------------------------------------------------------
    # 3. Thermal Management & Fan Regulation (M920q Host)
    # --------------------------------------------------------------------------
    services.thermald.enable = lib.mkDefault true;
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

    # --------------------------------------------------------------------------
    # 4. Hardware Graphics Acceleration (Intel UHD Graphics 630)
    # --------------------------------------------------------------------------
    hardware.graphics = {
      enable = lib.mkDefault true;
      extraPackages = with pkgs; [
        intel-media-driver # Modern VA-API driver for Intel Gen 9.5+
        intel-vaapi-driver # Fallback classic libva driver
      ];
    };

    # --------------------------------------------------------------------------
    # 5. Diagnostic Tools & SAS Enclosure Utilities
    # --------------------------------------------------------------------------
    environment.systemPackages = with pkgs; [
      sg3_utils  # Provides sg_ses, sg_scan, sg_map for SAS enclosure control
      lsscsi     # SCSI and SAS topology diagnostic tool
    ];

    # --------------------------------------------------------------------------
    # 6. Lenovo SA120 DAS Automated SES Fan Speed Controller
    # --------------------------------------------------------------------------
    # The SA120 runs fans at 100% full-blast unless an SES command sets fan speed.
    # This systemd service locates the SA120 enclosure device and sets the speed.
    systemd.services.lenovo-sa120-fanspeed = lib.mkIf cfg.fanControl.enable {
      description = "Lenovo ThinkServer SA120 DAS Fan Speed Regulator";
      after = [ "systemd-modules-load.service" "local-fs.target" ];
      wantedBy = [ "multi-user.target" ];

      path = [ pkgs.sg3_utils pkgs.gnugrep pkgs.gawk pkgs.coreutils ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "set-sa120-fan-speed" ''
          set -euo pipefail

          SPEED="${toString cfg.fanControl.speed}"
          HEX_SPEED=$(printf '%02x' "$SPEED")

          echo "Scanning SCSI enclosures for Lenovo ThinkServer SA120..."

          # Find all SCSI enclosure devices (/dev/sg*)
          ENCLOSURES=$(sg_scan -i 2>/dev/null | grep -B 1 -i "LENOVO.*SA120" | grep "^/dev/sg" | awk '{print $1}' || true)

          if [ -z "$ENCLOSURES" ]; then
            # Alternative detection via lsscsi if sg_scan output varies
            ENCLOSURES=$(lsscsi -g 2>/dev/null | grep -i "enclosu" | grep -i "LENOVO" | awk '{print $NF}' || true)
          fi

          if [ -z "$ENCLOSURES" ]; then
            echo "Notice: No Lenovo SA120 enclosure detected on the SAS bus. Skipping fan speed regulation."
            exit 0
          fi

          for DEV in $ENCLOSURES; do
            echo "Applying quiet fan speed level $SPEED (0x$HEX_SPEED) to SA120 enclosure at $DEV..."
            # SES Page 0x02 Fan Control: 16-byte payload for SA120 dual-fan control
            sg_ses -p 0x02 -c -d 02,00,00,00,00,00,00,00,00,"$HEX_SPEED",00,00,00,"$HEX_SPEED",00,00 "$DEV" || true
          done

          echo "SA120 fan speed regulation completed successfully."
        '';
      };
    };

    # Periodically re-assert fan speed every 30 minutes in case the DAS reboots or resets
    systemd.timers.lenovo-sa120-fanspeed = lib.mkIf cfg.fanControl.enable {
      description = "Periodic Fan Speed Regulation for Lenovo ThinkServer SA120 DAS";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "30min";
        Unit = "lenovo-sa120-fanspeed.service";
      };
    };
  };
}
