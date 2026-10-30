# Fleet Modules Library (`modules/`)

This directory contains the modular building blocks (the **"Organs"**) of the fleet. Every module strictly follows a **1 Module = 1 Software or Service** contract so individual tools or services can be toggled on or off per host without side effects.

---

## 1. Directory Hierarchy

```text
modules/
├── common/                 # Universal Nix settings, binary caches, Nerd Fonts, SOPS CLI
├── shared/                 # Cross-platform (macOS + Linux) user/developer/security modules
│   ├── remote/             # Cross-platform remote desktop clients (rustdesk.nix)
│   ├── security/           # Hardware keys, GnuPG, KeePassXC, Vaultwarden CLI
│   └── storage/            # Checksum & bitrot integrity verifiers
├── nixos/                  # Linux & NixOS system modules
│   ├── core/               # Kernel, boot, network, audio, printing, impermanence, remote deploy
│   ├── hardware/           # Disko layouts, Apple keyboard driver fixes, HP ProBook lab profile
│   ├── desktop/            # Display managers, Wayland compositors, Plasma 6 & Krohnkite tiling
│   ├── apps/               # Standalone GUI & CLI applications (1 module per application)
│   └── services/           # Self-hosted daemons & USD 308 infrastructure services (1 module per service)
│       └── game-servers/   # Pelican Panel, Minecraft, Terraria, Palworld
└── windows/                # Windows 11 declarative DSC, WinGet & PowerShell PDQ scripts
```

---

## 2. Common & Shared Cross-Platform Modules (`modules/common/`, `modules/shared/`)

| Module | Software / Service (1-to-1) | Roadmap Mapping |
| :--- | :--- | :--- |
| [`common/cachix.nix`](./common/cachix.nix) | Cachix Binary Cache Substituters | Core Foundation |
| [`common/fonts.nix`](./common/fonts.nix) | JetBrains Mono & Fira Code Nerd Fonts | Core Foundation |
| [`common/sops-tools.nix`](./common/sops-tools.nix) | `sops` & `age` CLI Binaries | 308 Project 17 |
| [`shared/ghostty.nix`](./shared/ghostty.nix) | Ghostty Terminal (`Ctrl+Shift` Universal Keybindings) | Personal Project 7 |
| [`shared/zellij.nix`](./shared/zellij.nix) | Zellij Multiplexer (`Alt+h/j/k/l` Universal Keybindings) | Personal Project 7 |
| [`shared/git.nix`](./shared/git.nix) | Git Version Control & SSH Signing Config | Personal Project 5 |
| [`shared/git-bug.nix`](./shared/git-bug.nix) | `git-bug` Distributed Offline Git Issue Tracker | Personal Project 12 |
| [`shared/tea.nix`](./shared/tea.nix) | `tea` Codeberg / Forgejo CLI Client | Personal Projects 12 & 24 |
| [`shared/lazygit.nix`](./shared/lazygit.nix) | `lazygit` Terminal UI for Git | Developer Workflow |
| [`shared/neovim.nix`](./shared/neovim.nix) | Neovim Primary Editor & Treesitter Toolchain | Core Dev Layer |
| [`shared/vim.nix`](./shared/vim.nix) | Vim Fallback Editor with Transparency Fix | Core Dev Layer |
| [`shared/security/yubikey-nordic.nix`](./shared/security/yubikey-nordic.nix) | YubiKey & Nordic OpenSK FIDO2/U2F Rules | Fleet Roadmap Phase 1 |
| [`shared/security/gpg.nix`](./shared/security/gpg.nix) | GnuPG Agent & Smartcard (`pcscd`) Daemon | Personal Project 5 |
| [`shared/security/vaultwarden-client.nix`](./shared/security/vaultwarden-client.nix) | Bitwarden / Vaultwarden CLI (`rbw`, `bitwarden-cli`) | 308 Project 6 / Fleet Phase 1 |
| [`shared/security/keepassxc.nix`](./shared/security/keepassxc.nix) | KeePassXC Offline KDBX Password Manager | Fleet Roadmap Phase 1 |
| [`shared/remote/rustdesk.nix`](./shared/remote/rustdesk.nix) | RustDesk Open-Source Remote Desktop Client | Fleet Roadmap Phase 1 |
| [`shared/storage/file-integrity-monitor.nix`](./shared/storage/file-integrity-monitor.nix) | `rhash` + `fleet-integrity-check` Bitrot Verifier | Fleet Roadmap Phase 2 |

