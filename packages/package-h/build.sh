#!/usr/bin/env bash
# Build script for package-h (Java)
# Creates executable JAR with all dependencies included

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERSION="1.0.0"
PACKAGE_NAME="package-h"

echo "======================================"
echo "Building $PACKAGE_NAME v$VERSION"
echo "======================================"

# Check for Maven
if ! command -v mvn &> /dev/null; then
    echo "ERROR: Maven is not installed"
    echo "Please install Maven: https://maven.apache.org/install.html"
    exit 1
fi

# Detect platform
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
    [[ "$ARCH" == "arm64" ]] && TARGET="aarch64-apple-darwin" || TARGET="x86_64-apple-darwin"
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

echo "Platform: $TARGET (Java is platform-independent)"
echo ""

# Clean and build
echo "Cleaning previous builds..."
mvn clean

echo ""
echo "Building with Maven..."
mvn package -DskipTests

# Create release directory
RELEASE_DIR="release"
mkdir -p "$RELEASE_DIR"

# The shaded JAR is platform-independent, but we'll tag it with current platform
# For distribution convenience
if [ -f "target/package-h.jar" ]; then
    # Universal JAR (works on all platforms)
    cp "target/package-h.jar" "$RELEASE_DIR/${PACKAGE_NAME}-universal.jar"
    
    # Platform-specific naming for organization
    cp "target/package-h.jar" "$RELEASE_DIR/${PACKAGE_NAME}-${TARGET}.jar"
else
    echo "ERROR: Build failed - JAR not found"
    exit 1
fi

# Create checksums and archives
cd "$RELEASE_DIR"

# Universal JAR checksums and archive
tar -czf "${PACKAGE_NAME}-universal.tar.gz" "${PACKAGE_NAME}-universal.jar"
if command -v sha256sum &> /dev/null; then
    sha256sum "${PACKAGE_NAME}-universal.jar" > "${PACKAGE_NAME}-universal.jar.sha256"
    sha256sum "${PACKAGE_NAME}-universal.tar.gz" > "${PACKAGE_NAME}-universal.tar.gz.sha256"
else
    shasum -a 256 "${PACKAGE_NAME}-universal.jar" > "${PACKAGE_NAME}-universal.jar.sha256"
    shasum -a 256 "${PACKAGE_NAME}-universal.tar.gz" > "${PACKAGE_NAME}-universal.tar.gz.sha256"
fi

# Platform-tagged JAR checksums
if command -v sha256sum &> /dev/null; then
    sha256sum "${PACKAGE_NAME}-${TARGET}.jar" > "${PACKAGE_NAME}-${TARGET}.jar.sha256"
else
    shasum -a 256 "${PACKAGE_NAME}-${TARGET}.jar" > "${PACKAGE_NAME}-${TARGET}.jar.sha256"
fi

cd "$SCRIPT_DIR"

echo ""
echo "✓ Build completed successfully!"
echo ""
echo "Release artifacts in: $RELEASE_DIR/"
ls -lh "$RELEASE_DIR"
echo ""
echo "To run:"
echo "  java -jar $RELEASE_DIR/${PACKAGE_NAME}-universal.jar"
echo ""
echo "Note: Java 17+ required on target system"
echo "      JAR files are platform-independent"
echo ""
