"""vault-health scanner. Read-only by default; --apply fixes only a cosmetic
safe subset (case / whitespace / smart-quote link repairs) and writes an undo log.

Ported from a battle-tested personal-vault scanner; folder classification is
generalized: every top-level folder is "active" unless it's archive/ or in SKIP.

Usage (from the vault root):
    python scripts/vault_health.py .              # full report (compact JSON)
    python scripts/vault_health.py . --json       # full report, pretty-printed
    python scripts/vault_health.py . --pulse      # one-line weekly pulse
    python scripts/vault_health.py . --fix-plan   # preview cosmetic fixes (no writes)
    python scripts/vault_health.py . --apply --undo .vault-health-undo.json
"""
import os
import re
import json
import time
import platform
import datetime
from collections import defaultdict

STALE_DAYS = 14
_SMART_NAME = re.compile(r"[‘’“”–—]")
_PERIODIC = re.compile(r"^\d{4}-(\d{2}-\d{2}|W\d{2})")


def is_periodic_note(filename):
    """Daily / weekly notes — append-only logs, never hand-indexed into MOCs."""
    return bool(_PERIODIC.match(filename))

# Doc-example link tokens that are noise, not real links. Keep MINIMAL — only
# placeholders implausible as real note titles. Over-broadening drops real links
# (e.g. "target"/"link"/"page" are plausible note names — must NOT be here).
EXAMPLE_TOKENS = {"x", "y", "note name", "wikilinks"}

# Folders that never count as vault content. _ROOT_SKIP applies only at the
# vault root (a user project may legitimately contain a "scripts" note folder);
# _ALWAYS_SKIP is pruned at any depth. guide/ is a generated artifact
# (relative md links, no wikilinks) and would read as pure orphans.
ARCHIVE_NAMES = {"archive"}
_ALWAYS_SKIP = {".obsidian", ".trash", ".git", ".claude", "node_modules"}
_ROOT_SKIP = {"scripts", "outputs", "guide", "sensitive", "Sensitive"}
SKIP = _ALWAYS_SKIP | _ROOT_SKIP

_LINK_RE = re.compile(r"(!?)\[\[([^\]\n]+?)\]\]")
_INLINE_CODE_RE = re.compile(r"`[^`]*`")
_SMART = {"’": "'", "‘": "'", "“": '"', "”": '"'}


def mask_code(text):
    """Blank fenced (``` / ~~~) and inline (`...`) code so links inside aren't parsed."""
    out = []
    in_fence = False
    marker = ""
    for line in text.split("\n"):
        stripped = line.lstrip()
        if in_fence:
            if stripped.startswith(marker):
                in_fence = False
            out.append("")
            continue
        if stripped.startswith("```") or stripped.startswith("~~~"):
            in_fence = True
            marker = stripped[:3]
            out.append("")
            continue
        out.append(_INLINE_CODE_RE.sub(lambda m: " " * len(m.group(0)), line))
    return "\n".join(out)


def normalize_target(raw):
    """Split a raw [[inner]] into target/alias/heading/block."""
    alias = heading = block = ""
    s = raw
    if "|" in s:
        s, alias = s.split("|", 1)
    if "^" in s:
        s, block = s.split("^", 1)
    if "#" in s:
        s, heading = s.split("#", 1)
    return {"target": s.strip(), "alias": alias.strip(),
            "heading": heading.strip(), "block": block.strip()}


def extract_links(text):
    """Return [{raw,target,alias,heading,block,is_embed}] after masking code + dropping examples."""
    masked = mask_code(text)
    links = []
    for m in _LINK_RE.finditer(masked):
        inner = m.group(2)
        n = normalize_target(inner)
        target = n["target"]
        if not target:
            continue
        if target.casefold() in EXAMPLE_TOKENS:
            continue
        links.append({"raw": inner, "target": target, "alias": n["alias"],
                      "heading": n["heading"], "block": n["block"],
                      "is_embed": m.group(1) == "!"})
    return links


def classify_folder(relpath):
    """active | archive | meta | skip, by top-level folder."""
    rel = relpath.replace("\\", "/")
    if "/" not in rel:
        return "meta"  # root-level file (CLAUDE.md, memory.md, ...)
    top = rel.split("/", 1)[0]
    if top in SKIP:
        return "skip"
    if top.lower() in ARCHIVE_NAMES:
        return "archive"
    return "active"


