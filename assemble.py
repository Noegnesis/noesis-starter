#!/usr/bin/env python3
"""assemble.py - deterministic module assembler for noesis-starter (Phase 2).

Reads module docs from modules/ (see modules/README.md for the schema),
validates them, resolves depends_on, renders {{key}} placeholders from an
answers file, and builds the selected modules into a vault. Dry-run by
default; --execute to write. Zero LLM tokens; no personal data lives here.

CLI:
  python assemble.py --validate [--modules modules/]
  python assemble.py --select daily,projects --answers answers.yaml \
      --dest <vault> [--modules modules/] [--execute]
"""
import argparse
import datetime
import re
import shutil
import sys
from pathlib import Path

try:
    import yaml
except ImportError:  # pragma: no cover
    yaml = None

TIERS = ("core", "persona", "advanced")
REQUIRED_SECTIONS = ("Concept", "Applies when", "Questions", "Creates",
                     "CLAUDE.md snippet")
OPTIONAL_SECTIONS = ("Slash commands", "Files", "Memory rules")
MARK_START = "<!-- noesis:modules:start -->"
MARK_END = "<!-- noesis:modules:end -->"

_Q_RE = re.compile(r"^- (?P<key>[a-z][a-z0-9_]*) — (?P<prompt>.+?)"
                   r"(?: \(default: (?P<default>.*)\))?$")
_SEED_RE = re.compile(r"^- (?P<path>\S+) — (?P<desc>.+)$")
_FILE_RE = re.compile(r"^- `(?P<src>[^`]+)`(?: → `(?P<dest>[^`]+)`)?$")
_FENCE_RE = re.compile(r"^```")


class ModuleError(Exception):
    pass


def _split_frontmatter(text, path):
    if not text.startswith("---"):
        raise ModuleError(f"{path}: no frontmatter block")
    end = text.find("\n---", 3)
    if end == -1:
        raise ModuleError(f"{path}: unterminated frontmatter")
    if yaml is None:
        raise ModuleError("pyyaml not installed (pip install -r requirements.txt)")
    try:
        fm = yaml.safe_load(text[3:end]) or {}
    except yaml.YAMLError as e:
        raise ModuleError(f"{path}: invalid frontmatter YAML: {e}")
    if not isinstance(fm, dict):
        raise ModuleError(f"{path}: frontmatter must be a YAML mapping")
    return fm, text[end + 4:]


def _split_sections(body):
    """{section title: text} for every '## ' heading in the body."""
    sections = {}
    current, lines = None, []
    for line in body.splitlines():
        if line.startswith("## "):
            if current is not None:
                sections[current] = "\n".join(lines).strip("\n")
            current, lines = line[3:].strip(), []
        elif current is not None:
            lines.append(line)
    if current is not None:
        sections[current] = "\n".join(lines).strip("\n")
    return sections


def parse_module(path):
    path = Path(path)
    fm, body = _split_frontmatter(path.read_text(encoding="utf-8"), path.name)
    return {"fm": fm, "sections": _split_sections(body), "path": path}


def parse_questions(text):
    out = []
    for line in (text or "").splitlines():
        line = line.rstrip()
        if not line.startswith("- "):
            continue
        m = _Q_RE.match(line)
        if m:
            out.append({"key": m.group("key"), "prompt": m.group("prompt"),
                        "default": m.group("default")})
    return out


def parse_creates(text):
    folders, seeds = [], []
    lines = (text or "").splitlines()
    i = 0
    while i < len(lines):
        line = lines[i].rstrip()
        if line.startswith("- ") and line.endswith("/"):
            folders.append(line[2:])
        else:
            m = _SEED_RE.match(line)
            if m:
                content = None
                if i + 1 < len(lines) and _FENCE_RE.match(lines[i + 1]):
                    fence_body = []
                    i += 2
                    while i < len(lines) and not _FENCE_RE.match(lines[i]):
                        fence_body.append(lines[i])
                        i += 1
                    content = "\n".join(fence_body)
                seeds.append({"path": m.group("path"), "desc": m.group("desc"),
                              "content": content})
        i += 1
    return {"folders": folders, "seeds": seeds}


