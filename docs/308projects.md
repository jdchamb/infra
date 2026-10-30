# USD 308 Project Board (`docs/308projects.md`)

> See [`modules/README.md`](../modules/README.md) for the 1-to-1 NixOS modules and PowerShell automation scripts built to support USD 308 infrastructure and fleet workflows.

---

## 🏃 In Progress (Operational Execution with 1-to-1 Modules Ready)
* [ ] **Project 2:** Compile list of bills for non-returned staff equipment for 2025-2026.
    * [x] *1-to-1 OCR & Archival Modules Built:* [`modules/nixos/services/paperless.nix`](../modules/nixos/services/paperless.nix), [`modules/nixos/apps/gimagereader.nix`](../modules/nixos/apps/gimagereader.nix), [`modules/nixos/apps/normcap.nix`](../modules/nixos/apps/normcap.nix), [`modules/nixos/apps/tesseract.nix`](../modules/nixos/apps/tesseract.nix)
* [ ] **Project 9:** Update Autodesk Fusion installer and isolate the FeatureCAM module deployment workflow.
    * [x] *1-to-1 Module & Script Built:* [`modules/nixos/apps/powershell.nix`](../modules/nixos/apps/powershell.nix) & [`modules/windows/scripts/Deploy-AutodeskFusionFeatureCAM.ps1`](../modules/windows/scripts/Deploy-AutodeskFusionFeatureCAM.ps1)
* [ ] **Project 11:** Pull all Wi-Fi MAC addresses for every device in Snipe-IT and compile a CSV import for macauth validation.
    * [x] *1-to-1 Module & CLI Tool Built:* [`modules/nixos/services/snipeit.nix`](../modules/nixos/services/snipeit.nix) (`snipeit-export-macs` script exports normalized MAC CSV from Snipe-IT REST API)
* [ ] **Project 13:** Maintain and update comprehensive ClearTouch inventory information on the master spreadsheet.
* [ ] **Project 22:** Print asset labels for cleartouches @ grandview.
    * [x] *1-to-1 Modules Built:* [`modules/nixos/apps/dymo.nix`](../modules/nixos/apps/dymo.nix) (`cups-dymo`) & [`modules/nixos/apps/glabels.nix`](../modules/nixos/apps/glabels.nix) (`glabels-qt`)
* [ ] **Project 23:** Go to grandview to scope out the situation.
* [ ] **Project 24:** Need to check out devices according to Pam's labels for HHS and HVS.
* [ ] **Project 25:** Need to add MAC addresses for ct wireless modules into snipeit.
    * [x] *1-to-1 Module & CLI Tool Built:* [`modules/nixos/services/snipeit.nix`](../modules/nixos/services/snipeit.nix) (`snipeit-add-ct-mac <asset-tag> <mac>`)

---

## ✅ Completed Tasks & Built Declarative Modules / Automation Scripts
* [x] **Project 1: Update PDQ packages (Adobe, Autodesk, HoverCAM, VLC, DYMO)**
    * *1-to-1 Modules:* [`modules/nixos/apps/vlc.nix`](../modules/nixos/apps/vlc.nix), [`modules/nixos/apps/dymo.nix`](../modules/nixos/apps/dymo.nix)
* [x] **Project 3: Declarative Snipe-IT Service Module (Evaluate current Debian + Git clone path vs fresh VM)**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Module:* [`modules/nixos/services/snipeit.nix`](../modules/nixos/services/snipeit.nix) (`services.fleet.snipeit.enable` declarative Snipe-IT + MariaDB container stack & REST CLI tools)
* [x] **Project 4: FileWave / macOS Test Host Profile (`nix-darwin`)**
    * *Completion Date:* 2026-10-29
    * *Test Host:* [`hosts/darwin/308-225660/default.nix`](../hosts/darwin/308-225660/default.nix)
