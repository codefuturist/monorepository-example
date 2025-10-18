#!/usr/bin/env bash
# Build script for package-b (Python)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERSION="1.0.0"
PACKAGE_NAME="package-b"

echo "======================================"
echo "Building $PACKAGE_NAME v$VERSION"
echo "======================================"

# Detect platform
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ARCH=$(uname -m)
    TARGET="${ARCH}-unknown-linux-gnu"
    EXT=""
elif [[ "$OSTYPE" == "darwin"* ]]; then
    ARCH=$(uname -m)
    [[ "$ARCH" == "arm64" ]] && TARGET="aarch64-apple-darwin" || TARGET="x86_64-apple-darwin"
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

echo "Installing build dependencies..."
pip install -q pyinstaller rich

echo "Building executable for current platform..."
pyinstaller --onefile \
    --name "${PACKAGE_NAME}" \
    --add-data "src/package_b:package_b" \
    --collect-all rich \
    src/package_b/__main__.py

RELEASE_DIR="release"
mkdir -p "$RELEASE_DIR"

BINARY_NAME="${PACKAGE_NAME}-${TARGET}${EXT}"
cp "dist/${PACKAGE_NAME}${EXT}" "$RELEASE_DIR/$BINARY_NAME"

cd "$RELEASE_DIR"
if [[ "$EXT" == ".exe" ]]; then
    zip "${PACKAGE_NAME}-${TARGET}.zip" "$BINARY_NAME"
    sha256sum "${PACKAGE_NAME}-${TARGET}.zip" > "${PACKAGE_NAME}-${TARGET}.zip.sha256"
else
    tar -czf "${PACKAGE_NAME}-${TARGET}.tar.gz" "$BINARY_NAME"
    shasum -a 256 "${PACKAGE_NAME}-${TARGET}.tar.gz" > "${PACKAGE_NAME}-${TARGET}.tar.gz.sha256"
fi

if command -v sha256sum &> /dev/null; then
    sha256sum "$BINARY_NAME" > "${BINARY_NAME}.sha256"
else
    shasum -a 256 "$BINARY_NAME" > "${BINARY_NAME}.sha256"
fi

cd "$SCRIPT_DIR"

echo ""
echo "✓ Build completed successfully!"
echo "Release artifacts in: $RELEASE_DIR/"
ls -lh "$RELEASE_DIR"
echo ""
