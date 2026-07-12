#!/usr/bin/env python3
"""scaffold.py - create a job-application kit folder from the template.

Config-driven: reads applications_dir + valid lanes from a per-user config
(see jobslib). Dry-run by default; pass --execute to write. No personal data.

Usage:
  python scaffold.py --config applications/_jobs/config.md \
      --org "Acme Co" --role "Widget Engineer" --lane track-1 \
      --req-id 123 --location Remote --remote --source "https://..." --execute
"""
import argparse
import datetime as _dt
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import jobslib

TEMPLATE = Path(__file__).resolve().parent / "templates" / "kit-hub.md"


def sanitize_path(name):
    bad = '<>:"/\\|?*'
    return "".join(c for c in name if c not in bad).strip().rstrip(".")


def yaml_safe(value):
    return value.replace('"', "'").strip()


def today():
    return _dt.date.today().isoformat()


def build_hub(values):
    text = TEMPLATE.read_text(encoding="utf-8")
    for key, val in values.items():
        text = text.replace("{" + key + "}", val)
    return text


def main(argv=None):
    p = argparse.ArgumentParser(description="Scaffold a job-application kit.")
    p.add_argument("--config", default=jobslib.DEFAULT_CONFIG_REL)
    p.add_argument("--org", required=True)
    p.add_argument("--role", required=True)
    p.add_argument("--lane", required=True)
    p.add_argument("--req-id", default="")
    p.add_argument("--location", default="")
    p.add_argument("--remote", action="store_true")
    p.add_argument("--deadline", default="")
    p.add_argument("--apply-target", default="")
    p.add_argument("--source", default="")
    p.add_argument("--warm-path", default="")
    p.add_argument("--status", default="interested", choices=jobslib.VALID_STATUS)
    p.add_argument("--jd-file", default="")
    p.add_argument("--force", action="store_true")
    p.add_argument("--execute", action="store_true", help="actually write (default: dry-run)")
    args = p.parse_args(argv)

    try:
        cfg = jobslib.load_config(args.config)
    except jobslib.ConfigError as e:
        p.error(str(e))
    lanes = jobslib.lane_keys(cfg)
    if args.lane not in lanes:
        p.error(f"unknown lane '{args.lane}'; config lanes are: {', '.join(lanes) or '(none)'}")
    apps_dir = jobslib.resolve_paths(cfg, args.config)["applications_dir"]

    org_fs, role_fs = sanitize_path(args.org), sanitize_path(args.role)
    folder = apps_dir / f"{org_fs} {role_fs}"
    hub = folder / f"{org_fs} {role_fs}.md"

    req_suffix = f" ({args.req_id})" if args.req_id else ""
    source_line = (f"- Source: {args.source}" if args.source
                   else "- (paste role context / comp / org notes here)")
    jd_line = ("[[Job Description]]" if args.jd_file
               else "(attach one with --jd-file, or paste below)")
    values = {
        "org": yaml_safe(args.org), "role": yaml_safe(args.role),
        "req_id": yaml_safe(args.req_id), "lane": args.lane, "status": args.status,
        "location": yaml_safe(args.location),
        "remote": "true" if args.remote else "false",
        "deadline": args.deadline, "apply_target": args.apply_target,
        "source": yaml_safe(args.source), "warm_path": yaml_safe(args.warm_path),
        "created": today(), "req_suffix": req_suffix, "source_line": source_line,
        "jd_line": jd_line, "stable_key": "",
    }
    hub_text = build_hub(values)

    jd_text = ""
    if args.jd_file:
        jd_path = Path(args.jd_file)
        if not jd_path.exists():
            p.error(f"--jd-file not found: {jd_path}")
        jd_text = jd_path.read_text(encoding="utf-8")

    print(f"applications dir: {apps_dir}")
    print(f"kit folder:       {folder}")
    print(f"hub file:         {hub}")
    print("--- hub frontmatter preview ---")
    fm_end = hub_text.find("\n---", 4)
    print(hub_text[: fm_end + 4] if fm_end != -1 else "\n".join(hub_text.splitlines()[:16]))

    if hub.exists() and not args.force:
        print(f"\n[!] hub already exists: {hub}\n    use --force to overwrite, or pick a different role name.")
        return 1
    if not args.execute:
        print("\n(dry-run -- nothing written. add --execute to create the kit.)")
        return 0

    folder.mkdir(parents=True, exist_ok=True)
    hub.write_text(hub_text, encoding="utf-8")
    written = [hub]
    if jd_text:
        jd_out = folder / "Job Description.md"
        jd_out.write_text(jd_text, encoding="utf-8")
        written.append(jd_out)
    print("\n=== WROTE ===")
    for w in written:
        print(f"  {w}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