---

## 3. NixOS Core, Hardware & Desktop Modules (`modules/nixos/{core,hardware,desktop}/`)

| Module | Software / Subsystem (1-to-1) | Roadmap Mapping |
| :--- | :--- | :--- |
| [`nixos/core/global.nix`](./nixos/core/global.nix) | Unified Global Baseline Import Aggregator | Personal Project 19 |
| [`nixos/core/bootstrap.nix`](./nixos/core/bootstrap.nix) | Zero-Touch ISO SSH, Auto-Clone & Age Key Staging | Personal Projects 1 & 20 |
| [`nixos/core/impermanence.nix`](./nixos/core/impermanence.nix) | Stateless Root ("Erase Your Darlings") `/persist` Mounts | Personal Project 3 |
| [`nixos/core/nixos-anywhere.nix`](./nixos/core/nixos-anywhere.nix) | `nixos-anywhere` Network Bare-Metal Installer | Personal Project 2 |
| [`nixos/core/deploy-rs.nix`](./nixos/core/deploy-rs.nix) | `deploy-rs` Multi-Node Atomic Fleet Deployer | Personal Project 2 |
| [`nixos/core/colmena.nix`](./nixos/core/colmena.nix) | `colmena` Parallel NixOS Hive Orchestrator | Personal Project 2 |
| [`nixos/core/boot.nix`](./nixos/core/boot.nix) | Mainline Linux Kernel & `systemd-boot` UEFI | Core Foundation |
| [`nixos/core/system.nix`](./nixos/core/system.nix) | Locale, Flakes Flags, Store Deduplication & GC | Core Foundation |
| [`nixos/core/network.nix`](./nixos/core/network.nix) | NetworkManager & Stateful Host Firewall | Core Foundation |
| [`nixos/core/user.nix`](./nixos/core/user.nix) | Primary User (`jchambers`) & Zsh Login Shell | Core Foundation |
| [`nixos/core/audio.nix`](./nixos/core/audio.nix) | PipeWire Multimedia Server & RealtimeKit | Core Foundation |
| [`nixos/core/printing.nix`](./nixos/core/printing.nix) | CUPS Printing Spooler & Avahi mDNS Discovery | Core Foundation |
| [`nixos/core/sops.nix`](./nixos/core/sops.nix) | `sops-nix` Runtime Secret Decryption Daemon | 308 Project 17 |
| [`nixos/hardware/apple-keyboard.nix`](./nixos/hardware/apple-keyboard.nix) | `hid_apple fnmode=2` (`F1`-`F12`) & NumLock Enforcement | Personal Projects 6 & 8 |
| [`nixos/hardware/disko-standard.nix`](./nixos/hardware/disko-standard.nix) | Disko GPT + Ext4 Standard Partition Layout | Core Storage |
| [`nixos/hardware/disko-btrfs.nix`](./nixos/hardware/disko-btrfs.nix) | Disko Btrfs Subvolume (`@root`, `@nix`, `@home`, `@snapshots`) | Fleet Roadmap Phase 2 |
| [`nixos/hardware/disko-impermanence.nix`](./nixos/hardware/disko-impermanence.nix) | Disko Btrfs Impermanence Layout (`@persist`) | Personal Project 3 |
| [`nixos/hardware/hp-probook.nix`](./nixos/hardware/hp-probook.nix) | HP ProBook Clamshell Lab Hardware Profile | Personal Project 11 |
| [`nixos/hardware/hw-utils.nix`](./nixos/hardware/hw-utils.nix) | Bus Probing & NIST Drive Sanitization Suite | Core Hardware |
| [`nixos/desktop/greetd.nix`](./nixos/desktop/greetd.nix) | Greetd + ReGreet Wayland Login Manager | Desktop Layer |
| [`nixos/desktop/hyprland.nix`](./nixos/desktop/hyprland.nix) | Hyprland Dynamic Tiling Wayland Compositor | Personal Project 7 |
| [`nixos/desktop/niri.nix`](./nixos/desktop/niri.nix) | Niri Scrollable-Strip Wayland Compositor | Personal Project 7 |
| [`nixos/desktop/sway.nix`](./nixos/desktop/sway.nix) | Sway i3-Compatible Wayland Compositor | Personal Project 7 |
| [`nixos/desktop/plasma.nix`](./nixos/desktop/plasma.nix) | KDE Plasma 6 Wayland (Breeze Dark + 8pt Fonts) | Personal Project 22 |
| [`nixos/desktop/krohnkite.nix`](./nixos/desktop/krohnkite.nix) | Krohnkite Dynamic Tiling Script for KWin 6 | Personal Project 23 |

