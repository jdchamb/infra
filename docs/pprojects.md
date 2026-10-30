# Personal Project Board (`docs/pprojects.md`)

> See [`modules/README.md`](../modules/README.md) for the full 1-to-1 catalog of NixOS modules built for these projects, and [`docs/host-profiles.md`](./host-profiles.md) for the active host matrix.

---

## 🏃 In Progress & Active Hardware / Lab Validation
* [ ] **🔥 PRIORITY #1 (Ground Zero): Re-initialize SOPS & Age Personal/Homelab Cryptographic Identity from Scratch**
    * *Objective:* Rebuild personal homelab secrets trust root following legacy key loss. Protect personal tokens (Cloudflare DNS, Borg backup passphrases, Forgejo runner tokens) from ever being stored in plaintext.
    * *Runbook & Generator:* [**`docs/sops-bootstrap-runbook.md`**](./sops-bootstrap-runbook.md) & [`scripts/bootstrap-sops-keys.sh`](../scripts/bootstrap-sops-keys.sh)
    * *Action Items:*
        1. [ ] Generate new personal Age keypair via `scripts/bootstrap-sops-keys.sh personal`.
        2. [ ] Backup private key to offline password vault.
        3. [ ] Register new personal public key into [`.sops.yaml`](../.sops.yaml).
        4. [ ] Re-initialize [`secrets/personal.yaml`](../secrets/personal.yaml) with clean schema.
* [ ] **Project 11:** Physical deployment of 5-node validation lab out of workspace HP ProBooks to execute localized testing.
    * [x] *1-to-1 Module & Hosts Built:* [`modules/nixos/hardware/hp-probook.nix`](../modules/nixos/hardware/hp-probook.nix) & [`hosts/nixos/lab-probook/default.nix`](../hosts/nixos/lab-probook/default.nix) (`#lab-pb01` .. `#lab-pb05` in [`flake.nix`](../flake.nix))
* [ ] **Project 16:** Run physical PoE infrastructure drops for Reolink doorbell deployments.
    * [x] *1-to-1 Modules Built:* [`modules/nixos/services/home-assistant.nix`](../modules/nixos/services/home-assistant.nix) (Reolink integration), [`modules/nixos/apps/vlc.nix`](../modules/nixos/apps/vlc.nix), [`modules/nixos/apps/nmap.nix`](../modules/nixos/apps/nmap.nix)
* [ ] **Project 17:** Test physical structural capabilities of the homelab Brocade switch.
    * [x] *1-to-1 Modules Built:* [`modules/nixos/apps/minicom.nix`](../modules/nixos/apps/minicom.nix) (9600 8N1 serial console), [`modules/nixos/apps/wireshark.nix`](../modules/nixos/apps/wireshark.nix), [`modules/nixos/apps/iperf3.nix`](../modules/nixos/apps/iperf3.nix)
* [ ] **Project 18:** Punch down physical structural patch panels in home network enclosure.
    * [x] *1-to-1 Modules Built:* [`modules/nixos/apps/iperf3.nix`](../modules/nixos/apps/iperf3.nix) & [`modules/nixos/apps/wireshark.nix`](../modules/nixos/apps/wireshark.nix)

---

## ✅ Completed Tasks (Declarative 1-to-1 Modules & Documentation)
* [x] **Project 1: Custom ISO with remote access & bootstrap automation**
    * *Completion Date:* 2026-10-29
    * *Module:* [`modules/nixos/core/bootstrap.nix`](../modules/nixos/core/bootstrap.nix), [`hosts/nixos/installer/bootstrap-iso.nix`](../hosts/nixos/installer/bootstrap-iso.nix), [`hosts/nixos/installer/recovery-iso.nix`](../hosts/nixos/installer/recovery-iso.nix)
    * *Resolution:* Built declarative `bootstrap.nix` with `infra-auto-clone` systemd service, SSH authorized keys, and Disko + NixOS bootstrap tooling.
* [x] **Project 2: Build NixOS on remote machine via network**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Modules:* [`modules/nixos/core/nixos-anywhere.nix`](../modules/nixos/core/nixos-anywhere.nix), [`modules/nixos/core/deploy-rs.nix`](../modules/nixos/core/deploy-rs.nix), [`modules/nixos/core/colmena.nix`](../modules/nixos/core/colmena.nix)
* [x] **Project 3: Setup "Erase your darlings" stateless root profiles**
    * *Completion Date:* 2026-10-29
    * *Modules:* [`modules/nixos/core/impermanence.nix`](../modules/nixos/core/impermanence.nix) & [`modules/nixos/hardware/disko-impermanence.nix`](../modules/nixos/hardware/disko-impermanence.nix)
* [x] **Project 4: Build `README.md` files for structural mapping across all configuration sub-directories**
    * *Completion Date:* 2026-10-29
    * *Documentation:* [`README.md`](../README.md), [`docs/README.md`](./README.md), [`hosts/README.md`](../hosts/README.md), [`modules/README.md`](../modules/README.md), [`home/README.md`](../home/README.md), [`secrets/README.md`](../secrets/README.md)
