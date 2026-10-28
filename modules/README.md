# Fleet Modules Library (`modules/`)

This directory contains the modular building blocks (the **"Organs"**) of the fleet. Rather than duplicating configurations across individual machines, features are declared as reusable modules and imported by hosts as needed.

---

## Module Hierarchy & Purpose

```
modules/
├── common/             # Universal foundations (imported everywhere)
│   ├── cachix.nix      # Community binary cache substitutes (speeds up builds)
│   ├── fonts.nix       # Nerd fonts & typographic glyphs
│   └── sops-tools.nix  # Age & SOPS command line utilities
├── shared/             # Multi-OS user/developer tools (cross-platform contract)
│   ├── ghostty.nix     # Ghostty GPU terminal emulator & shared theme
│   ├── git.nix         # Global Git configuration & Markdown LSP (marksman)
│   ├── neovim.nix      # Neovim development editor + Treesitter build dependencies
│   ├── vim.nix         # Lightweight fallback Vim editor & transparency fix
│   └── zellij.nix      # Zellij terminal multiplexer
├── nixos/              # Linux & NixOS specific system modules
│   ├── apps/           # Desktop GUI applications (Firefox, Remmina, Kate, etc.)
│   ├── core/           # Operating system core (boot, audio, printing, network)
│   ├── desktop/        # Display managers & Wayland compositors (Hyprland, Niri, Sway)
│   ├── hardware/       # Disko declarative disk partitions & hw utilities
│   └── services/       # Daemons, CIFS automounts (308-storage), and Samba
├── darwin/             # macOS / nix-darwin specific modules
└── windows/            # Windows 11 configuration layer (WinGet & PowerShell DSC)
```

---

## Architectural Rules for Successors

### Rule 1: The "Shared" Module Contract (`modules/shared/`)
* Any module placed inside `modules/shared/` **must be portable across both macOS and Linux**.
* Never assume a system-level NixOS option (like `programs.git` or `programs.neovim`) exists when evaluated under `nix-darwin`.
* **Standard Pattern:**
  ```nix
  { pkgs, lib, options, ... }:
  {
    config = lib.mkMerge [
      {
        environment.systemPackages = [ pkgs.myTool ];
      }
      (lib.optionalAttrs (options ? programs && options.programs ? myTool) {
        programs.myTool = { enable = true; };
      })
    ];
  }
  ```

### Rule 2: System vs. User Boundaries
* **System Modules (`modules/`):** Handle root-level concerns: daemons, launchd/systemd services, hardware drivers, network firewalls, and system-wide packages.
* **User Modules (`home/`):** Handle user-space configurations: shell prompts, aliases, history retention, application dotfiles, and editor extensions.

### Rule 3: Secrets Decryption Contract
* Plaintext passwords or credentials must **never** be placed inside this directory.
* If a module needs credentials (e.g. `308-storage.nix` mounting CIFS network shares), reference the decrypted SOPS path in `/run/secrets/` managed by `sops-nix`.
