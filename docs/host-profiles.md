# Host Profile & Fleet Architecture Logs (`docs/host-profiles.md`)

> **Roadmap Reference:** Personal Project 13 — *Setup host profile logs documenting the specific role/architecture for every active machine.*

This document tracks the exact hardware architecture, storage topology, cryptographic secret state, and active module composition for every node declared in [`flake.nix`](../flake.nix).

---

## 1. `308-222242` — Primary Production Linux Workstation
- **Entrypoint:** [`hosts/nixos/308-222242/default.nix`](../hosts/nixos/308-222242/default.nix)
- **Hardware Scan:** [`hosts/nixos/308-222242/hardware.nix`](../hosts/nixos/308-222242/hardware.nix)
- **Architecture:** `x86_64-linux` (Intel Core with `kvm-intel` hardware virtualization & mainline `linuxPackages_latest` kernel)
- **Storage Topology:**
  - `/` (`ext4`): `UUID=45ed33f8-dd8c-49f6-bbaf-e24406716bc6`
  - `/boot` (`vfat`): `UUID=F07A-954D` (`systemd-boot` UEFI)
  - Network CIFS Automounts ([`modules/nixos/services/308-storage.nix`](../modules/nixos/services/308-storage.nix)):
    - `/home/jchambers/Shares/WorkStorage` $\rightarrow$ `//172.16.3.0/Backups/JoshBackups`
    - `/home/jchambers/Shares/CloudStorage` $\rightarrow$ `//cloud-storage.usd308.com/Resources/TSC`
    - `/home/jchambers/Shares/PDQServer/Software` $\rightarrow$ `//pdq.usd308.com/Software`
    - `/home/jchambers/Shares/PDQServer/Scripts` $\rightarrow$ `//pdq.usd308.com/Scripts`
- **Secret Management:** Active `sops-nix` daemon ([`modules/nixos/core/sops.nix`](../modules/nixos/core/sops.nix)) using `/var/lib/sops-nix/308-key.txt` to populate `/etc/nixos/secrets/308-adminjc` and `/etc/nixos/secrets/308-admin308`.
- **Graphical Sessions:** `greetd` + `regreet` ([`modules/nixos/desktop/greetd.nix`](../modules/nixos/desktop/greetd.nix)) launching Hyprland, Niri, Sway, or KDE Plasma 6 (`plasma.nix` + `krohnkite.nix`).
- **Operational Role:** Daily driver workstation for NixOS development, USD 308 fleet management (Snipe-IT MAC exports, PDQ/Autodesk script staging, DYMO label printing, ClearTouch ADB management), and remote lab orchestration.

---

## 2. `308-225660` — Primary Work Apple Silicon MacBook
- **Entrypoint:** [`hosts/darwin/308-225660/default.nix`](../hosts/darwin/308-225660/default.nix)
- **Architecture:** `aarch64-darwin` (Apple Silicon M-Series, macOS 27.0.1+)
- **Management Engine:** `nix-darwin` + `home-manager` + `nix-homebrew` + native `nix.linux-builder` (Virtualization.framework compiling both `aarch64-linux` and `x86_64-linux`).
- **Shared 1-to-1 Modules:**
  - [`home/default.nix`](../home/default.nix) (`zsh.nix`, `git-sync.nix`, `starship.nix`)
  - [`modules/shared/git.nix`](../modules/shared/git.nix), [`git-bug.nix`](../modules/shared/git-bug.nix), [`lazygit.nix`](../modules/shared/lazygit.nix), [`vim.nix`](../modules/shared/vim.nix), [`neovim.nix`](../modules/shared/neovim.nix), [`zellij.nix`](../modules/shared/zellij.nix), [`ghostty.nix`](../modules/shared/ghostty.nix)
  - [`modules/shared/security/yubikey-nordic.nix`](../modules/shared/security/yubikey-nordic.nix), [`gpg.nix`](../modules/shared/security/gpg.nix), [`vaultwarden-client.nix`](../modules/shared/security/vaultwarden-client.nix)
  - [`modules/shared/storage/file-integrity-monitor.nix`](../modules/shared/storage/file-integrity-monitor.nix)
- **Operational Role:** Mobile field engineering laptop for USD 308 building visits (Grandview, HHS, HVS, HMS8), FileWave testing, and hosting `308-225660NixOSVM`.

---

## 3. `308-225660NixOSVM` — Apple Silicon UTM / VZ Virtual Machine
- **Entrypoint:** [`hosts/nixos/308-225660NixOSVM/default.nix`](../hosts/nixos/308-225660NixOSVM/default.nix)
- **Architecture:** `aarch64-linux` (VirtIO paravirtualized guest on `308-225660`)
- **Storage Topology:** Declarative Disko GPT layout ([`modules/nixos/hardware/disko-standard.nix`](../modules/nixos/hardware/disko-standard.nix)) targeting `/dev/vda`.
- **Guest Integration:** `services.qemuGuest.enable = true` and `services.spice-vdagentd.enable = true`.
- **Operational Role:** Local ARM64 NixOS sandbox for testing service modules before bare-metal deployment.

---

## 4. `bootstrap-iso` & `recovery-iso` — Provisioning & Rescue Live Media
- **Entrypoints:** [`hosts/nixos/installer/bootstrap-iso.nix`](../hosts/nixos/installer/bootstrap-iso.nix) & [`hosts/nixos/installer/recovery-iso.nix`](../hosts/nixos/installer/recovery-iso.nix)
- **Architecture:** `x86_64-linux`
- **Bootstrap Automation ([`modules/nixos/core/bootstrap.nix`](../modules/nixos/core/bootstrap.nix)):**
  - OpenSSH enabled at boot with Ed25519 public key authorized for `root`, `nixos`, and `jchambers`.
  - Systemd service `clone-infra-repo.service` automatically clones `https://codeberg.org/jchambers-codeberg/infra.git` to `/home/nixos/src/infra`.
  - Bundled `bootstrap-age-key` and `bootstrap-install` CLI scripts for staging SOPS keys and executing Disko installs.

---

## 5. `lab-pb01` .. `lab-pb05` — 5-Node HP ProBook Validation Lab
- **Entrypoint:** [`hosts/nixos/lab-probook/default.nix`](../hosts/nixos/lab-probook/default.nix)
- **Hardware Profile:** [`modules/nixos/hardware/hp-probook.nix`](../modules/nixos/hardware/hp-probook.nix)
- **Architecture:** `x86_64-linux` (5x repurposed workspace HP ProBook laptops)
- **Key Features:**
  - Clamshell operation (`services.logind.lidSwitch = "ignore"`) so all 5 laptops operate with lids closed on the lab rack.
  - Configured as Network UPS Tools followers (`services.fleet.nut.mode = "netclient"`) via [`modules/nixos/services/nut.nix`](../modules/nixos/services/nut.nix) with Cockpit web admin ([`cockpit.nix`](../modules/nixos/services/cockpit.nix)) on port `9090`.
