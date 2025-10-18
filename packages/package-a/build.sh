#!/usr/bin/env bash
# Build script for package-a (Python)
# Builds standalone executables for multiple platforms using PyInstaller

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "Building package-a executables"
echo "======================================"

# Install build dependencies
echo "Installing build dependencies..."
pip install -q pyinstaller colorama

# Build for current platform
echo "Building executable for current platform..."
pyinstaller --onefile \
    --name package-a \
    --add-data "src/package_a:package_a" \
    --collect-all colorama \
    src/package_a/__main__.py

echo ""
echo "✓ Build completed successfully!"
echo ""
echo "Binary location: dist/package-a"
echo ""
echo "To build for multiple platforms:"
echo "  - Run this script on each target OS (Linux, macOS, Windows)"
echo "  - Or use Docker/CI for cross-platform builds"
echo ""
