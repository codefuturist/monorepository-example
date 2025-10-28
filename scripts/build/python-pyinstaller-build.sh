#!/usr/bin/env bash
# ==============================================================================
# REUSABLE PYTHON BUILD SCRIPT (PyInstaller)
# ==============================================================================
# This script can be used in any Python project with minimal configuration.
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
VERSION="${VERSION:-1.0.0}"                                    # Project version
PACKAGE_NAME="${PACKAGE_NAME:-my-python-app}"                  # Package name (used for output files)
ENTRY_POINT="${ENTRY_POINT:-src/main.py}"                      # Main entry point file
RELEASE_DIR="${RELEASE_DIR:-release}"                          # Where final artifacts are stored

# Tool installation
INSTALL_TOOLS="${INSTALL_TOOLS:-false}"                        # Set to 'true' to auto-install required build tools

# Docker build options
USE_DOCKER="${USE_DOCKER:-false}"                              # Set to 'true' to build in Docker container
DOCKER_IMAGE="${DOCKER_IMAGE:-python:3.11-slim}"               # Docker image to use for builds

# PyInstaller configuration
PYINSTALLER_NAME="${PYINSTALLER_NAME:-$PACKAGE_NAME}"          # Name of the built executable
PYINSTALLER_FLAGS="${PYINSTALLER_FLAGS:---onefile}"            # PyInstaller flags (--onefile, --windowed, etc.)

# Dependencies to collect (space-separated)
# Format: "--add-data source:dest" or "--collect-all package"
if [[ -z "${PYINSTALLER_DATA[*]}" ]]; then
    PYINSTALLER_DATA=()  # Default: no additional data files
fi

# Runtime dependencies to install before building
BUILD_DEPS="${BUILD_DEPS:-pyinstaller}"

# ==============================================================================
# IMPLEMENTATION - REUSABLE ACROSS ALL PYTHON PROJECTS
# ==============================================================================

# Remember the package directory (where build.sh was called from)
PACKAGE_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================"
echo "Building $PACKAGE_NAME v$VERSION"
echo "======================================"
echo ""
echo "✓ PyInstaller creates STANDALONE executables"
echo "  - No Python interpreter required by end users"
echo "  - All dependencies bundled into single executable"
echo "  - Cross-platform builds require building on target OS"
echo ""