---

## 4. NixOS Standalone Applications (`modules/nixos/apps/` — 1 Module per Application)

| Module | Application (1-to-1) | Roadmap Mapping |
| :--- | :--- | :--- |
| [`nixos/apps/dolphin.nix`](./nixos/apps/dolphin.nix) | KDE Dolphin File Manager (16px Details View, SMB Cache Opt) | Personal Projects 9 & 22 |
| [`nixos/apps/kate.nix`](./nixos/apps/kate.nix) | KDE Kate Editor (`Ctrl+Alt+N` Nix XML Snippets) | Personal Project 26 |
| [`nixos/apps/krdc.nix`](./nixos/apps/krdc.nix) | KDE KRDC Remote Desktop Client | 308 Project 10 |
| [`nixos/apps/tigervnc.nix`](./nixos/apps/tigervnc.nix) | TigerVNC Client for UltraVNC Endpoints | 308 Project 10 |
| [`nixos/apps/remmina.nix`](./nixos/apps/remmina.nix) | Remmina Multi-Protocol Remote Desktop Client | Fleet Remote Support |
| [`nixos/apps/vlc.nix`](./nixos/apps/vlc.nix) | VLC Media & RTSP Camera Stream Player | 308 Project 1 / Project 16 |
| [`nixos/apps/dymo.nix`](./nixos/apps/dymo.nix) | CUPS DYMO LabelWriter Printer Driver | 308 Projects 1, 19, 21, 22 |
| [`nixos/apps/glabels.nix`](./nixos/apps/glabels.nix) | gLabels Barcode & Asset Tag Designer | 308 Projects 19, 21, 22 |
| [`nixos/apps/adb.nix`](./nixos/apps/adb.nix) | Android Debug Bridge (`adb`) + ClearTouch `ct-profile-setup` | 308 Project 27 |
| [`nixos/apps/scrcpy.nix`](./nixos/apps/scrcpy.nix) | Scrcpy Low-Latency Android Screen Mirroring | 308 Project 27 |
| [`nixos/apps/apple-tools.nix`](./nixos/apps/apple-tools.nix) | `libimobiledevice` & `usbmuxd` iOS Asset Processing | 308 Projects 29 & 30 |
| [`nixos/apps/1password.nix`](./nixos/apps/1password.nix) | 1Password Desktop & CLI with Polkit Unlock | 308 Project 6 |
| [`nixos/apps/bitwarden.nix`](./nixos/apps/bitwarden.nix) | Bitwarden Desktop GUI Client | 308 Project 6 |
| [`nixos/apps/wireshark.nix`](./nixos/apps/wireshark.nix) | Wireshark Network Packet Analyzer | Personal Projects 16, 17, 18 |
| [`nixos/apps/minicom.nix`](./nixos/apps/minicom.nix) | Minicom RS-232 Serial Console (Brocade Switch) | Personal Project 17 |
| [`nixos/apps/iperf3.nix`](./nixos/apps/iperf3.nix) | `iperf3` Line-Rate Network Throughput Tester | Personal Projects 17 & 18 |
| [`nixos/apps/nmap.nix`](./nixos/apps/nmap.nix) | `nmap` Network & ONVIF/RTSP Discovery Scanner | Personal Projects 16 & 17 |
| [`nixos/apps/powershell.nix`](./nixos/apps/powershell.nix) | Microsoft PowerShell Core (`pwsh`) | 308 Projects 1, 9, 14, 16 |
| [`nixos/apps/wimlib.nix`](./nixos/apps/wimlib.nix) | `wimlib-imagex` Windows 11 WIM Image Optimizer | 308 Project 5 |
| [`nixos/apps/kernel-lfs-tools.nix`](./nixos/apps/kernel-lfs-tools.nix) | Silicon, Linux From Scratch & Nix Store Lab Toolchain | `docs/pprojectslearn.md` |
| [`nixos/apps/firefox.nix`](./nixos/apps/firefox.nix) | Mozilla Firefox Web Browser | Core Desktop App |
| [`nixos/apps/digikam.nix`](./nixos/apps/digikam.nix) | DigiKam Photo Library Manager | Media Management |
| [`nixos/apps/filelight.nix`](./nixos/apps/filelight.nix) | KDE Filelight Disk Usage Sunburst Analyzer | Storage Diagnostics |
| [`nixos/apps/kdf.nix`](./nixos/apps/kdf.nix) | KDE KDiskFree Block & Share Space Monitor | Storage Diagnostics |
| [`nixos/apps/partitionmanager.nix`](./nixos/apps/partitionmanager.nix) | KDE Partition Manager | Storage Diagnostics |
| [`nixos/apps/isoimagewriter.nix`](./nixos/apps/isoimagewriter.nix) | KDE ISO Image Writer USB Flasher | Personal Project 1 |
| [`nixos/apps/gimagereader.nix`](./nixos/apps/gimagereader.nix) | gImageReader GTK OCR Document Scanner | 308 Project 2 |
| [`nixos/apps/normcap.nix`](./nixos/apps/normcap.nix) | NormCap Screen-Selection OCR to Clipboard | OCR Workflow |
| [`nixos/apps/tesseract.nix`](./nixos/apps/tesseract.nix) | Tesseract CLI OCR & `ocrmypdf` | OCR Workflow |
| [`nixos/apps/media.nix`](./nixos/apps/media.nix) | `mpv`, `imv`, and `pavucontrol` | Media Playback |

