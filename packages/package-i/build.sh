#!/usr/bin/env bash
# ==============================================================================
# Package I Build Script
# ==============================================================================

set -e

# Package configuration
export VERSION="1.0.0"
export PACKAGE_NAME="package-i"
export RELEASE_DIR="release"
export CARGO_FLAGS=""

# Use shared build script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_SCRIPT="$SCRIPT_DIR/../../scripts/build/rust-cargo-build.sh"

if [[ -f "$SHARED_SCRIPT" ]]; then
    source "$SHARED_SCRIPT"
else
    echo "Error: Shared build script not found at $SHARED_SCRIPT"
    exit 1
fi
