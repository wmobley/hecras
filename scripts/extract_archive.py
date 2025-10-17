#!/usr/bin/env python3
"""Extract a user-supplied archive into a destination directory.

Supports ZIP and TAR (including compressed variants). Removes common macOS
metadata artifacts and flattens single top-level directories for convenience.
"""

from __future__ import annotations

import shutil
import sys
import tarfile
import zipfile
from pathlib import Path


def cleanup_mac_artifacts(root: Path) -> None:
    """Remove macOS-specific artifacts that may be present in archives."""
    for mac_dir in root.rglob("__MACOSX"):
        shutil.rmtree(mac_dir, ignore_errors=True)
    for ds_store in root.rglob(".DS_Store"):
        try:
            ds_store.unlink()
        except OSError:
            pass


def flatten_single_directory(root: Path) -> None:
    """If the archive had a single directory, move its contents up one level."""
    entries = [
        path for path in root.iterdir()
        if path.name not in {"__MACOSX"} and not path.name.startswith(".")
    ]
    if len(entries) == 1 and entries[0].is_dir():
        inner = entries[0]
        for child in inner.iterdir():
            shutil.move(str(child), root / child.name)
        shutil.rmtree(inner, ignore_errors=True)


def extract_archive(archive_path: Path, dest_dir: Path) -> None:
    """Extract the archive into dest_dir, handling supported formats."""
    dest_dir.mkdir(parents=True, exist_ok=True)
    if zipfile.is_zipfile(archive_path):
        with zipfile.ZipFile(archive_path) as zf:
            zf.extractall(dest_dir)
    elif tarfile.is_tarfile(archive_path):
        with tarfile.open(archive_path) as tf:
            tf.extractall(dest_dir)
    else:
        raise SystemExit(f"Unsupported archive format: {archive_path}")

    cleanup_mac_artifacts(dest_dir)
    flatten_single_directory(dest_dir)


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print("Usage: extract_archive.py <archive_path> <dest_dir>", file=sys.stderr)
        return 2

    archive_path = Path(argv[1]).resolve()
    dest_dir = Path(argv[2]).resolve()

    if not archive_path.exists():
        # Nothing to extract; not an error to simplify usage in run.sh.
        return 0

    extract_archive(archive_path, dest_dir)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
