## 1. Personal Homelab & NixOS Configuration (Image: 3919.jpg)

This project handles local system administration, cluster orchestration, and desktop environment customization using NixOS and Home Manager.

### Active Tasks
* **Homelab Learning:** Research and document how to structure environments using Home Manager.
* **Portable Configuration:** Build a portable NixOS installation variant pre-configured with secure SSH access.
* **Task Documentation:** Create a `.md` markdown file dedicated entirely to tracking running task notes.
* **Security & Encryption:** Initialize and set up a personalized GPG key.
* **Hardware Defaults:** Configure the environment layout so that `Num Lock` is automatically toggled **ON** by default at boot.
* **Hardware Functionality:** Remap or setup function keys (`Fn keys`) to strictly register as `Fn` keys natively.
* **Desktop Environment Styling:** Explicitly declare and enforce global dark mode parameters across the Plasma desktop interface.

### Completed / Cancelled Tasks
* ~~*Zsh + Starship configuration (Fix ghostly config issue)*~~
* ~~*plasma.nix → add kfile*~~
* ~~*Disable plasma emoji shortcut (ctrl + ;)*~~
* ~~*Setup digikam for NixOS*~~
* ~~*Add exfat support for partition module*~~

# Project 1:
Custom iso

# Project 2:
Build NixOS on remote machine via network

# Project 3:
Setup erase your darlings

# Project 4:
Build readme.mds for each of my folders

# Project 5:
Setup GPG/online identity for developer work

# Project 6:
Apple keyboard numlock .Nix

# Project 7:
declare dark mode for plasma via plasma-manager

# Project 8:
setup fn keys to to just be f keys by default and that pressing the fn key utilites the alternative functions for those kexys. Reverse what I have now. 

# Project 9: declare dolphin setup

Project 10:
Refactor 

# Project 11: De-Googling the Foldable (Motorola Razr Ultra 2025)

## Overview
Investigation into moving the Motorola Razr Ultra 2025 off stock firmware to achieve a privacy-focused, FLOSS-aligned ecosystem (LineageOS / AOSP). The project is currently on hold due to hardware-specific framework maturity risks inherent to clamshell form factors.

## Current Device Status
* **Hardware:** Motorola Razr Ultra 2025
* **Firmware:** Stock Moto (MyUX / HelloUI) 
* **State:** Bootloader locked; running aggressive local ADB de-bloating as a temporary mitigation.

## Critical Risks & Hardware Quirks (Why We Postponed)
1. **Dual-Display Frameworks:** AOSP lacks native abstraction for the square outer cover screen. Risk of broken app scaling, asymmetric refresh rates, and display wake lag during flip transitions.
2. **Hinge State Logic:** Proprietary Hall sensor mappings handle the open/closed/flex states. Generic ROMs / GSIs often fail to read these, causing erratic UI behavior and sensor-driven battery drain.
3. **Camera Array Inversion:** The physical state dictates whether the primary cameras act as front-facing or rear-facing. Custom ROMs frequently suffer from inverted viewfinders or system crashes during handoffs.

## Revisit Checklist / Triggers
* [ ] Check XDA / LineageOS device trees for official `devicename` support.
* [ ] Verify if Motorola has released the complete kernel source code for this specific model revision.
* [ ] Monitor community fixes for dual-screen state management on clamshell foldables.

## Immediate Alternative Workaround
Execute an aggressive user-space de-bloat via ADB (`adb shell pm uninstall --user 0 <package>`) to disable Moto AI hooks, tracking stubs, and non-essential Google frameworks without breaking the proprietary display and hinge drivers.
