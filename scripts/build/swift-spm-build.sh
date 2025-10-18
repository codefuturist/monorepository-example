#!/usr/bin/env bash
# ==============================================================================
# REUSABLE SWIFT BUILD SCRIPT
# ==============================================================================
# This script can be used in any Swift project with minimal configuration.
# Just update the configuration variables or set them as environment variables.
#
# Note: Swift Package Manager executables are macOS-only (requires Xcode/Swift toolchain)
# ==============================================================================

set -e

# ==============================================================================
# CONFIGURATION - Set via environment variables or use defaults
# ==============================================================================
VERSION="${VERSION:-1.0.0}"
PACKAGE_NAME="${PACKAGE_NAME:-my-swift-app}"
RELEASE_DIR="${RELEASE_DIR:-release}"

# Tool installation
INSTALL_TOOLS="${INSTALL_TOOLS:-false}"            # Set to 'true' to auto-install required build tools

# Docker build options (Linux only - Swift in Docker doesn't support macOS builds)
USE_DOCKER="${USE_DOCKER:-false}"                  # Set to 'true' to build Linux binaries in Docker
DOCKER_IMAGE="${DOCKER_IMAGE:-swift:5.9-jammy}"    # Docker image to use for builds

# Build options
BUILD_CONFIG="${BUILD_CONFIG:-release}"           # Build configuration (debug/release)
SWIFT_FLAGS="${SWIFT_FLAGS:-}"                     # Additional Swift build flags
CREATE_UNIVERSAL="${CREATE_UNIVERSAL:-true}"       # Create universal binary (arm64 + x86_64) - ENABLED by default for releases

# ==============================================================================
# IMPLEMENTATION - REUSABLE ACROSS ALL SWIFT PROJECTS
# ==============================================================================

# Remember the package directory (where build.sh was called from)
PACKAGE_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================"
echo "Building $PACKAGE_NAME v$VERSION"
echo "======================================"

# Ensure we're in the package directory
cd "$PACKAGE_DIR"

# ==============================================================================
# TOOL INSTALLATION (if requested)
# ==============================================================================
if [ "$INSTALL_TOOLS" = "true" ]; then
    echo ""
    echo "======================================"
    echo "Installing Build Tools"
    echo "======================================"
    echo ""
    
    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Platform: macOS"
        echo ""
        
        # Check if Swift is installed
        if ! command -v swift &> /dev/null; then
            echo "Swift not found. Installing Xcode Command Line Tools..."
            echo "Note: For full Swift support, install Xcode from the App Store"
            xcode-select --install
            
            echo ""
            echo "⚠ If swift is still not available, please install Xcode from:"
            echo "  https://apps.apple.com/app/xcode/id497799835"
        else
            echo "✓ Swift already installed: $(swift --version | head -1)"
        fi
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Platform: Linux"
        echo ""
        
        if ! command -v swift &> /dev/null; then
            echo "Installing Swift for Linux..."
            echo "Note: This requires manual download and installation"
            echo ""
            echo "Please visit: https://swift.org/download/"
            echo "Or use Docker: docker pull swift:latest"
        else
            echo "✓ Swift already installed: $(swift --version | head -1)"
        fi
        
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
        echo "Platform: Windows"
        echo ""
        
        if ! command -v swift &> /dev/null; then
            echo "Installing Swift for Windows..."
            echo "Note: Swift on Windows is still experimental"
            echo ""
            echo "Please visit: https://swift.org/download/"
            echo "Or use Chocolatey: choco install swift"
        else
            echo "✓ Swift already installed"
        fi
    fi
    
    echo ""
    echo "✓ Build tools check complete"
    echo ""
fi

