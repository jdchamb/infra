# Fleet UEFI Secure Boot Runbook (Lanzaboote & sbctl)

## Architecture Overview

This fleet implements declarative UEFI Secure Boot using **Lanzaboote** (`github:nix-community/lanzaboote`) paired with **sbctl**.

```
+-----------------------------------------------------------+
|                      UEFI Firmware                        |
|  Enforces: Platform Key (PK), KEK, and Database (db) keys |
+-----------------------------------------------------------+
                             |
                      Launches & Verifies
                             v
+-----------------------------------------------------------+
|              Lanzaboote Signed systemd-boot               |
|      Validates Signed Linux Unified Kernel Images / Stubs  |
+-----------------------------------------------------------+
                             |
                     Executes Verified
                             v
+-----------------------------------------------------------+
|                 NixOS Mainline Linux Kernel               |
|         Bootstraps systemd initramfs & ZFS/Ext4/Btrfs     |
+-----------------------------------------------------------+
```

### Key Highlights
1. **Automated Key Generation**: Keys are automatically provisioned in `/var/lib/sbctl` by `generate-sb-keys.service` on first boot if they do not exist.
2. **Graceful Transition (`allowUnsigned = true`)**: Systems build and boot without failing even before keys exist on disk.
3. **Automated Key Staging (`autoEnrollKeys`)**: Keys are converted into authenticated EFI variables (`PK.auth`, `KEK.auth`, `db.auth`) and placed into `/boot/loader/keys/auto` along with Microsoft OEM certificates.
4. **Firmware Setup Mode Enrollment**: When a machine's UEFI firmware is put into **Setup Mode**, `systemd-boot` automatically enrolls the staged keys into the motherboard NVRAM upon next boot.

---

## Machine Activation Workflow

### Step 1: Rebuild and Switch
On the target NixOS machine, pull the latest flake configuration and run:
```bash
rebuild
# or: sudo nixos-rebuild switch --flake ~/src/infra#<hostname>
```

### Step 2: Enrolling Keys into UEFI Firmware

You can enroll keys using either **Automatic Firmware Enrollment** or the **Manual CLI**:

#### Option A: Automatic Firmware Enrollment (Recommended)
1. Reboot into motherboard firmware/BIOS:
   ```bash
   systemctl reboot --firmware-setup
   ```
2. Navigate to **Security** -> **Secure Boot**.
3. Enable Secure Boot and select **"Reset to Setup Mode"** (or clear the Platform Key / PK).
   > [!CAUTION]
   > Do **NOT** select "Clear All Secure Boot Keys" if prompted, as that may wipe the Forbidden Signature Database (`dbx`). Only select "Reset to Setup Mode" or delete/erase the PK.
4. Save and reboot (F10).
5. `systemd-boot` detects Setup Mode, loads the staged keys from the ESP, enrolls them into UEFI NVRAM, and locks Secure Boot into User Mode.

#### Option B: Manual CLI Enrollment
If you prefer enrolling from the running Linux environment while in Setup Mode:
```bash
# 1. Verify that the firmware is currently in Setup Mode:
sudo sbctl status

# 2. Enroll keys (including Microsoft certificates for Option ROMs and dual-boot):
sudo sbctl enroll-keys --microsoft

# 3. Reboot the machine:
sudo reboot
```

---

## Verification & Status Commands

Verify that Secure Boot is active and enforcing signature verification:

```bash
bootctl status
```
Look for:
```
System:
      Firmware: UEFI 2.70+
    Secure Boot: enabled (user)
  TPM2 Support: yes
```

Or query `sbctl`:
```bash
sudo sbctl status
```
Output:
```
Installed:	✓ sbctl is installed
Owner GUID:	<uuid>
Setup Mode:	✓ Disabled
Secure Boot:	✓ Enabled
Vendor Keys:	microsoft
```

---

## Troubleshooting & Recovery

### Firmware Reset / BIOS Update
Updating motherboard BIOS often restores factory default keys or resets Secure Boot variables.
* If a BIOS update wipes custom keys, enter the BIOS menu, select **Reset to Setup Mode**, and reboot.
* `systemd-boot` will automatically re-enroll your keys from `/boot/loader/keys/auto`.

### Disabling Secure Boot on a Specific Node
If a virtual machine or test appliance needs Secure Boot disabled, set:
```nix
core.secureboot.enable = false;
```
in the host's configuration file. Standard `systemd-boot` without Lanzaboote signature enforcement will be restored.