* [x] **Project 5: Windows 11 Deployment Image Optimization (DISM & WIMlib)**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Module & Script:* [`modules/nixos/apps/wimlib.nix`](../modules/nixos/apps/wimlib.nix) (`wimlib-imagex`) & [`modules/windows/scripts/Optimize-Win11Image.ps1`](../modules/windows/scripts/Optimize-Win11Image.ps1)
* [x] **Project 6: Centralized Password Manager Vault for the USD 308 Tech Dept**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Modules:* [`modules/nixos/services/vaultwarden.nix`](../modules/nixos/services/vaultwarden.nix) (Server), [`modules/shared/security/vaultwarden-client.nix`](../modules/shared/security/vaultwarden-client.nix) (`bw` CLI), [`modules/nixos/apps/bitwarden.nix`](../modules/nixos/apps/bitwarden.nix) (Desktop GUI), [`modules/nixos/apps/1password.nix`](../modules/nixos/apps/1password.nix)
* [x] **Project 7: Mock Ticketing System with Internal Documentation**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Module:* [`modules/nixos/services/zammad.nix`](../modules/nixos/services/zammad.nix) (Self-hosted helpdesk container on port 8082)
* [x] **Project 8: Internal USD 308 Technical Wiki for Department Documentation**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Module:* [`modules/nixos/services/silverbullet.nix`](../modules/nixos/services/silverbullet.nix) (SilverBullet Markdown wiki server on port 3001)
* [x] **Project 10: UltraVNC PDQ Deployment Package & Linux VNC Clients**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Modules & Script:* [`modules/nixos/apps/krdc.nix`](../modules/nixos/apps/krdc.nix), [`modules/nixos/apps/tigervnc.nix`](../modules/nixos/apps/tigervnc.nix), & [`modules/windows/scripts/Deploy-UltraVNC.ps1`](../modules/windows/scripts/Deploy-UltraVNC.ps1)
* [x] **Project 14: Automated Uninstaller for Lingering Autodesk Registry and File Remnants on Windows 11**
    * *Completion Date:* 2026-10-29
    * *Script:* [`modules/windows/scripts/Remove-AutodeskRemnants.ps1`](../modules/windows/scripts/Remove-AutodeskRemnants.ps1)
* [x] **Project 15: FOG / PXE Network Boot Server Replacement for WDS**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Module:* [`modules/nixos/services/fog-pxe.nix`](../modules/nixos/services/fog-pxe.nix) (`dnsmasq` TFTP/iPXE boot responder + `/srv/tftp`)
* [x] **Project 16: PDQ Email Notification Delivery Pipeline Verification**
    * *Completion Date:* 2026-10-29
    * *Script:* [`modules/windows/scripts/Test-PDQEmailPipeline.ps1`](../modules/windows/scripts/Test-PDQEmailPipeline.ps1)
* [x] **Project 17: Setup secrets management using SOPS / age for encrypted credentials**
    * *Modules:* [`modules/nixos/core/sops.nix`](../modules/nixos/core/sops.nix) & [`modules/common/sops-tools.nix`](../modules/common/sops-tools.nix)
    * *Completion Date:* 2026-06-26
    * *Resolution:* Integrated `sops-nix` engine into `308-222242` using a locally stored master age key file decrypting straight into `/run/secrets/`.
* [x] **Project 18: Wire up and test USD 308 network share automounts**
    * *Module:* [`modules/nixos/services/308-storage.nix`](../modules/nixos/services/308-storage.nix)
    * *Completion Date:* 2026-06-25
    * *Resolution:* Refactored infrastructure shares (`WorkStorage`, `CloudStorage`, `PDQServer/Software`, `PDQServer/Scripts`) into systemd mounts with `network-online.target` dependencies.
* [x] **Project 19: Print chromebook labels for Pam** (Supported by [`modules/nixos/apps/dymo.nix`](../modules/nixos/apps/dymo.nix))
    * *Completion Date:* 2026-06-26 16:11 CDT
* [x] **Project 20: Inventory HP laptops for James**
    * *Completion Date:* 2026-06-29 13:21:28 CDT
* [x] **Project 21: Print HVS Labels for Pam** (Supported by [`modules/nixos/apps/dymo.nix`](../modules/nixos/apps/dymo.nix))
    * *Completion Date:* 2026-06-29 09:29:17 CDT
* [x] **Project 26: CTEA missed boards, HHS A204 A106 f100 f105, HMS8 3rd floor, HMS8 414 115 116, lil hawks childcare center, SJH, Lincoln**
* [x] **Project 27: ClearTouch Android User Profile Provisioning Tooling**
    * *Completion Date:* 2026-10-29
    * *1-to-1 Modules:* [`modules/nixos/apps/adb.nix`](../modules/nixos/apps/adb.nix) (`adb` + `cleartouch-lockdown-guest`) & [`modules/nixos/apps/scrcpy.nix`](../modules/nixos/apps/scrcpy.nix) (`scrcpy`)
* [x] **Project 28: Process RMA'd boards**
* [x] **Project 29: Process iphone for James** (Supported by [`modules/nixos/apps/apple-tools.nix`](../modules/nixos/apps/apple-tools.nix))
    * *Completion Date:* 2026.07.10 CDT
* [x] **Project 30: Process another iphone for James** (Supported by [`modules/nixos/apps/apple-tools.nix`](../modules/nixos/apps/apple-tools.nix))
