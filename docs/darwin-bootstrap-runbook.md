# macOS / nix-darwin Bootstrap Runbook (`docs/darwin-bootstrap-runbook.md`)

> **Target Hosts:** `308-225660` (Apple Silicon MacBook) and `MBA-Chambers` (MacBook Air)  
> **Flake Targets:** `darwinConfigurations."308-225660"` & `darwinConfigurations."MBA-Chambers"`  
> **Primary Script:** [`scripts/bootstrap-darwin.sh`](../scripts/bootstrap-darwin.sh)

---

## 1. Overview & Architecture

Bootstrapping `nix-darwin` transforms an out-of-the-box macOS installation into an atomically managed system. On macOS, `nix-darwin` handles:
1. **System Preferences:** Dock layout, Finder defaults, keyboard repeat rates, dark mode.
2. **LaunchDaemons & Services:** Native Apple Virtualization.framework Linux builder (`org.nixos.linux-builder`), Nix daemon settings.
3. **Shell Environment:** `/etc/zshrc`, `/etc/bashrc`, `/etc/shells`.
4. **Declarative Homebrew:** GUI macOS applications (Ghostty, VS Code, KeepassXC, VLC) via `nix-homebrew`.
5. **Home Manager:** Dotfiles, prompt (`starship`), terminal utilities.

---

## 2. Common First-Switch Blockers & Root Causes

During the initial bootstrap switch (`darwin-rebuild switch` or `nix run nix-darwin`), three common failure modes occur:

### Blocker 1: `/etc` Pre-Existing File Collisions
* **Symptom:**
  ```
  error: The following files would be overwritten by nix-darwin:
    /etc/bashrc
    /etc/zshrc
    /etc/nix/nix.conf
    /etc/pam.d/sudo_local
  ```
* **Cause:** Apple macOS ships with factory template files, and the official Nix daemon installer creates `/etc/nix/nix.conf`. `nix-darwin` refuses to overwrite non-symlinked files to avoid data loss.
* **Remedy:** Rename these existing files with a `.before-nix-darwin` suffix:
  ```bash
  for f in /etc/bashrc /etc/zshrc /etc/bash.bashrc /etc/nix/nix.conf /etc/pam.d/sudo_local; do
    [ -e "$f" ] && [ ! -L "$f" ] && sudo mv "$f" "${f}.before-nix-darwin"
  done
  ```

---

### Blocker 2: Disabled Experimental Features (`nix-command flakes`)
* **Symptom:**
  ```
  error: experimental Nix feature 'nix-command' is disabled; use '--extra-experimental-features nix-command' to override
  ```
* **Cause:** When `/etc/nix/nix.conf` is moved to `nix.conf.before-nix-darwin`, the global Nix daemon setting `experimental-features = nix-command flakes` is temporarily absent until `nix-darwin` writes its managed configuration.
* **Remedy:** 
  1. Export `NIX_CONFIG="experimental-features = nix-command flakes"` in your shell before running bootstrap commands.
  2. Pass `--extra-experimental-features "nix-command flakes"` to CLI invocations.
  3. Declarative Guardrail: Ensure [`hosts/darwin/308-225660/default.nix`](../hosts/darwin/308-225660/default.nix) asserts:
     ```nix
     nix.settings.experimental-features = [ "nix-command" "flakes" ];
     ```

---

### Blocker 3: `$HOME` Misattribution via `sudo`
* **Symptom:** Home Manager attempts to link dotfiles into `/var/root` instead of `/Users/jchambers`, or files receive root ownership.
* **Cause:** Executing `sudo nix run nix-darwin` or `sudo darwin-rebuild` evaluates the flake under root's profile and sets `$HOME=/var/root`.
* **Remedy:** Always execute `darwin-rebuild` or `nix run nix-darwin` as your **standard user** (`jchambers`). `darwin-rebuild` will automatically invoke `sudo` internally for system-level activation scripts (`/run/current-system/activate`).

---

## 3. Automated Bootstrap Execution

The repository provides [`scripts/bootstrap-darwin.sh`](../scripts/bootstrap-darwin.sh), which automates all preparation steps, validates permissions, backs up conflict files, and activates the configuration.

### Run on `308-225660`:
```bash
~/src/infra/scripts/bootstrap-darwin.sh 308-225660
```

### Run on `MBA-Chambers`:
```bash
~/src/infra/scripts/bootstrap-darwin.sh MBA-Chambers
```

---

## 4. Manual Step-by-Step Runbook (If Not Using Script)

If you prefer to perform the bootstrap manually without the wrapper script:

```bash
# 1. Enter the repository
cd ~/src/infra

# 2. Preserve experimental features for the current session
export NIX_CONFIG="experimental-features = nix-command flakes"

# 3. Safely back up conflicting /etc files
for f in /etc/bashrc /etc/zshrc /etc/bash.bashrc /etc/nix/nix.conf /etc/pam.d/sudo_local; do
  if [ -e "$f" ] && [ ! -L "$f" ]; then
    sudo mv "$f" "${f}.before-nix-darwin"
  fi
done

# 4. Trigger bootstrap activation as standard user (let nix-darwin prompt for sudo)
# If a pre-built result symlink exists:
./result/sw/bin/darwin-rebuild switch --flake .#308-225660

# Or using nix-darwin runner:
nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake .#308-225660
```

---

## 5. Post-Bootstrap Verification

Once the switch command completes successfully:

1. **Verify `darwin-rebuild` in PATH:**
   ```bash
   which darwin-rebuild
   # Expected: /run/current-system/sw/bin/darwin-rebuild
   ```

2. **Verify Universal `rebuild` Command:**
   ```bash
   rebuild
   ```

3. **Verify Apple Virtualization Linux Builder Daemon:**
   ```bash
   sudo launchctl list | grep linux-builder
   ```

4. **Verify Cross-Compilation (ARM64 & x86_64 Linux on Apple Silicon):**
   ```bash
   nix build --system aarch64-linux nixpkgs#hello --no-link
   nix build --system x86_64-linux nixpkgs#hello --no-link
   ```
