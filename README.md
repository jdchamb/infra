# Declarative Multi-OS Fleet Infrastructure

Multi-platform declarative configuration repository managing **NixOS** (Linux workstations and custom ISOs), **nix-darwin** (macOS laptops), and **Windows** (WinGet DSC & PowerShell DSC).

---

## Architecture Overview

```
.
├── flake.nix                       # Thin entry point orchestrating all Nix builds
├── flake.lock                      # Locked dependency revisions
├── secrets/                        # Encrypted secret files managed via sops-nix & age
│   ├── 308-secrets.yaml
│   └── personal-secrets.yaml
├── hosts/
│   ├── nixos/                      # NixOS system host declarations
│   │   ├── wrk-dt01/               # Work workstation (x86_64-linux)
│   │   ├── vm-mac-utm01/           # Apple Silicon UTM VM (aarch64-linux)
│   │   └── installer/              # Deployment ISOs (bootstrap-iso, recovery-iso)
│   ├── darwin/                     # nix-darwin system host declarations
│   │   └── 308-225660/             # Apple Silicon MacBook (aarch64-darwin)
│   └── windows/                    # Windows system target configurations
│       └── wrk-win01/              # Workstation target profiles
├── modules/
│   ├── common/                     # Cross-platform fonts, Cachix, sops tools
│   ├── shared/                     # Cross-platform user tools (git, vim, neovim, zellij, ghostty)
│   ├── nixos/                      # Linux/NixOS specific options
│   │   ├── core/                   # Audio, boot, network, printing, system, user, sops
│   │   ├── desktop/                # Greetd, Hyprland, Niri, Sway
│   │   ├── hardware/               # Disko layouts, hardware inspection utilities
│   │   ├── services/               # CIFS mounts (308-storage), Samba, Ollama, AnythingLLM
│   │   └── apps/                   # Standalone desktop apps (Firefox, Kate, Dolphin, etc.)
│   ├── darwin/                     # macOS-specific modules (dock, finder, brew)
│   └── windows/                    # Windows declarative configuration layer
│       ├── winget/                 # WinGet DSC YAML manifests
│       ├── dsc/                    # PowerShell Desired State Configuration scripts
│       ├── registry/               # Declarative registry tweaks
│       └── scripts/                # Bootstrap runner scripts
└── home/                           # User-space configuration (Home Manager)
    ├── default.nix                 # Unified user profile entry point
    └── programs/                   # Modular dotfiles (Zsh, Starship, etc.)
```

---

## Deployment Quickstart

### NixOS (wrk-dt01)
```bash
sudo nixos-rebuild switch --flake .#wrk-dt01
```

### macOS / nix-darwin (308-225660)
```bash
sudo darwin-rebuild switch --flake .#308-225660
```

### NixOS Bootstrapping Media
```bash
# Minimal bootstrap console image
nix build .#nixosConfigurations.bootstrap-iso.config.system.build.isoImage

# Full graphical recovery image
nix build .#nixosConfigurations.recovery-iso.config.system.build.isoImage
```

### Windows (wrk-win01)
Open PowerShell as Administrator:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
.\modules\windows\scripts\bootstrap.ps1
```