def is_moc(filename):
    return filename.startswith("MOC")


def _cos_norm(s):
    for k, v in _SMART.items():
        s = s.replace(k, v)
    return re.sub(r"\s+", " ", s).strip().casefold()


def cosmetic_equal(a, b):
    """Equal after case / smart-quote / whitespace normalization (for --fix safe subset)."""
    return _cos_norm(a) == _cos_norm(b)


def has_frontmatter(text):
    """True only if the file starts with a closed YAML frontmatter block."""
    t = text.lstrip("﻿")
    if not t.startswith("---"):
        return False
    lines = t.split("\n")
    if lines[0].strip() != "---":
        return False
    return any(ln.strip() == "---" for ln in lines[1:])


def build_index(relpaths):
    """relpaths: note paths without .md. Returns (by_base, by_relpath)."""
    by_base = {}
    by_rel = {}
    for rp in relpaths:
        key = rp.replace("\\", "/").lower()
        by_rel[key] = rp
        base = key.rsplit("/", 1)[-1]
        by_base.setdefault(base, []).append(rp)
    return by_base, by_rel


def resolve(raw, by_base, by_rel):
    """Resolve a raw link target. kind: note|asset|self|broken; ambiguous: bool."""
    t = normalize_target(raw)["target"]
    if not t:
        return {"kind": "self", "path": None, "ambiguous": False}
    ext = os.path.splitext(t)[1].lower()
    if ext and ext != ".md":
        return {"kind": "asset", "path": None, "ambiguous": False}
    if t.lower().endswith(".md"):
        t = t[:-3]
    key = t.replace("\\", "/").lower()
    if key in by_rel:
        return {"kind": "note", "path": by_rel[key], "ambiguous": False}
    base = key.rsplit("/", 1)[-1]
    if base in by_base:
        matches = by_base[base]
        return {"kind": "note", "path": matches[0], "ambiguous": len(matches) > 1}
    return {"kind": "broken", "path": None, "ambiguous": False}


def name_issues(filename):
    """Filename-level naming artifacts (sync-conflict leftovers, etc.)."""
    issues = []
    if filename.startswith("Copy of "):
        issues.append("copy-of")
    if "  " in filename:
        issues.append("double-space")
    if _SMART_NAME.search(filename):
        issues.append("smart-char")
    if filename != filename.strip():
        issues.append("edge-space")
    return issues


def _walk_notes(root):
    """Return abs paths of all .md files, pruning skip dirs."""
    notes = []
    root_abs = os.path.abspath(root)
    for dirpath, dirs, files in os.walk(root):
        skip = SKIP if os.path.abspath(dirpath) == root_abs else _ALWAYS_SKIP
        dirs[:] = [d for d in dirs if d not in skip]
        for f in files:
            if f.lower().endswith(".md"):
                notes.append(os.path.join(dirpath, f))
    return notes


def _top(rel):
    rel = rel.replace("\\", "/")
    return rel.split("/", 1)[0] if "/" in rel else "(root)"


