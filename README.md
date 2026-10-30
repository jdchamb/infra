# Declarative Multi-OS Fleet Infrastructure

A unified, declarative fleet repository orchestrating **NixOS** (production workstations, Apple Silicon VMs, and deployment ISOs), **nix-darwin** (Apple Silicon MacBooks), and **Windows** (PowerShell DSC & WinGet).

---

## 1. Fleet Roster & Machine Topology

| Hostname | Platform / Architecture | Operating System | Primary Purpose & Hardware | Rebuild Command |
| :--- | :--- | :--- | :--- | :--- |
| **`308-225660`** | `aarch64-darwin` | macOS 27.0.1+ | Primary Work Apple Silicon MacBook. Native GUI, Apple VZ Linux Builder. | `rebuild` |
| **`308-222242`** | `x86_64-linux` | NixOS Unstable | Production Bare-Metal Linux Workstation (Intel Core, Wayland/KDE desktop, CIFS shares, self-hosted fleet services). | `rebuild` |
| **`308-225660NixOSVM`** | `aarch64-linux` | NixOS Unstable | Paravirtualized Linux Guest on MacBook (Apple Virtualization / UTM, VirtIO, SSH). | `rebuild` |
| **`lab-pb01` .. `lab-pb05`** | `x86_64-linux` | NixOS Unstable | 5x HP ProBook Test Fleet Laptops (Parameterized via `hosts/nixos/lab-probook/default.nix`). | `rebuild switch lab-pb01` |
| **`bootstrap-iso`** | `x86_64-linux` | NixOS Live | Minimal headless console deployment ISO for bare-metal fleet provisioning. | *(Build ISO)* |
| **`recovery-iso`** | `x86_64-linux` | NixOS Live | Graphical live USB recovery environment with disk repair & diagnostic tools. | *(Build ISO)* |
| **`wrk-win01`** | `x86_64-windows` | Windows 11 | Windows target environment managed via WinGet DSC and PowerShell DSC. | *(Bootstrap script)* |

---

## 2. Directory Architecture & Map

```
.
├── flake.nix                       # Fleet blueprint orchestrating all Nix configurations
├── flake.lock                      # Cryptographically pinned dependency hashes
├── secrets/                        # Encrypted secret files managed via sops-nix & age
│   ├── 308-secrets.yaml            # USD 308 infrastructure credentials (SMB passwords, keys)
│   └── personal-secrets.yaml       # Personal / homelab credentials
├── hosts/                          # Host identity declarations (The "Body")
│   ├── darwin/
│   │   └── 308-225660/             # Apple Silicon MacBook (nix-darwin defaults & Homebrew)
│   ├── nixos/
│   │   ├── 308-222242/             # Production Linux Workstation (hardware & module graph)
│   │   ├── 308-225660NixOSVM/      # Apple Silicon UTM / VZ Paravirtualized VM
│   │   ├── lab-probook/            # Parameterized HP ProBook test fleet (lab-pb01..05)
│   │   └── installer/              # Deployment ISOs (bootstrap-iso, recovery-iso)
│   └── windows/
│       └── wrk-win01/              # Windows workstation target profiles
├── modules/                        # Reusable 1-to-1 system building blocks (The "Organs")
│   ├── common/                     # Cross-platform fonts, Cachix, sops tools
│   ├── shared/                     # Multi-OS 1-to-1 tooling (git, git-bug, tea, lazygit, vim, neovim, zellij, ghostty)
│   │   ├── security/               # GPG, KeePassXC, Vaultwarden CLI
│   │   ├── remote/                 # RustDesk remote desktop
│   │   └── storage/                # File Integrity Monitor (FIM)
│   ├── nixos/                      # Linux/NixOS specific 1-to-1 modules
│   │   ├── core/                   # Global aggregator, bootstrap, impermanence, audio, boot, network, printing, system, user, sops, deploy-rs, colmena, nixos-anywhere
│   │   ├── desktop/                # Greetd, Hyprland, Niri, Sway, KDE Plasma 6, Krohnkite
│   │   ├── hardware/               # Disko layouts (standard, btrfs, impermanence), Apple keyboard, HP ProBook, hw-utils
│   │   ├── services/               # 1-to-1 self-hosted fleet services (Vaultwarden, Snipe-IT, Zammad, Forgejo, Harmonia, AdGuard, NUT, Nextcloud, Paperless, etc.)
│   │   │   └── game-servers/       # Pelican Panel, Minecraft, Terraria, Palworld
│   │   └── apps/                   # 1-to-1 standalone desktop & diagnostic apps (Dolphin, Kate, KRDC, TigerVNC, VLC, Wireshark, Minicom, Dymo, ADB, etc.)
│   ├── darwin/                     # macOS-specific modules (dock, finder, brew)
│   └── windows/                    # Windows declarative configuration layer
│       ├── winget/                 # WinGet DSC YAML manifests
│       ├── dsc/                    # PowerShell Desired State Configuration scripts
│       ├── registry/               # Declarative registry tweaks
│       └── scripts/                # Bootstrap & deployment scripts (Autodesk, UltraVNC, Win11 image, PDQ)
└── home/                           # User-space configuration via Home Manager (The "Soul")
    ├── default.nix                 # Unified user profile entry point ('jchambers')
    └── programs/
        ├── zsh.nix                 # Interactive shell, 50k history, fzf, zoxide, rebuild()
        ├── starship.nix            # Cross-shell prompt (Catppuccin Mocha theme)
        └── git-sync.nix            # Zsh chpwd hook for interactive git pull --rebase
```

