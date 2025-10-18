#!/usr/bin/env bash
# ==============================================================================
# REUSABLE PYTHON BUILD SCRIPT (PyInstaller)
# ==============================================================================
# This script can be used in any Python project with minimal configuration.
# Just update the CONFIGURATION section below.
#
# USAGE:
#   Copy this script to your project root and customize the CONFIGURATION section.
#   Or source this script and override variables before calling it.
# ==============================================================================

set -e

# ==============================================================================
# CONFIGURATION - UPDATE THESE VALUES FOR YOUR PROJECT
# ==============================================================================
VERSION="${VERSION:-1.0.0}"                                    # Project version
PACKAGE_NAME="${PACKAGE_NAME:-my-python-app}"                  # Package name (used for output files)
ENTRY_POINT="${ENTRY_POINT:-src/main.py}"                      # Main entry point file
RELEASE_DIR="${RELEASE_DIR:-release}"                          # Where final artifacts are stored

# PyInstaller configuration
PYINSTALLER_NAME="${PYINSTALLER_NAME:-$PACKAGE_NAME}"          # Name of the built executable
PYINSTALLER_FLAGS="${PYINSTALLER_FLAGS:---onefile}"            # PyInstaller flags (--onefile, --windowed, etc.)

# Dependencies to collect (space-separated)
# Format: "--add-data source:dest" or "--collect-all package"
if [[ -z "${PYINSTALLER_DATA[*]}" ]]; then
    PYINSTALLER_DATA=()  # Default: no additional data files
fi

# Runtime dependencies to install before building
BUILD_DEPS="${BUILD_DEPS:-pyinstaller}"

# ==============================================================================
# IMPLEMENTATION - REUSABLE ACROSS ALL PYTHON PROJECTS
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "Building $PACKAGE_NAME v$VERSION"
echo "======================================"

# Detect platform
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        TARGET="x86_64-unknown-linux-gnu"
    elif [[ "$ARCH" == "aarch64" ]]; then
        TARGET="aarch64-unknown-linux-gnu"
    else
        TARGET="${ARCH}-unknown-linux-gnu"
    fi
    EXT=""
elif [[ "$OSTYPE" == "darwin"* ]]; then
    ARCH=$(uname -m)
    if [[ "$ARCH" == "arm64" ]]; then
        TARGET="aarch64-apple-darwin"
    else
        TARGET="x86_64-apple-darwin"
    fi
    EXT=""
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" || "$ARCH" == "AMD64" ]]; then
        TARGET="x86_64-pc-windows-msvc"
    elif [[ "$ARCH" == "aarch64" || "$ARCH" == "ARM64" ]]; then
        TARGET="aarch64-pc-windows-msvc"
    else
        TARGET="x86_64-pc-windows-msvc"
    fi
    EXT=".exe"
else
    TARGET="unknown"
    EXT=""
fi

echo "Platform: $TARGET"
echo ""

# Install build dependencies
echo "Installing build dependencies..."
pip install -q $BUILD_DEPS

# Build for current platform
echo "Building executable for current platform..."
pyinstaller $PYINSTALLER_FLAGS \
    --name "$PYINSTALLER_NAME" \
    "${PYINSTALLER_DATA[@]}" \
    "$ENTRY_POINT"

# Create release directory
mkdir -p "$RELEASE_DIR"

# Copy and rename binary
BINARY_NAME="${PACKAGE_NAME}-${TARGET}${EXT}"
cp "dist/${PYINSTALLER_NAME}${EXT}" "$RELEASE_DIR/$BINARY_NAME"

# Create tar.gz (Unix) or zip (Windows)
cd "$RELEASE_DIR"
if [[ "$EXT" == ".exe" ]]; then
    # Windows: create zip
    zip "${PACKAGE_NAME}-${TARGET}.zip" "$BINARY_NAME"
    sha256sum "${PACKAGE_NAME}-${TARGET}.zip" > "${PACKAGE_NAME}-${TARGET}.zip.sha256"
else
    # Unix: create tar.gz
    tar -czf "${PACKAGE_NAME}-${TARGET}.tar.gz" "$BINARY_NAME"
    shasum -a 256 "${PACKAGE_NAME}-${TARGET}.tar.gz" > "${PACKAGE_NAME}-${TARGET}.tar.gz.sha256"
fi

# Create checksum for binary
if command -v sha256sum &> /dev/null; then
    sha256sum "$BINARY_NAME" > "${BINARY_NAME}.sha256"
else
    shasum -a 256 "$BINARY_NAME" > "${BINARY_NAME}.sha256"
fi

cd "$SCRIPT_DIR"

echo ""
echo "✓ Build completed successfully!"
echo ""
echo "Release artifacts in: $RELEASE_DIR/"
ls -lh "$RELEASE_DIR"
echo ""
