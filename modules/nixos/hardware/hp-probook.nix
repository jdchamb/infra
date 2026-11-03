# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/hp-probook.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 11 — HP ProBook Lab Cluster):
#   Provides the shared hardware, firmware, thermal, and power management profile
#   for the 5-node HP ProBook physical validation lab ('lab-pb01' through 'lab-pb05').
#   Configures clamshell lid-switch ignore rules (so all 5 laptops can run 24/7
#   with closed lids on a server shelf without suspending), enables Intel CPU
#   microcode patches, runs Intel thermald, and ensures secure SSH accessibility.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Laptops make fantastic, energy-efficient homelab servers because they come
#   with a built-in battery backup (UPS), low power consumption, and compact form factor.
#   However, default laptop Linux settings will suspend (sleep) the computer the
#   moment you close the display lid.
#   - 'services.logind' Lid Overrides: Instructs systemd-logind to completely IGNORE
#     the lid switch sensor, allowing the laptops to run continuously on a shelf.
#   - Intel Microcode & Firmware: Applies Intel CPU hardware bug fixes, security patches
#     (Spectre/Meltdown mitigations), and proprietary Wi-Fi/Ethernet firmware blobs.
#   - 'thermald': Intel Thermal Daemon actively monitors hardware sensors and controls
#     fan speeds to keep temperatures within safe operating thresholds in closed-lid mode.
#   - SSH Hardening: Disables insecure password login, enforcing SSH Ed25519 public
#     key authentication exclusively.
#
# HOW TO USE:
#   - Imported by any HP ProBook host profile (e.g. 'hosts/nixos/lab-probook/default.nix').
#   - Inspect active CPU thermal status:
#       systemctl status thermald
#   - Connect to any lab node remotely:
#       ssh jchambers@<probook-ip>
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. Firmware & CPU Microcode
  # --------------------------------------------------------------------------
  # Enables loading of proprietary firmware blobs for Intel wireless cards & Realtek NICs
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # Installs Intel CPU microcode updates at early boot to patch silicon errata
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  # Standard storage & USB controller modules required in initrd to mount root without hardware-configuration.nix
  boot.initrd.availableKernelModules = [
    "xhci_pci"     # USB 3.0 controller
    "nvme"         # M.2 NVMe SSD storage controller
    "ahci"         # 2.5-inch SATA storage controller
    "usbhid"       # USB keyboards and mice
    "usb_storage"  # USB flash drives
    "sd_mod"       # SCSI/SATA disk driver
  ];

  # --------------------------------------------------------------------------
  # 2. Clamshell Lab Mode (systemd-logind)
  # Prevents the laptops from entering sleep/suspend mode when their lids are shut.
  # --------------------------------------------------------------------------
  services.logind.settings = {
    Login = {
      HandleLidSwitch = "ignore";               # Ignore lid close on battery
      HandleLidSwitchDocked = "ignore";         # Ignore lid close when attached to dock/monitors
      HandleLidSwitchExternalPower = "ignore";  # Ignore lid close when plugged into AC wall power
    };
  };

  # --------------------------------------------------------------------------
  # 3. Declarative HP BIOS Power & Wake-on-AC Management
  # Configures the laptop to automatically power on from a cold shutdown whenever
  # AC wall power is connected/restored (via barrel plug, power strip, or inline switch).
  # --------------------------------------------------------------------------
  boot.kernelModules = [ "hp-bioscfg" ];

  systemd.services.hp-bios-power-config = {
    description = "Declarative HP ProBook BIOS Power Configuration";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    path = with pkgs; [ coreutils gnugrep kmod ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      BIOS_DIR="/sys/class/firmware-attributes/hp-bioscfg/attributes"

      if [ ! -d "$BIOS_DIR" ]; then
        modprobe hp-bioscfg 2>/dev/null || true
      fi

      if [ -d "$BIOS_DIR" ]; then
        set_attr() {
          local pattern="$1"
          local target_val="$2"

          for attr_path in "$BIOS_DIR"/*; do
            [ -d "$attr_path" ] || continue
            local attr_name
            attr_name="$(basename "$attr_path")"

            if echo "$attr_name" | grep -iqE "$pattern"; then
              if [ -f "$attr_path/current_value" ]; then
                local current
                current="$(cat "$attr_path/current_value" 2>/dev/null || true)"

                local final_val="$target_val"
                if [ -f "$attr_path/possible_values" ]; then
                  local matched
                  matched="$(grep -iE "^$target_val" "$attr_path/possible_values" 2>/dev/null | head -n1 || true)"
                  [ -n "$matched" ] && final_val="$matched"
                fi

                if [ "$current" != "$final_val" ]; then
                  echo "hp-bioscfg: Updating $attr_name from '$current' to '$final_val'"
                  echo "$final_val" > "$attr_path/current_value" 2>/dev/null || true
                else
                  echo "hp-bioscfg: $attr_name is already set to '$current'"
                fi
              fi
            fi
          done
        }

        # Set AC Power Loss behavior to "Power On"
        set_attr "ac.*power.*loss|after.*power.*loss|restore.*on.*ac" "Power On"

        # Set Wake on AC to "Enable" or "Enabled"
        set_attr "wake.*on.*ac" "Enable"
      fi
    '';
  };

  # --------------------------------------------------------------------------
  # 4. Thermal & Power Daemon Management
  # --------------------------------------------------------------------------
  # Intel Open Source Technology Center Thermal Daemon (prevents thermal runaway)
  services.thermald.enable = true;

  # DBus daemon that lets desktop and system services adjust power profiles
  services.power-profiles-daemon.enable = lib.mkDefault true;

  # --------------------------------------------------------------------------
  # 4. OpenSSH Daemon & Firewall
  # --------------------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      # Require cryptographic SSH keypairs; reject password brute-force attacks
      PasswordAuthentication = lib.mkDefault false;
      # Disallow password-based root logins
      PermitRootLogin = lib.mkDefault "prohibit-password";
    };
  };

  # Allow inbound SSH traffic on TCP port 22 through the Linux firewall
  networking.firewall.allowedTCPPorts = [ 22 ];

  # --------------------------------------------------------------------------
  # 5. Pre-Authorized Administrator Public SSH Keys
  # Note: Public keys are safe to commit to Git.
  # --------------------------------------------------------------------------
  users.users.jchambers.openssh.authorizedKeys.keys = [
    # Primary administrative laptop SSH key (308-225660)
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG7l6ZZz1UQBiZ9Xlg0xdvNRJGaeWwhIPktBOcbhsVZw jchambers@308-225660"
  ];
}
