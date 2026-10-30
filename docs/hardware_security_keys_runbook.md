# Hardware Security Keys & OpenSK Deployment Runbook

This runbook documents the deployment, firmware architecture, and operational workflows for our **Nordic Semiconductor nRF52840 Dongles** running **Google OpenSK**, integrated across the USD 308 fleet and personal homelab nodes.

---

## 1. Hardware & Firmware Architecture

### Hardware: Nordic nRF52840 Dongle (PCA10059)
* **Processor**: ARM Cortex-M4F @ 64 MHz, 1 MB Flash, 256 KB RAM
* **USB Interface**: USB 2.0 Full Speed (12 Mbps)
* **Radio**: 2.4 GHz Multi-Protocol (Bluetooth 5 LE, Thread, Zigbee, IEEE 802.15.4)
* **Physical Controls**:
  * **User Button (`SW1`)**: Large white button facing upwards (conveys physical presence / user touch for FIDO2 challenges).
  * **RESET Button (`SW2`)**: Small button mounted **sideways** on the edge (triggers DFU bootloader mode).
  * **Status LEDs**: Multi-color RGB LED + Green LED.

### Firmware: Google OpenSK on Tock OS
* **Branch**: `2.1` (FIDO Alliance certified CTAP 2.0 implementation).
* **Operating System**: **Tock OS**, a secure, memory-isolated embedded microkernel written in Rust.
* **Cryptography**: ECDSA P-256 signatures, SHA-256 hashing, hardware True Random Number Generation (TRNG), and tamper-resistant on-chip credential storage.

---

## 2. Authentic Nordic Identity vs. Optional Yubico Compatibility (`0x1050`)

### Upstream Open-Source Standard: Nordic Semiconductor (`VID: 0x1915`)
By default, the fleet builds and deploys Google OpenSK with authentic Nordic Semiconductor descriptors:
* **Vendor ID (`VID`)**: `0x1915` (Nordic Semiconductor ASA)
* **Product ID (`PID`)**: `0x521f` (OpenSK)
* **Standards Compliance**: Fully compliant with FIDO Alliance CTAP 2.0 / WebAuthn specifications. Supported natively across modern web browsers (Chrome, Firefox, Safari, Edge), PAM U2F on Linux/macOS, Bitwarden, Google, GitHub, and Forgejo.

### Enterprise Whitelisting & The Optional Yubico Patch (`--spoof-yubico`)
Some proprietary enterprise clients (such as **Cisco Duo Authentication for Windows Logon** offline access) enforce arbitrary, hardcoded vendor whitelists filtering strictly for:
* **Yubico** (`VID: 0x1050`)
* **Feitian** (`VID: 0x096E`)
* **Thetis / GoTrust** (`VID: 0x1EA8`)

