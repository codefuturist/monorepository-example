#!/usr/bin/env bash
# ==============================================================================
# REUSABLE GO BUILD SCRIPT
# ==============================================================================
# This script can be used in any Go project with minimal configuration.
# Just update the CONFIGURATION section below.
# ==============================================================================

set -e

# ==============================================================================
# CONFIGURATION - UPDATE THESE VALUES FOR YOUR PROJECT
# ==============================================================================
VERSION="1.0.0"                # Project version
PACKAGE_NAME="package-g"       # Package name (used for output files)
MAIN_FILE="./cmd/main.go"      # Path to main.go file
RELEASE_DIR="release"          # Where final artifacts are stored

# Build options
LDFLAGS="-s -w"                # Linker flags (strip debug info for smaller binaries)
BUILD_FLAGS=""                 # Additional go build flags

# Build targets (GOOS:GOARCH:TARGET_NAME)
# Modify this array to add/remove platforms
TARGETS=(
    "linux:amd64:x86_64-unknown-linux-gnu"
    "linux:arm64:aarch64-unknown-linux-gnu"
    "darwin:amd64:x86_64-apple-darwin"
    "darwin:arm64:aarch64-apple-darwin"
    "windows:amd64:x86_64-pc-windows-msvc"
    "windows:arm64:aarch64-pc-windows-msvc"
)

# ==============================================================================
# IMPLEMENTATION - REUSABLE ACROSS ALL GO PROJECTS
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "Building $PACKAGE_NAME v$VERSION"
echo "======================================"

# Download dependencies
echo "Downloading dependencies..."
go mod download

mkdir -p "$RELEASE_DIR"

echo ""
echo "Building for multiple platforms..."
echo ""

for TARGET_SPEC in "${TARGETS[@]}"; do
    IFS=':' read -r GOOS GOARCH RUST_TARGET <<< "$TARGET_SPEC"
    
    OUTPUT_NAME="${PACKAGE_NAME}-${RUST_TARGET}"
    if [ "$GOOS" = "windows" ]; then
        OUTPUT_NAME="${OUTPUT_NAME}.exe"
    fi
    
    echo "Building for $RUST_TARGET (GOOS=$GOOS GOARCH=$GOARCH)..."
    
    if env GOOS="$GOOS" GOARCH="$GOARCH" go build -ldflags="$LDFLAGS" $BUILD_FLAGS -o "$RELEASE_DIR/$OUTPUT_NAME" "$MAIN_FILE"; then
        echo "  ✓ $OUTPUT_NAME"
        
        # Create archive and checksum
        cd "$RELEASE_DIR"
        if [ "$GOOS" = "windows" ]; then
            zip "${PACKAGE_NAME}-${RUST_TARGET}.zip" "$OUTPUT_NAME"
            sha256sum "${PACKAGE_NAME}-${RUST_TARGET}.zip" > "${PACKAGE_NAME}-${RUST_TARGET}.zip.sha256" 2>/dev/null || \
            shasum -a 256 "${PACKAGE_NAME}-${RUST_TARGET}.zip" > "${PACKAGE_NAME}-${RUST_TARGET}.zip.sha256"
        else
            tar -czf "${PACKAGE_NAME}-${RUST_TARGET}.tar.gz" "$OUTPUT_NAME"
            shasum -a 256 "${PACKAGE_NAME}-${RUST_TARGET}.tar.gz" > "${PACKAGE_NAME}-${RUST_TARGET}.tar.gz.sha256" 2>/dev/null || \
            sha256sum "${PACKAGE_NAME}-${RUST_TARGET}.tar.gz" > "${PACKAGE_NAME}-${RUST_TARGET}.tar.gz.sha256"
        fi
        
        # Binary checksum
        if command -v sha256sum &> /dev/null; then
            sha256sum "$OUTPUT_NAME" > "${OUTPUT_NAME}.sha256"
        else
            shasum -a 256 "$OUTPUT_NAME" > "${OUTPUT_NAME}.sha256"
        fi
        
        cd "$SCRIPT_DIR"
    else
        echo "  ✗ Failed to build for $RUST_TARGET"
    fi
done

echo ""
echo "✓ Build completed successfully!"
echo ""
echo "Release artifacts created in: $RELEASE_DIR/"
ls -lh "$RELEASE_DIR" | grep -E '\.(tar\.gz|zip|sha256)$' || ls -lh "$RELEASE_DIR"
echo ""
