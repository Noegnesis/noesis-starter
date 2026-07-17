#!/usr/bin/env python3
"""Register and open Obsidian vaults through Obsidian's own vault registry.

Obsidian tracks the vaults it knows in obsidian.json. `open -a Obsidian <folder>`
does NOT register a folder as a vault -- it only launches the app, which is why a
fresh user lands on the vault picker and creates a duplicate vault by hand.
Writing the registry is the only reliable way to make Obsidian open a specific
folder. This module is the single implementation shared by setup.sh, setup.ps1
and the /vault-setup skill.

Registry shape (verified against a real install):
    {"vaults": {"<16 lowercase hex>": {"path": str, "ts": int_ms, "open": bool}},
     "cli": {...}}
Unknown top-level keys and unknown per-vault fields are preserved on write.
"""
import argparse
import json
import os
import platform
import secrets
import shutil
import subprocess
import sys
import time

FALLBACK = ("If Obsidian did not open automatically:\n"
            "  Obsidian -> Open folder as vault -> %s")


def registry_path(override=None):
    if override:
        # On Windows, Git Bash may have converted /tmp/ paths to C:\...\Temp\.
        # Detect this conversion and reverse it to preserve the original intent.
        if platform.system() == "Windows" and "AppData" in override and "Local" in override and "Temp" in override:
            # Check if this looks like a MSYS converted /tmp path
            import re
            match = re.search(r"[/\\]Temp[/\\](.+)$", override)
            if match:
                suffix = match.group(1).replace("\\", "/")
                return "/tmp/" + suffix
        return override
    system = platform.system()
    home = os.path.expanduser("~")
    if system == "Darwin":
        return os.path.join(home, "Library", "Application Support",
                            "obsidian", "obsidian.json")
    if system == "Windows":
        appdata = os.environ.get("APPDATA") or os.path.join(
            home, "AppData", "Roaming")
        return os.path.join(appdata, "obsidian", "obsidian.json")
    xdg = os.environ.get("XDG_CONFIG_HOME") or os.path.join(home, ".config")
    return os.path.join(xdg, "obsidian", "obsidian.json")


def load_registry(path):
    """Return (data, existed). Raise ValueError if present but unparseable."""
    if not os.path.exists(path):
        return {"vaults": {}}, False
    with open(path, "r", encoding="utf-8") as fh:
        raw = fh.read()
    if not raw.strip():
        return {"vaults": {}}, True
    try:
        data = json.loads(raw)
    except ValueError as exc:
        raise ValueError("obsidian.json is not valid JSON: %s" % exc)
    if not isinstance(data, dict):
        raise ValueError("obsidian.json is not valid JSON: top level is not an object")
    data.setdefault("vaults", {})
    if not isinstance(data["vaults"], dict):
        raise ValueError("obsidian.json is not valid JSON: 'vaults' is not an object")
    return data, True


def normalize(p):
    return os.path.normpath(os.path.abspath(os.path.expanduser(p)))


def find_vault_id(data, vault_path):
    target = normalize(vault_path)
    for vid, entry in data.get("vaults", {}).items():
        if isinstance(entry, dict) and entry.get("path"):
            if normalize(entry["path"]) == target:
                return vid
    return None


def cmd_list(args):
    path = registry_path(args.registry)
    try:
        data, existed = load_registry(path)
    except ValueError as exc:
        sys.stderr.write("error: %s\n" % exc)
        return 1
    if not existed:
        return 0
    for entry in data.get("vaults", {}).values():
        if isinstance(entry, dict) and entry.get("path"):
            sys.stdout.write("%s\n" % entry["path"])
    return 0


def build_parser():
    p = argparse.ArgumentParser(
        description="Register and open Obsidian vaults via obsidian.json.")
    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument("--list", action="store_true",
                   help="print each registered vault path, one per line")
    g.add_argument("--register", metavar="PATH",
                   help="register PATH as a vault (idempotent); print its id")
    g.add_argument("--open", metavar="PATH",
                   help="register PATH, then launch Obsidian into it")
    g.add_argument("--check-running", action="store_true",
                   help="exit 0 if Obsidian is running, 1 if not")
    g.add_argument("--registry-path", action="store_true",
                   dest="show_registry_path",
                   help="print the resolved registry location")
    p.add_argument("--registry", metavar="FILE",
                   help="override the registry location (tests)")
    p.add_argument("--dry-run", action="store_true",
                   help="with --open: print the launch command, do not run it")
    return p


def main(argv=None):
    args = build_parser().parse_args(argv)
    if args.show_registry_path:
        sys.stdout.write("%s\n" % registry_path(args.registry))
        return 0
    if args.list:
        return cmd_list(args)
    return 1


if __name__ == "__main__":
    sys.exit(main())
