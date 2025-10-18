#!/usr/bin/env bash
# ==============================================================================
# BUILD ALL PACKAGES
# ==============================================================================
# Minimal script to build all packages in the monorepo
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# List of all packages
PACKAGES=(
    "package-a"
    "package-b"
    "package-c"
    "package-d"
    "package-e"
    "package-f"
    "package-g"
    "package-h"
    "package-i"
)

echo "════════════════════════════════════════════════════════"
echo "Building All Packages"
echo "════════════════════════════════════════════════════════"
echo ""

FAILED=()
SUCCEEDED=()

for pkg in "${PACKAGES[@]}"; do
    echo "→ Building $pkg..."
    
    if [ -f "packages/$pkg/build.sh" ]; then
        LOG_FILE="/tmp/${pkg}-build.log"
        if (cd "packages/$pkg" && bash build.sh > "$LOG_FILE" 2>&1); then
            echo "  ✓ $pkg built successfully"
            SUCCEEDED+=("$pkg")
        else
            echo "  ✗ $pkg build failed"
            echo "    Last 5 lines of output:"
            tail -5 "$LOG_FILE" | sed 's/^/    /'
            FAILED+=("$pkg")
        fi
    else
        echo "  ⊘ $pkg: build.sh not found"
        FAILED+=("$pkg (no build.sh)")
    fi
    echo ""
done

echo "════════════════════════════════════════════════════════"
echo "Build Summary"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Succeeded: ${#SUCCEEDED[@]}"
echo "Failed: ${#FAILED[@]}"
echo ""

if [ ${#FAILED[@]} -gt 0 ]; then
    echo "Failed packages:"
    for pkg in "${FAILED[@]}"; do
        echo "  - $pkg"
    done
    echo ""
    exit 1
fi

echo "✓ All packages built successfully!"
echo ""
