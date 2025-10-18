#!/usr/bin/env bash
# ==============================================================================
# REUSABLE RUST BUILD SCRIPT (Cargo)
# ==============================================================================
# This script can be used in any Rust project with minimal configuration.
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
VERSION="${VERSION:-1.0.0}"                    # Project version
PACKAGE_NAME="${PACKAGE_NAME:-my-rust-app}"    # Package/binary name (from Cargo.toml)
RELEASE_DIR="${RELEASE_DIR:-release}"          # Where final artifacts are stored

# Tool installation
INSTALL_TOOLS="${INSTALL_TOOLS:-false}"        # Set to 'true' to auto-install required build tools

# Docker build options (uses 'cross' tool which is Docker-based)
USE_DOCKER="${USE_DOCKER:-false}"              # Set to 'true' to build in Docker container (forces USE_CROSS=true)
DOCKER_IMAGE="${DOCKER_IMAGE:-rust:1.75-slim}" # Docker image for non-cross builds

# Build options
CARGO_FLAGS="${CARGO_FLAGS:-}"                 # Additional cargo build flags (e.g., "--features xyz")
CROSS_COMPILE="${CROSS_COMPILE:-true}"         # Enable cross-compilation for multiple targets
USE_CROSS="${USE_CROSS:-auto}"                 # Use 'cross' tool for cross-compilation (auto/true/false)

# Cross-compilation targets (only used if CROSS_COMPILE=true)
# Format: TARGET:EXT (where EXT is file extension, empty for Unix)
# On Linux: only build for Linux architectures (x86_64 and arm64)
# On macOS/Windows: build for all platforms
if [[ -z "${CROSS_TARGETS[*]}" ]]; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        CROSS_TARGETS=(
            # Linux - both architectures only
            "x86_64-unknown-linux-gnu:"
            "aarch64-unknown-linux-gnu:"
        )
    else
        CROSS_TARGETS=(
            # Linux - both architectures
            "x86_64-unknown-linux-gnu:"
            "aarch64-unknown-linux-gnu:"
            # macOS - both architectures
            "x86_64-apple-darwin:"
            "aarch64-apple-darwin:"
            # Windows - both architectures (using GNU toolchain for easier cross-compilation)
            "x86_64-pc-windows-gnu:.exe"
            "aarch64-pc-windows-gnullvm:.exe"
        )
    fi
fi

# ==============================================================================
# IMPLEMENTATION - REUSABLE ACROSS ALL RUST PROJECTS
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
        
        # Check if Rust is installed
        if ! command -v rustc &> /dev/null || ! command -v cargo &> /dev/null; then
            echo "Installing Rust..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
        else
            echo "✓ Rust already installed: $(rustc --version)"
            echo "✓ Cargo already installed: $(cargo --version)"
        fi
        
        # Check if 'cross' is installed (for cross-compilation)
        if [ "$CROSS_COMPILE" = "true" ] && ! command -v cross &> /dev/null; then
            echo "Installing 'cross' tool for cross-compilation..."
            cargo install cross --git https://github.com/cross-rs/cross
        fi
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Platform: Linux"
        echo ""
        
        if ! command -v rustc &> /dev/null || ! command -v cargo &> /dev/null; then
            echo "Installing Rust..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
        else
            echo "✓ Rust already installed: $(rustc --version)"
            echo "✓ Cargo already installed: $(cargo --version)"
        fi
        
        # Install cross-compilation dependencies
        if [ "$CROSS_COMPILE" = "true" ]; then
            echo "Installing cross-compilation dependencies..."
            
            # Detect package manager
            if command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y gcc-mingw-w64 gcc-aarch64-linux-gnu
            elif command -v yum &> /dev/null; then
                sudo yum install -y mingw64-gcc gcc-aarch64-linux-gnu
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y mingw64-gcc gcc-aarch64-linux-gnu
            fi
            
            # Install 'cross' tool
            if ! command -v cross &> /dev/null; then
                echo "Installing 'cross' tool..."
                cargo install cross --git https://github.com/cross-rs/cross
            fi
        fi
        
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
        echo "Platform: Windows"
        echo ""
        
        if ! command -v rustc &> /dev/null || ! command -v cargo &> /dev/null; then
            echo "Installing Rust..."
            echo "Please download and run the installer from:"
            echo "  https://rustup.rs/"
            echo ""
            echo "Or use Chocolatey:"
            echo "  choco install rust -y"
        else
            echo "✓ Rust already installed: $(rustc --version)"
            echo "✓ Cargo already installed: $(cargo --version)"
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
    echo "Note: Rust Docker builds will use the 'cross' tool for cross-compilation"
    echo "      This provides consistent, reproducible builds across platforms"
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
    
    # Setup cleanup trap for cross tool containers
    cleanup_rust_docker() {
        echo ""
        echo "Cleaning up Docker resources..."
        # Clean up any cross tool containers
        docker ps -a --filter "name=cross-" --format "{{.ID}}" | xargs -r docker rm -f 2>/dev/null || true
        # Clean up target directory artifacts if needed
        echo "✓ Docker cleanup complete"
    }
    trap cleanup_rust_docker EXIT INT TERM
    
    # For Rust, we'll use cross which is already Docker-based
    # Just ensure cross is installed and force its use
    if ! command -v cross &> /dev/null; then
        echo "Installing 'cross' tool for Docker-based builds..."
        cargo install cross --git https://github.com/cross-rs/cross
    fi
    
    # Force cross usage when Docker mode is enabled
    # Note: 'cross' only has Docker images for Linux and Windows targets
    #       macOS targets will fall back to native cargo builds
    export USE_CROSS="true"
    
    echo "✓ Docker mode enabled (using 'cross' tool)"
    echo "  Note: Docker images only available for Linux/Windows targets"
    echo "        macOS targets will use native builds"
    echo ""