# ==============================================================================
# TOOL INSTALLATION (if requested)
# ==============================================================================
if [ "$INSTALL_TOOLS" = "true" ]; then
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

        # Check if Python3 is installed
        if ! command -v python3 &> /dev/null; then
            echo "Installing Python 3..."
            brew install python3
        else
            echo "✓ Python 3 already installed: $(python3 --version)"
        fi

        # Check if pip is installed
        if ! command -v pip3 &> /dev/null; then
            echo "Installing pip..."
            python3 -m ensurepip --upgrade
        else
            echo "✓ pip already installed: $(pip3 --version)"
        fi

    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Platform: Linux"
        echo ""

        # Detect package manager
        if command -v apt-get &> /dev/null; then
            echo "Using apt (Debian/Ubuntu)..."
            if ! command -v python3 &> /dev/null; then
                echo "Installing Python 3..."
                sudo apt-get update
                sudo apt-get install -y python3 python3-pip python3-dev
            else
                echo "✓ Python 3 already installed: $(python3 --version)"
            fi
        elif command -v yum &> /dev/null; then
            echo "Using yum (RHEL/CentOS/Fedora)..."
            if ! command -v python3 &> /dev/null; then
                echo "Installing Python 3..."
                sudo yum install -y python3 python3-pip python3-devel
            else
                echo "✓ Python 3 already installed: $(python3 --version)"
            fi
        elif command -v dnf &> /dev/null; then
            echo "Using dnf (Fedora)..."
            if ! command -v python3 &> /dev/null; then
                echo "Installing Python 3..."
                sudo dnf install -y python3 python3-pip python3-devel
            else
                echo "✓ Python 3 already installed: $(python3 --version)"
            fi
        else
            echo "⚠ Unknown package manager. Please install Python 3 manually."
        fi

    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
        echo "Platform: Windows"
        echo ""

        # Check if Chocolatey is installed
        if ! command -v choco &> /dev/null; then
            echo "⚠ Chocolatey not found."
            echo "Please install Python manually from:"
            echo "  https://www.python.org/downloads/"
            echo "Or install Chocolatey first:"
            echo "  https://chocolatey.org/install"
        else
            if ! command -v python &> /dev/null; then
                echo "Installing Python 3..."
                choco install python3 -y
            else
                echo "✓ Python already installed: $(python --version)"
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
    DOCKER_CONTAINER_NAME="build-python-${PACKAGE_NAME}-$$"
    cleanup_python_docker() {
        echo ""
        echo "Cleaning up Docker resources..."
        docker rm -f "$DOCKER_CONTAINER_NAME" 2>/dev/null || true
        # Clean up any intermediate build artifacts in Docker
        rm -rf dist build *.spec 2>/dev/null || true
        echo "✓ Docker cleanup complete"
    }
    trap cleanup_python_docker EXIT INT TERM

    # Ensure image is available
    ensure_docker_image "$DOCKER_IMAGE"

    echo "Building in Docker container using: $DOCKER_IMAGE"
    echo "Working directory: $(pwd)"
    echo ""

    # Build command to run inside Docker
    BUILD_CMD="set -e && \
        apt-get update -qq && apt-get install -y -qq binutils > /dev/null 2>&1 && \
        pip install --quiet $BUILD_DEPS && \
        cd /workspace && \
        pyinstaller $PYINSTALLER_FLAGS --name $PYINSTALLER_NAME $ENTRY_POINT && \
        mkdir -p release && \
        cp dist/$PYINSTALLER_NAME release/ && \
        cd release && \
        tar -czf ${PYINSTALLER_NAME}.tar.gz $PYINSTALLER_NAME && \
        sha256sum ${PYINSTALLER_NAME}.tar.gz > ${PYINSTALLER_NAME}.tar.gz.sha256 && \
        sha256sum $PYINSTALLER_NAME > ${PYINSTALLER_NAME}.sha256"

    # Run build in Docker
    BUILD_SUCCESS=false
    if docker run --name "$DOCKER_CONTAINER_NAME" --rm \
        -v "$(pwd):/workspace" \
        -w /workspace \
        "$DOCKER_IMAGE" \
        sh -c "$BUILD_CMD"; then
        BUILD_SUCCESS=true
    fi

    # Cleanup intermediate files
    rm -rf dist build *.spec 2>/dev/null || true

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

# ==============================================================================
# PRE-BUILD CLEANUP
# ==============================================================================
echo "Cleaning previous build artifacts..."
rm -rf "$RELEASE_DIR" dist build *.spec 2>/dev/null || true
echo "✓ Cleanup complete"
echo ""
echo "⚠ PyInstaller builds for the current platform/architecture only"
echo "  - Build on Linux x86_64 → Linux x86_64 binary"
echo "  - Build on macOS ARM64 → macOS ARM64 binary"
echo "  - Build on Windows x86_64 → Windows x86_64 binary"
echo "  - To get all platforms: build on each target platform/architecture"
echo "  - Or use USE_DOCKER=true to build Linux binaries in a container"
echo ""

# Ensure we're in the package directory
cd "$PACKAGE_DIR"

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
echo ""

# Create and activate virtual environment
VENV_DIR=".build_venv"
if [[ ! -d "$VENV_DIR" ]]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

echo "Activating virtual environment..."
# Windows uses Scripts/activate, Unix uses bin/activate
if [[ -f "$VENV_DIR/Scripts/activate" ]]; then
    source "$VENV_DIR/Scripts/activate"
else
    source "$VENV_DIR/bin/activate"
fi

# Clean up previous build artifacts
echo "Cleaning up previous build artifacts..."
rm -rf "$RELEASE_DIR" 2>/dev/null || true
rm -rf dist 2>/dev/null || true
rm -rf build 2>/dev/null || true
rm -f *.spec 2>/dev/null || true
echo "  ✓ Cleanup completed"
echo ""

# Install package dependencies from pyproject.toml
if [[ -f "pyproject.toml" ]]; then
    echo "Installing package dependencies from pyproject.toml..."
    pip install -q -e .
else
    echo "Warning: pyproject.toml not found, skipping package dependency installation"
fi

# Install build dependencies
echo "Installing build dependencies..."
pip install -q $BUILD_DEPS

# Build for current platform
echo "Building executable for current platform..."

# Build pyinstaller command with proper array handling
PYINSTALLER_CMD=(pyinstaller $PYINSTALLER_FLAGS --name "$PYINSTALLER_NAME")

