#!/usr/bin/env bash
# ==============================================================================
# REUSABLE GO BUILD SCRIPT
# ==============================================================================
# This script can be used in any Go project with minimal configuration.
# Just update the CONFIGURATION section below.
#
# USAGE:
#   Copy this script to your project root and customize the CONFIGURATION section.
#   Or source this script and override variables before calling it.
# ==============================================================================

set -e

# ==============================================================================
# CONFIGURATION - UPDATE THESE VALUES FOR YOUR PROJECT
# ==============================================================================
VERSION="${VERSION:-1.0.0}"                          # Project version
PACKAGE_NAME="${PACKAGE_NAME:-my-go-app}"            # Package name (used for output files)
MAIN_FILE="${MAIN_FILE:-./cmd/main.go}"              # Path to main.go file
RELEASE_DIR="${RELEASE_DIR:-release}"                # Where final artifacts are stored

# Tool installation
INSTALL_TOOLS="${INSTALL_TOOLS:-false}"              # Set to 'true' to auto-install required build tools

# Docker build options
USE_DOCKER="${USE_DOCKER:-false}"                    # Set to 'true' to build in Docker container
DOCKER_IMAGE="${DOCKER_IMAGE:-golang:1.21-alpine}"  # Docker image to use for builds

# Build options
LDFLAGS="${LDFLAGS:--s -w}"                          # Linker flags (strip debug info for smaller binaries)
BUILD_FLAGS="${BUILD_FLAGS:-}"                       # Additional go build flags

# Cross-compilation configuration
CROSS_COMPILE="${CROSS_COMPILE:-true}"         # Enable cross-compilation for multiple targets

# Build targets (GOOS:GOARCH:TARGET_NAME)
# Modify this array to add/remove platforms
# Note: Go natively supports cross-compilation without additional setup!
if [[ -z "${TARGETS[*]}" ]]; then
    if [ "$CROSS_COMPILE" = "true" ]; then
        # On Linux: only build for Linux architectures (x86_64 and arm64)
        # On macOS: build for all platforms
        # On Windows: build for all platforms
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            TARGETS=(
                "linux:amd64:x86_64-unknown-linux-gnu"
                "linux:arm64:aarch64-unknown-linux-gnu"
            )
        else
            TARGETS=(
                "linux:amd64:x86_64-unknown-linux-gnu"
                "linux:arm64:aarch64-unknown-linux-gnu"
                "darwin:amd64:x86_64-apple-darwin"
                "darwin:arm64:aarch64-apple-darwin"
                "windows:amd64:x86_64-pc-windows-msvc"
                "windows:arm64:aarch64-pc-windows-msvc"
            )
        fi
    else
        # Build for native platform only
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            ARCH=$(uname -m)
            if [[ "$ARCH" == "x86_64" ]]; then
                TARGETS=("linux:amd64:x86_64-unknown-linux-gnu")
            elif [[ "$ARCH" == "aarch64" ]]; then
                TARGETS=("linux:arm64:aarch64-unknown-linux-gnu")
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            ARCH=$(uname -m)
            if [[ "$ARCH" == "arm64" ]]; then
                TARGETS=("darwin:arm64:aarch64-apple-darwin")
            else
                TARGETS=("darwin:amd64:x86_64-apple-darwin")
            fi
        elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
            TARGETS=("windows:amd64:x86_64-pc-windows-msvc")
        fi
    fi
fi

# ==============================================================================
# IMPLEMENTATION - REUSABLE ACROSS ALL GO PROJECTS
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
        
        # Check if Homebrew is installed
        if ! command -v brew &> /dev/null; then
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        
        # Check if Go is installed
        if ! command -v go &> /dev/null; then
            echo "Installing Go..."
            brew install go
        else
            echo "✓ Go already installed: $(go version)"
        fi
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Platform: Linux"
        echo ""
        
        if ! command -v go &> /dev/null; then
            echo "Go not found. Installing latest version..."
            
            # Download and install Go
            GO_VERSION="1.21.5"  # Update as needed
            wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf /tmp/go.tar.gz
            rm /tmp/go.tar.gz
            
            # Add to PATH
            if ! grep -q '/usr/local/go/bin' ~/.bashrc; then
                echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
            fi
            export PATH=$PATH:/usr/local/go/bin
            
            echo "✓ Go installed: $(go version)"
        else
            echo "✓ Go already installed: $(go version)"
        fi
        
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
        echo "Platform: Windows"
        echo ""
        
        # Check if Chocolatey is installed
        if ! command -v choco &> /dev/null; then
            echo "⚠ Chocolatey not found."
            echo "Please install Go manually from:"
            echo "  https://go.dev/dl/"
            echo "Or install Chocolatey first:"
            echo "  https://chocolatey.org/install"
        else
            if ! command -v go &> /dev/null; then
                echo "Installing Go..."
                choco install golang -y
            else
                echo "✓ Go already installed: $(go version)"
            fi
        fi
    fi
    
    echo ""
    echo "✓ Build tools check complete"
    echo ""
