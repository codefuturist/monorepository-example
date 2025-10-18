#!/usr/bin/env bash
# Build script for package-e (Rust)
# Builds release binaries for multiple platforms

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERSION="1.0.0"
PACKAGE_NAME="package-e"

echo "======================================"
echo "Building $PACKAGE_NAME v$VERSION"
echo "======================================"

# Detect platform and set Rust target
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
    TARGET="x86_64-unknown-linux-gnu"
    EXT=""
fi

echo "Platform: $TARGET"
echo ""

# Build release binary
echo "Building release binary..."
cargo build --release --target "$TARGET" 2>/dev/null || cargo build --release

# Create release directory
RELEASE_DIR="release"
mkdir -p "$RELEASE_DIR"

# Copy binary with proper naming
BINARY_NAME="${PACKAGE_NAME}-${TARGET}${EXT}"
if cargo build --release --target "$TARGET" 2>/dev/null; then
    cp "target/${TARGET}/release/${PACKAGE_NAME}${EXT}" "$RELEASE_DIR/$BINARY_NAME"
else
    cp "target/release/${PACKAGE_NAME}${EXT}" "$RELEASE_DIR/$BINARY_NAME"
fi

chmod +x "$RELEASE_DIR/$BINARY_NAME" 2>/dev/null || true

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
echo "For cross-compilation to other platforms, install targets:"
echo "  rustup target add aarch64-unknown-linux-gnu"
echo "  rustup target add x86_64-unknown-linux-gnu"
echo "  rustup target add aarch64-apple-darwin"
echo "  rustup target add x86_64-apple-darwin"
echo "  rustup target add x86_64-pc-windows-msvc"
echo ""