---

## 5. NixOS Infrastructure & Self-Hosted Services (`modules/nixos/services/` — 1 Module per Service)

| Module | Service (1-to-1) | Roadmap Mapping |
| :--- | :--- | :--- |
| [`nixos/services/nut.nix`](./nixos/services/nut.nix) | Network UPS Tools (`power.ups`) Daemon (`:3493`) | Personal Project 15 / Phase 2 |
| [`nixos/services/adguard-home.nix`](./nixos/services/adguard-home.nix) | AdGuard Home DNS Sinkhole & DoH Server (`:3000`, `:53`) | Personal Project 21 / Phase 4 |
| [`nixos/services/pihole.nix`](./nixos/services/pihole.nix) | Pi-hole Containerized DNS Sinkhole (`:8053`, `:53`) | Fleet Roadmap Phase 4 |
| [`nixos/services/harmonia.nix`](./nixos/services/harmonia.nix) | Harmonia Rust Nix Binary Cache Server (`:5000`) | Personal Project 24 |
| [`nixos/services/forgejo-runner.nix`](./nixos/services/forgejo-runner.nix) | Codeberg / Forgejo Actions CI Runner Daemon | Personal Project 24 |
| [`nixos/services/forgejo.nix`](./nixos/services/forgejo.nix) | Self-Hosted Forgejo Git Software Forge (`:3001`) | Personal Project 24 / Phase 3 |
| [`nixos/services/vaultwarden.nix`](./nixos/services/vaultwarden.nix) | Vaultwarden Enterprise Password Server (`:8222`) | 308 Project 6 / Phase 3 |
| [`nixos/services/snipeit.nix`](./nixos/services/snipeit.nix) | Snipe-IT Asset Server + `snipeit-export-macs` & `snipeit-add-ct-mac` | 308 Projects 3, 11, 25 |
| [`nixos/services/zammad.nix`](./nixos/services/zammad.nix) | Mock IT Helpdesk Ticketing System (`:8085`) & SLA Templates | 308 Project 7 |
| [`nixos/services/silverbullet.nix`](./nixos/services/silverbullet.nix) | SilverBullet Markdown Technical Wiki Server (`:3002`) | 308 Project 8 / Phase 3 |
| [`nixos/services/memos.nix`](./nixos/services/memos.nix) | Memos Lightweight Note-Taking Server (`:5230`) | Fleet Roadmap Phase 3 |
| [`nixos/services/paperless.nix`](./nixos/services/paperless.nix) | Paperless-ngx OCR Document & Invoice Archival (`:28981`) | 308 Project 2 / Phase 3 |
| [`nixos/services/nextcloud.nix`](./nixos/services/nextcloud.nix) | Nextcloud File Sync, Calendar & Contacts Suite | Fleet Roadmap Phase 3 |
| [`nixos/services/backup-borg.nix`](./nixos/services/backup-borg.nix) | BorgBackup Encrypted Deduplicated Backup Service | Fleet Roadmap Phase 2 |
| [`nixos/services/fog-pxe.nix`](./nixos/services/fog-pxe.nix) | FOG / iPXE / TFTP + NFSv4 Network Imaging Server | 308 Project 15 |
| [`nixos/services/immich.nix`](./nixos/services/immich.nix) | Immich ML Photo & Video Management Server (`:2283`) | Fleet Roadmap Phase 4 |
| [`nixos/services/jellyfin.nix`](./nixos/services/jellyfin.nix) | Jellyfin Hardware-Accelerated Media Server (`:8096`) | Fleet Roadmap Phase 4 |
| [`nixos/services/navidrome.nix`](./nixos/services/navidrome.nix) | Navidrome Music Streaming Server (`:4533`) | Fleet Roadmap Phase 4 |
| [`nixos/services/home-assistant.nix`](./nixos/services/home-assistant.nix) | Home Assistant IoT & Reolink Doorbell Server (`:8123`) | Personal Project 16 / Phase 4 |
| [`nixos/services/miniflux.nix`](./nixos/services/miniflux.nix) | Miniflux Minimalist RSS Feed Reader (`:8088`) | Fleet Roadmap Phase 4 |
| [`nixos/services/cockpit.nix`](./nixos/services/cockpit.nix) | Cockpit Web-Based Linux System Admin GUI (`:9090`) | Fleet Roadmap Phase 4 |
| [`nixos/services/planka.nix`](./nixos/services/planka.nix) | Planka Self-Hosted Kanban Project Board (`:3003`) | Fleet Roadmap Phase 4 |
| [`nixos/services/game-servers/pelican.nix`](./nixos/services/game-servers/pelican.nix) | Pelican Panel & Wings Game Server Orchestrator (`:8084`) | Fleet Roadmap Phase 5 |
| [`nixos/services/game-servers/minecraft.nix`](./nixos/services/game-servers/minecraft.nix) | Dedicated Minecraft Server (`:25565`) | Fleet Roadmap Phase 5 |
| [`nixos/services/game-servers/terraria.nix`](./nixos/services/game-servers/terraria.nix) | Dedicated Terraria Server (`:7777`) | Fleet Roadmap Phase 5 |
| [`nixos/services/game-servers/palworld.nix`](./nixos/services/game-servers/palworld.nix) | Dedicated Palworld Server (`:8211/udp`) | Fleet Roadmap Phase 5 |
| [`nixos/services/308-storage.nix`](./nixos/services/308-storage.nix) | USD 308 Systemd CIFS Share Automounts | 308 Project 18 |
| [`nixos/services/samba.nix`](./nixos/services/samba.nix) | Hardened SMB2/3 Client, GVfs & WSDD Discovery | Core Network Storage |
| [`nixos/services/ollama.nix`](./nixos/services/ollama.nix) | Ollama LLM Client Bound to `10.14.5.16:11434` | Local AI Stack |
| [`nixos/services/anythingllm.nix`](./nixos/services/anythingllm.nix) | AnythingLLM Local RAG Container | Local AI Stack |