fi

# ==============================================================================
# DOCKER BUILD (if requested)
# ==============================================================================
if [ "$USE_DOCKER" = "true" ]; then
    echo "======================================"
    echo "Docker Build Mode"
    echo "======================================"
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
    DOCKER_CONTAINER_NAME="build-go-${PACKAGE_NAME}-$$"
    cleanup_go_docker() {
        echo ""
        echo "Cleaning up Docker resources..."
        docker rm -f "$DOCKER_CONTAINER_NAME" 2>/dev/null || true
        echo "✓ Docker cleanup complete"
    }
    trap cleanup_go_docker EXIT INT TERM
    
    # Ensure image is available
    ensure_docker_image "$DOCKER_IMAGE"
    
    echo "Building in Docker container using: $DOCKER_IMAGE"
    echo "Cross-compilation: $([ "$CROSS_COMPILE" = "true" ] && echo "ENABLED" || echo "DISABLED")"
    echo ""
    
    # Create release directory on host
    mkdir -p "$RELEASE_DIR"
    
    # Prepare target list for Docker build
    TARGET_LIST=""
    for target_spec in "${TARGETS[@]}"; do
        IFS=':' read -r GOOS GOARCH TARGET_NAME <<< "$target_spec"
        TARGET_LIST="$TARGET_LIST$GOOS:$GOARCH:$TARGET_NAME "
    done
    
    # Build command to run inside Docker
    BUILD_CMD="set -e && \
        apk add --no-cache bash tar gzip coreutils > /dev/null 2>&1 && \
        cd /workspace && \
        go mod download && \
        mkdir -p release && \
        for target in $TARGET_LIST; do \
            IFS=':' read -r GOOS GOARCH TARGET_NAME <<< \"\$target\"; \
            echo \"Building for \$TARGET_NAME...\"; \
            EXT=\"\"; [ \"\$GOOS\" = \"windows\" ] && EXT=\".exe\"; \
            BINARY_NAME=\"${PACKAGE_NAME}-\${TARGET_NAME}\${EXT}\"; \
            CGO_ENABLED=0 GOOS=\$GOOS GOARCH=\$GOARCH go build $BUILD_FLAGS -ldflags \"$LDFLAGS\" -o \"release/\$BINARY_NAME\" $MAIN_FILE && \
            cd release && \
            if [ \"\$GOOS\" = \"windows\" ]; then \
                zip -q \"\${BINARY_NAME%.exe}.zip\" \"\$BINARY_NAME\" && \
                sha256sum \"\${BINARY_NAME%.exe}.zip\" > \"\${BINARY_NAME%.exe}.zip.sha256\" && \
                sha256sum \"\$BINARY_NAME\" > \"\${BINARY_NAME}.sha256\"; \
            else \
                tar -czf \"\${BINARY_NAME}.tar.gz\" \"\$BINARY_NAME\" && \
                sha256sum \"\${BINARY_NAME}.tar.gz\" > \"\${BINARY_NAME}.tar.gz.sha256\" && \
                sha256sum \"\$BINARY_NAME\" > \"\${BINARY_NAME}.sha256\"; \
            fi && \
            cd ..; \
        done"
    
    # Run build in Docker
    BUILD_SUCCESS=false
    if docker run --name "$DOCKER_CONTAINER_NAME" --rm \
        -v "$(pwd):/workspace" \
        -w /workspace \
        "$DOCKER_IMAGE" \
        sh -c "$BUILD_CMD"; then
        BUILD_SUCCESS=true
    fi
    
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

if [ "$CROSS_COMPILE" = "true" ]; then
    echo "Cross-compilation: ENABLED (building for ${#TARGETS[@]} platforms)"
else
    echo "Cross-compilation: DISABLED (native platform only)"
fi
echo ""

