#!/usr/bin/env bash
# ==============================================================================
# REUSABLE C++ BUILD SCRIPT (CMake)
# ==============================================================================
# This script can be used in any C++ project with minimal configuration.
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
PACKAGE_NAME="${PACKAGE_NAME:-my-cpp-project}"       # Package name (used for output files)
CMAKE_TARGET_NAME="${CMAKE_TARGET_NAME:-$PACKAGE_NAME}"  # CMake executable target name
BUILD_TYPE="${BUILD_TYPE:-Release}"                  # CMake build type: Release, Debug, RelWithDebInfo

# Tool installation
INSTALL_TOOLS="${INSTALL_TOOLS:-false}"              # Set to 'true' to auto-install required build tools

# Docker build options
USE_DOCKER="${USE_DOCKER:-false}"                    # Set to 'true' to build in Docker container
DOCKER_IMAGE="${DOCKER_IMAGE:-gcc:latest}"           # Docker image to use for builds

# Directory configuration
BUILD_DIR="${BUILD_DIR:-build-release}"              # Where CMake builds the project
RELEASE_DIR="${RELEASE_DIR:-release}"                # Where final artifacts are stored

# ==============================================================================
# IMPLEMENTATION - REUSABLE ACROSS ALL C++ PROJECTS
# ==============================================================================

# Remember the package directory (where build.sh was called from)
PACKAGE_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================"
echo "Building $PACKAGE_NAME v$VERSION"
echo "======================================"
echo ""
echo "Note: C++ CMake builds for the current platform only."
echo "      Cross-compilation requires specific toolchains and configuration."
echo ""

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
        
        # Check if CMake is installed
        if ! command -v cmake &> /dev/null; then
            echo "Installing CMake..."
            brew install cmake
        else
            echo "✓ CMake already installed: $(cmake --version | head -1)"
        fi
        
        # Check if compiler is available
        if ! command -v clang++ &> /dev/null && ! command -v g++ &> /dev/null; then
            echo "Installing Xcode Command Line Tools..."
            xcode-select --install
        else
            echo "✓ C++ compiler available"
        fi
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Platform: Linux"
        echo ""
        
        # Detect package manager
        if command -v apt-get &> /dev/null; then
            echo "Using apt (Debian/Ubuntu)..."
            
            if ! command -v cmake &> /dev/null; then
                echo "Installing CMake..."
                sudo apt-get update
                sudo apt-get install -y cmake
            else
                echo "✓ CMake already installed: $(cmake --version | head -1)"
            fi
            
            if ! command -v g++ &> /dev/null; then
                echo "Installing build essentials..."
                sudo apt-get install -y build-essential
            else
                echo "✓ C++ compiler available: $(g++ --version | head -1)"
            fi
            
        elif command -v yum &> /dev/null; then
            echo "Using yum (RHEL/CentOS)..."
            
            if ! command -v cmake &> /dev/null; then
                sudo yum install -y cmake
            else
                echo "✓ CMake already installed: $(cmake --version | head -1)"
            fi
            
            if ! command -v g++ &> /dev/null; then
                sudo yum groupinstall -y "Development Tools"
            else
                echo "✓ C++ compiler available"
            fi
            
        elif command -v dnf &> /dev/null; then
            echo "Using dnf (Fedora)..."
            
            if ! command -v cmake &> /dev/null; then
                sudo dnf install -y cmake
            else
                echo "✓ CMake already installed: $(cmake --version | head -1)"
            fi
            
            if ! command -v g++ &> /dev/null; then
                sudo dnf groupinstall -y "Development Tools"
            else
                echo "✓ C++ compiler available"
            fi
        fi
        
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
        echo "Platform: Windows"
        echo ""
        
        # Check if Chocolatey is installed
        if ! command -v choco &> /dev/null; then
            echo "⚠ Chocolatey not found."
            echo "Please install build tools manually:"
            echo "  - CMake: https://cmake.org/download/"
            echo "  - Visual Studio: https://visualstudio.microsoft.com/"
            echo "  - Or MinGW: https://www.mingw-w64.org/"
            echo ""
            echo "Or install Chocolatey first:"
            echo "  https://chocolatey.org/install"
        else
            if ! command -v cmake &> /dev/null; then
                echo "Installing CMake..."
                choco install cmake -y
            else
                echo "✓ CMake already installed"
            fi
            
            # Install MinGW as C++ compiler
            if ! command -v g++ &> /dev/null; then
                echo "Installing MinGW..."
                choco install mingw -y
            else
                echo "✓ C++ compiler available"
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
    DOCKER_CONTAINER_NAME="build-cpp-${PACKAGE_NAME}-$$"
    
    cleanup_cpp_docker() {
        echo ""
        echo "Cleaning up Docker resources..."
        docker rm -f "$DOCKER_CONTAINER_NAME" 2>/dev/null || true
        rm -rf build-release/ 2>/dev/null || true
        echo "✓ Docker cleanup complete"
    }
    trap cleanup_cpp_docker EXIT INT TERM
    
    # Ensure image is available
    ensure_docker_image "$DOCKER_IMAGE"
    
    echo "Building in Docker container using: $DOCKER_IMAGE"
    echo ""
    
    # Create release directory on host
    mkdir -p "$RELEASE_DIR"
    
    # Build command to run inside Docker
    BUILD_CMD="set -e && \
        apt-get update -qq && apt-get install -y -qq cmake make > /dev/null 2>&1 && \
        cd /workspace && \
        mkdir -p build-release && \
        cd build-release && \
        cmake .. -DCMAKE_BUILD_TYPE=$BUILD_TYPE && \
        cmake --build . --config $BUILD_TYPE && \
        cd .. && \
        mkdir -p release && \
        BINARY_NAME='${PACKAGE_NAME}-x86_64-unknown-linux-gnu' && \
        cp build-release/${CMAKE_TARGET_NAME} release/\$BINARY_NAME && \
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
    rm -rf build-release/ 2>/dev/null || true
    
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