def parse_files(text):
    out = []
    for line in (text or "").splitlines():
        m = _FILE_RE.match(line.rstrip())
        if m:
            out.append({"src": m.group("src"),
                        "dest": m.group("dest") or m.group("src")})
    return out


def _first_fence(text):
    lines = (text or "").splitlines()
    for i, line in enumerate(lines):
        if _FENCE_RE.match(line):
            for j in range(i + 1, len(lines)):
                if _FENCE_RE.match(lines[j]):
                    return "\n".join(lines[i + 1:j])
    return None


def validate_module(mod):
    problems = []
    fm, sections, path = mod["fm"], mod["sections"], mod["path"]
    mid = fm.get("id")
    if not mid or not re.fullmatch(r"[a-z][a-z0-9-]*", str(mid)):
        problems.append(f"{path.name}: id must be kebab-case, got {mid!r}")
    elif mid != path.stem:
        problems.append(f"{path.name}: id '{mid}' does not match filename")
    if fm.get("tier") not in TIERS:
        problems.append(f"{path.name}: tier must be one of {'|'.join(TIERS)}, "
                        f"got {fm.get('tier')!r}")
    if not fm.get("title"):
        problems.append(f"{path.name}: title is required")
    for key in ("depends_on", "suggests"):
        if key in fm and not isinstance(fm[key], list):
            problems.append(f"{path.name}: {key} must be a list")
    for sec in REQUIRED_SECTIONS:
        if sec not in sections:
            problems.append(f"{path.name}: missing section: {sec}")
    if "CLAUDE.md snippet" in sections and _first_fence(
            sections["CLAUDE.md snippet"]) is None:
        problems.append(f"{path.name}: CLAUDE.md snippet has no fenced block")
    for f in parse_files(sections.get("Files", "")):
        if not (Path(__file__).resolve().parent / f["src"]).exists():
            problems.append(f"{path.name}: Files source missing from repo: "
                            f"{f['src']}")
    return problems


def load_modules(modules_dir):
    modules_dir = Path(modules_dir)
    mods = {}
    for p in sorted(modules_dir.glob("*.md")):
        if p.name == "README.md":
            continue
        mod = parse_module(p)
        mods[mod["fm"].get("id") or p.stem] = mod
    return mods


def _cmd_validate(modules_dir):
    modules_dir = Path(modules_dir)
    problems, ids = [], []
    for p in sorted(modules_dir.glob("*.md")):
        if p.name == "README.md":
            continue
        try:
            mod = parse_module(p)
        except ModuleError as e:
            problems.append(str(e))
            continue
        problems.extend(validate_module(mod))
        ids.append(mod["fm"].get("id") or p.stem)
    if problems:
        for prob in problems:
            print(f"problem: {prob}")
        return 1
    print(f"modules OK: {len(ids)} module(s): {', '.join(sorted(ids))}")
    return 0


def resolve(selected, mods):
    """Topological order over selected + transitive depends_on.
    Kahn's algorithm with the ready list kept sorted -> deterministic."""
    needed, stack = set(), list(selected)
    while stack:
        mid = stack.pop()
        if mid in needed:
            continue
        if mid not in mods:
            raise ModuleError(f"unknown module id: {mid}")
        needed.add(mid)
        stack.extend(mods[mid]["fm"].get("depends_on") or [])
    deps = {m: [d for d in (mods[m]["fm"].get("depends_on") or []) if d in needed]
            for m in needed}
    order, ready = [], sorted(m for m in needed if not deps[m])
    while ready:
        mid = ready.pop(0)
        order.append(mid)
        newly = []
        for m in needed:
            if m not in order and m not in ready and mid in deps[m]:
                deps[m] = [d for d in deps[m] if d != mid]
                if not deps[m]:
                    newly.append(m)
        ready = sorted(ready + newly)
    if len(order) != len(needed):
        stuck = sorted(needed - set(order))
        raise ModuleError(f"dependency cycle involving: {', '.join(stuck)}")
    return order