# ==============================================================================
# DOCKER BUILD (if requested) - Linux binaries only
# ==============================================================================
if [ "$USE_DOCKER" = "true" ]; then
    echo "======================================"
    echo "Docker Build Mode (Linux Binary)"
    echo "======================================"
    echo ""
    echo "Note: Docker builds produce Linux binaries only"
    echo "      For macOS binaries, build natively on macOS"
    echo ""
    
    # Source Docker utilities
    DOCKER_UTILS="${SCRIPT_DIR}/docker-build-utils.sh"
    if [ -f "$DOCKER_UTILS" ]; then
        source "$DOCKER_UTILS"
    else
        echo "ERROR: Docker utilities not found at $DOCKER_UTILS"
        exit 1
    fi
    
    # Check Docker availability
    if ! check_docker; then
        exit 1
    fi
    
    # Setup cleanup trap
    DOCKER_CONTAINER_NAME="build-swift-${PACKAGE_NAME}-$$"
    
    cleanup_swift_docker() {
        echo ""
        echo "Cleaning up Docker resources..."
        docker rm -f "$DOCKER_CONTAINER_NAME" 2>/dev/null || true
        rm -rf .build/ 2>/dev/null || true
        echo "✓ Docker cleanup complete"
    }
    trap cleanup_swift_docker EXIT INT TERM
    
    # Ensure image is available
    ensure_docker_image "$DOCKER_IMAGE"
    
    echo "Building in Docker container using: $DOCKER_IMAGE"
    echo ""
    
    # Create release directory on host
    mkdir -p "$RELEASE_DIR"
    
    # Build command to run inside Docker
    BUILD_CMD="set -e && \
        cd /workspace && \
        swift build -c $BUILD_CONFIG && \
        mkdir -p release && \
        BINARY_NAME='${PACKAGE_NAME}-x86_64-unknown-linux-gnu' && \
        cp .build/$BUILD_CONFIG/$PACKAGE_NAME release/\$BINARY_NAME && \
        cd release && \
        tar -czf \${BINARY_NAME}.tar.gz \$BINARY_NAME && \
        sha256sum \${BINARY_NAME}.tar.gz > \${BINARY_NAME}.tar.gz.sha256 && \
        sha256sum \$BINARY_NAME > \${BINARY_NAME}.sha256"
    
    # Run build in Docker
    BUILD_SUCCESS=false
    if docker run --name "$DOCKER_CONTAINER_NAME" --rm \
        -v "$(pwd):/workspace" \
        -w /workspace \
        "$DOCKER_IMAGE" \
        sh -c "$BUILD_CMD"; then
        BUILD_SUCCESS=true
    fi
    
    # Clean up intermediate artifacts
    rm -rf .build/ 2>/dev/null || true
    
    if [ "$BUILD_SUCCESS" = "true" ]; then
        echo ""
        echo "======================================"
        echo "Docker Build Complete"
        echo "======================================"
        echo ""
        echo "Release artifacts in: $RELEASE_DIR/"
        ls -lh "$RELEASE_DIR"
        echo ""
        exit 0
    else
        echo "ERROR: Docker build failed"
        exit 1
    fi
fi

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "ERROR: Swift Package Manager executables require macOS"
    echo "Please build on a macOS system with Xcode or Swift toolchain installed"
    echo ""
    echo "Alternatively, for Linux builds:"
    echo "  - Use official Swift Docker images: USE_DOCKER=true"
    echo "  - Install Swift for Linux: https://swift.org/download/"
    echo ""
    echo "Or run with INSTALL_TOOLS=true to see installation instructions"
    exit 1
fi

# Check for Swift
if ! command -v swift &> /dev/null; then
    echo "ERROR: Swift is not installed"
    echo "Please install Swift/Xcode:"
    echo "  - Install Xcode from the App Store, or"
    echo "  - Install Swift toolchain: https://swift.org/download/"
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    TARGET="aarch64-apple-darwin"
else
    TARGET="x86_64-apple-darwin"
fi

echo "Build Platform: $TARGET"
echo "Build Configuration: $BUILD_CONFIG"
if [ "$CREATE_UNIVERSAL" = "true" ]; then
    echo "Universal Binary: Yes (arm64 + x86_64)"
else
    echo "Universal Binary: No (native architecture only)"
fi
echo ""

