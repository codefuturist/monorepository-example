#!/usr/bin/env bash
# Build script for package-a (Python)
# Builds standalone executables for multiple platforms using PyInstaller

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERSION="1.2.0"
PACKAGE_NAME="package-a"

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
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    TARGET="x86_64-pc-windows-msvc"
    EXT=".exe"
else
    TARGET="unknown"
    EXT=""
fi

echo "Platform: $TARGET"
echo ""

# Install build dependencies
echo "Installing build dependencies..."
pip install -q pyinstaller colorama

# Build for current platform
echo "Building executable for current platform..."
pyinstaller --onefile \
    --name "${PACKAGE_NAME}" \
    --add-data "src/package_a:package_a" \
    --collect-all colorama \
    src/package_a/__main__.py

# Create release directory
RELEASE_DIR="release"
mkdir -p "$RELEASE_DIR"

# Copy and rename binary
BINARY_NAME="${PACKAGE_NAME}-${TARGET}${EXT}"
cp "dist/${PACKAGE_NAME}${EXT}" "$RELEASE_DIR/$BINARY_NAME"

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
