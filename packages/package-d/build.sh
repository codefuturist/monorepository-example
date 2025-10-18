#!/usr/bin/env bash
# ==============================================================================
# Package D Build Script
# ==============================================================================
# This script uses the shared C++ build script with project-specific configuration.
# ==============================================================================

set -e

# ==============================================================================
# PACKAGE CONFIGURATION
# ==============================================================================
export VERSION="1.0.0"
export PACKAGE_NAME="package-d"
export CMAKE_TARGET_NAME="package_d_cli"
export BUILD_TYPE="Release"
export BUILD_DIR="build-release"
export RELEASE_DIR="release"

# ==============================================================================
# EXECUTION - Use shared build script
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_SCRIPT="$SCRIPT_DIR/../../scripts/build/cpp-cmake-build.sh"

if [[ -f "$SHARED_SCRIPT" ]]; then
    # Use shared script
    source "$SHARED_SCRIPT"
else
    echo "Error: Shared build script not found at $SHARED_SCRIPT"
    exit 1
fi
