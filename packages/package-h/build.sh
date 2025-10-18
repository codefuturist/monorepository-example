#!/usr/bin/env bash
# ==============================================================================
# Package H Build Script (Java/Maven)
# ==============================================================================

set -e

# Package configuration
export VERSION="1.0.0"
export PACKAGE_NAME="package-h"
export RELEASE_DIR="release"
export MAVEN_ARGS="-DskipTests"
export MAVEN_GOALS="clean package"
export JAR_NAME="package-h.jar"
export CREATE_UNIVERSAL="true"
export CREATE_PLATFORM_TAGGED="true"

# Use shared build script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_SCRIPT="$SCRIPT_DIR/../../scripts/build/java-maven-build.sh"

if [[ -f "$SHARED_SCRIPT" ]]; then
    source "$SHARED_SCRIPT"
else
    echo "Error: Shared build script not found at $SHARED_SCRIPT"
    exit 1
fi