# Clean up previous build artifacts
echo "Cleaning up previous build artifacts..."
rm -rf "$RELEASE_DIR" 2>/dev/null || true
echo "  ✓ Cleanup completed"
echo ""

# Download dependencies
echo "Downloading dependencies..."
go mod download

mkdir -p "$RELEASE_DIR"

echo ""
echo "Building for multiple platforms..."
echo ""

for TARGET_SPEC in "${TARGETS[@]}"; do
    IFS=':' read -r GOOS GOARCH RUST_TARGET <<< "$TARGET_SPEC"
    
    OUTPUT_NAME="${PACKAGE_NAME}-${RUST_TARGET}"
    if [ "$GOOS" = "windows" ]; then
        OUTPUT_NAME="${OUTPUT_NAME}.exe"
    fi
    
    echo "Building for $RUST_TARGET (GOOS=$GOOS GOARCH=$GOARCH)..."
    
    if env GOOS="$GOOS" GOARCH="$GOARCH" go build -ldflags="$LDFLAGS" $BUILD_FLAGS -o "$RELEASE_DIR/$OUTPUT_NAME" "$MAIN_FILE"; then
        echo "  ✓ $OUTPUT_NAME built"
        
        # Verify binary exists
        if [ ! -f "$RELEASE_DIR/$OUTPUT_NAME" ]; then
            echo "  ✗ ERROR: Binary not found at $RELEASE_DIR/$OUTPUT_NAME"
            continue
        fi
        
        # Verify binary size (should be > 0)
        BINARY_SIZE=$(stat -f%z "$RELEASE_DIR/$OUTPUT_NAME" 2>/dev/null || stat -c%s "$RELEASE_DIR/$OUTPUT_NAME" 2>/dev/null || echo "0")
        if [ "$BINARY_SIZE" -eq 0 ]; then
            echo "  ✗ ERROR: Binary has zero size: $RELEASE_DIR/$OUTPUT_NAME"
            continue
        fi
        echo "  ✓ Binary verified (size: $BINARY_SIZE bytes)"
        
        # Create archive and checksum
        cd "$RELEASE_DIR"
        if [ "$GOOS" = "windows" ]; then
            zip "${PACKAGE_NAME}-${RUST_TARGET}.zip" "$OUTPUT_NAME"
            sha256sum "${PACKAGE_NAME}-${RUST_TARGET}.zip" > "${PACKAGE_NAME}-${RUST_TARGET}.zip.sha256" 2>/dev/null || \
            shasum -a 256 "${PACKAGE_NAME}-${RUST_TARGET}.zip" > "${PACKAGE_NAME}-${RUST_TARGET}.zip.sha256"
        else
            tar -czf "${PACKAGE_NAME}-${RUST_TARGET}.tar.gz" "$OUTPUT_NAME"
            shasum -a 256 "${PACKAGE_NAME}-${RUST_TARGET}.tar.gz" > "${PACKAGE_NAME}-${RUST_TARGET}.tar.gz.sha256" 2>/dev/null || \
            sha256sum "${PACKAGE_NAME}-${RUST_TARGET}.tar.gz" > "${PACKAGE_NAME}-${RUST_TARGET}.tar.gz.sha256"
        fi
        
        # Binary checksum
        if command -v sha256sum &> /dev/null; then
            sha256sum "$OUTPUT_NAME" > "${OUTPUT_NAME}.sha256"
        else
            shasum -a 256 "$OUTPUT_NAME" > "${OUTPUT_NAME}.sha256"
        fi
        
        cd "$PACKAGE_DIR"
    else
        echo "  ✗ Failed to build for $RUST_TARGET"
    fi
done

echo ""
echo "════════════════════════════════════════════════════════"
echo "Build Summary"
echo "════════════════════════════════════════════════════════"
echo "Platform builds: ${#TARGETS[@]}"
echo ""
echo "✓ Build completed successfully!"
echo ""
echo "Release artifacts created in: $RELEASE_DIR/"
ls -lh "$RELEASE_DIR" | grep -E '\.(tar\.gz|zip|sha256)$' || ls -lh "$RELEASE_DIR" || true
echo ""

if [ "$CROSS_COMPILE" = "true" ]; then
    echo "Cross-compilation completed for multiple platforms"
    echo "Go natively supports cross-compilation - no additional setup needed!"
else
    echo "Built for native platform only"
    echo "To enable cross-compilation, set: CROSS_COMPILE=true"
fi
echo ""
