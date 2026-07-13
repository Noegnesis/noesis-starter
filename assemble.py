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
import re
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
    try:
        mods = load_modules(modules_dir)
    except ModuleError as e:
        print(f"problem: {e}", file=sys.stderr)
        return 1
    problems = []
    for mod in mods.values():
        problems.extend(validate_module(mod))
    if problems:
        for prob in problems:
            print(f"problem: {prob}")
        return 1
    print(f"modules OK: {len(mods)} module(s): {', '.join(sorted(mods))}")
    return 0


def main(argv=None):
    p = argparse.ArgumentParser(description="noesis module assembler")
    p.add_argument("--modules", default=str(Path(__file__).resolve().parent / "modules"))
    p.add_argument("--validate", action="store_true")
    args = p.parse_args(argv)
    if args.validate:
        return _cmd_validate(args.modules)
    p.error("nothing to do — pass --validate (build mode arrives in a later task)")


if __name__ == "__main__":
    sys.exit(main())
