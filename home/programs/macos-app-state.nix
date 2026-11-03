# ==============================================================================
# USER PROGRAM: home/programs/macos-app-state.nix (macOS SOPS File & SSH Sync)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Provides automatic, popup-free synchronization between local macOS
#   POSIX state files (SSH identities, exported Windows App .rdp profiles,
#   Cyberduck bookmarks, and TigerVNC profiles) and the Git-tracked SOPS vault
#   ('secrets/work.yaml').
#
#   IMPORTANT MACOS DESIGN BOUNDARY:
#   This module intentionally DOES NOT invoke '/usr/bin/security' to mutate
#   'login.keychain-db' or read TCC-protected '~/Library/Containers/' sandboxes,
#   avoiding all macOS Keychain ACL and TCC modal password prompts.
# ==============================================================================

{ config, pkgs, lib, ... }:

let
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.pyyaml ]);

  macosStateSyncScript = pkgs.writeScriptBin "macos-state-sync" ''
    #!${pythonEnv}/bin/python3
    import base64
    import glob
    import hashlib
    import io
    import json
    import os
    import subprocess
    import sys
    import tarfile
    import yaml

    EXTRA_PATH = "${lib.makeBinPath [ pkgs.sops pkgs.age pkgs.zstd pkgs.coreutils ]}:/usr/bin:/bin:/usr/sbin:/sbin"
    os.environ["PATH"] = EXTRA_PATH + ":" + os.environ.get("PATH", "")

    HOME = os.path.expanduser("~")
    AGE_KEY_FILE = os.environ.get("SOPS_AGE_KEY_FILE", os.path.join(HOME, ".config/sops/age/keys.txt"))
    os.environ["SOPS_AGE_KEY_FILE"] = AGE_KEY_FILE

    WINDOWS_APP_RDP_DIR = os.path.join(HOME, "Documents/Windows App")
    CYBERDUCK_DIRS = [
        os.path.join(HOME, "Library/Group Containers/G69SCX94XU.duck/Library/Application Support/duck/Bookmarks"),
        os.path.join(HOME, "Library/Application Support/Cyberduck/Bookmarks"),
    ]
    TIGERVNC_DIR = os.path.join(HOME, ".vnc")

    SSH_KEYS = [
        {
            "name": "codeberg",
            "label": "Codeberg Git SSH Key (id_ed25519_codeberg)",
            "priv_path": os.path.join(HOME, ".ssh/id_ed25519_codeberg"),
            "pub_path": os.path.join(HOME, ".ssh/id_ed25519_codeberg.pub"),
            "sops_priv": "ssh-codeberg-private-key",
            "sops_pub": "ssh-codeberg-public-key",
        },
        {
            "name": "nixvm",
            "label": "NixVM SSH Key (id_ed25519_nixvm)",
            "priv_path": os.path.join(HOME, ".ssh/id_ed25519_nixvm"),
            "pub_path": os.path.join(HOME, ".ssh/id_ed25519_nixvm.pub"),
            "sops_priv": "ssh-nixvm-private-key",
            "sops_pub": "ssh-nixvm-public-key",
        },
    ]


    def banner(title: str) -> None:
        print("==================================================================", flush=True)
        print(f"  {title}", flush=True)
        print("==================================================================", flush=True)


    def info(section: str, msg: str) -> None:
        print(f"  -> [{section}] {msg}", flush=True)


    def detail(msg: str) -> None:
        print(f"     {msg}", flush=True)


    def decrypt_sops_yaml(yaml_path: str) -> dict:
        if not os.path.exists(yaml_path):
            return {}
        res = subprocess.run(["sops", "-d", yaml_path], capture_output=True, text=True)
        if res.returncode != 0:
            return {}
        data = yaml.safe_load(res.stdout)
        return data if isinstance(data, dict) else {}


    def sops_set_key(yaml_path: str, key: str, value: str) -> bool:
        payload = f'["{key}"] {json.dumps(value)}'
        res = subprocess.run(["sops", "--set", payload, yaml_path], capture_output=True, text=True)
        return res.returncode == 0


    def zstd_compress_b64(raw_bytes: bytes) -> str:
        res = subprocess.run(["zstd", "-q", "-19", "-c"], input=raw_bytes, capture_output=True, check=True)
        return base64.b64encode(res.stdout).decode("ascii")


    def zstd_decompress_b64(b64_str: str) -> bytes:
        compressed = base64.b64decode(b64_str.encode("ascii"))
        res = subprocess.run(["zstd", "-q", "-d", "-c"], input=compressed, capture_output=True, check=True)
        return res.stdout


    def archive_directory_files(base_dir: str, patterns: list) -> tuple:
        if not base_dir or not os.path.isdir(base_dir):
            return (0, "", 0, "")
        matched = []
        for pat in patterns:
            matched.extend(glob.glob(os.path.join(base_dir, pat)))
        matched = sorted(set([p for p in matched if os.path.isfile(p)]))
        if not matched:
            return (0, "", 0, "")

        hasher = hashlib.sha256()
        max_mtime = 0
        tar_buf = io.BytesIO()
        with tarfile.open(fileobj=tar_buf, mode="w") as tf:
            for fpath in matched:
                rel = os.path.relpath(fpath, base_dir)
                st = os.stat(fpath)
                max_mtime = max(max_mtime, int(st.st_mtime))
                with open(fpath, "rb") as f:
                    data = f.read()
                hasher.update(rel.encode("utf-8"))
                hasher.update(data)
                ti = tarfile.TarInfo(name=rel)
                ti.size = len(data)
                ti.mode = 0o600
                ti.mtime = 0
                tf.addfile(ti, io.BytesIO(data))

        return (len(matched), hasher.hexdigest(), max_mtime, zstd_compress_b64(tar_buf.getvalue()))


    def extract_directory_archive(base_dir: str, b64_payload: str) -> int:
        raw_tar = zstd_decompress_b64(b64_payload)
        os.makedirs(base_dir, exist_ok=True)
        count = 0
        with tarfile.open(fileobj=io.BytesIO(raw_tar), mode="r") as tf:
            for member in tf.getmembers():
                if not member.isfile() or ".." in member.name or member.name.startswith("/"):
                    continue
                dest = os.path.join(base_dir, member.name)
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                extracted = tf.extractfile(member)
                if extracted is not None:
                    with open(dest, "wb") as out_f:
                        out_f.write(extracted.read())
                    os.chmod(dest, 0o600)
                    count += 1
        return count


    def pre_rebuild(flake_dir: str) -> int:
        banner("[1/3] PRE-REBUILD: Syncing Local SSH Keys & Profiles -> SOPS")
        work_yaml = os.path.join(flake_dir, "secrets/work.yaml")
        if not os.path.exists(AGE_KEY_FILE):
            return 0
        vault = decrypt_sops_yaml(work_yaml)
        if not vault:
            return 0

        for k in SSH_KEYS:
            info("SSH Keys", f"Checking {k['label']}...")
            if os.path.exists(k["priv_path"]):
                with open(k["priv_path"], "r", encoding="utf-8") as f:
                    local_priv = f.read()
                if local_priv != vault.get(k["sops_priv"], ""):
                    detail(f"[SYNC] Saving {os.path.basename(k['priv_path'])} into secrets/work.yaml...")
                    sops_set_key(work_yaml, k["sops_priv"], local_priv)
                else:
                    detail(f"[OK] {os.path.basename(k['priv_path'])} matches SOPS vault.")
            if os.path.exists(k["pub_path"]):
                with open(k["pub_path"], "r", encoding="utf-8") as f:
                    local_pub = f.read()
                if local_pub != vault.get(k["sops_pub"], ""):
                    sops_set_key(work_yaml, k["sops_pub"], local_pub)

        for label, base_dir, pats, prefix in [
            ("Windows App .rdp", WINDOWS_APP_RDP_DIR, ["*.rdp"], "windows-app-rdp"),
            ("Cyberduck", next((d for d in CYBERDUCK_DIRS if os.path.isdir(d)), CYBERDUCK_DIRS[0]), ["*.duck"], "cyberduck-bookmarks"),
            ("TigerVNC", TIGERVNC_DIR, ["*.tigervnc", "*.vnc"], "tigervnc-profiles"),
        ]:
            count, sha, mtime, b64 = archive_directory_files(base_dir, pats)
            if count > 0:
                info(label, f"Found {count} profile(s) in {base_dir}.")
                if sha != str(vault.get(f"{prefix}-sha256", "")) and mtime >= int(vault.get(f"{prefix}-updated-at", 0) or 0):
                    detail(f"[SYNC] Saving {label} profiles into secrets/work.yaml...")
                    sops_set_key(work_yaml, f"{prefix}-tar-zstd-b64", b64)
                    sops_set_key(work_yaml, f"{prefix}-sha256", sha)
                    sops_set_key(work_yaml, f"{prefix}-updated-at", str(mtime))
        return 0


    def post_rebuild(flake_dir: str, force: bool = False) -> int:
        banner("[3/3] POST-REBUILD: Verifying Restored SSH Keys & Profiles")
        work_yaml = os.path.join(flake_dir, "secrets/work.yaml")
        if not os.path.exists(AGE_KEY_FILE):
            return 0
        vault = decrypt_sops_yaml(work_yaml)
        if not vault:
            return 0

        os.makedirs(os.path.join(HOME, ".ssh"), mode=0o700, exist_ok=True)
        for k in SSH_KEYS:
            vault_priv = vault.get(k["sops_priv"], "")
            vault_pub = vault.get(k["sops_pub"], "")
            if vault_priv and (force or not os.path.exists(k["priv_path"])):
                with open(k["priv_path"], "w", encoding="utf-8") as f:
                    f.write(vault_priv if vault_priv.endswith("\n") else vault_priv + "\n")
                os.chmod(k["priv_path"], 0o600)
                info("SSH Keys", f"[RESTORE] Restored {k['priv_path']} (mode 0600) from SOPS.")
            else:
                info("SSH Keys", f"[OK] {k['priv_path']} verified in place.")
            if vault_pub and (force or not os.path.exists(k["pub_path"])):
                with open(k["pub_path"], "w", encoding="utf-8") as f:
                    f.write(vault_pub if vault_pub.endswith("\n") else vault_pub + "\n")
                os.chmod(k["pub_path"], 0o644)

        for label, base_dir, pats, prefix in [
            ("Windows App .rdp", WINDOWS_APP_RDP_DIR, ["*.rdp"], "windows-app-rdp"),
            ("Cyberduck", next((d for d in CYBERDUCK_DIRS if os.path.isdir(d)), CYBERDUCK_DIRS[0]), ["*.duck"], "cyberduck-bookmarks"),
            ("TigerVNC", TIGERVNC_DIR, ["*.tigervnc", "*.vnc"], "tigervnc-profiles"),
        ]:
            b64 = vault.get(f"{prefix}-tar-zstd-b64", "")
            if b64:
                count, sha, mtime, _ = archive_directory_files(base_dir, pats)
                vault_sha = str(vault.get(f"{prefix}-sha256", ""))
                vault_mtime = int(vault.get(f"{prefix}-updated-at", 0) or 0)
                if force or count == 0 or (sha != vault_sha and vault_mtime > mtime):
                    n = extract_directory_archive(base_dir, b64)
                    info(label, f"[RESTORE] Restored {n} profile(s) to {base_dir}.")
        return 0


    def main() -> int:
        mode = sys.argv[1] if len(sys.argv) > 1 else "status"
        flake_dir = sys.argv[2] if len(sys.argv) > 2 and not sys.argv[2].startswith("-") else os.path.join(HOME, "src/infra")
        if mode in ("pre-rebuild", "backup"):
            return pre_rebuild(flake_dir)
        elif mode in ("post-rebuild", "restore"):
            return post_rebuild(flake_dir, force="--force" in sys.argv)
        return 0


    if __name__ == "__main__":
        sys.exit(main())
  '';
in
{
  config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    home.packages = [
      macosStateSyncScript
    ];
  };
}