# Clean up previous build artifacts
echo "Cleaning up previous build artifacts..."
rm -rf "$RELEASE_DIR" 2>/dev/null || true
rm -rf .build 2>/dev/null || true
echo "  ✓ Cleanup completed"
echo ""

# Build release binary
echo "Building with Swift Package Manager..."
if [ "$CREATE_UNIVERSAL" = "true" ]; then
    # Build universal binary (requires Xcode 12.2+)
    echo "Creating universal binary for arm64 and x86_64..."
    swift build -c "$BUILD_CONFIG" --arch arm64 --arch x86_64 $SWIFT_FLAGS
    TARGET="universal-apple-darwin"
else
    # Build for native architecture
    swift build -c "$BUILD_CONFIG" $SWIFT_FLAGS
fi

# Get binary path
BINARY_PATH=$(swift build -c "$BUILD_CONFIG" --show-bin-path)/$PACKAGE_NAME

# Check if binary was created
if [ ! -f "$BINARY_PATH" ]; then
    echo ""
    echo "ERROR: Build failed - binary not found at $BINARY_PATH"
    echo ""
    exit 1
fi

# Create release directory
mkdir -p "$RELEASE_DIR"

# Copy binary with proper naming
BINARY_NAME="${PACKAGE_NAME}-${TARGET}"
cp "$BINARY_PATH" "$RELEASE_DIR/$BINARY_NAME"
chmod +x "$RELEASE_DIR/$BINARY_NAME"

# Verify binary exists and is valid
echo ""
echo "Verifying built binary..."
if [ ! -f "$RELEASE_DIR/$BINARY_NAME" ]; then
    echo "ERROR: Binary not found at $RELEASE_DIR/$BINARY_NAME"
    exit 1
fi

# Check if binary is executable
if [ ! -x "$RELEASE_DIR/$BINARY_NAME" ]; then
    echo "ERROR: Binary is not executable: $RELEASE_DIR/$BINARY_NAME"
    exit 1
fi

# Verify binary size
BINARY_SIZE=$(stat -f%z "$RELEASE_DIR/$BINARY_NAME" 2>/dev/null || stat -c%s "$RELEASE_DIR/$BINARY_NAME" 2>/dev/null || echo "0")
if [ "$BINARY_SIZE" -eq 0 ]; then
    echo "ERROR: Binary has zero size"
    exit 1
fi

# Verify binary file type (should be Mach-O for macOS)
if command -v file &> /dev/null; then
    FILE_TYPE=$(file "$RELEASE_DIR/$BINARY_NAME")
    echo "Binary type: $FILE_TYPE"
    if [[ "$FILE_TYPE" == *"Mach-O"* ]] || [[ "$FILE_TYPE" == *"executable"* ]]; then
        echo "  ✓ Binary verification passed (size: $BINARY_SIZE bytes)"
    else
        echo "ERROR: Binary is not a valid macOS executable"
        exit 1
    fi
else
    echo "  ✓ Binary verified (size: $BINARY_SIZE bytes)"
fi
echo ""

# Create archives and checksums
cd "$RELEASE_DIR"
echo "Creating archive and checksums..."
tar -czf "${PACKAGE_NAME}-${TARGET}.tar.gz" "$BINARY_NAME"

if command -v sha256sum &> /dev/null; then
    sha256sum "${PACKAGE_NAME}-${TARGET}.tar.gz" > "${PACKAGE_NAME}-${TARGET}.tar.gz.sha256"
    sha256sum "$BINARY_NAME" > "${BINARY_NAME}.sha256"
else
    shasum -a 256 "${PACKAGE_NAME}-${TARGET}.tar.gz" > "${PACKAGE_NAME}-${TARGET}.tar.gz.sha256"
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
echo "Platform Requirements:"
echo "  - macOS (10.15+ for arm64, 10.13+ for x86_64)"
if [ "$CREATE_UNIVERSAL" = "true" ]; then
    echo "  - Universal binary runs on both Intel and Apple Silicon Macs"
else
    echo "  - Binary is architecture-specific ($ARCH)"
    echo "  - For universal binary, set CREATE_UNIVERSAL=true"
fi
echo ""
