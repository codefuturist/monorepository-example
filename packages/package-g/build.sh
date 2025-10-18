#!/usr/bin/env bash
# Build script for package-g (Go)
# Builds release binaries for multiple platforms

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERSION="1.0.0"
PACKAGE_NAME="package-g"

echo "======================================"
echo "Building $PACKAGE_NAME v$VERSION"
echo "======================================"

# Download dependencies
echo "Downloading dependencies..."
go mod download

RELEASE_DIR="release"
mkdir -p "$RELEASE_DIR"

# Define build targets matching Rust/Starship conventions
declare -a TARGETS=(
    "linux:amd64:x86_64-unknown-linux-gnu"
    "linux:arm64:aarch64-unknown-linux-gnu"
    "darwin:amd64:x86_64-apple-darwin"
    "darwin:arm64:aarch64-apple-darwin"
    "windows:amd64:x86_64-pc-windows-msvc"
    "windows:arm64:aarch64-pc-windows-msvc"
)

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
    
    if env GOOS="$GOOS" GOARCH="$GOARCH" go build -ldflags="-s -w" -o "$RELEASE_DIR/$OUTPUT_NAME" ./cmd/main.go; then
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
