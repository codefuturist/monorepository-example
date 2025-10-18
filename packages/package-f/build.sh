#!/usr/bin/env bash
# Build script for package-f (Swift)
# Builds release binaries (macOS only)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "Building package-f executables"
echo "======================================"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "ERROR: Swift Package Manager executables require macOS"
    echo "Please build on a macOS system"
    exit 1
fi

echo "Platform: macOS"
echo ""

# Build release binary
echo "Building release binary..."
swift build -c release

# Create dist directory
DIST_DIR="dist"
mkdir -p "$DIST_DIR"

# Copy binary to dist
BINARY_PATH=$(swift build -c release --show-bin-path)/package-f
cp "$BINARY_PATH" "$DIST_DIR/package-f-macos"
chmod +x "$DIST_DIR/package-f-macos"

echo ""
echo "✓ Build completed successfully!"
echo ""
echo "Binary location: $DIST_DIR/package-f-macos"
echo ""
echo "To test: ./$DIST_DIR/package-f-macos"
echo ""
echo "Note: Swift executables are currently macOS-only"
echo "For iOS deployment, use Xcode to build for iOS targets"
echo ""
