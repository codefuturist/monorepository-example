#!/usr/bin/env bash
# Build script for package-b (Python)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "Building package-b executables"
echo "======================================"

echo "Installing build dependencies..."
pip install -q pyinstaller rich

echo "Building executable for current platform..."
pyinstaller --onefile \
    --name package-b \
    --add-data "src/package_b:package_b" \
    --collect-all rich \
    src/package_b/__main__.py

echo ""
echo "✓ Build completed successfully!"
echo "Binary location: dist/package-b"
echo ""
