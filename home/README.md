# User Environment Subsystem (`home/`)

This directory contains user-space configuration managed by **Home Manager**. In our multi-OS architecture, `home/` represents the **"Soul"**—the developer environment, interactive shell, prompt, and muscle memory that follows the user (`jchambers`) to every machine in the fleet.

---

## Directory Layout

```
home/
├── default.nix                 # Unified user profile entry point
└── programs/                   # Modular program configurations
    ├── zsh.nix                 # Interactive Zsh shell, fzf, zoxide, rebuild()
    └── starship.nix            # Cross-shell prompt (Catppuccin Mocha theme)
```

---

## How Home Manager Integrates into the Fleet

In `flake.nix`, both the NixOS builder (`mkNixos`) and the macOS builder (`mkDarwin`) automatically bind this directory to the primary user:

```nix
home-manager.users.jchambers = import ./home;
```

### Dynamic Home Directory Resolution
Because macOS and Linux use different filesystem conventions for home directories, `home/default.nix` dynamically evaluates the correct path at build time:

```nix
homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/jchambers" else "/home/jchambers";
```

This guarantees that all dotfiles (`~/.config/`, shell configs, prompt configurations) are linked to the correct location regardless of whether you are sitting at a MacBook, a Linux workstation, or an SSH session into a VM.

---

## Daily Workflow & Tooling

### 1. The Multi-OS Rebuild Command
Defined in `home/programs/zsh.nix`, the `rebuild` command automatically detects the host platform:
* On macOS $\rightarrow$ executes `sudo darwin-rebuild switch --flake ~/src/infra#<hostname>`
* On Linux $\rightarrow$ executes `sudo nixos-rebuild switch --flake ~/src/infra#<hostname>`

### 2. Interactive Navigation Tools
* **`z <keyword>`**: Teleports to any directory based on frecency (frequency + recency).
* **`zi`**: Interactive fuzzy directory picker via `fzf`.
* **`Ctrl + R`**: Fuzzy search over 50,000 commands in shared history.
* **`Ctrl + T`**: Interactive file finder that inserts selected paths at the cursor.
* **`Option + C`**: Directory jumper that `cd`s into the chosen folder.

---

## Adding New User Programs

To declare a new tool or dotfile for `jchambers`:
1. Create a module in `home/programs/mytool.nix`:
   ```nix
   { config, pkgs, ... }:
   {
     programs.mytool = {
       enable = true;
       # tool-specific options here
     };
   }
   ```
2. Import it into `home/default.nix`:
   ```nix
   imports = [
     ./programs/zsh.nix
     ./programs/starship.nix
     ./programs/mytool.nix
   ];
   ```
3. Run `rebuild` to activate it across your machines.
