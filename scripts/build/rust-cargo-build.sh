#!/usr/bin/env bash
# ==============================================================================
# REUSABLE RUST BUILD SCRIPT (Cargo)
# ==============================================================================
# This script can be used in any Rust project with minimal configuration.
# Just update the CONFIGURATION section below.
#
# USAGE:
#   Copy this script to your project root and customize the CONFIGURATION section.
#   Or source this script and override variables before calling it.
# ==============================================================================

set -e

# ==============================================================================
# CONFIGURATION - UPDATE THESE VALUES FOR YOUR PROJECT
# ==============================================================================
VERSION="${VERSION:-1.0.0}"                    # Project version
PACKAGE_NAME="${PACKAGE_NAME:-my-rust-app}"    # Package/binary name (from Cargo.toml)
RELEASE_DIR="${RELEASE_DIR:-release}"          # Where final artifacts are stored

# Build options
CARGO_FLAGS="${CARGO_FLAGS:-}"                 # Additional cargo build flags (e.g., "--features xyz")

# ==============================================================================
# IMPLEMENTATION - REUSABLE ACROSS ALL RUST PROJECTS
# ==============================================================================

# Remember the package directory (where build.sh was called from)
PACKAGE_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    TARGET="x86_64-unknown-linux-gnu"
    EXT=""
fi

echo "Platform: $TARGET"
echo ""

# Build release binary
echo "Building release binary..."
cargo build --release --target "$TARGET" $CARGO_FLAGS 2>/dev/null || cargo build --release $CARGO_FLAGS

# Create release directory
mkdir -p "$RELEASE_DIR"

# Copy binary with proper naming
BINARY_NAME="${PACKAGE_NAME}-${TARGET}${EXT}"
if cargo build --release --target "$TARGET" $CARGO_FLAGS 2>/dev/null; then
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
echo "  rustup target add aarch64-pc-windows-msvc"
echo ""
