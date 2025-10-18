#!/usr/bin/env bash
# ==============================================================================
# REUSABLE C++ BUILD SCRIPT
# ==============================================================================
# This script can be used in any C++ project with minimal configuration.
# Just update the CONFIGURATION section below.
# ==============================================================================

set -e

# ==============================================================================
# CONFIGURATION - UPDATE THESE VALUES FOR YOUR PROJECT
# ==============================================================================
VERSION="1.0.0"                    # Project version
PACKAGE_NAME="package-d"           # Package name (used for output files)
CMAKE_TARGET_NAME="package_d_cli"  # CMake executable target name
BUILD_TYPE="Release"               # CMake build type: Release, Debug, RelWithDebInfo

# Directory configuration
BUILD_DIR="build-release"          # Where CMake builds the project
RELEASE_DIR="release"              # Where final artifacts are stored

# ==============================================================================
# IMPLEMENTATION - REUSABLE ACROSS ALL C++ PROJECTS
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "Building $PACKAGE_NAME v$VERSION"
echo "======================================"

# Detect OS and architecture
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
echo "Build directory: $BUILD_DIR"
echo ""

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure with CMake
echo "Configuring with CMake..."
cmake .. -DCMAKE_BUILD_TYPE="$BUILD_TYPE"

# Build
echo "Building..."
cmake --build . --config "$BUILD_TYPE"

# Create release directory
cd "$SCRIPT_DIR"
mkdir -p "$RELEASE_DIR"

# Copy executable with proper naming
BINARY_NAME="${PACKAGE_NAME}-${TARGET}${EXT}"
if [[ "$EXT" == ".exe" ]]; then
    cp "$BUILD_DIR/$BUILD_TYPE/${CMAKE_TARGET_NAME}.exe" "$RELEASE_DIR/$BINARY_NAME" 2>/dev/null || \
    cp "$BUILD_DIR/${CMAKE_TARGET_NAME}.exe" "$RELEASE_DIR/$BINARY_NAME"
else
    cp "$BUILD_DIR/${CMAKE_TARGET_NAME}" "$RELEASE_DIR/$BINARY_NAME"
    chmod +x "$RELEASE_DIR/$BINARY_NAME"
fi

# Create archives and checksums
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
echo ""
echo "Release artifacts in: $RELEASE_DIR/"
ls -lh "$RELEASE_DIR"
echo ""
echo "To test: ./$RELEASE_DIR/$BINARY_NAME"
echo ""
