# Universal Environment Keybinding Pattern (`docs/keybindings.md`)

> **Roadmap Reference:** Personal Project 7 — *Clean up Ghostty and Zellij files to implement a Universal Environment Keybinding Pattern.*

To eliminate modifier key collisions when working inside nested layers (**Wayland Compositor $\rightarrow$ Ghostty Terminal $\rightarrow$ Zellij Multiplexer $\rightarrow$ Neovim**), each layer owns a dedicated modifier namespace while sharing identical directional (`H`/`J`/`K`/`L`) ergonomics.

---

## 🧭 Modifier Namespace Hierarchy

| Environment Layer | Dedicated Modifier | Directional Focus | Split / Spawn | Close Active |
| :--- | :--- | :--- | :--- | :--- |
| **1. Wayland Compositor**<br>([`hyprland.nix`](../modules/nixos/desktop/hyprland.nix), [`niri.nix`](../modules/nixos/desktop/niri.nix), [`sway.nix`](../modules/nixos/desktop/sway.nix)) | **`Super` (`Mod4`)** | `Super + H/J/K/L` | `Super + Q` (Ghostty)<br>`Super + E` (Firefox)<br>`Super + R` (Rofi) | `Super + C` |
| **2. Terminal Multiplexer**<br>([`zellij.nix`](../modules/shared/zellij.nix)) | **`Alt`** | `Alt + H/J/K/L` | `Alt + N` (New Pane)<br>`Alt + D` (Split Right)<br>`Alt + S` (Split Down)<br>`Alt + T` (New Tab) | `Alt + X` |
| **3. Terminal Emulator**<br>([`ghostty.nix`](../modules/shared/ghostty.nix)) | **`Ctrl + Shift`** | `Ctrl + Shift + H/J/K/L` | `Ctrl + Shift + D` (Right)<br>`Ctrl + Shift + S` (Down)<br>`Ctrl + Shift + T` (Tab) | `Ctrl + Shift + X` |
| **4. Editor (Kate / Neovim)**<br>([`kate.nix`](../modules/nixos/apps/kate.nix), [`neovim.nix`](../modules/shared/neovim.nix)) | **Normal Mode / `Ctrl+Alt`** | `h/j/k/l` | `Ctrl + Alt + N` (Kate Nix Snippets) | `:q` / `Ctrl + W` |

---

## ⌨️ Apple Keyboard Hardware Adjustments ([`apple-keyboard.nix`](../modules/nixos/hardware/apple-keyboard.nix))

- **Top-Row Function Keys (Project 8):** `hid_apple fnmode=2` is enforced at the kernel module level so `F1`–`F12` emit standard function key scancodes without needing to hold `Fn`.
- **Numeric Keypad (Project 6):** NumLock is automatically activated across TTY1–TTY6 (`setleds -D +num`), SDDM, and Wayland compositors (`numlock_by_default = true`) at boot.
