#!/usr/bin/env bash
# ==============================================================================
# INFRASTRUCTURE UTILITY: scripts/flash-nordic-opensk.sh
# ==============================================================================
#
# PURPOSE:
#   Automates building and flashing Google OpenSK onto Nordic nRF52840 USB Dongles
#   (PCA10059) across macOS (nix-darwin) and Linux (NixOS).
#
# WHAT THIS SCRIPT DOES:
#   1. Verifies that the required flasher ('nrfutil') and Rust toolchain ('rustup') are ready.
#   2. Clones or updates the stable OpenSK 2.1 repository (FIDO Alliance certified CTAP2).
#   3. Patches the USB descriptors to announce Yubico Vendor ID (0x1050 / 0x0407)
#      so that enterprise services (such as Duo for Windows Logon Offline Access)
#      recognize the hardware without "No security key found" rejections.
#   4. Compiles the Tock OS embedded kernel and OpenSK application.
#   5. Scans for Nordic dongles pulsing in DFU mode and flashes them sequentially.
#
# HOW TO PUT A DONGLE INTO DFU MODE:
#   - Leave the dongle plugged into USB (it needs power).
#   - Press the small, sideways RESET button once (located next to the white user button).
#   - The LED will begin pulsing with a slow red fade pattern.
# ==============================================================================

set -euo pipefail

# Visual styling
BOLD="$(tput bold 2>/dev/null || echo '')"
GREEN="$(tput setaf 2 2>/dev/null || echo '')"
YELLOW="$(tput setaf 3 2>/dev/null || echo '')"
RED="$(tput setaf 1 2>/dev/null || echo '')"
RESET="$(tput sgr0 2>/dev/null || echo '')"

info()  { echo "${BOLD}${GREEN}[INFO]${RESET} $*"; }
warn()  { echo "${BOLD}${YELLOW}[WARN]${RESET} $*"; }
error() { echo "${BOLD}${RED}[ERROR]${RESET} $*" >&2; }

echo "${BOLD}==================================================================${RESET}"
echo "${BOLD}  Nordic nRF52840 OpenSK (Yubico Identity) Auto-Flasher          ${RESET}"
echo "${BOLD}==================================================================${RESET}"

# ------------------------------------------------------------------------------
# 1. PREREQUISITE CHECKS
# ------------------------------------------------------------------------------
# Check for nrfutil
if ! command -v nrfutil &>/dev/null; then
  error "Nordic 'nrfutil' CLI not found."
  echo "  - On macOS: brew install --cask nrfutil"
  echo "  - On Linux: Download standalone binary from https://www.nordicsemi.com/Products/Development-tools/nrf-util"
  exit 1
fi

# Ensure nrf5sdk-tools extension is installed inside nrfutil
if ! nrfutil list | grep -q "nrf5sdk-tools.*Installed"; then
  info "Installing 'nrf5sdk-tools' plugin into nrfutil..."
  nrfutil install nrf5sdk-tools device
fi

# Check for rustup
if ! command -v rustup &>/dev/null; then
  if [ -x "/opt/homebrew/opt/rustup/bin/rustup" ]; then
    export PATH="/opt/homebrew/opt/rustup/bin:$HOME/.cargo/bin:$PATH"
  else
    error "'rustup' is required to compile embedded firmware."
    echo "  - On macOS: brew install rustup && export PATH=\"/opt/homebrew/opt/rustup/bin:\$PATH\""
    echo "  - Or run:   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
  fi
fi

# ------------------------------------------------------------------------------
# 2. PREPARE OPENSK BUILD DIRECTORY
# ------------------------------------------------------------------------------
BUILD_ROOT="${OPENSK_CACHE_DIR:-$HOME/src/OpenSK}"

if [ ! -d "$BUILD_ROOT/.git" ]; then
  info "Cloning OpenSK into $BUILD_ROOT..."
  git clone --recurse-submodules https://github.com/google/OpenSK.git "$BUILD_ROOT"
fi

cd "$BUILD_ROOT"

info "Checking out stable 2.1 branch and syncing submodules..."
git checkout 2.1
git submodule update --init --recursive

# Run OpenSK setup if virtualenv does not exist
if [ ! -d "py_virtual_env" ]; then
  info "Initializing Python virtualenv and embedded dependencies..."
  ./setup.sh