def scan_vault(root, now=None):
    """Walk the vault once and return the health report dict (read-only)."""
    if now is None:
        now = time.time()
    t0 = time.time()
    notes = _walk_notes(root)
    rels = [os.path.relpath(p, root).replace("\\", "/") for p in notes]
    rel_no_ext = [os.path.splitext(r)[0] for r in rels]
    by_base, by_rel = build_index(rel_no_ext)

    info = {}
    indeg = defaultdict(int)
    outdeg = defaultdict(int)
    adj = defaultdict(set)
    broken_links = []
    read_errors = 0

    for p, rel, rne in zip(notes, rels, rel_no_ext):
        fname = os.path.basename(p)
        try:
            with open(p, encoding="utf-8", errors="replace") as fh:
                txt = fh.read()
        except Exception:
            read_errors += 1
            txt = ""
        ignored = _is_ignored(txt)
        seen = set()
        for link in extract_links(txt):
            res = resolve(link["target"], by_base, by_rel)
            kind = res["kind"]
            if kind in ("asset", "self"):
                continue
            if kind == "broken":
                if not ignored:
                    broken_links.append({"src": rel, "target": link["target"], "raw": link["raw"]})
                continue
            tgt = res["path"]
            if tgt == rne or link["target"] in seen:
                continue
            seen.add(link["target"])
            outdeg[rne] += 1
            indeg[tgt] += 1
            adj[rne].add(tgt)
        _mt = os.path.getmtime(p)
        info[rne] = {"rel": rel, "folder": classify_folder(rel), "is_moc": is_moc(fname),
                     "mtime": _mt, "asof": _parse_updated_epoch(txt) or _mt,
                     "has_fm": has_frontmatter(txt), "fname": fname}

    # by-folder counts
    by_folder = defaultdict(int)
    for meta in info.values():
        by_folder[_top(meta["rel"])] += 1

    # orphans (no links in or out; periodic notes are logs, not orphans)
    active_orphans = []
    archive_count = 0
    for rne, meta in info.items():
        if meta["is_moc"] or outdeg[rne] or indeg[rne] or is_periodic_note(meta["fname"]):
            continue
        if meta["folder"] == "active":
            active_orphans.append(meta["rel"])
        elif meta["folder"] == "archive":
            archive_count += 1

    # MOC-reachability BFS
    moc_roots = [rne for rne, meta in info.items() if meta["is_moc"]]
    reached = set(moc_roots)
    stack = list(moc_roots)
    while stack:
        for nxt in adj.get(stack.pop(), ()):
            if nxt not in reached:
                reached.add(nxt)
                stack.append(nxt)

    folder_notes = defaultdict(list)
    for rne, meta in info.items():
        if meta["folder"] == "active" and not meta["is_moc"]:
            folder_notes[_top(meta["rel"])].append(rne)
    coverage = {}
    for folder, members in folder_notes.items():
        reach = sum(1 for m in members if m in reached)
        n = len(members)
        coverage[folder] = {"notes": n, "reachable": reach,
                            "pct": round(100 * reach / n) if n else 100}

    # stale MOCs — old AND behind a newer non-periodic note in their subtree
    stale_mocs = []
    for rne, meta in info.items():
        if not meta["is_moc"]:
            continue
        age = (now - meta["asof"]) / 86400
        if age <= STALE_DAYS:
            continue
        moc_dir = os.path.dirname(meta["rel"])
        newer = any(
            not m2["is_moc"] and not is_periodic_note(m2["fname"]) and m2["asof"] > meta["asof"]
            and (os.path.dirname(m2["rel"]) == moc_dir
                 or os.path.dirname(m2["rel"]).startswith(moc_dir + "/"))
            for m2 in info.values()
        )
        if newer:
            stale_mocs.append({"path": meta["rel"], "age_days": round(age, 1), "child_has_newer": True})

    # naming + frontmatter
    naming = defaultdict(int)
    for meta in info.values():
        for iss in name_issues(meta["fname"]):
            naming[iss] += 1
    active_missing = sum(1 for m in info.values()
                         if m["folder"] == "active" and not m["is_moc"] and not m["has_fm"])

    # ambiguous basenames (same name, multiple files) — independent of links
    ambiguous = sorted(b for b, lst in by_base.items() if len(lst) > 1)

    # inbox backlog: anything sitting in inbox/ (all file types, not just .md)
    inbox = os.path.join(root, "inbox")
    in_ages = []
    if os.path.isdir(inbox):
        for f in os.listdir(inbox):
            fp = os.path.join(inbox, f)
            if os.path.isfile(fp) and not f.startswith("."):
                in_ages.append((now - os.path.getmtime(fp)) / 86400)

    return {
        "scanned": len(info),
        "read_errors": read_errors,
        "scan_seconds": round(time.time() - t0, 2),
        "device": platform.node(),
        "by_folder": dict(by_folder),
        "broken_links": broken_links,
        "orphans": {"active": active_orphans, "archive_count": archive_count},
        "stale_mocs": stale_mocs,
        "coverage": coverage,
        "mocs": sorted(m["rel"] for m in info.values() if m["is_moc"]),
        "ambiguous_basenames": ambiguous,
        "inbox": {"count": len(in_ages),
                  "oldest_days": round(max(in_ages), 1) if in_ages else 0,
                  "newest_days": round(min(in_ages), 1) if in_ages else 0},
        "naming_artifacts": dict(naming),
        "frontmatter": {"active_missing": active_missing},
    }


# ---------------- --fix safe subset (cosmetic-only, guarded) ----------------

