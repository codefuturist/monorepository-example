#!/usr/bin/env bash
# Build script for package-c (Python)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "Building package-c executables"
echo "======================================"

echo "Installing build dependencies..."
pip install -q pyinstaller tabulate

echo "Building executable for current platform..."
pyinstaller --onefile \
    --name package-c \
    --add-data "src/package_c:package_c" \
    --collect-all tabulate \
    src/package_c/__main__.py

echo ""
echo "✓ Build completed successfully!"
echo "Binary location: dist/package-c"
echo ""
