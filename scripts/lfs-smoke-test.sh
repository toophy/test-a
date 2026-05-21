#!/usr/bin/env bash
set -euo pipefail

# Git LFS smoke test for this repository.
# Intended to run in GitHub Actions, where git-lfs and authenticated remotes are available.

echo "== Git version =="
git --version

echo "== Git LFS version =="
git lfs version

git lfs install --local

git lfs track "test-lfs/*.bin"
git lfs track "test-lfs/*.zip"

mkdir -p test-lfs

# On the first branch run, these files do not exist yet, so generate real payloads.
# On PR runs, they usually already exist as LFS pointer checkout files, so do not overwrite them.
if [[ ! -f test-lfs/lfs-smoke.bin ]]; then
  python3 - <<'PY'
from pathlib import Path
payload = (b"Git LFS smoke test payload for toophy/test-a\n" * 4096)
Path("test-lfs/lfs-smoke.bin").write_bytes(payload)
PY
fi

if [[ ! -f test-lfs/lfs-smoke.zip ]]; then
  python3 - <<'PY'
from pathlib import Path
import zipfile
source = Path("test-lfs/lfs-smoke.bin")
with zipfile.ZipFile("test-lfs/lfs-smoke.zip", "w", compression=zipfile.ZIP_DEFLATED) as zf:
    zf.write(source, arcname=source.name)
PY
fi

git add .gitattributes test-lfs/lfs-smoke.bin test-lfs/lfs-smoke.zip

echo "== Staged changes =="
git status --short

if ! git diff --cached --quiet; then
  git commit -m "test(lfs): add generated LFS smoke assets"
else
  echo "No new LFS files to commit."
fi

echo "== Git LFS tracked files =="
git lfs ls-files
tracked_count="$(git lfs ls-files | wc -l | tr -d ' ')"
if [[ "$tracked_count" -lt 2 ]]; then
  echo "Expected at least 2 Git LFS tracked files, got $tracked_count" >&2
  exit 1
fi

echo "== Verify files are stored as LFS pointers in git history =="
git cat-file -p HEAD:test-lfs/lfs-smoke.bin | grep -q "version https://git-lfs.github.com/spec/v1"
git cat-file -p HEAD:test-lfs/lfs-smoke.zip | grep -q "version https://git-lfs.github.com/spec/v1"

echo "== Local LFS fsck =="
if ! git lfs fsck; then
  echo "Local LFS objects are missing; downloading from the GitHub LFS store and retrying."
  git lfs pull --include="test-lfs/*" --exclude=""
  git lfs checkout
  git lfs fsck
fi

echo "Git LFS smoke test passed locally."
