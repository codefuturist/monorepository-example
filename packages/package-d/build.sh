#!/usr/bin/env bash
# Build script for package-d (C++)
# Builds executables for multiple platforms

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "Building package-d executables"
echo "======================================"

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    PLATFORM="windows"
else
    PLATFORM="unknown"
fi

BUILD_DIR="build-${PLATFORM}"
DIST_DIR="dist"

echo "Platform: $PLATFORM"
echo "Build directory: $BUILD_DIR"
echo ""

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure with CMake
echo "Configuring with CMake..."
cmake .. -DCMAKE_BUILD_TYPE=Release

# Build
echo "Building..."
cmake --build . --config Release

# Create dist directory and copy executable
cd "$SCRIPT_DIR"
mkdir -p "$DIST_DIR"

if [[ "$PLATFORM" == "windows" ]]; then
    cp "$BUILD_DIR/Release/package_d_cli.exe" "$DIST_DIR/package-d-${PLATFORM}.exe" 2>/dev/null || \
    cp "$BUILD_DIR/package_d_cli.exe" "$DIST_DIR/package-d-${PLATFORM}.exe"
else
    cp "$BUILD_DIR/package_d_cli" "$DIST_DIR/package-d-${PLATFORM}"
    chmod +x "$DIST_DIR/package-d-${PLATFORM}"
fi

echo ""
echo "✓ Build completed successfully!"
echo ""
echo "Binary location: $DIST_DIR/package-d-${PLATFORM}"
echo ""
echo "To test: ./$DIST_DIR/package-d-${PLATFORM}"
echo ""