For compatibility with vendor-locked legacy software, [`scripts/flash-nordic-opensk.sh`](file:///Users/jchambers/src/infra/scripts/flash-nordic-opensk.sh) includes an optional `--spoof-yubico` flag that patches the USB descriptors:
```rust
const VENDOR_ID: u16 = 0x1050;   // Yubico
const PRODUCT_ID: u16 = 0x0407;  // YubiKey 5 Series FIDO
static STRINGS = &["Yubico", "YubiKey FIDO", "v5.4", "FIDO2"];
```

### Dual Fleet Architecture
Our shared Nix module ([`modules/shared/security/yubikey-nordic.nix`](file:///Users/jchambers/src/infra/modules/shared/security/yubikey-nordic.nix)) configures `udev` and PAM rules for **both** `0x1915` (Nordic) and `0x1050` (Yubico). This ensures complete, seamless compatibility across the fleet whether someone plugs in an authentic YubiKey 5 or a Nordic OpenSK dongle.

---

## 3. Quick Rebuild & Flash Runbook

We have baked a one-step build and flashing script directly into the `infra` repository:

```bash
cd ~/src/infra
./scripts/flash-nordic-opensk.sh
```

### Manual Step-by-Step Procedure

1. **Put Dongle in DFU Mode**:
   * Insert dongle into USB.
   * Press the **sideways RESET button (`SW2`)** once.
   * Verify the LED pulses with a **slow red breathing fade**.

2. **Compile Firmware**:
   ```bash
   cd ~/src/OpenSK
   export PATH="/opt/homebrew/opt/rustup/bin:$HOME/.cargo/bin:$PWD/elf2tab/bin:$PATH"
   py_virtual_env/bin/python3 deploy.py \
     --board=nrf52840_dongle_dfu \
     --opensk \
     --programmer=none \
     --disable-check-patches
   ```

3. **Package DFU Archive**:
   ```bash
   nrfutil nrf5sdk-tools pkg generate \
     --hw-version 52 \
     --sd-req 0x00 \
     --application-version 1 \
     --application target/nrf52840_dongle_dfu_merged.hex \
     /tmp/nordic_opensk_dfu.zip
   ```

4. **Flash over USB Serial**:
   ```bash
   # On macOS:
   nrfutil nrf5sdk-tools dfu usb-serial -pkg /tmp/nordic_opensk_dfu.zip -p /dev/cu.usbmodem<SERIAL>1

   # On Linux:
   nrfutil nrf5sdk-tools dfu usb-serial -pkg /tmp/nordic_opensk_dfu.zip -p /dev/ttyACM0
   ```

5. **Activate**:
   Unplug the dongle and plug it back in. It boots immediately as **Nordic Semiconductor ASA OpenSK** (or YubiKey FIDO if `--spoof-yubico` was used).

---

## 4. Multi-Key Backup Strategy & Interchangeability

### How FIDO2 Key Isolation Works
Every physical FIDO2 key generates its own private keys in internal silicon. Key 2 cannot mathematically answer for a challenge issued to Key 1 unless Key 2 was also registered with the service.

### Recommended Setup: The Primary + Backup Pattern
On each service (Duo, Google, GitHub, Bitwarden):
1. Plug in **Dongle 1** $\rightarrow$ Click *"Add Security Key"* $\rightarrow$ Name it `Primary Key`
2. Plug in **Dongle 2** $\rightarrow$ Click *"Add Security Key"* $\rightarrow$ Name it `Backup Key`
3. Store **Dongle 2** in your desk drawer or safe.

**Result**: You can use either key interchangeably. If you ever lose or forget your Primary Key, grab your Backup Key and log in with zero downtime.

---

## 5. Declarative Fleet Integration (NixOS & nix-darwin)

The shared module [`modules/shared/security/yubikey-nordic.nix`](file:///Users/jchambers/src/infra/modules/shared/security/yubikey-nordic.nix) is imported across our nodes:
* `hosts/darwin/308-225660/default.nix` (MacBook)
* `hosts/nixos/308-222242/default.nix` (Workstation)
* `hosts/nixos/308-225660NixOSVM/default.nix` (Virtual Machine)

### What it Enforces:
1. **Linux `udev` Access**:
   Automatically tags raw HID devices matching either `0x1050` (Yubico) or `0x1915` (Nordic) with `TAG+="uaccess"` so desktop users can touch the key without root permissions.
2. **Standardized RP Origin (`pam://local`)**:
   Standardizes `origin=pam://local` across both macOS (`sudo_local`) and NixOS (`security.pam.u2f`). This guarantees key registrations are 100% portable across all laptops, workstations, and VMs regardless of hostname changes.
3. **Declarative Key Management**:
   The single source of truth for enrolled U2F/FIDO2 keys is stored in [`home/programs/u2f_keys`](../home/programs/u2f_keys).
   - Home Manager automatically symlinks it to `~/.config/Yubico/u2f_keys` on all nodes.
   - NixOS links it to `/etc/u2f_mappings` for system-wide and display manager authentication.
4. **PAM U2F Integration**:
   Enables `pam_u2f` with `cue = true` (*"Please touch the device."*).
5. **Cross-Platform Safety**:
   Uses `lib.optionalAttrs` guards so Linux-specific options never break nix-darwin evaluation on macOS.

---

## 6. Advanced Quality-of-Life (QoL) Configurations

### A. Touch-to-`sudo` & Clean Enrollment Runbook
To enroll your Primary Key and Backup Key(s) from scratch into the declarative repository:

```bash
# 1. Clean up old/orphaned test keys:
rm -f ~/.config/Yubico/u2f_keys*

# 2. Insert PRIMARY KEY (SW1 facing up) and enroll:
pamu2fcfg -o pam://local | tr -d '\n' > ~/src/infra/home/programs/u2f_keys
# -> Press the top flat button (SW1) when the dongle LED pulses/prompts.

# 3. Unplug Primary Key, insert BACKUP KEY, and append on the same line:
pamu2fcfg -n -o pam://local | tr -d '\n' >> ~/src/infra/home/programs/u2f_keys
# -> Press the top flat button (SW1) on the Backup Key.
# (Repeat step 3 for any additional backup keys)

# 4. Add trailing newline to finalize:
echo "" >> ~/src/infra/home/programs/u2f_keys

# 5. Deploy configuration across the system:
rebuild
# (or: sudo darwin-rebuild switch --flake ~/src/infra#308-225660)
```

**Single-Line Formatting Rule**:
PAM U2F requires all keys for a single user to reside on one single line formatted as:
`jchambers:<key1_handle>,<key1_pubkey>,es256,+presence:<key2_handle>,<key2_pubkey>,es256,+presence`
The `tr -d '\n'` pipeline above guarantees proper single-line concatenation without manual string manipulation.

### B. Hardware-Backed Git Commit Signing
Generate an SSH key backed physically by the dongle's FIDO2 silicon:
```bash
ssh-keygen -t ed25519-sk -O resident -C "joshua@chambers-net.org (Nordic Hardware Key)"
```
Add the public key to GitHub/Forgejo as a **Signing Key**. Git will require a physical button tap on the dongle before allowing any signed commit.