### Subsystem Documentation Guides
For detailed operational runbooks and architectural specifications of each subsystem, refer to:
* **[Hosts Subsystem Guide (`hosts/README.md`)](hosts/README.md):** Host roster, machine hardware profiles, and step-by-step instructions to register a new machine.
* **[Modules Library Guide (`modules/README.md`)](modules/README.md):** Reusable module taxonomy, cross-platform shared contracts, and system vs. user boundaries.
* **[User Environment Guide (`home/README.md`)](home/README.md):** Home Manager user-space configuration, dynamic path resolution, and dotfile deployment.
* **[Secrets Management Guide (`secrets/README.md`)](secrets/README.md):** SOPS + Age security model, master key locations, secret editing, and disaster recovery.
* **[Engineering Documentation Index (`docs/README.md`)](docs/README.md):** USD 308 project milestones, historical logs, and learning journals.

---

## 3. Daily Operations & Successor Runbook

### The Universal Rebuild Command
Every machine running this repository has a smart shell function called `rebuild` (aliased to `update`):

```bash
# Apply changes on whatever machine you are currently sitting at:
rebuild

# Test changes without making them the default boot generation:
rebuild test

# Rebuild and switch a specific remote or target node explicitly:
rebuild switch 308-222242
```

### Day-to-Day Navigation Shortcuts
* **`z <keyword>`**: Teleports directly to any visited folder (e.g. `z infra` or `z 308`).
* **`zi`**: Interactive fuzzy directory picker powered by `fzf`.
* **`Ctrl + R`**: Interactive fuzzy search across 50,000 command history entries.
* **`Ctrl + T`**: Interactive fuzzy file finder (inserts selected path directly into your cursor).
* **`Option + C`** *(or `Alt+C`)*: Fuzzy directory navigator (immediately `cd`s into the selected folder).

---

## 4. Disaster Recovery & Bare-Metal Provisioning

### A. Generating Deployment Live ISOs
To produce bootable installation media on any machine with Nix installed:

```bash
# 1. Build the minimal console deployment ISO:
nix build .#nixosConfigurations.bootstrap-iso.config.system.build.isoImage

# 2. Build the graphical recovery ISO:
nix build .#nixosConfigurations.recovery-iso.config.system.build.isoImage

# The resulting bootable .iso will be symlinked at ./result/iso/
```

### B. Bootstrapping a New NixOS Node with Disko
1. Boot the target machine using `bootstrap-iso` or `recovery-iso`.
2. Connect to the machine via SSH (it automatically advertises port 22).
3. Run the automated Disko partitioner and installer:
```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode zap_create_mount ./modules/nixos/hardware/disko-standard.nix

sudo nixos-install --flake .#308-222242
```

### C. Bootstrapping a New macOS MacBook (`nix-darwin`)
1. Install Nix using the official multi-user installer.
2. Clone this repository into `~/src/infra`.
3. Run the one-time initial switch:
```bash
cd ~/src/infra
nix run nix-darwin -- switch --flake .#308-225660
```

---

## 5. Secrets Management & Decryption (SOPS + Age)

Secrets are encrypted at rest inside the repository (`secrets/*.yaml`) and decrypted on-the-fly at boot:

* **Encryption Tooling:** Managed via `sops` and `age`.
* **Rules Configuration:** Defined in `.sops.yaml`.
* **Master Age Key Location:**
  * macOS: `~/.config/sops/age/keys.txt`
  * NixOS: `/var/lib/sops-nix/key.txt`
* **Volatile Decryption:** During system activation, `sops-nix` decrypts secrets straight into an in-memory `tmpfs` RAM filesystem at `/run/secrets/`, ensuring plaintext credentials are never written to permanent disk storage.
* **Editing Secrets:**
```bash
sops secrets/308-secrets.yaml
```

---

## 6. Windows Fleet Configuration (`wrk-win01`)

For Windows nodes, declarative configuration is applied using WinGet DSC and PowerShell Desired State Configuration:

1. Open PowerShell as Administrator on the target Windows node.
2. Execute the bootstrap script:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
.\modules\windows\scripts\bootstrap.ps1
```