fi

# Clean up previous build artifacts
echo "Cleaning up previous build artifacts..."
rm -rf "$RELEASE_DIR" 2>/dev/null || true
rm -rf target 2>/dev/null || true
echo "  ✓ Cleanup completed"
echo ""

# Create release directory
mkdir -p "$RELEASE_DIR"

# Determine which targets to build
BUILD_TARGETS=()
if [ "$CROSS_COMPILE" = "true" ]; then
    echo "Cross-compilation enabled - building for multiple platforms"
    echo ""
    BUILD_TARGETS=("${CROSS_TARGETS[@]}")
else
    # Build for native platform only
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        ARCH=$(uname -m)
        if [[ "$ARCH" == "x86_64" ]]; then
            BUILD_TARGETS=("x86_64-unknown-linux-gnu:")
        elif [[ "$ARCH" == "aarch64" ]]; then
            BUILD_TARGETS=("aarch64-unknown-linux-gnu:")
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        ARCH=$(uname -m)
        if [[ "$ARCH" == "arm64" ]]; then
            BUILD_TARGETS=("aarch64-apple-darwin:")
        else
            BUILD_TARGETS=("x86_64-apple-darwin:")
        fi
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
        BUILD_TARGETS=("x86_64-pc-windows-gnu:.exe")
    fi
fi

# Build for each target
SUCCESSFUL_BUILDS=0
FAILED_BUILDS=0

