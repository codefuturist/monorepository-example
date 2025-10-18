#!/usr/bin/env bash
# ==============================================================================
# REUSABLE SWIFT BUILD SCRIPT
# ==============================================================================
# This script can be used in any Swift project with minimal configuration.
# Just update the configuration variables or set them as environment variables.
#
# Note: Swift Package Manager executables are macOS-only (requires Xcode/Swift toolchain)
# ==============================================================================

set -e

# ==============================================================================
# CONFIGURATION - Set via environment variables or use defaults
# ==============================================================================
VERSION="${VERSION:-1.0.0}"
PACKAGE_NAME="${PACKAGE_NAME:-my-swift-app}"
RELEASE_DIR="${RELEASE_DIR:-release}"

# Build options
BUILD_CONFIG="${BUILD_CONFIG:-release}"           # Build configuration (debug/release)
SWIFT_FLAGS="${SWIFT_FLAGS:-}"                     # Additional Swift build flags
CREATE_UNIVERSAL="${CREATE_UNIVERSAL:-false}"      # Create universal binary (arm64 + x86_64)

# ==============================================================================
# IMPLEMENTATION - REUSABLE ACROSS ALL SWIFT PROJECTS
# ==============================================================================

# Remember the package directory (where build.sh was called from)
PACKAGE_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================"
echo "Building $PACKAGE_NAME v$VERSION"
echo "======================================"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "ERROR: Swift Package Manager executables require macOS"
    echo "Please build on a macOS system with Xcode or Swift toolchain installed"
    echo ""
    echo "Alternatively, for Linux builds:"
    echo "  - Use official Swift Docker images"
    echo "  - Install Swift for Linux: https://swift.org/download/"
    exit 1
fi

# Check for Swift
if ! command -v swift &> /dev/null; then
    echo "ERROR: Swift is not installed"
    echo "Please install Swift/Xcode:"
    echo "  - Install Xcode from the App Store, or"
    echo "  - Install Swift toolchain: https://swift.org/download/"
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    TARGET="aarch64-apple-darwin"
else
    TARGET="x86_64-apple-darwin"
fi

echo "Build Platform: $TARGET"
echo "Build Configuration: $BUILD_CONFIG"
if [ "$CREATE_UNIVERSAL" = "true" ]; then
    echo "Universal Binary: Yes (arm64 + x86_64)"
else
    echo "Universal Binary: No (native architecture only)"
fi
echo ""

# Build release binary
echo "Building with Swift Package Manager..."
if [ "$CREATE_UNIVERSAL" = "true" ]; then
    # Build universal binary (requires Xcode 12.2+)
    echo "Creating universal binary for arm64 and x86_64..."
    swift build -c "$BUILD_CONFIG" --arch arm64 --arch x86_64 $SWIFT_FLAGS
    TARGET="universal-apple-darwin"
else
    # Build for native architecture
    swift build -c "$BUILD_CONFIG" $SWIFT_FLAGS
fi

# Get binary path
BINARY_PATH=$(swift build -c "$BUILD_CONFIG" --show-bin-path)/$PACKAGE_NAME

# Check if binary was created
if [ ! -f "$BINARY_PATH" ]; then
    echo ""
    echo "ERROR: Build failed - binary not found at $BINARY_PATH"
    echo ""
    exit 1
fi

# Create release directory
mkdir -p "$RELEASE_DIR"

# Copy binary with proper naming
BINARY_NAME="${PACKAGE_NAME}-${TARGET}"
cp "$BINARY_PATH" "$RELEASE_DIR/$BINARY_NAME"
chmod +x "$RELEASE_DIR/$BINARY_NAME"

# Create archives and checksums
cd "$RELEASE_DIR"
echo "Creating archive and checksums..."
tar -czf "${PACKAGE_NAME}-${TARGET}.tar.gz" "$BINARY_NAME"

if command -v sha256sum &> /dev/null; then
    sha256sum "${PACKAGE_NAME}-${TARGET}.tar.gz" > "${PACKAGE_NAME}-${TARGET}.tar.gz.sha256"
    sha256sum "$BINARY_NAME" > "${BINARY_NAME}.sha256"
else
    shasum -a 256 "${PACKAGE_NAME}-${TARGET}.tar.gz" > "${PACKAGE_NAME}-${TARGET}.tar.gz.sha256"
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
echo "Platform Requirements:"
echo "  - macOS (10.15+ for arm64, 10.13+ for x86_64)"
if [ "$CREATE_UNIVERSAL" = "true" ]; then
    echo "  - Universal binary runs on both Intel and Apple Silicon Macs"
else
    echo "  - Binary is architecture-specific ($ARCH)"
    echo "  - For universal binary, set CREATE_UNIVERSAL=true"
fi
echo ""
