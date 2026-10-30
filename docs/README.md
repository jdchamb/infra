# Documentation Subsystem (`docs/`)

This directory contains reference notes, engineering logs, architecture decisions, and project milestones for the USD 308 infrastructure fleet and personal homelab.

---

## 📚 Document Index

| Document | Scope & Purpose |
| :--- | :--- |
| **[`pprojects.md`](./pprojects.md)** | **Personal Project Board:** Homelab infrastructure, NixOS architecture, desktop environment tuning, and FLOSS community contributions (Projects 1–26), mapped 1-to-1 to their NixOS modules. |
| **[`308projects.md`](./308projects.md)** | **USD 308 Project Board:** School district fleet engineering (PDQ, Snipe-IT, ClearTouch, Vaultwarden, FOG PXE, SOPS, SMB shares), mapped 1-to-1 to their NixOS modules and PowerShell scripts. |
| **[`fleet_services_roadmap.md`](./fleet_services_roadmap.md)** | **Fleet Services & Wishlist Implementation Plan:** 5-phase architecture covering client tools, Btrfs/Borg storage, self-hosted cloud, media/IoT, and game server orchestration. |
| **[`pprojectslearn.md`](./pprojectslearn.md)** | **Linux Engineering & Declarative Architecture Learning Plan:** 3-Phase curriculum from Silicon & UEFI $\rightarrow$ Linux From Scratch $\rightarrow$ NixOS Derivations & Flakes (supported by [`modules/nixos/apps/kernel-lfs-tools.nix`](../modules/nixos/apps/kernel-lfs-tools.nix)). |
| **[`host-profiles.md`](./host-profiles.md)** | **Host Profile & Architecture Logs (Project 13):** Detailed hardware, storage, secret, and module matrix for every active node in [`flake.nix`](../flake.nix). |
| **[`keybindings.md`](./keybindings.md)** | **Universal Environment Keybinding Pattern (Project 7):** Collision-free shortcut hierarchy across Wayland Compositors (`Super`), Zellij (`Alt`), and Ghostty (`Ctrl+Shift`). |
| **[`hardware_security_keys_runbook.md`](./hardware_security_keys_runbook.md)** | **Hardware Security Keys & OpenSK Runbook:** Deployment and firmware workflow for Nordic nRF52840 FIDO2 dongles and YubiKeys. |
