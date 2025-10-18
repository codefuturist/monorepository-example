#!/usr/bin/env bash
# Build script for package-h (Java)
# Creates executable JAR with all dependencies included

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "Building package-h executables"
echo "======================================"

# Check for Maven
if ! command -v mvn &> /dev/null; then
    echo "ERROR: Maven is not installed"
    echo "Please install Maven: https://maven.apache.org/install.html"
    exit 1
fi

# Clean and build
echo "Cleaning previous builds..."
mvn clean

echo ""
echo "Building with Maven..."
mvn package -DskipTests

# Create dist directory
DIST_DIR="dist"
mkdir -p "$DIST_DIR"

# Copy the shaded JAR (includes all dependencies)
if [ -f "target/package-h.jar" ]; then
    cp "target/package-h.jar" "$DIST_DIR/package-h.jar"
else
    echo "ERROR: Build failed - JAR not found"
    exit 1
fi

# Create platform-specific launcher scripts
cat > "$DIST_DIR/package-h.sh" << 'EOF'
#!/usr/bin/env bash
# Launcher script for package-h (Unix/Linux/macOS)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
java -jar "$SCRIPT_DIR/package-h.jar" "$@"
EOF

cat > "$DIST_DIR/package-h.bat" << 'EOF'
@echo off
REM Launcher script for package-h (Windows)
java -jar "%~dp0package-h.jar" %*
EOF

chmod +x "$DIST_DIR/package-h.sh"

echo ""
echo "✓ Build completed successfully!"
echo ""
echo "Executable JAR: $DIST_DIR/package-h.jar"
echo ""
echo "To run on different platforms:"
echo "  Linux/macOS: ./$DIST_DIR/package-h.sh"
echo "  Windows:     $DIST_DIR\\package-h.bat"
echo "  Any:         java -jar $DIST_DIR/package-h.jar"
echo ""
echo "Note: Java 17+ required on target system"
echo ""