# Add data files if specified
if [[ ${#PYINSTALLER_DATA[@]} -gt 0 ]]; then
    PYINSTALLER_CMD+=("${PYINSTALLER_DATA[@]}")
fi

# Add entry point
PYINSTALLER_CMD+=("$ENTRY_POINT")

# Execute the command from package directory
cd "$PACKAGE_DIR"
"${PYINSTALLER_CMD[@]}"

# Create release directory
mkdir -p "$RELEASE_DIR"

# Copy and rename binary
BINARY_NAME="${PACKAGE_NAME}-${TARGET}${EXT}"
cp "dist/${PYINSTALLER_NAME}${EXT}" "$RELEASE_DIR/$BINARY_NAME"

# Verify binary exists and is executable
echo ""
echo "Verifying built binary..."
if [ ! -f "$RELEASE_DIR/$BINARY_NAME" ]; then
    echo "ERROR: Binary not found at $RELEASE_DIR/$BINARY_NAME"
    exit 1
fi

# Check if binary is executable (Unix only)
if [[ "$EXT" != ".exe" ]]; then
    chmod +x "$RELEASE_DIR/$BINARY_NAME"
    if [ ! -x "$RELEASE_DIR/$BINARY_NAME" ]; then
        echo "ERROR: Binary is not executable: $RELEASE_DIR/$BINARY_NAME"
        exit 1
    fi
fi

# Verify binary file type
if command -v file &> /dev/null; then
    FILE_TYPE=$(file "$RELEASE_DIR/$BINARY_NAME")
    echo "Binary type: $FILE_TYPE"
    if [[ "$FILE_TYPE" == *"executable"* ]] || [[ "$FILE_TYPE" == *"Mach-O"* ]] || [[ "$FILE_TYPE" == *"ELF"* ]] || [[ "$FILE_TYPE" == *"PE32"* ]]; then
        echo "  ✓ Binary verification passed"
    else
        echo "WARNING: Binary may not be a valid executable"
    fi
else
    echo "  ✓ Binary exists (file command not available for detailed verification)"
fi
echo ""

# Create tar.gz (Unix) or zip (Windows)
cd "$PACKAGE_DIR/$RELEASE_DIR"
if [[ "$EXT" == ".exe" ]]; then
    # Windows: create zip (use tar which is available in Windows 10+, or PowerShell)
    if command -v zip &> /dev/null; then
        zip "${PACKAGE_NAME}-${TARGET}.zip" "$BINARY_NAME"
    else
        # Use tar with zip format (available in Windows 10+)
        powershell.exe -Command "Compress-Archive -Path '$BINARY_NAME' -DestinationPath '${PACKAGE_NAME}-${TARGET}.zip' -Force" 2>/dev/null || \
        tar -a -cf "${PACKAGE_NAME}-${TARGET}.zip" "$BINARY_NAME"
    fi
    sha256sum "${PACKAGE_NAME}-${TARGET}.zip" > "${PACKAGE_NAME}-${TARGET}.zip.sha256"
else
    # Unix: create tar.gz
    tar -czf "${PACKAGE_NAME}-${TARGET}.tar.gz" "$BINARY_NAME"
    shasum -a 256 "${PACKAGE_NAME}-${TARGET}.tar.gz" > "${PACKAGE_NAME}-${TARGET}.tar.gz.sha256"
fi

# Create checksum for binary
if command -v sha256sum &> /dev/null; then
    sha256sum "$BINARY_NAME" > "${BINARY_NAME}.sha256"
else
    shasum -a 256 "$BINARY_NAME" > "${BINARY_NAME}.sha256"
fi

cd "$PACKAGE_DIR"

# Deactivate virtual environment
deactivate 2>/dev/null || true

echo ""
echo "════════════════════════════════════════════════════════"
echo "Build Summary"
echo "════════════════════════════════════════════════════════"
echo "✓ STANDALONE executable created successfully!"
echo ""
echo "End users can run this binary WITHOUT installing Python!"
echo "  - Python interpreter: ✓ Bundled"
echo "  - All dependencies: ✓ Bundled"
echo "  - Just download and run: ✓ Ready"
echo ""
echo "Release artifacts in: $RELEASE_DIR/"
ls -lh "$RELEASE_DIR"
echo ""
echo "Note: Build used virtual environment at $VENV_DIR (can be deleted)"
echo ""
echo "To get binaries for other platforms/architectures:"
echo "  - Build this package on each target platform"
echo "  - Or use CI/CD with multiple runners (Linux x64/ARM64, macOS x64/ARM64, Windows x64/ARM64)"
echo ""
