#!/usr/bin/env python3
"""Build a Hermes plugin release bundle with the canonical Agent Feeds skill vendored."""

from __future__ import annotations

import argparse
import subprocess
import tempfile
import zipfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CORE_ROOT = ROOT.parent / "agentfeeds"
INCLUDE_PATHS = [
    "README.md",
    "LICENSE",
    "__init__.py",
    "plugin.yaml",
    "install.sh",
    "bin",
    "recipes",
    "pyproject.toml",
]
EXCLUDE_PARTS = {"__pycache__", ".pytest_cache", ".venv", "dist", "vendor"}
EXCLUDE_SUFFIXES = {".pyc", ".pyo"}


def should_include(path: Path) -> bool:
    return not any(part in EXCLUDE_PARTS for part in path.parts) and path.suffix not in EXCLUDE_SUFFIXES


def iter_plugin_files():
    for item in INCLUDE_PATHS:
        path = ROOT / item
        if not path.exists():
            continue
        if path.is_file():
            if should_include(path.relative_to(ROOT)):
                yield path
            continue
        for child in sorted(path.rglob("*")):
            if child.is_file() and should_include(child.relative_to(ROOT)):
                yield child


def build_canonical_skill_zip(core_root: Path, output: Path) -> None:
    builder = core_root / "scripts" / "bundle" / "build_skill_bundle.py"
    if not builder.exists():
        raise FileNotFoundError(f"canonical skill bundle builder not found: {builder}")
    subprocess.run(["python3", str(builder), "--output", str(output)], cwd=core_root, check=True)


def build_bundle(core_root: Path, output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    if output.exists():
        output.unlink()

    with tempfile.TemporaryDirectory() as tmp:
        skill_zip = Path(tmp) / "agentfeeds-skill.zip"
        build_canonical_skill_zip(core_root, skill_zip)

        with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED) as archive:
            for path in iter_plugin_files():
                archive.write(path, path.relative_to(ROOT))
            with zipfile.ZipFile(skill_zip) as skill_archive:
                for name in sorted(skill_archive.namelist()):
                    if name.endswith("/"):
                        continue
                    archive.writestr(f"vendor/agentfeeds-skill/{name}", skill_archive.read(name))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Build Agent Feeds Hermes plugin bundle")
    parser.add_argument("--core-root", type=Path, default=DEFAULT_CORE_ROOT)
    parser.add_argument("--output", type=Path, default=Path("dist") / "agentfeeds-hermes-plugin.zip")
    return parser


def main() -> int:
    args = build_parser().parse_args()
    build_bundle(args.core_root.expanduser().resolve(), args.output)
    print(f"wrote: {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
