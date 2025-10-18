#!/usr/bin/env bash
# ==============================================================================
# Package F Build Script (Swift)
# ==============================================================================

set -e

# Package configuration
export VERSION="1.0.0"
export PACKAGE_NAME="package-f"
export RELEASE_DIR="release"
export BUILD_CONFIG="release"
export SWIFT_FLAGS=""
export CREATE_UNIVERSAL="false"

# Use shared build script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_SCRIPT="$SCRIPT_DIR/../../scripts/build/swift-spm-build.sh"

if [[ -f "$SHARED_SCRIPT" ]]; then
    source "$SHARED_SCRIPT"
else
    echo "Error: Shared build script not found at $SHARED_SCRIPT"
    exit 1
fi
