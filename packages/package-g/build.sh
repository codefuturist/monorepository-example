#!/usr/bin/env bash
# ==============================================================================
# Package G Build Script
# ==============================================================================

set -e

# Package configuration
export VERSION="1.0.0"
export PACKAGE_NAME="package-g"
export MAIN_FILE="./cmd/main.go"
export RELEASE_DIR="release"
export LDFLAGS="-s -w"
export BUILD_FLAGS=""
export TARGETS=(
    "linux:amd64:x86_64-unknown-linux-gnu"
    "linux:arm64:aarch64-unknown-linux-gnu"
    "darwin:amd64:x86_64-apple-darwin"
    "darwin:arm64:aarch64-apple-darwin"
    "windows:amd64:x86_64-pc-windows-msvc"
    "windows:arm64:aarch64-pc-windows-msvc"
)

# Use shared build script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_SCRIPT="$SCRIPT_DIR/../../scripts/build/go-build.sh"

if [[ -f "$SHARED_SCRIPT" ]]; then
    source "$SHARED_SCRIPT"
else
    echo "Error: Shared build script not found at $SHARED_SCRIPT"
    exit 1
fi
