# Secrets Management Subsystem (`secrets/`)

This directory houses encrypted credentials, API tokens, passwords, and private parameters managed via **SOPS (Secrets OPerationS)** and **Age**.

---

## Security Philosophy

1. **Encrypted at Rest:** All YAML files inside this directory are cryptographically encrypted using Age public keys. They are safe to commit to version control.
2. **Volatile Decryption Only:** At system boot, `sops-nix` decrypts these files into an in-memory `tmpfs` RAM filesystem (`/run/secrets/`). **Plaintext secrets are never written to permanent disk storage.**
3. **No Plaintext Leaks:** Secret values are symlinked directly into services (e.g. SMB automount credentials in `modules/nixos/services/308-storage.nix`).

---

## Master Key Hierarchy & Storage

Decryption requires the private Age key matching the public key registered in `.sops.yaml`.

| Key Scope | Purpose | Private Key Location |
| :--- | :--- | :--- |
| **USD 308 Key** | Decrypts `308-secrets.yaml` (network share credentials, domain logins) | macOS: `~/.config/sops/age/keys.txt`<br>NixOS: `/var/lib/sops-nix/key.txt` |
| **Personal Key** | Decrypts `personal-secrets.yaml` (homelab, private tokens) | `~/.config/sops/age/keys.txt` |

> [!CRITICAL]
> **Disaster Recovery Backup:**
> The Age private keys located in `/var/lib/sops-nix/key.txt` and `~/.config/sops/age/keys.txt` must be backed up securely offline (e.g. in 1Password or an encrypted USB drive). If these private keys are lost, the encrypted secrets files cannot be recovered.

---

## How to Edit or Add Secrets

To view or edit secrets, ensure you have your Age private key in place and use the `sops` CLI tool:

### 1. Editing an Existing Secret File
```bash
sops secrets/308-secrets.yaml
```
SOPS will open your `$EDITOR` (Neovim/Vim). Edit the plaintext values, save, and exit. SOPS automatically re-encrypts the file before saving to disk.

### 2. Creating a New Encrypted File
1. Ensure the new file path matches the regex in `.sops.yaml` (e.g., `secrets/308-*.yaml`).
2. Run:
```bash
sops secrets/308-newsecret.yaml
```
3. SOPS will encrypt the file using the appropriate public keys defined in the rules.

---

## Re-Keying Secrets (If Keys Are Rotated)

If a host or user key is added or rotated in `.sops.yaml`:
```bash
sops updatekeys secrets/308-secrets.yaml
```
This re-encrypts the file in-place with the updated key recipients without altering the underlying secret values.
