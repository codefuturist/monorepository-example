#!/usr/bin/env bash
# Build script for package-e (Rust)
# Builds release binaries for multiple platforms

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "Building package-e executables"
echo "======================================"

# Detect platform
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
    TARGET="x86_64-unknown-linux-gnu"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
    TARGET="x86_64-apple-darwin"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    PLATFORM="windows"
    TARGET="x86_64-pc-windows-msvc"
else
    PLATFORM="unknown"
    TARGET=""
fi

echo "Platform: $PLATFORM"
echo "Target: $TARGET"
echo ""

# Build release binary
echo "Building release binary..."
cargo build --release

# Create dist directory
DIST_DIR="dist"
mkdir -p "$DIST_DIR"

# Copy binary to dist
if [[ "$PLATFORM" == "windows" ]]; then
    cp "target/release/package-e.exe" "$DIST_DIR/package-e-${PLATFORM}.exe"
else
    cp "target/release/package-e" "$DIST_DIR/package-e-${PLATFORM}"
    chmod +x "$DIST_DIR/package-e-${PLATFORM}"
fi

echo ""
echo "✓ Build completed successfully!"
echo ""
echo "Binary location: $DIST_DIR/package-e-${PLATFORM}"
echo ""
echo "To test: ./$DIST_DIR/package-e-${PLATFORM}"
echo ""
echo "For cross-compilation to other platforms:"
echo "  Linux:   cargo build --release --target x86_64-unknown-linux-gnu"
echo "  macOS:   cargo build --release --target x86_64-apple-darwin"
echo "  Windows: cargo build --release --target x86_64-pc-windows-msvc"
echo ""
