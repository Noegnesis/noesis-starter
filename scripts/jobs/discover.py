#!/usr/bin/env python3
"""discover.py - config-driven job discovery for the noesis-jobs module.

Fetches roles from the config's ATS boards + feeds + Adzuna, filters by the
config's lane keywords, verifies liveness, dedupes against the tracker and a
local state file, and writes status:discovered stubs through scaffold's
template. Dry-run by default; --execute to write. No personal data lives
here - boards, keywords, and filters all come from the per-user config.

CLI: python discover.py --config applications/_jobs/config.md \
       [--source ats|feeds|adzuna|all] [--lane <key|all>] [--limit N] [--execute]
"""
import argparse
import html
import json
import re
import sys
import urllib.parse
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import jobslib
import scaffold  # reuse build_hub / sanitize_path / yaml_safe / today

USER_AGENT = "noesis-jobs-discover/1.0"


# --- http (always injectable; tests never touch the network) ---------------

def http_get_json(url, headers=None):
    req = urllib.request.Request(url, headers=headers or {"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def url_is_live(url, headers=None, opener=urllib.request.urlopen):
    req = urllib.request.Request(url, headers=headers or {"User-Agent": USER_AGENT})
    try:
        with opener(req, timeout=30) as resp:
            return getattr(resp, "status", 200) == 200
    except Exception:
        return False


# --- small text helpers -----------------------------------------------------

def slug(s):
    return re.sub(r"-+", "-", re.sub(r"[^a-z0-9]+", "-", (s or "").lower())).strip("-")


def strip_html(s):
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", s or ""))).strip()


def _flat(s):
    """Collapse whitespace to single spaces. Neutralizes untrusted feed text
    before it enters a filename or YAML."""
    return re.sub(r"\s+", " ", (s or "")).strip()


def _role(source, company, role, url, stable_key, location="", remote=False,
          posted_date="", jd_excerpt=""):
    return {"source": source, "company": company, "role": role, "url": url,
            "stable_key": stable_key, "location": location, "remote": remote,
            "posted_date": posted_date, "jd_excerpt": jd_excerpt,
            "lane_guess": "", "liveness": ""}


# --- parsers (pure; fixture-testable) ----------------------------------------

def parse_greenhouse(payload, company, board_slug):
    out = []
    for j in payload.get("jobs", []):
        loc = (j.get("location") or {}).get("name", "")
        out.append(_role("greenhouse", company, j.get("title", ""),
                         j.get("absolute_url", ""), f"gh:{board_slug}:{j.get('id')}",
                         location=loc, remote="remote" in loc.lower(),
                         posted_date=j.get("updated_at", ""),
                         jd_excerpt=strip_html(j.get("content", ""))[:500]))
    return out


def parse_lever(payload, company, board_slug):
    out = []
    for j in payload:
        loc = (j.get("categories") or {}).get("location", "")
        out.append(_role("lever", company, j.get("text", ""),
                         j.get("hostedUrl", ""), f"lever:{board_slug}:{j.get('id')}",
                         location=loc, remote="remote" in loc.lower(),
                         jd_excerpt=strip_html(j.get("descriptionPlain", ""))[:500]))
    return out


def parse_ashby(payload, company, board_slug):
    out = []
    for j in payload.get("jobs", []):
        out.append(_role("ashby", company, j.get("title", ""),
                         j.get("jobUrl") or j.get("applyUrl", ""),
                         f"ashby:{board_slug}:{j.get('id')}",
                         location=j.get("location", ""),
                         remote=bool(j.get("isRemote")),
                         posted_date=j.get("publishedDate", ""),
                         jd_excerpt=strip_html(j.get("descriptionPlain", ""))[:500]))
    return out


def parse_remotive(payload):
    out = []
    for j in payload.get("jobs", []):
        out.append(_role("remotive", j.get("company_name", ""),
                         j.get("title", ""), j.get("url", ""),
                         f"remotive:{j.get('id')}",
                         location=j.get("candidate_required_location", ""),
                         remote=True, posted_date=j.get("publication_date", ""),
                         jd_excerpt=strip_html(j.get("description", ""))[:500]))
    return out


def parse_remoteok(payload):
    out = []
    for j in payload:
        if not isinstance(j, dict) or "position" not in j:
            continue
        out.append(_role("remoteok", j.get("company", ""),
                         j.get("position", ""), j.get("url", ""),
                         f"remoteok:{j.get('id')}",
                         location=j.get("location", ""), remote=True,
                         posted_date=j.get("date", ""),
                         jd_excerpt=strip_html(j.get("description", ""))[:500]))
    return out


def parse_adzuna(payload):
    out = []
    for j in payload.get("results", []):
        loc = (j.get("location") or {}).get("display_name", "")
        out.append(_role("adzuna", (j.get("company") or {}).get("display_name", ""),
                         j.get("title", ""), j.get("redirect_url", ""),
                         f"adzuna:{j.get('id')}", location=loc,
                         remote="remote" in loc.lower(),
                         posted_date=j.get("created", ""),
                         jd_excerpt=strip_html(j.get("description", ""))[:500]))
    return out


# --- fetchers (config-driven; getter injectable) ------------------------------

_ATS_URL = {
    "greenhouse": "https://boards-api.greenhouse.io/v1/boards/{slug}/jobs?content=true",
    "lever": "https://api.lever.co/v0/postings/{slug}?mode=json",
    "ashby": "https://api.ashbyhq.com/posting-api/job-board/{slug}",
}
_ATS_PARSER = {"greenhouse": parse_greenhouse, "lever": parse_lever,
               "ashby": parse_ashby}


def parse_board(entry):
    """'greenhouse:acme' -> ('greenhouse', 'acme'); unknown shapes -> (None, None)."""
    if not isinstance(entry, str) or ":" not in entry:
        return (None, None)
    ats, _, board_slug = entry.partition(":")
    ats, board_slug = ats.strip().lower(), board_slug.strip()
    return (ats, board_slug) if ats in _ATS_URL and board_slug else (None, None)


def fetch_ats(boards, getter=None):
    getter = getter or http_get_json
    out = []
    for entry in boards or []:
        ats, board_slug = parse_board(entry)
        if not ats:
            print(f"  [skip] unrecognized ats_boards entry: {entry!r}", file=sys.stderr)
            continue
        try:
            payload = getter(_ATS_URL[ats].format(slug=board_slug))
            out.extend(_ATS_PARSER[ats](payload, board_slug, board_slug))
        except Exception as e:
            print(f"  [skip] {entry}: {e}", file=sys.stderr)
    return out


def fetch_feeds(feeds, getter=None):
    getter = getter or http_get_json
    out = []
    for entry in feeds or []:
        try:
            if isinstance(entry, str) and entry.lower().startswith("remotive:"):
                term = entry.partition(":")[2].strip()
                payload = getter("https://remotive.com/api/remote-jobs?search=" +
                                 urllib.parse.quote(term))
                out.extend(parse_remotive(payload))
            elif isinstance(entry, str) and entry.lower() == "remoteok":
                out.extend(parse_remoteok(getter("https://remoteok.com/api")))
            else:
                print(f"  [skip] unrecognized feeds entry: {entry!r}", file=sys.stderr)
        except Exception as e:
            print(f"  [skip] {entry}: {e}", file=sys.stderr)
    return out


def fetch_adzuna(adz, env_path, getter=None):
    getter = getter or http_get_json
    adz = adz or {}
    app_id = jobslib.load_secret(adz.get("app_id_ref", "ADZUNA_APP_ID"), env_path)
    app_key = jobslib.load_secret(adz.get("app_key_ref", "ADZUNA_APP_KEY"), env_path)
    if not app_id or not app_key:
        print("  [skip] adzuna: no keys in .env — discovery runs ATS + feeds only",
              file=sys.stderr)
        return []
    what, where = adz.get("what", ""), adz.get("where", "")
    country = adz.get("country", "us")
    url = (f"https://api.adzuna.com/v1/api/jobs/{country}/search/1?"
           f"app_id={app_id}&app_key={app_key}&results_per_page=50&"
           f"what={urllib.parse.quote(what)}&where={urllib.parse.quote(where)}")
    try:
        return parse_adzuna(getter(url))
    except Exception as e:
        print(f"  [skip] adzuna: {e}", file=sys.stderr)
        return []


# --- filtering ---------------------------------------------------------------

def lane_keyword_map(cfg):
    """{lane_key: [lowercased keywords]} for lanes that declare keywords."""
    out = {}
    for lane in cfg.get("lanes") or []:
        kws = [str(k).lower() for k in (lane or {}).get("keywords") or []]
        if (lane or {}).get("key") and kws:
            out[lane["key"]] = kws
    return out


def guess_lane(role, keyword_map):
    """First matching lane key; 'multi' when 2+ lanes match; '' when none."""
    text = (role.get("role", "") + " " + role.get("jd_excerpt", "")).lower()
    hits = [k for k, kws in keyword_map.items()
            if any(re.search(r"\b" + re.escape(w), text) for w in kws)]
    if len(hits) >= 2:
        return "multi"
    return hits[0] if hits else ""


def is_excluded(role, patterns):
    title = role.get("role", "").lower()
    return any(re.search(r"\b" + re.escape(str(p).lower()) + r"\b", title)
               for p in patterns or [])


ATS_SOURCES = ("greenhouse", "lever", "ashby")


def verify_liveness(role, is_live=None):
    """ATS results came from a live board API; feed/aggregator URLs get a check."""
    is_live = is_live or url_is_live
    if role.get("source") in ATS_SOURCES:
        return "verified"
    return "verified" if role.get("url") and is_live(role["url"]) else "unverified"


# --- dedupe + state -----------------------------------------------------------

def role_key(role):
    return f"{slug(role.get('company', ''))}::{slug(role.get('role', ''))}"


def read_frontmatter(path):
    text = Path(path).read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    fm = {}
    for line in text[3:end].splitlines():
        if ":" in line:
            k, v = line.split(":", 1)
            fm[k.strip()] = v.strip().strip('"').strip("'")
    return fm


def load_existing(apps_dir, seen):
    keys = set(seen or [])
    apps_dir = Path(apps_dir)
    if apps_dir.exists():
        for md in apps_dir.rglob("*.md"):
            fm = read_frontmatter(md)
            if fm.get("type") != "application":
                continue
            if fm.get("stable_key"):
                keys.add(fm["stable_key"])
            keys.add(role_key({"company": fm.get("org", ""),
                               "role": fm.get("role", "")}))
    return keys


def dedupe(roles, existing):
    fresh, skipped = [], []
    for r in roles:
        sk, rk = r.get("stable_key", ""), role_key(r)
        if sk in existing or rk in existing:
            skipped.append(r)
        else:
            fresh.append(r)
        existing.add(sk)
        existing.add(rk)
    return fresh, skipped


def ensure_state(state_dir):
    state_dir = Path(state_dir)
    state_dir.mkdir(parents=True, exist_ok=True)
    rs = state_dir / "run-state.json"
    if not rs.exists():
        rs.write_text(json.dumps({"seen_stable_keys": [], "last_run": ""},
                                 indent=2), encoding="utf-8")
    runs = state_dir / "discover-runs.tsv"
    if not runs.exists():
        runs.write_text("", encoding="utf-8")


def append_run_ledger(row, ledger_path):
    cols = ["date", "source", "fetched", "filtered", "live", "net_new", "written"]
    with open(ledger_path, "a", encoding="utf-8") as f:
        f.write("\t".join(str(row.get(c, "")) for c in cols) + "\n")


def update_run_state(state_path, new_keys, today):
    state_path = Path(state_path)
    state = json.loads(state_path.read_text(encoding="utf-8"))
    seen = set(state.get("seen_stable_keys", []))
    seen.update(k for k in new_keys if k)
    state["seen_stable_keys"] = sorted(seen)
    state["last_run"] = today
    state_path.write_text(json.dumps(state, indent=2), encoding="utf-8")


# --- stub writing (one kit shape, via scaffold) --------------------------------

def write_stub(role, apps_dir):
    company = scaffold.sanitize_path(_flat(role.get("company", "")) or "Unknown")
    title = scaffold.sanitize_path(_flat(role.get("role", "")) or "Role")
    folder = Path(apps_dir) / f"{company} {title}"
    hub = folder / f"{company} {title}.md"
    src_line = f"- Source: {_flat(role.get('url', ''))}"
    if role.get("jd_excerpt"):
        src_line += f"\n- {_flat(role['jd_excerpt'])}"
    if role.get("liveness") == "unverified":
        src_line += "\n- liveness UNVERIFIED at discovery — re-check before applying"
    values = {
        "org": scaffold.yaml_safe(_flat(role.get("company", ""))),
        "role": scaffold.yaml_safe(_flat(role.get("role", ""))),
        "req_id": "", "lane": role.get("lane_guess") or "", "status": "discovered",
        "location": scaffold.yaml_safe(_flat(role.get("location", ""))),
        "remote": "true" if role.get("remote") else "false",
        "deadline": "", "apply_target": "",
        "source": scaffold.yaml_safe(_flat(role.get("url", ""))),
        "warm_path": "", "created": scaffold.today(),
        "req_suffix": "", "source_line": src_line,
        "stable_key": scaffold.yaml_safe(_flat(role.get("stable_key", ""))),
        "jd_line": "(attach one with --jd-file, or paste below)",
    }
    folder.mkdir(parents=True, exist_ok=True)
    hub.write_text(scaffold.build_hub(values), encoding="utf-8")
    return hub


# --- orchestration --------------------------------------------------------------

def run_discovery(cfg, config_path, source, lane, limit, execute, *,
                  getter=None, is_live=None):
    getter = getter or http_get_json
    is_live = is_live or url_is_live
    disc = cfg.get("discovery") or {}
    apps_dir = jobslib.resolve_paths(cfg, config_path)["applications_dir"]
    config_dir = Path(config_path).resolve().parent
    state_dir = config_dir / "state"

    raw = []
    if source in ("ats", "all"):
        raw += fetch_ats(disc.get("ats_boards"), getter)
    if source in ("feeds", "all"):
        raw += fetch_feeds(disc.get("feeds"), getter)
    if source in ("adzuna", "all"):
        raw += fetch_adzuna(disc.get("adzuna"), config_dir / ".env", getter)
    fetched = len(raw)

    keyword_map = lane_keyword_map(cfg)
    exclude = disc.get("exclude_titles") or []
    filtered = []
    for r in raw:
        if is_excluded(r, exclude):
            continue
        lg = guess_lane(r, keyword_map)
        if keyword_map and not lg:
            continue
        if lane != "all" and lg not in (lane, "multi"):
            continue
        r["lane_guess"] = lg
        filtered.append(r)
    if raw and not keyword_map:
        print("  [note] no lane keywords in config — keeping every fetched role. "
              "Add lanes[].keywords to filter.", file=sys.stderr)

    for r in filtered:
        r["liveness"] = verify_liveness(r, is_live=is_live)
    live = sum(1 for r in filtered if r["liveness"] == "verified")

    rs = state_dir / "run-state.json"
    if rs.exists():
        state = json.loads(rs.read_text(encoding="utf-8"))
    else:
        state = {"seen_stable_keys": [], "last_run": ""}
    existing = load_existing(apps_dir, state.get("seen_stable_keys", []))
    fresh, _ = dedupe(filtered, existing)
    if limit:
        fresh = fresh[:limit]

    written, written_keys, digest = 0, [], []
    for r in fresh:
        co, ro = _flat(r["company"]), _flat(r["role"])
        tag = "" if r["liveness"] == "verified" else " [UNVERIFIED]"
        digest.append(f"  - [{r['lane_guess'] or '?'}] {co} — {ro}{tag}  {_flat(r['url'])}")
        if execute:
            try:
                write_stub(r, apps_dir)
                written += 1
                written_keys.append(r["stable_key"])
            except Exception as e:
                print(f"  [skip write] {co} — {ro}: {e}", file=sys.stderr)

    today = scaffold.today()
    if execute:
        ensure_state(state_dir)
        append_run_ledger({"date": today, "source": source, "fetched": fetched,
                           "filtered": len(filtered), "live": live,
                           "net_new": len(fresh), "written": written},
                          state_dir / "discover-runs.tsv")
        update_run_state(state_dir / "run-state.json", written_keys, today)
    return {"fetched": fetched, "filtered": len(filtered), "live": live,
            "net_new": len(fresh), "written": written, "digest": digest}


def main(argv=None):
    p = argparse.ArgumentParser(description="Discover job postings from your config's sources.")
    p.add_argument("--config", default=jobslib.DEFAULT_CONFIG_REL)
    p.add_argument("--source", default="all", choices=["ats", "feeds", "adzuna", "all"])
    p.add_argument("--lane", default="all")
    p.add_argument("--limit", type=int, default=0)
    p.add_argument("--execute", action="store_true", help="write stubs (default: dry-run)")
    args = p.parse_args(argv)

    try:
        cfg = jobslib.load_config(args.config)
    except jobslib.ConfigError as e:
        p.error(str(e))
    lanes = jobslib.lane_keys(cfg)
    if args.lane != "all" and args.lane not in lanes:
        p.error(f"unknown lane '{args.lane}'; config lanes are: {', '.join(lanes)}")

    s = run_discovery(cfg, args.config, args.source, args.lane, args.limit,
                      args.execute)
    print(f"\nfetched={s['fetched']} filtered={s['filtered']} live={s['live']} "
          f"net-new={s['net_new']} written={s['written']}")
    print("\n--- net-new roles ---" if s["digest"] else "\n(no net-new roles)")
    for line in s["digest"]:
        print(line)
    if not args.execute:
        print("\n(dry-run — nothing written. add --execute to write stubs.)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
