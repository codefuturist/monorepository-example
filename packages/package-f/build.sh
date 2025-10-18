#!/usr/bin/env bash
# Build script for package-f (Swift)
# Builds release binaries (macOS only)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERSION="1.0.0"
PACKAGE_NAME="package-f"

echo "======================================"
echo "Building $PACKAGE_NAME v$VERSION"
echo "======================================"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "ERROR: Swift Package Manager executables require macOS"
    echo "Please build on a macOS system"
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    TARGET="aarch64-apple-darwin"
else
    TARGET="x86_64-apple-darwin"
fi

echo "Platform: $TARGET"
echo ""

# Build release binary
echo "Building release binary..."
swift build -c release

# Create release directory
RELEASE_DIR="release"
mkdir -p "$RELEASE_DIR"

# Copy binary with proper naming
BINARY_PATH=$(swift build -c release --show-bin-path)/package-f
BINARY_NAME="${PACKAGE_NAME}-${TARGET}"
cp "$BINARY_PATH" "$RELEASE_DIR/$BINARY_NAME"
chmod +x "$RELEASE_DIR/$BINARY_NAME"

# Create archives and checksums
cd "$RELEASE_DIR"
tar -czf "${PACKAGE_NAME}-${TARGET}.tar.gz" "$BINARY_NAME"
shasum -a 256 "${PACKAGE_NAME}-${TARGET}.tar.gz" > "${PACKAGE_NAME}-${TARGET}.tar.gz.sha256"
shasum -a 256 "$BINARY_NAME" > "${BINARY_NAME}.sha256"

cd "$SCRIPT_DIR"

echo ""
echo "✓ Build completed successfully!"
echo ""
echo "Release artifacts in: $RELEASE_DIR/"
ls -lh "$RELEASE_DIR"
echo ""
echo "To test: ./$RELEASE_DIR/$BINARY_NAME"
echo ""
echo "Note: Swift executables are macOS-only"
echo "For universal binary, use: swift build -c release --arch arm64 --arch x86_64"
echo ""