def _sub_links_in_segment(seg, old_target, new_target):
    count = 0

    def repl(m):
        nonlocal count
        n = normalize_target(m.group(2))
        if not cosmetic_equal(n["target"], old_target):
            return m.group(0)
        count += 1
        rebuilt = new_target
        if n["heading"]:
            rebuilt += "#" + n["heading"]
        if n["block"]:
            rebuilt += "^" + n["block"]
        if n["alias"]:
            rebuilt += "|" + n["alias"]
        return m.group(1) + "[[" + rebuilt + "]]"

    return _LINK_RE.sub(repl, seg), count


def replace_link_target(text, old_target, new_target):
    """Replace [[old_target...]] -> [[new_target...]] preserving alias/heading/block.
    Skips fenced and inline code. Returns (new_text, count)."""
    out = []
    count = 0
    in_fence = False
    marker = ""
    for line in text.split("\n"):
        stripped = line.lstrip()
        if in_fence:
            if stripped.startswith(marker):
                in_fence = False
            out.append(line)
            continue
        if stripped.startswith("```") or stripped.startswith("~~~"):
            in_fence = True
            marker = stripped[:3]
            out.append(line)
            continue
        # split out inline-code spans; only substitute in non-code segments
        parts = re.split(r"(`[^`]*`)", line)
        for i, seg in enumerate(parts):
            if seg.startswith("`"):
                continue
            parts[i], c = _sub_links_in_segment(seg, old_target, new_target)
            count += c
        out.append("".join(parts))
    return "\n".join(out), count


def compute_fix_plan(root):
    """Find broken links that are cosmetically (whitespace/smart-quote/case) one
    unambiguous existing note. Returns [{path, old, new, occurrences}]. No writes."""
    notes = _walk_notes(root)
    rels = [os.path.relpath(p, root).replace("\\", "/") for p in notes]
    rne = [os.path.splitext(r)[0] for r in rels]
    by_base, by_rel = build_index(rne)

    cos_idx = defaultdict(set)
    for r in rne:
        base = r.replace("\\", "/").rsplit("/", 1)[-1]
        cos_idx[_cos_norm(base)].add(base)

    plan = []
    for p, rel in zip(notes, rels):
        try:
            with open(p, encoding="utf-8", errors="replace") as fh:
                txt = fh.read()
        except Exception:
            continue
        if _is_ignored(txt):
            continue
        seen = set()
        for link in extract_links(txt):
            if resolve(link["target"], by_base, by_rel)["kind"] != "broken":
                continue
            t = link["target"]
            base = t.replace("\\", "/").rsplit("/", 1)[-1]
            cands = cos_idx.get(_cos_norm(base))
            if not cands or len(cands) != 1:
                continue  # zero or ambiguous -> not auto-fixable
            new = next(iter(cands))
            if new == t or t in seen:
                continue
            seen.add(t)
            _, occ = replace_link_target(txt, t, new)
            plan.append({"path": rel, "old": t, "new": new, "occurrences": occ})
    return plan


def _frontmatter_block(text):
    if not has_frontmatter(text):
        return ""
    body = text.lstrip("﻿")
    return body.split("---", 2)[1] if body.count("---") >= 2 else ""


def _parse_updated_epoch(text):
    """If frontmatter declares `updated: YYYY-MM-DD`, return its epoch (local midnight);
    else None. Lets a hand-maintained MOC assert it's content-current independent of
    file mtime — e.g. after a bulk sync bumps neighbor mtimes."""
    m = re.search(r"(?mi)^updated:\s*['\"]?(\d{4})-(\d{2})-(\d{2})", _frontmatter_block(text))
    if not m:
        return None
    try:
        return datetime.datetime(int(m.group(1)), int(m.group(2)), int(m.group(3))).timestamp()
    except ValueError:
        return None


def _is_voice_raw(text):
    return re.search(r"(?mi)^voice:\s*raw\b", _frontmatter_block(text)) is not None


def _is_ignored(text):
    """Files opting out of broken-link checks via `vault-health: ignore` frontmatter
    (for reference/doc notes that contain illustrative example wikilinks)."""
    return re.search(r"(?mi)^vault-health:\s*ignore\b", _frontmatter_block(text)) is not None


