#!/usr/bin/env bash
# ==============================================================================
# Package C Build Script
# ==============================================================================

set -e

# Package configuration
export VERSION="1.0.0"
export PACKAGE_NAME="package-c"
export ENTRY_POINT="src/package_c/__main__.py"
export RELEASE_DIR="release"
export PYINSTALLER_NAME="$PACKAGE_NAME"
export PYINSTALLER_FLAGS="--onefile"
export PYINSTALLER_DATA=(
    "--add-data src/package_c:package_c"
    "--collect-all tabulate"
)
export BUILD_DEPS="pyinstaller tabulate"

# Use shared build script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_SCRIPT="$SCRIPT_DIR/../../scripts/build/python-pyinstaller-build.sh"

if [[ -f "$SHARED_SCRIPT" ]]; then
    source "$SHARED_SCRIPT"
else
    echo "Error: Shared build script not found at $SHARED_SCRIPT"
    exit 1
fi
