#!/usr/bin/env python3
"""jobslib.py — shared config + path spine for the noesis-jobs module.

Loads a per-user config (a fenced YAML block inside a .md), validates it,
resolves paths for vault or standalone use, and reads secrets from .env.
No personal data lives here — everything comes from the user's config.

CLI: python jobslib.py validate [applications/_jobs/config.md]
"""
import os
import re
from pathlib import Path

try:
    import yaml
except ImportError:  # pragma: no cover
    yaml = None

DEFAULT_CONFIG_REL = "applications/_jobs/config.md"
VALID_STATUS = ("discovered", "interested", "tailoring", "applied",
                "interview", "offer", "rejected", "archived")

_YAML_BLOCK = re.compile(r"```ya?ml\s*\n(.*?)\n```", re.DOTALL)


class ConfigError(Exception):
    pass


def load_config(config_path):
    """Parse the first fenced YAML block from the config .md. Returns a dict."""
    p = Path(config_path)
    if not p.exists():
        raise ConfigError(f"config not found: {p}")
    if yaml is None:
        raise ConfigError("pyyaml not installed (pip install -r requirements.txt)")
    m = _YAML_BLOCK.search(p.read_text(encoding="utf-8"))
    if not m:
        raise ConfigError(f"no ```yaml block found in {p}")
    try:
        cfg = yaml.safe_load(m.group(1)) or {}
    except yaml.YAMLError as e:
        raise ConfigError(f"invalid YAML in {p}: {e}")
    if not isinstance(cfg, dict):
        raise ConfigError(f"config must be a YAML mapping, got {type(cfg).__name__}")
    return cfg


def validate_config(cfg):
    """Return a list of human-readable problems ([] means valid)."""
    problems = []
    if not (cfg.get("profile") or {}).get("name"):
        problems.append("profile.name is required")
    lanes = cfg.get("lanes") or []
    if not lanes:
        problems.append("at least one lane is required")
    for i, lane in enumerate(lanes):
        if not (lane or {}).get("key"):
            problems.append(f"lanes[{i}].key is required")
    return problems


def lane_keys(cfg):
    return [l["key"] for l in (cfg.get("lanes") or []) if (l or {}).get("key")]


def resolve_paths(cfg, config_path):
    """Resolve applications_dir + vault_root. Standalone when vault_root is null."""
    config_path = Path(config_path).resolve()
    paths = cfg.get("paths") or {}
    vault_root = paths.get("vault_root")
    vault_root = Path(vault_root).expanduser() if vault_root else None
    apps = paths.get("applications_dir")
    if apps:
        apps_dir = Path(apps).expanduser()
    elif vault_root:
        apps_dir = vault_root / "applications"
    else:
        # standalone: the applications dir is the parent of the _jobs/ folder
        apps_dir = config_path.parent.parent
    return {"vault_root": vault_root, "applications_dir": apps_dir}


def load_secret(name, env_path=None):
    """Read a secret from .env (python-dotenv if present) or the environment."""
    if env_path:
        env_path = Path(env_path)
        if env_path.exists():
            try:
                from dotenv import dotenv_values
                vals = dotenv_values(str(env_path))
                if vals.get(name):
                    return vals[name]
            except ImportError:
                for line in env_path.read_text(encoding="utf-8").splitlines():
                    line = line.strip()
                    if line.startswith(name + "="):
                        return line.split("=", 1)[1].strip().strip('"\'')
    return os.environ.get(name)


def _main(argv=None):
    import argparse
    p = argparse.ArgumentParser(description="jobs config utilities")
    sub = p.add_subparsers(dest="cmd", required=True)
    v = sub.add_parser("validate", help="load + validate a config .md; exit 0 iff clean")
    v.add_argument("config", nargs="?", default=DEFAULT_CONFIG_REL)
    args = p.parse_args(argv)

    import sys
    try:
        cfg = load_config(args.config)
    except ConfigError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    problems = validate_config(cfg)
    if problems:
        for prob in problems:
            print(f"problem: {prob}")
        return 1
    keys = lane_keys(cfg)
    print(f"config OK: {len(keys)} lane(s): {', '.join(keys)}")
    return 0


if __name__ == "__main__":  # pragma: no cover
    import sys
    sys.exit(_main())
