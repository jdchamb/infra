# Documentation Subsystem (`docs/`)

This directory contains reference notes, engineering logs, architecture decisions, and project milestones for the USD 308 infrastructure fleet and personal homelab.

---

## 🧭 Novice Orientation: Why This Repository Is Structured This Way

If you are new to **NixOS**, **nix-darwin**, or declarative infrastructure, here is the mental model behind this repository:

1. **Declarative vs. Imperative Configuration:**
   * On traditional operating systems (Ubuntu, Windows, standard macOS), you configure a machine *imperatively*—by clicking settings menus, running installers, and editing files in `/etc` by hand over months or years. If the hard drive dies, you have to remember every step you took to rebuild it.
   * In this repository, every machine's state is written down *declaratively* as code starting from [`flake.nix`](../flake.nix). When you run `rebuild`, Nix reads these files, builds the exact software and configuration files inside `/nix/store`, and atomically switches your system to match the code.

2. **The "Body, Organs, and Soul" Architecture:**
   * **The Body ([`hosts/`](../hosts/README.md)):** Each physical or virtual machine has a folder in `hosts/` matching its hostname (`308-222242`, `308-225660`, `MBA-Chambers`, `308-225660NixOSVM`, `lab-pb01`..`05`). A host file defines *which* hardware it runs on and *which* modules it imports.
   * **The Organs ([`modules/`](../modules/README.md)):** Every piece of software or service lives in its own **1-to-1 module** inside `modules/` (1 module = 1 tool or service). Because each tool is isolated in its own file, turning a feature on or off on any machine is as simple as adding or toggling one line.
   * **The Soul ([`home/`](../home/README.md)):** User-level dotfiles (Zsh shell, Starship prompt, keyboard shortcuts, directory auto-sync) live in `home/` and are managed by **Home Manager** so your terminal feels identical whether you are sitting at a macOS MacBook or a Linux workstation.

---

## 📚 Document Index

| Document | Scope & Purpose |
| :--- | :--- |
| **[`pprojects.md`](./pprojects.md)** | **Personal Project Board:** Homelab infrastructure, NixOS architecture, desktop environment tuning, and FLOSS community contributions (Projects 1–27), mapped 1-to-1 to their NixOS modules. |
| **[`308projects.md`](./308projects.md)** | **USD 308 Project Board:** School district fleet engineering (PDQ, Snipe-IT, ClearTouch, Vaultwarden, FOG PXE, SOPS, SMB shares), mapped 1-to-1 to their NixOS modules and PowerShell scripts. |
| **[`fleet_services_roadmap.md`](./fleet_services_roadmap.md)** | **Fleet Services & Wishlist Implementation Plan:** 5-phase architecture covering client tools, Btrfs/Borg storage, self-hosted cloud, media/IoT, and game server orchestration. |
| **[`pprojectslearn.md`](./pprojectslearn.md)** | **Linux Engineering & Declarative Architecture Learning Plan:** 3-Phase curriculum from Silicon & UEFI $\rightarrow$ Linux From Scratch $\rightarrow$ NixOS Derivations & Flakes (supported by [`modules/nixos/apps/kernel-lfs-tools.nix`](../modules/nixos/apps/kernel-lfs-tools.nix)). |
| **[`host-profiles.md`](./host-profiles.md)** | **Host Profile & Architecture Logs (Project 13):** Detailed hardware, storage, secret, and module matrix for every active node in [`flake.nix`](../flake.nix). |
| **[`darwin-bootstrap-runbook.md`](./darwin-bootstrap-runbook.md)** | **macOS / nix-darwin Bootstrap Runbook:** Complete operational guide for provisioning MacBooks (`308-225660`, `MBA-Chambers`), resolving `/etc` conflicts, and managing the Apple VZ builder. |
| **[`keybindings.md`](./keybindings.md)** | **Universal Environment Keybinding Pattern (Project 7):** Collision-free shortcut hierarchy across Wayland Compositors (`Super`), Zellij (`Alt`), and Ghostty (`Ctrl+Shift`). |
| **[`hardware_security_keys_runbook.md`](./hardware_security_keys_runbook.md)** | **Hardware Security Keys & OpenSK Runbook:** Deployment and firmware workflow for Nordic nRF52840 FIDO2 dongles and YubiKeys. |
