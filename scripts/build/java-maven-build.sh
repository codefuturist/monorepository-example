#!/usr/bin/env bash
# ==============================================================================
# REUSABLE JAVA/MAVEN BUILD SCRIPT
# ==============================================================================
# This script can be used in any Java/Maven project with minimal configuration.
# Just update the configuration variables or set them as environment variables.
#
# Java JARs are platform-independent, but we tag them with the build platform
# for organizational purposes.
# ==============================================================================

set -e

# ==============================================================================
# CONFIGURATION - Set via environment variables or use defaults
# ==============================================================================
VERSION="${VERSION:-1.0.0}"
PACKAGE_NAME="${PACKAGE_NAME:-my-java-app}"
RELEASE_DIR="${RELEASE_DIR:-release}"

# Maven options
MAVEN_ARGS="${MAVEN_ARGS:--DskipTests}"           # Default: skip tests during build
MAVEN_GOALS="${MAVEN_GOALS:-clean package}"       # Default: clean and package
JAR_NAME="${JAR_NAME:-$PACKAGE_NAME.jar}"         # JAR file name in target/
CREATE_UNIVERSAL="${CREATE_UNIVERSAL:-true}"       # Create universal JAR
CREATE_PLATFORM_TAGGED="${CREATE_PLATFORM_TAGGED:-true}"  # Create platform-tagged JAR

# ==============================================================================
# IMPLEMENTATION - REUSABLE ACROSS ALL JAVA/MAVEN PROJECTS
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "Building $PACKAGE_NAME v$VERSION"
echo "======================================"

# Check for Maven
if ! command -v mvn &> /dev/null; then
    echo "ERROR: Maven is not installed"
    echo "Please install Maven: https://maven.apache.org/install.html"
    echo ""
    echo "On macOS:   brew install maven"
    echo "On Ubuntu:  sudo apt install maven"
    echo "On Windows: choco install maven"
    exit 1
fi

# Detect platform for tagging (Java JARs are platform-independent)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        TARGET="x86_64-unknown-linux-gnu"
    elif [[ "$ARCH" == "aarch64" ]]; then
        TARGET="aarch64-unknown-linux-gnu"
    else
        TARGET="${ARCH}-unknown-linux-gnu"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    ARCH=$(uname -m)
    if [[ "$ARCH" == "arm64" ]]; then
        TARGET="aarch64-apple-darwin"
    else
        TARGET="x86_64-apple-darwin"
    fi
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" || "$ARCH" == "AMD64" ]]; then
        TARGET="x86_64-pc-windows-msvc"
    elif [[ "$ARCH" == "aarch64" || "$ARCH" == "ARM64" ]]; then
        TARGET="aarch64-pc-windows-msvc"
    else
        TARGET="x86_64-pc-windows-msvc"
    fi
else
    TARGET="universal-java"
fi

echo "Build Platform: $TARGET"
echo "Maven Goals: $MAVEN_GOALS"
echo "Maven Args: $MAVEN_ARGS"
echo ""
echo "Note: Java JARs are platform-independent"
echo "      Platform tagging is for organizational purposes only"
echo ""

# Build with Maven
echo "Building with Maven..."
mvn $MAVEN_GOALS $MAVEN_ARGS

# Check if JAR was created
if [ ! -f "target/$JAR_NAME" ]; then
    echo ""
    echo "ERROR: Build failed - JAR not found at target/$JAR_NAME"
    echo ""
    exit 1
fi

# Create release directory
mkdir -p "$RELEASE_DIR"

# Copy JARs with appropriate naming
if [ "$CREATE_UNIVERSAL" = "true" ]; then
    echo "Creating universal JAR (platform-independent)..."
    cp "target/$JAR_NAME" "$RELEASE_DIR/${PACKAGE_NAME}-universal.jar"
fi

if [ "$CREATE_PLATFORM_TAGGED" = "true" ]; then
    echo "Creating platform-tagged JAR (for organization)..."
    cp "target/$JAR_NAME" "$RELEASE_DIR/${PACKAGE_NAME}-${TARGET}.jar"
fi

# Create checksums and archives
cd "$RELEASE_DIR"

# Universal JAR artifacts
if [ "$CREATE_UNIVERSAL" = "true" ]; then
    echo "Creating universal JAR archive and checksums..."
    tar -czf "${PACKAGE_NAME}-universal.tar.gz" "${PACKAGE_NAME}-universal.jar"
    
    if command -v sha256sum &> /dev/null; then
        sha256sum "${PACKAGE_NAME}-universal.jar" > "${PACKAGE_NAME}-universal.jar.sha256"
        sha256sum "${PACKAGE_NAME}-universal.tar.gz" > "${PACKAGE_NAME}-universal.tar.gz.sha256"
    else
        shasum -a 256 "${PACKAGE_NAME}-universal.jar" > "${PACKAGE_NAME}-universal.jar.sha256"
        shasum -a 256 "${PACKAGE_NAME}-universal.tar.gz" > "${PACKAGE_NAME}-universal.tar.gz.sha256"
    fi
fi

# Platform-tagged JAR artifacts
if [ "$CREATE_PLATFORM_TAGGED" = "true" ]; then
    echo "Creating platform-tagged JAR archive and checksums..."
    tar -czf "${PACKAGE_NAME}-${TARGET}.tar.gz" "${PACKAGE_NAME}-${TARGET}.jar"
    
    if command -v sha256sum &> /dev/null; then
        sha256sum "${PACKAGE_NAME}-${TARGET}.jar" > "${PACKAGE_NAME}-${TARGET}.jar.sha256"
        sha256sum "${PACKAGE_NAME}-${TARGET}.tar.gz" > "${PACKAGE_NAME}-${TARGET}.tar.gz.sha256"
    else
        shasum -a 256 "${PACKAGE_NAME}-${TARGET}.jar" > "${PACKAGE_NAME}-${TARGET}.jar.sha256"
        shasum -a 256 "${PACKAGE_NAME}-${TARGET}.tar.gz" > "${PACKAGE_NAME}-${TARGET}.tar.gz.sha256"
    fi
fi

cd "$SCRIPT_DIR"

echo ""
echo "✓ Build completed successfully!"
echo ""
echo "Release artifacts in: $RELEASE_DIR/"
ls -lh "$RELEASE_DIR"
echo ""

if [ "$CREATE_UNIVERSAL" = "true" ]; then
    echo "To run (universal JAR):"
    echo "  java -jar $RELEASE_DIR/${PACKAGE_NAME}-universal.jar"
    echo ""
fi

echo "Java Runtime Requirements:"
echo "  - Check pom.xml for required Java version"
echo "  - JARs are platform-independent (run on any OS with compatible JVM)"
echo ""
