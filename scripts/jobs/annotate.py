#!/usr/bin/env python3
"""annotate.py - idempotent frontmatter upsert for job-application hubs.

Writes score fields (tier/fit_score/lane/eligibility/score_why/scored_date)
or a status change onto an existing hub, preserving the body and all other
frontmatter. Lanes validate against the per-user config; no personal data.

CLI: python annotate.py --config applications/_jobs/config.md \
       --hub "applications/<Org Role>/<Org Role>.md" --tier A --fit-score 87
"""
import argparse
import datetime as _dt
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import jobslib

VALID_ELIG = ("ok", "blocked", "check")


def format_value(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return str(v)
    s = " ".join(str(v).split())
    if s == "":
        return ""
    if any(c in s for c in ' :#"\'') or s[0] in '>|@`&*!%':
        return '"' + s.replace('"', "'") + '"'
    return s


def upsert_frontmatter(text, updates):
    if not text.startswith("---"):
        raise ValueError("file has no YAML frontmatter block")
    end = text.find("\n---", 3)
    if end == -1:
        raise ValueError("unterminated frontmatter block")
    lines = text[4:end].splitlines()
    body = text[end:]  # begins with "\n---"
    keyidx = {}
    for i, line in enumerate(lines):
        if ":" in line and line == line.lstrip():  # top-level key (no indent)
            keyidx[line.split(":", 1)[0].strip()] = i
    for k, v in updates.items():
        newline = f"{k}: {format_value(v)}"
        if k in keyidx:
            lines[keyidx[k]] = newline
        else:
            lines.append(newline)
    return "---\n" + "\n".join(lines) + body


def main(argv=None):
    p = argparse.ArgumentParser(
        description="Upsert score/status frontmatter on a job hub.")
    p.add_argument("--config", default=jobslib.DEFAULT_CONFIG_REL)
    p.add_argument("--hub", required=True)
    p.add_argument("--tier", choices=["A", "B", "C"])
    p.add_argument("--fit-score", type=int)
    p.add_argument("--lane")
    p.add_argument("--eligibility", choices=list(VALID_ELIG))
    p.add_argument("--why")
    p.add_argument("--status", choices=list(jobslib.VALID_STATUS))
    p.add_argument("--scored-date")
    args = p.parse_args(argv)

    if args.lane:
        try:
            lanes = jobslib.lane_keys(jobslib.load_config(args.config))
        except jobslib.ConfigError as e:
            p.error(str(e))
        if args.lane not in lanes + ["multi"]:
            p.error(f"unknown lane '{args.lane}'; config lanes are: "
                    f"{', '.join(lanes)} (or 'multi')")

    updates = {}
    if args.tier:
        updates["tier"] = args.tier
    if args.fit_score is not None:
        updates["fit_score"] = args.fit_score
    if args.lane:
        updates["lane"] = args.lane
    if args.eligibility:
        updates["eligibility"] = args.eligibility
    if args.why is not None:
        updates["score_why"] = args.why
    if args.status:
        updates["status"] = args.status
    if any(k in updates for k in ("tier", "fit_score", "lane",
                                  "eligibility", "score_why")):
        updates["scored_date"] = args.scored_date or _dt.date.today().isoformat()
    if not updates:
        p.error("nothing to update — pass at least one field")

    path = Path(args.hub)
    if not path.exists():
        p.error(f"--hub not found: {path}")
    new = upsert_frontmatter(path.read_text(encoding="utf-8"), updates)
    path.write_text(new, encoding="utf-8")
    print(f"annotated {path.name}: " +
          ", ".join(f"{k}={v}" for k, v in updates.items()))
    return 0


if __name__ == "__main__":
    sys.exit(main())
