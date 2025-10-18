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

# Tool installation
INSTALL_TOOLS="${INSTALL_TOOLS:-false}"            # Set to 'true' to auto-install required build tools

# Docker build options
USE_DOCKER="${USE_DOCKER:-false}"                  # Set to 'true' to build in Docker container
DOCKER_IMAGE="${DOCKER_IMAGE:-maven:3.9-eclipse-temurin-17}"  # Docker image to use for builds

# Maven options
MAVEN_ARGS="${MAVEN_ARGS:--DskipTests}"           # Default: skip tests during build
MAVEN_GOALS="${MAVEN_GOALS:-clean package}"       # Default: clean and package
JAR_NAME="${JAR_NAME:-$PACKAGE_NAME.jar}"         # JAR file name in target/
CREATE_UNIVERSAL="${CREATE_UNIVERSAL:-true}"       # Create universal JAR
CREATE_PLATFORM_TAGGED="${CREATE_PLATFORM_TAGGED:-true}"  # Create platform-tagged JAR

# ==============================================================================
# IMPLEMENTATION - REUSABLE ACROSS ALL JAVA PROJECTS
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
        
        # Check if Java is installed
        if ! command -v java &> /dev/null; then
            echo "Installing Java (OpenJDK)..."
            brew install openjdk
        else
            echo "✓ Java already installed: $(java -version 2>&1 | head -1)"
        fi
        
        # Check if Maven is installed
        if ! command -v mvn &> /dev/null; then
            echo "Installing Maven..."
            brew install maven
        else
            echo "✓ Maven already installed: $(mvn -version | head -1)"
        fi
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Platform: Linux"
        echo ""
        
        # Detect package manager
        if command -v apt-get &> /dev/null; then
            echo "Using apt (Debian/Ubuntu)..."
            
            if ! command -v java &> /dev/null; then
                echo "Installing Java (OpenJDK)..."
                sudo apt-get update
                sudo apt-get install -y openjdk-17-jdk
            else
                echo "✓ Java already installed: $(java -version 2>&1 | head -1)"
            fi
            
            if ! command -v mvn &> /dev/null; then
                echo "Installing Maven..."
                sudo apt-get install -y maven
            else
                echo "✓ Maven already installed: $(mvn -version | head -1)"
            fi
            
        elif command -v yum &> /dev/null; then
            echo "Using yum (RHEL/CentOS)..."
            
            if ! command -v java &> /dev/null; then
                sudo yum install -y java-17-openjdk-devel
            else
                echo "✓ Java already installed"
            fi
            
            if ! command -v mvn &> /dev/null; then
                sudo yum install -y maven
            else
                echo "✓ Maven already installed"
            fi
            
        elif command -v dnf &> /dev/null; then
            echo "Using dnf (Fedora)..."
            
            if ! command -v java &> /dev/null; then
                sudo dnf install -y java-17-openjdk-devel
            else
                echo "✓ Java already installed"
            fi
            
            if ! command -v mvn &> /dev/null; then
                sudo dnf install -y maven
            else
                echo "✓ Maven already installed"
            fi
        fi
        
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
        echo "Platform: Windows"
        echo ""
        
        # Check if Chocolatey is installed
        if ! command -v choco &> /dev/null; then
            echo "⚠ Chocolatey not found."
            echo "Please install build tools manually:"
            echo "  - Java: https://adoptium.net/"
            echo "  - Maven: https://maven.apache.org/download.cgi"
            echo ""
            echo "Or install Chocolatey first:"
            echo "  https://chocolatey.org/install"
        else
            if ! command -v java &> /dev/null; then
                echo "Installing Java..."
                choco install openjdk -y
            else
                echo "✓ Java already installed"
            fi
            
            if ! command -v mvn &> /dev/null; then
                echo "Installing Maven..."
                choco install maven -y
            else
                echo "✓ Maven already installed"
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
    DOCKER_CONTAINER_NAME="build-java-${PACKAGE_NAME}-$$"
    
    cleanup_java_docker() {
        echo ""
        echo "Cleaning up Docker resources..."
        docker rm -f "$DOCKER_CONTAINER_NAME" 2>/dev/null || true
        # Maven handles target/ cleanup, but ensure it's done
        echo "✓ Docker cleanup complete"
    }
    trap cleanup_java_docker EXIT INT TERM
    
    # Ensure image is available
    ensure_docker_image "$DOCKER_IMAGE"
    
    echo "Building in Docker container using: $DOCKER_IMAGE"
    echo ""
    
    # Create release directory on host
    mkdir -p "$RELEASE_DIR"
    
    # Build command to run inside Docker
    BUILD_CMD="set -e && \
        cd /workspace && \
        mvn $MAVEN_GOALS $MAVEN_ARGS && \
        mkdir -p release && \
        cp target/$JAR_NAME release/${PACKAGE_NAME}-universal.jar && \
        cd release && \
        sha256sum ${PACKAGE_NAME}-universal.jar > ${PACKAGE_NAME}-universal.jar.sha256 && \
        tar -czf ${PACKAGE_NAME}-universal.tar.gz ${PACKAGE_NAME}-universal.jar && \
        sha256sum ${PACKAGE_NAME}-universal.tar.gz > ${PACKAGE_NAME}-universal.tar.gz.sha256"
    
    # Run build in Docker
    BUILD_SUCCESS=false
    if docker run --name "$DOCKER_CONTAINER_NAME" --rm \
        -v "$(pwd):/workspace" \
        -v "$HOME/.m2:/root/.m2" \
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