---

## 6. Windows 11 & PDQ Automation Scripts (`modules/windows/scripts/`)

| Script | Purpose | Roadmap Mapping |
| :--- | :--- | :--- |
| [`windows/scripts/bootstrap.ps1`](./windows/scripts/bootstrap.ps1) | Windows 11 DSC & WinGet workstation bootstrapper | Windows Fleet |
| [`windows/scripts/Remove-AutodeskRemnants.ps1`](./windows/scripts/Remove-AutodeskRemnants.ps1) | Deep Autodesk Fusion/FeatureCAM registry & file remnant scrubber | 308 Project 14 |
| [`windows/scripts/Deploy-AutodeskFusionFeatureCAM.ps1`](./windows/scripts/Deploy-AutodeskFusionFeatureCAM.ps1) | Silent admin installer for Autodesk Fusion & isolated FeatureCAM ODIS | 308 Project 9 |
| [`windows/scripts/Deploy-UltraVNC.ps1`](./windows/scripts/Deploy-UltraVNC.ps1) | Silent PDQ deployment & service hardening for UltraVNC | 308 Project 10 |
| [`windows/scripts/Optimize-Win11Image.ps1`](./windows/scripts/Optimize-Win11Image.ps1) | Offline DISM Windows 11 `.wim` bloatware stripper & compressor | 308 Project 5 |
| [`windows/scripts/Test-PDQEmailPipeline.ps1`](./windows/scripts/Test-PDQEmailPipeline.ps1) | SMTP TLS notification relay validator for PDQ Deploy | 308 Project 16 |