for TARGET_SPEC in "${BUILD_TARGETS[@]}"; do
    IFS=':' read -r TARGET EXT <<< "$TARGET_SPEC"
    
    echo "→ Building for $TARGET..."
    
    # Try to install target if not present
    if ! rustup target list --installed | grep -q "^${TARGET}$"; then
        echo "  Installing Rust target $TARGET..."
        if rustup target add "$TARGET" 2>/dev/null; then
            echo "  ✓ Target installed"
        else
            echo "  ⚠ Could not install target $TARGET (skipping)"
            ((FAILED_BUILDS++))
            continue
        fi
    fi
    
    # Determine which build tool to use
    BUILD_CMD="cargo"
    if [[ "$USE_CROSS" == "true" ]] || [[ "$USE_CROSS" == "auto" && "$CROSS_COMPILE" == "true" ]]; then
        # Check if 'cross' is available and if we're cross-compiling
        if command -v cross &> /dev/null; then
            # Use cross for Linux targets when not on Linux
            if [[ "$TARGET" == *"linux"* && "$OSTYPE" != "linux"* ]]; then
                BUILD_CMD="cross"
            fi
            # Use cross for Windows targets when not on Windows
            if [[ "$TARGET" == *"windows"* && "$OSTYPE" != "msys" && "$OSTYPE" != "win32" && "$OSTYPE" != "cygwin" ]]; then
                BUILD_CMD="cross"
            fi
        fi
    fi
    
    # Build for this target
    if $BUILD_CMD build --release --target "$TARGET" $CARGO_FLAGS 2>&1 | grep -v "^warning:" | grep -E "(error|Error|ERROR)" > /dev/null; then
        echo "  ✗ Build failed for $TARGET"
        ((FAILED_BUILDS++))
        continue
    fi
    
    if ! $BUILD_CMD build --release --target "$TARGET" $CARGO_FLAGS > /dev/null 2>&1; then
        echo "  ✗ Build failed for $TARGET"
        ((FAILED_BUILDS++))
        continue
    fi
    
    # Copy binary with proper naming
    BINARY_NAME="${PACKAGE_NAME}-${TARGET}${EXT}"
    SOURCE_BINARY="target/${TARGET}/release/${PACKAGE_NAME}${EXT}"
    
    if [ ! -f "$SOURCE_BINARY" ]; then
        echo "  ✗ Binary not found at $SOURCE_BINARY"
        ((FAILED_BUILDS++))
        continue
    fi
    
    cp "$SOURCE_BINARY" "$RELEASE_DIR/$BINARY_NAME"
    chmod +x "$RELEASE_DIR/$BINARY_NAME" 2>/dev/null || true
    
    # Verify binary
    if [ ! -f "$RELEASE_DIR/$BINARY_NAME" ]; then
        echo "  ✗ Failed to copy binary"
        ((FAILED_BUILDS++))
        continue
    fi
    
    # Get binary size
    BINARY_SIZE=$(stat -f%z "$RELEASE_DIR/$BINARY_NAME" 2>/dev/null || stat -c%s "$RELEASE_DIR/$BINARY_NAME" 2>/dev/null || echo "0")
    if [ "$BINARY_SIZE" -eq 0 ]; then
        echo "  ✗ Binary has zero size"
        ((FAILED_BUILDS++))
        continue
    fi
    
    # Create archives and checksums
    cd "$RELEASE_DIR"
    if [[ "$EXT" == ".exe" ]]; then
        zip -q "${PACKAGE_NAME}-${TARGET}.zip" "$BINARY_NAME"
        if command -v sha256sum &> /dev/null; then
            sha256sum "${PACKAGE_NAME}-${TARGET}.zip" > "${PACKAGE_NAME}-${TARGET}.zip.sha256"
            sha256sum "$BINARY_NAME" > "${BINARY_NAME}.sha256"
        else
            shasum -a 256 "${PACKAGE_NAME}-${TARGET}.zip" > "${PACKAGE_NAME}-${TARGET}.zip.sha256"
            shasum -a 256 "$BINARY_NAME" > "${BINARY_NAME}.sha256"
        fi
    else
        tar -czf "${PACKAGE_NAME}-${TARGET}.tar.gz" "$BINARY_NAME"
        if command -v sha256sum &> /dev/null; then
            sha256sum "${PACKAGE_NAME}-${TARGET}.tar.gz" > "${PACKAGE_NAME}-${TARGET}.tar.gz.sha256"
            sha256sum "$BINARY_NAME" > "${BINARY_NAME}.sha256"
        else
            shasum -a 256 "${PACKAGE_NAME}-${TARGET}.tar.gz" > "${PACKAGE_NAME}-${TARGET}.tar.gz.sha256"
            shasum -a 256 "$BINARY_NAME" > "${BINARY_NAME}.sha256"
        fi
    fi
    cd "$PACKAGE_DIR"
    
    echo "  ✓ $TARGET built successfully (size: $BINARY_SIZE bytes)"
    ((SUCCESSFUL_BUILDS++))
    echo ""
done

echo ""
echo "════════════════════════════════════════════════════════"
echo "Build Summary"
echo "════════════════════════════════════════════════════════"
echo "Successful builds: $SUCCESSFUL_BUILDS"
echo "Failed builds: $FAILED_BUILDS"
echo ""

if [ $SUCCESSFUL_BUILDS -eq 0 ]; then
    echo "ERROR: No successful builds!"
    exit 1
fi

echo "Release artifacts in: $RELEASE_DIR/"
ls -lh "$RELEASE_DIR" | grep -E "\.(tar\.gz|zip|exe|$PACKAGE_NAME)" || ls -lh "$RELEASE_DIR"
echo ""

if [ "$CROSS_COMPILE" = "true" ]; then
    echo "Cross-compilation completed for multiple platforms"
else
    echo "Built for native platform only"
    echo "To enable cross-compilation, set: CROSS_COMPILE=true"
fi
echo ""