# Check for Maven
if ! command -v mvn &> /dev/null; then
    echo "ERROR: Maven is not installed"
    echo "Please install Maven: https://maven.apache.org/install.html"
    echo ""
    echo "On macOS:   brew install maven"
    echo "On Ubuntu:  sudo apt install maven"
    echo "On Windows: choco install maven"
    echo ""
    echo "Or run with INSTALL_TOOLS=true to auto-install"
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
echo "✓ Java JARs are PLATFORM-INDEPENDENT!"
echo "  The same JAR runs on Linux, macOS, and Windows"
echo "  Platform tagging is for organizational purposes only"
echo ""

# Clean up previous build artifacts
echo "Cleaning up previous build artifacts..."
rm -rf "$RELEASE_DIR" 2>/dev/null || true
rm -rf target 2>/dev/null || true
echo "  ✓ Cleanup completed"
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

# Verify JAR files
echo ""
echo "Verifying built JAR(s)..."
JAR_VERIFIED=false

if [ "$CREATE_UNIVERSAL" = "true" ]; then
    JAR_FILE="$RELEASE_DIR/${PACKAGE_NAME}-universal.jar"
    if [ ! -f "$JAR_FILE" ]; then
        echo "ERROR: JAR not found at $JAR_FILE"
        exit 1
    fi
    
    # Verify it's a valid JAR (ZIP format)
    if command -v file &> /dev/null; then
        FILE_TYPE=$(file "$JAR_FILE")
        if [[ "$FILE_TYPE" == *"Java"* ]] || [[ "$FILE_TYPE" == *"Zip"* ]] || [[ "$FILE_TYPE" == *"archive"* ]]; then
            JAR_SIZE=$(stat -f%z "$JAR_FILE" 2>/dev/null || stat -c%s "$JAR_FILE" 2>/dev/null || echo "0")
            echo "  ✓ Universal JAR verified (size: $JAR_SIZE bytes)"
            JAR_VERIFIED=true
        else
            echo "ERROR: Invalid JAR file format: $JAR_FILE"
            exit 1
        fi
    else
        JAR_SIZE=$(stat -f%z "$JAR_FILE" 2>/dev/null || stat -c%s "$JAR_FILE" 2>/dev/null || echo "0")
        if [ "$JAR_SIZE" -gt 0 ]; then
            echo "  ✓ Universal JAR verified (size: $JAR_SIZE bytes)"
            JAR_VERIFIED=true
        else
            echo "ERROR: JAR has zero size"
            exit 1
        fi
    fi
fi

if [ "$CREATE_PLATFORM_TAGGED" = "true" ]; then
    JAR_FILE="$RELEASE_DIR/${PACKAGE_NAME}-${TARGET}.jar"
    if [ ! -f "$JAR_FILE" ]; then
        echo "ERROR: JAR not found at $JAR_FILE"
        exit 1
    fi
    
    # Verify it's a valid JAR (ZIP format)
    if command -v file &> /dev/null; then
        FILE_TYPE=$(file "$JAR_FILE")
        if [[ "$FILE_TYPE" == *"Java"* ]] || [[ "$FILE_TYPE" == *"Zip"* ]] || [[ "$FILE_TYPE" == *"archive"* ]]; then
            JAR_SIZE=$(stat -f%z "$JAR_FILE" 2>/dev/null || stat -c%s "$JAR_FILE" 2>/dev/null || echo "0")
            echo "  ✓ Platform-tagged JAR verified (size: $JAR_SIZE bytes)"
            JAR_VERIFIED=true
        else
            echo "ERROR: Invalid JAR file format: $JAR_FILE"
            exit 1
        fi
    else
        JAR_SIZE=$(stat -f%z "$JAR_FILE" 2>/dev/null || stat -c%s "$JAR_FILE" 2>/dev/null || echo "0")
        if [ "$JAR_SIZE" -gt 0 ]; then
            echo "  ✓ Platform-tagged JAR verified (size: $JAR_SIZE bytes)"
            JAR_VERIFIED=true
        else
            echo "ERROR: JAR has zero size"
            exit 1
        fi
    fi
fi

if [ "$JAR_VERIFIED" = false ]; then
    echo "ERROR: No JARs were created or verified"
    exit 1
fi
echo ""

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