# Detect OS and architecture
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        TARGET="x86_64-unknown-linux-gnu"
    elif [[ "$ARCH" == "aarch64" ]]; then
        TARGET="aarch64-unknown-linux-gnu"
    else
        TARGET="${ARCH}-unknown-linux-gnu"
    fi
    EXT=""
elif [[ "$OSTYPE" == "darwin"* ]]; then
    ARCH=$(uname -m)
    if [[ "$ARCH" == "arm64" ]]; then
        TARGET="aarch64-apple-darwin"
    else
        TARGET="x86_64-apple-darwin"
    fi
    EXT=""
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" || "$ARCH" == "AMD64" ]]; then
        TARGET="x86_64-pc-windows-msvc"
    elif [[ "$ARCH" == "aarch64" || "$ARCH" == "ARM64" ]]; then
        TARGET="aarch64-pc-windows-msvc"
    else
        TARGET="x86_64-pc-windows-msvc"
    fi
    EXT=".exe"
else
    TARGET="unknown"
    EXT=""
fi

echo "Platform: $TARGET"
echo "Build directory: $BUILD_DIR"
echo ""

# Clean up previous build artifacts
echo "Cleaning up previous build artifacts..."
rm -rf "$BUILD_DIR" 2>/dev/null || true
rm -rf "$RELEASE_DIR" 2>/dev/null || true
echo "  ✓ Cleanup completed"
echo ""

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure with CMake
echo "Configuring with CMake..."
cmake .. -DCMAKE_BUILD_TYPE="$BUILD_TYPE"

# Build
echo "Building..."
cmake --build . --config "$BUILD_TYPE"

# Go back to package directory
cd "$PACKAGE_DIR"

# Create release directory
mkdir -p "$RELEASE_DIR"

# Copy executable with proper naming
BINARY_NAME="${PACKAGE_NAME}-${TARGET}${EXT}"
if [[ "$EXT" == ".exe" ]]; then
    cp "$BUILD_DIR/$BUILD_TYPE/${CMAKE_TARGET_NAME}.exe" "$RELEASE_DIR/$BINARY_NAME" 2>/dev/null || \
    cp "$BUILD_DIR/${CMAKE_TARGET_NAME}.exe" "$RELEASE_DIR/$BINARY_NAME"
else
    cp "$BUILD_DIR/${CMAKE_TARGET_NAME}" "$RELEASE_DIR/$BINARY_NAME"
    chmod +x "$RELEASE_DIR/$BINARY_NAME"
fi

# Verify binary exists and is valid
echo ""
echo "Verifying built binary..."
if [ ! -f "$RELEASE_DIR/$BINARY_NAME" ]; then
    echo "ERROR: Binary not found at $RELEASE_DIR/$BINARY_NAME"
    exit 1
fi

# Check if binary is executable (Unix only)
if [[ "$EXT" != ".exe" ]] && [ ! -x "$RELEASE_DIR/$BINARY_NAME" ]; then
    echo "ERROR: Binary is not executable: $RELEASE_DIR/$BINARY_NAME"
    exit 1
fi

# Verify binary size
BINARY_SIZE=$(stat -f%z "$RELEASE_DIR/$BINARY_NAME" 2>/dev/null || stat -c%s "$RELEASE_DIR/$BINARY_NAME" 2>/dev/null || echo "0")
if [ "$BINARY_SIZE" -eq 0 ]; then
    echo "ERROR: Binary has zero size"
    exit 1
fi

# Verify binary file type
if command -v file &> /dev/null; then
    FILE_TYPE=$(file "$RELEASE_DIR/$BINARY_NAME")
    echo "Binary type: $FILE_TYPE"
    if [[ "$FILE_TYPE" == *"executable"* ]] || [[ "$FILE_TYPE" == *"Mach-O"* ]] || [[ "$FILE_TYPE" == *"ELF"* ]] || [[ "$FILE_TYPE" == *"PE32"* ]]; then
        echo "  ✓ Binary verification passed (size: $BINARY_SIZE bytes)"
    else
        echo "ERROR: Binary is not a valid executable"
        exit 1
    fi
else
    echo "  ✓ Binary verified (size: $BINARY_SIZE bytes)"
fi
echo ""

# Create archives and checksums
cd "$RELEASE_DIR"
if [[ "$EXT" == ".exe" ]]; then
    zip "${PACKAGE_NAME}-${TARGET}.zip" "$BINARY_NAME"
    sha256sum "${PACKAGE_NAME}-${TARGET}.zip" > "${PACKAGE_NAME}-${TARGET}.zip.sha256"
else
    tar -czf "${PACKAGE_NAME}-${TARGET}.tar.gz" "$BINARY_NAME"
    shasum -a 256 "${PACKAGE_NAME}-${TARGET}.tar.gz" > "${PACKAGE_NAME}-${TARGET}.tar.gz.sha256"
fi

if command -v sha256sum &> /dev/null; then
    sha256sum "$BINARY_NAME" > "${BINARY_NAME}.sha256"
else
    shasum -a 256 "$BINARY_NAME" > "${BINARY_NAME}.sha256"
fi

cd "$PACKAGE_DIR"

echo ""
echo "✓ Build completed successfully!"
echo ""
echo "Release artifacts in: $RELEASE_DIR/"
ls -lh "$RELEASE_DIR"
echo ""
echo "To test: ./$RELEASE_DIR/$BINARY_NAME"
echo ""