def render(text, module_id, answers, questions):
    """Fill {{key}} from answers[module_id][key], else the question default.
    Returns (rendered, missing) where missing entries are 'module.key'."""
    bykey = {q["key"]: q for q in questions}
    mod_answers = (answers or {}).get(module_id) or {}
    missing = []

    def _sub(m):
        key = m.group(1)
        if key in mod_answers and mod_answers[key] is not None:
            return str(mod_answers[key])
        q = bykey.get(key)
        if q and q.get("default") is not None:
            return q["default"]
        missing.append(f"{module_id}.{key}")
        return m.group(0)

    return re.sub(r"\{\{([a-z][a-z0-9_]*)\}\}", _sub, text or ""), missing


def build_plan(order, mods, answers):
    folders, seeds, copies, blocks, errors = [], [], [], [], []
    for mid in order:
        mod = mods[mid]
        qs = parse_questions(mod["sections"].get("Questions", ""))
        creates = parse_creates(mod["sections"].get("Creates", ""))
        for f in creates["folders"]:
            if f not in folders:
                folders.append(f)
        for s in creates["seeds"]:
            content = s["content"] if s["content"] is not None else f"# {s['desc']}"
            rendered, miss = render(content, mid, answers, qs)
            errors.extend(f"missing answer: {k}" for k in miss)
            seeds.append({"path": s["path"], "content": rendered})
        copies.extend(parse_files(mod["sections"].get("Files", "")))
        snippet, miss = render(_first_fence(
            mod["sections"]["CLAUDE.md snippet"]) or "", mid, answers, qs)
        errors.extend(f"missing answer: {k}" for k in miss)
        block = f"### {mod['fm'].get('title', mid)}\n{snippet}"
        rules, miss2 = render(mod["sections"].get("Memory rules", ""), mid,
                              answers, qs)
        errors.extend(f"missing answer: {k}" for k in miss2)
        if rules.strip():
            block += "\n" + rules.strip()
        blocks.append(block)
    region = (MARK_START + "\n"
              + "<!-- Assembled by assemble.py — re-run it to update; "
                "edit outside this region. -->\n\n"
              + "\n\n".join(blocks) + "\n" + MARK_END)
    return {"order": order, "folders": folders, "seeds": seeds,
            "copies": copies, "region": region, "errors": errors}


def _load_answers(path):
    if not path:
        return {}
    p = Path(path)
    if not p.exists():
        raise ModuleError(f"answers file not found: {p}")
    data = yaml.safe_load(p.read_text(encoding="utf-8")) or {}
    if not isinstance(data, dict):
        raise ModuleError("answers file must be a YAML mapping of module ids")
    return data


def _print_plan(plan, dest):
    print(f"assemble plan -> {dest}")
    print(f"modules ({len(plan['order'])}): {', '.join(plan['order'])}")
    print("folders:")
    for f in plan["folders"]:
        print(f"  {f}")
    for s in plan["seeds"]:
        print(f"seed: {s['path']}")
    for c in plan["copies"]:
        print(f"copy: {c['src']} -> {c['dest']}")
    print("--- CLAUDE.md managed region ---")
    print(plan["region"])


def upsert_region(existing, region):
    if existing is None:
        return region + "\n", "created"
    if MARK_START in existing and MARK_END in existing:
        if existing.index(MARK_END) < existing.index(MARK_START):
            raise ModuleError("CLAUDE.md managed-region markers are malformed "
                              "(end marker precedes start) — fix the file and re-run")
        head = existing.split(MARK_START, 1)[0]
        tail = existing.split(MARK_END, 1)[1]
        return head + region + tail, "replaced"
    sep = "" if existing.endswith("\n\n") else ("\n" if existing.endswith("\n") else "\n\n")
    return existing + sep + region + "\n", "appended"