def apply_fixes(root, plan, undo_path=None):
    """Apply a fix plan. Skips voice:raw files. Writes an undo log. Returns summary."""
    by_file = defaultdict(list)
    for it in plan:
        by_file[it["path"]].append(it)

    applied = []
    undo = []
    for rel, items in by_file.items():
        p = os.path.join(root, rel.replace("/", os.sep))
        try:
            with open(p, encoding="utf-8", errors="replace") as fh:
                txt = fh.read()
        except Exception:
            continue
        if _is_voice_raw(txt):
            continue  # never touch protected raw voice
        orig = txt
        total = 0
        for it in items:
            txt, c = replace_link_target(txt, it["old"], it["new"])
            total += c
        if total and txt != orig:
            undo.append({"path": rel, "before": orig})
            with open(p, "w", encoding="utf-8") as fh:
                fh.write(txt)
            applied.append({"path": rel, "fixes": total})

    if undo and undo_path:
        with open(undo_path, "w", encoding="utf-8") as fh:
            json.dump(undo, fh, ensure_ascii=False, indent=2)
    return {"applied": applied, "undo_count": len(undo)}


# ---------------- pulse (weekly one-liner) ----------------

def pulse_payload(report, prev=None):
    """Compact metrics + nudge decision for the weekly pulse."""
    broken = len(report["broken_links"])
    orphans = len(report["orphans"]["active"])
    stale = len(report["stale_mocs"])
    inbox = report["inbox"]["count"]
    prev_orphans = prev.get("active_orphans") if prev else None
    rose = prev_orphans is not None and orphans > prev_orphans
    nudge = broken > 0 or stale >= 3 or rose
    return {"broken": broken, "active_orphans": orphans, "stale_mocs": stale,
            "inbox": inbox, "orphans_rose": rose, "nudge": nudge}


def pulse_line(payload):
    """One-line human string for the weekly note."""
    def plural(n, word):
        return f"{n} {word}" + ("" if n == 1 else "s")
    # ASCII separators only — this line gets pasted through Windows pipes.
    line = (f"Vault health: {plural(payload['broken'], 'broken link')} | "
            f"{plural(payload['active_orphans'], 'active orphan')} | "
            f"{plural(payload['stale_mocs'], 'stale MOC')} | "
            f"{payload['inbox']} in inbox")
    if payload["nudge"]:
        line += " - run /vault-health for the full report"
    return line


# ---------------- CLI ----------------

def main(argv=None):
    import argparse
    import sys
    try:
        sys.stdout.reconfigure(encoding="utf-8")  # consistent UTF-8 JSON on Windows pipes
    except Exception:
        pass
    ap = argparse.ArgumentParser(description="Read-only vault-health scanner.")
    ap.add_argument("root", help="vault root path")
    ap.add_argument("--pulse", action="store_true", help="compact pulse JSON for the weekly review")
    ap.add_argument("--json", action="store_true", help="pretty-print the full report")
    ap.add_argument("--fix-plan", action="store_true", dest="fix_plan",
                    help="emit cosmetic-safe-subset fix plan (no writes)")
    ap.add_argument("--apply", action="store_true",
                    help="apply the cosmetic-safe-subset fixes (writes undo log)")
    ap.add_argument("--pulse-state", dest="pulse_state", default=None,
                    help="path to persist pulse counts for delta tracking")
    ap.add_argument("--undo", default=None, help="path to write the undo log for --apply")
    args = ap.parse_args(argv)

    if not os.path.isdir(args.root):
        print(json.dumps({"error": "vault root not found", "root": args.root}))
        return 1

    if args.fix_plan:
        print(json.dumps(compute_fix_plan(args.root), ensure_ascii=False, indent=2))
        return 0

    if args.apply:
        plan = compute_fix_plan(args.root)
        res = apply_fixes(args.root, plan, undo_path=args.undo)
        print(json.dumps(res, ensure_ascii=False, indent=2))
        return 0

    report = scan_vault(args.root)

    if args.pulse:
        prev = None
        if args.pulse_state and os.path.exists(args.pulse_state):
            try:
                with open(args.pulse_state, encoding="utf-8") as fh:
                    prev = json.load(fh)
            except Exception:
                prev = None
        payload = pulse_payload(report, prev)
        payload["line"] = pulse_line(payload)
        if args.pulse_state:
            try:
                parent = os.path.dirname(args.pulse_state)
                if parent:
                    os.makedirs(parent, exist_ok=True)
                with open(args.pulse_state, "w", encoding="utf-8") as fh:
                    json.dump(payload, fh, ensure_ascii=False)
            except Exception:
                pass
        print(json.dumps(payload, ensure_ascii=False))
        return 0

    print(json.dumps(report, ensure_ascii=False, indent=2 if args.json else None))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