* [x] **Project 5: Setup GPG/online cryptographic identity for signed developer git workflows**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Modules:* [`modules/shared/security/gpg.nix`](../modules/shared/security/gpg.nix) & [`modules/shared/git.nix`](../modules/shared/git.nix)
* [x] **Project 6: Enforce Apple keyboard numlock `.nix` configuration states**
    * *Completion Date:* 2026-10-29
    * *Module:* [`modules/nixos/hardware/apple-keyboard.nix`](../modules/nixos/hardware/apple-keyboard.nix) (TTY `setleds`, SDDM, and Wayland `numlock_by_default`)
* [x] **Project 7: Clean up Ghostty and Zellij files to implement a Universal Environment Keybinding Pattern**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Modules:* [`modules/shared/ghostty.nix`](../modules/shared/ghostty.nix), [`modules/shared/zellij.nix`](../modules/shared/zellij.nix), and [`docs/keybindings.md`](./keybindings.md)
* [x] **Project 8: Swap default top-row Fn key behaviors to map to standard functional `F1`-`F12` controls by default**
    * *Completion Date:* 2026-10-29
    * *Module:* [`modules/nixos/hardware/apple-keyboard.nix`](../modules/nixos/hardware/apple-keyboard.nix) (`options hid_apple fnmode=2`)
* [x] **Project 9: Declare Dolphin structural optimizations (item sizes, default list views, and cache adjustments)**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Module:* [`modules/nixos/apps/dolphin.nix`](../modules/nixos/apps/dolphin.nix) (Details mode default, preview settings, GVFS & KIO cache tuning)
* [x] **Project 10: Refactor local documents and personal lists layout**
    * *Completion Date:* 2026-10-29
    * *Documentation:* [`docs/README.md`](./README.md)
* [x] **Project 12: Evaluate migrating status project trackers into true localized Git issue pipelines**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Modules:* [`modules/shared/git-bug.nix`](../modules/shared/git-bug.nix) (`git-bug` offline-first distributed Git issue tracker) & [`modules/shared/tea.nix`](../modules/shared/tea.nix) (Codeberg `tea` CLI)
* [x] **Project 13: Setup host profile logs documenting the specific role/architecture for every active machine**
    * *Completion Date:* 2026-10-29
    * *Documentation:* [`docs/host-profiles.md`](./host-profiles.md)
* [x] **Project 14: Hardware Retargeting: Decommission wrk-lt01**
    * *Completion Date:* 2026-06-29 13:59:59 CDT
    * *Resolution:* Removed old mobile hardware configurations from deployment matrices to focus on immediate multi-node scale optimizations.
* [x] **Project 15: Setup Network UPS Tools (NUT) for home server stack power monitoring**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Module:* [`modules/nixos/services/nut.nix`](../modules/nixos/services/nut.nix) (`power.ups` server/client monitoring on port 3493)
* [x] **Project 19: Build global configurations for core modules in the configuration repository (`global.nix`)**
    * *Completion Date:* 2026-10-29
    * *Module:* [`modules/nixos/core/global.nix`](../modules/nixos/core/global.nix)
* [x] **Project 20: Setup git for auto cloning `src/infra` repo to a device & custom ISO**
    * *Completion Date:* 2026-10-29
    * *Modules:* [`modules/nixos/core/bootstrap.nix`](../modules/nixos/core/bootstrap.nix) (`infra-auto-clone` systemd service) & [`home/programs/git-sync.nix`](../home/programs/git-sync.nix) (interactive `chpwd` auto-fetch/rebase prompt)
* [x] **Project 21: Setup AdGuard for NixOS**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Module:* [`modules/nixos/services/adguard-home.nix`](../modules/nixos/services/adguard-home.nix) (`services.adguardhome` with Quad9/Cloudflare DoH)
* [x] **Project 22: Setup KDE Plasma Dolphin to have dark mode and smallest text**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Modules:* [`modules/nixos/desktop/plasma.nix`](../modules/nixos/desktop/plasma.nix) & [`modules/nixos/apps/dolphin.nix`](../modules/nixos/apps/dolphin.nix) (Breeze Dark + 8pt compact font defaults)
* [x] **Project 23: Setup tiling with Krohnkite or Fluid Tile**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Module:* [`modules/nixos/desktop/krohnkite.nix`](../modules/nixos/desktop/krohnkite.nix) (`kdePackages.krohnkite` KWin script)
* [x] **Project 24: Support Codeberg and NixOS (Host server, runner, or binary cache mirror)**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Modules:* [`modules/nixos/services/harmonia.nix`](../modules/nixos/services/harmonia.nix) (Nix binary cache mirror), [`modules/nixos/services/forgejo-runner.nix`](../modules/nixos/services/forgejo-runner.nix) (Codeberg Actions CI runner), and [`modules/nixos/services/forgejo.nix`](../modules/nixos/services/forgejo.nix)
* [x] **Project 25: Prepare comprehensive architectural comments for all Nix configurations**
    * *Completion Date:* 2026-10-29
    * *Resolution:* Standardized architectural `ROLE & ARCHITECTURE` headers and inline comments across all `.nix` files in `flake.nix`, `hosts/`, `home/`, and `modules/`.
* [x] **Project 26: Optimize Kate text editor declarations (`kate.nix`)**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Module:* [`modules/nixos/apps/kate.nix`](../modules/nixos/apps/kate.nix) (5-file recent list, 16-tab cap, session confirmation)
* [x] **Project 27: Linux Kernel & Linux From Scratch (LFS) engineering toolchain**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Module:* [`modules/nixos/apps/kernel-lfs-tools.nix`](../modules/nixos/apps/kernel-lfs-tools.nix)
