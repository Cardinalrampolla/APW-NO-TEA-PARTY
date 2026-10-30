#!/usr/bin/env python3
"""Read-only APW Godot prototype source preflight. Does not push or modify files."""
import argparse
import os
from pathlib import Path
import subprocess
import sys

IGNORED_DIRS = {".git", ".godot", ".import", "__pycache__", "node_modules", "build", "dist"}
SENSITIVE_NAMES = {".env", ".env.local", ".env.production", "id_rsa", "id_ed25519", "credentials.json", "service-account.json"}
SENSITIVE_SUFFIXES = {".pem", ".p12", ".pfx", ".key"}
GODOT_SUFFIXES = {".gd", ".tscn", ".tres", ".godot", ".gdshader"}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("project", type=Path, help="Local Godot project directory")
    args = parser.parse_args()
    root = args.project.resolve()
    if not root.is_dir():
        print("FAIL: project directory does not exist", file=sys.stderr)
        return 2
    errors, warnings, source_files = [], [], []
    if not (root / "project.godot").is_file():
        errors.append("Missing project.godot: verify this is the Godot prototype root")
    for current, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in IGNORED_DIRS]
        for name in files:
            p = Path(current) / name
            rel = p.relative_to(root)
            if name.lower() in SENSITIVE_NAMES or p.suffix.lower() in SENSITIVE_SUFFIXES:
                errors.append(f"Potential secret file: {rel} (exclude and inspect before publishing)")
            if p.suffix.lower() in GODOT_SUFFIXES:
                source_files.append(rel)
            if p.stat().st_size > 25 * 1024 * 1024:
                warnings.append(f"Large file over 25 MiB: {rel}")
    if not source_files:
        errors.append("No Godot source files found")
    git = subprocess.run(["git", "-C", str(root), "status", "--short", "--untracked-files=all"],
                         capture_output=True, text=True, check=False) if _git_available() else None
    if git is None:
        warnings.append("Git unavailable; cannot inspect staged/untracked files")
    elif git.returncode:
        warnings.append("Git status failed; confirm repository root")
    else:
        for line in git.stdout.splitlines():
            path = line[3:].strip().strip('"')
            parts = set(Path(path).parts)
            if parts & {".godot", ".import", "__pycache__", "node_modules"}:
                errors.append(f"Generated/cache path in Git status: {path}")
    print(f"APW prototype preflight: {root}")
    print(f"Godot source files: {len(source_files)}")
    for warning in warnings:
        print("WARN:", warning)
    for error in errors:
        print("FAIL:", error)
    if errors:
        print("BLOCKED: inspect issues before publishing; no files changed")
        return 1
    print("PASS: basic source-layout/filename hygiene only; NOT a secrets-content scan or runtime test")
    return 0

def _git_available():
    try:
        return subprocess.run(["git", "--version"], capture_output=True, check=False).returncode == 0
    except OSError:
        return False

if __name__ == "__main__":
    raise SystemExit(main())