def _old_region_titles(existing):
    if not existing or MARK_START not in existing or MARK_END not in existing:
        return []
    region = existing.split(MARK_START, 1)[1].split(MARK_END, 1)[0]
    return [line[4:].strip() for line in region.splitlines()
            if line.startswith("### ")]


def _contained(dest, relpath):
    target = (dest / relpath).resolve()
    dest = dest.resolve()
    return target == dest or dest in target.parents


def _apply_plan(plan, dest):
    dest = Path(dest)
    escapes = [p for p in (plan["folders"]
                           + [s["path"] for s in plan["seeds"]]
                           + [c["dest"] for c in plan["copies"]])
               if not _contained(dest, p)]
    if escapes:
        for p in escapes:
            print(f"problem: path escapes the vault: {p}")
        return 1
    dest.mkdir(parents=True, exist_ok=True)
    for folder in plan["folders"]:
        (dest / folder).mkdir(parents=True, exist_ok=True)
        print(f"folder: {folder}")
    for seed in plan["seeds"]:
        target = dest / seed["path"]
        if target.exists():
            print(f"seed: {seed['path']} — skip (exists)")
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(seed["content"] + "\n", encoding="utf-8")
        print(f"seed: {seed['path']} — written")
    repo_root = Path(__file__).resolve().parent
    for copy in plan["copies"]:
        target = dest / copy["dest"]
        if target.exists():
            print(f"copy: {copy['dest']} — skip (exists)")
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(repo_root / copy["src"], target)
        print(f"copy: {copy['src']} -> {copy['dest']}")
    claude = dest / "CLAUDE.md"
    existing = claude.read_text(encoding="utf-8") if claude.exists() else None
    new_titles = {line[4:].strip() for line in plan["region"].splitlines()
                  if line.startswith("### ")}
    for title in _old_region_titles(existing):
        if title not in new_titles:
            print(f"orphaned: {title} (folders left in place)")
    if existing is not None:
        stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
        shutil.copyfile(claude, dest / f"CLAUDE.md.bak.{stamp}")
    try:
        new_text, action = upsert_region(existing, plan["region"])
    except ModuleError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    claude.write_text(new_text, encoding="utf-8")
    print(f"CLAUDE.md region: {action}")
    return 0


def main(argv=None):
    p = argparse.ArgumentParser(description="noesis module assembler")
    p.add_argument("--modules", default=str(Path(__file__).resolve().parent / "modules"))
    p.add_argument("--validate", action="store_true")
    p.add_argument("--select", default="")
    p.add_argument("--answers", default="")
    p.add_argument("--dest", default="")
    p.add_argument("--execute", action="store_true",
                   help="actually write (default: dry-run)")
    args = p.parse_args(argv)

    if args.validate:
        return _cmd_validate(args.modules)
    if not args.select or not args.dest:
        p.error("build mode needs --select and --dest (or use --validate)")
    try:
        mods = load_modules(args.modules)
        problems = []
        for mod in mods.values():
            problems.extend(validate_module(mod))
        if problems:
            for prob in problems:
                print(f"problem: {prob}")
            return 1
        selected = [s.strip() for s in args.select.split(",") if s.strip()]
        order = resolve(selected, mods)
        plan = build_plan(order, mods, _load_answers(args.answers))
    except ModuleError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1
    if plan["errors"]:
        for err in plan["errors"]:
            print(f"problem: {err}")
        return 1
    _print_plan(plan, args.dest)
    if not args.execute:
        print("\n(dry-run — nothing written. add --execute to build.)")
        return 0
    return _apply_plan(plan, Path(args.dest))


if __name__ == "__main__":
    sys.exit(main())