fi

# ------------------------------------------------------------------------------
# 3. APPLY YUBICO DESCRIPTOR PATCH (For Duo Windows Logon & Universal Compatibility)
# ------------------------------------------------------------------------------
info "Enforcing Yubico Vendor ID (0x1050) and Product ID (0x0407)..."

MAIN_RS="boards/nordic/nrf52840_dongle_opensk/src/main.rs"
TOCK_MAIN_RS="third_party/tock/boards/nordic/nrf52840_dongle_opensk/src/main.rs"

for target_file in "$MAIN_RS" "$TOCK_MAIN_RS"; do
  if [ -f "$target_file" ]; then
    sed -i.bak -e 's/const VENDOR_ID: u16 = 0x1915;/const VENDOR_ID: u16 = 0x1050;/' "$target_file"
    sed -i.bak -e 's/const PRODUCT_ID: u16 = 0x521f;/const PRODUCT_ID: u16 = 0x0407;/' "$target_file"
    sed -i.bak -e 's/"Nordic Semiconductor ASA"/"Yubico"/' "$target_file"
    sed -i.bak -e 's/"OpenSK"/"YubiKey FIDO"/' "$target_file"
    rm -f "${target_file}.bak"
  fi
done

# ------------------------------------------------------------------------------
# 4. COMPILE FIRMWARE AND PACKAGE DFU ARCHIVE
# ------------------------------------------------------------------------------
info "Compiling Tock OS kernel and OpenSK application (Release)..."
export PATH="/opt/homebrew/opt/rustup/bin:$HOME/.cargo/bin:$PWD/elf2tab/bin:$PATH"
py_virtual_env/bin/python3 deploy.py --board=nrf52840_dongle_dfu --opensk --programmer=none --disable-check-patches

HEX_FILE="target/nrf52840_dongle_dfu_merged.hex"
DFU_ZIP="/tmp/yubikey_dfu.zip"

info "Generating Nordic DFU zip package..."
rm -f "$DFU_ZIP"
nrfutil nrf5sdk-tools pkg generate \
  --hw-version 52 \
  --sd-req 0x00 \
  --application-version 1 \
  --application "$HEX_FILE" \
  "$DFU_ZIP"

info "Firmware successfully built and packaged at $DFU_ZIP"

# ------------------------------------------------------------------------------
# 5. SCAN AND FLASH CONNECTED DONGLES
# ------------------------------------------------------------------------------
echo ""
echo "${BOLD}Scanning for Nordic Dongles in DFU mode...${RESET}"

# Find serial ports matching usbmodem on macOS or ttyACM on Linux
DFU_PORTS=()
if [ "$(uname -s)" = "Darwin" ]; then
  for p in /dev/cu.usbmodem*; do
    if [ -e "$p" ]; then DFU_PORTS+=("$p"); fi
  done
else
  for p in /dev/ttyACM*; do
    if [ -e "$p" ]; then DFU_PORTS+=("$p"); fi
  done
fi

if [ "${#DFU_PORTS[@]}" -eq 0 ]; then
  warn "No dongles found in DFU mode."
  echo "To flash a dongle:"
  echo "  1. Leave it plugged in."
  echo "  2. Press the sideways RESET button once (red LED will pulse slowly)."
  echo "  3. Re-run this script: ./scripts/flash-nordic-opensk.sh"
  exit 0
fi

info "Found ${#DFU_PORTS[@]} dongle(s) ready to flash:"
for port in "${DFU_PORTS[@]}"; do
  echo "  -> $port"
done

echo ""
read -r -p "Proceed with flashing these dongles? [Y/n] " CONFIRM
CONFIRM="${CONFIRM:-Y}"
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Aborted by user."
  exit 0
fi

for port in "${DFU_PORTS[@]}"; do
  echo ""
  info "Flashing target dongle on $port..."
  nrfutil nrf5sdk-tools dfu usb-serial -pkg "$DFU_ZIP" -p "$port"
  info "Dongle on $port successfully programmed!"
done

echo ""
echo "${BOLD}${GREEN}==================================================================${RESET}"
echo "${BOLD}${GREEN}  All dongles successfully flashed!                              ${RESET}"
echo "${BOLD}${GREEN}==================================================================${RESET}"
echo "Next step: Unplug the dongles and plug them back in to boot into OpenSK."
