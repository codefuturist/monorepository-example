#!/usr/bin/env bash
# Build script for package-g (Go)
# Builds release binaries for multiple platforms

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "Building package-g executables"
echo "======================================"

# Download dependencies
echo "Downloading dependencies..."
go mod download

# Detect current platform
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CURRENT_OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    CURRENT_OS="darwin"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    CURRENT_OS="windows"
else
    CURRENT_OS="linux"
fi

DIST_DIR="dist"
mkdir -p "$DIST_DIR"

# Build for multiple platforms
PLATFORMS=("linux/amd64" "darwin/amd64" "windows/amd64")

echo ""
echo "Building for multiple platforms..."
echo ""

for PLATFORM in "${PLATFORMS[@]}"; do
    GOOS=${PLATFORM%/*}
    GOARCH=${PLATFORM#*/}
    
    OUTPUT_NAME="package-g-${GOOS}-${GOARCH}"
    if [ "$GOOS" = "windows" ]; then
        OUTPUT_NAME="${OUTPUT_NAME}.exe"
    fi
    
    echo "Building for $GOOS/$GOARCH..."
    env GOOS="$GOOS" GOARCH="$GOARCH" go build -ldflags="-s -w" -o "$DIST_DIR/$OUTPUT_NAME" ./cmd/main.go
    
    if [ $? -eq 0 ]; then
        echo "  ✓ $OUTPUT_NAME"
    else
        echo "  ✗ Failed to build for $GOOS/$GOARCH"
    fi
done

echo ""
echo "✓ Build completed successfully!"
echo ""
echo "Binaries created in: $DIST_DIR/"
ls -lh "$DIST_DIR"
echo ""
echo "To test current platform:"
if [ "$CURRENT_OS" = "windows" ]; then
    echo "  $DIST_DIR/package-g-windows-amd64.exe"
else
    echo "  ./$DIST_DIR/package-g-${CURRENT_OS}-amd64"
fi
echo ""
