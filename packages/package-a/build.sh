#!/usr/bin/env bash
# ==============================================================================
# Package A Build Script
# ==============================================================================

set -e

# Package configuration
export VERSION="1.2.0"
export PACKAGE_NAME="package-a"
export ENTRY_POINT="src/package_a/__main__.py"
export RELEASE_DIR="release"
export PYINSTALLER_NAME="$PACKAGE_NAME"
export PYINSTALLER_FLAGS="--onefile"
export PYINSTALLER_DATA=(
    "--add-data src/package_a:package_a"
    "--collect-all colorama"
)
export BUILD_DEPS="pyinstaller colorama"

# Use shared build script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_SCRIPT="$SCRIPT_DIR/../../scripts/build/python-pyinstaller-build.sh"

if [[ -f "$SHARED_SCRIPT" ]]; then
    source "$SHARED_SCRIPT"
else
    echo "Error: Shared build script not found at $SHARED_SCRIPT"
    exit 1
fi
