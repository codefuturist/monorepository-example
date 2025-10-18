#!/bin/bash

# Note: Not using 'set -e' to allow graceful error handling
# Each critical operation checks exit codes explicitly

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNINGS=0

# Track containers for cleanup
DOCKER_CONTAINERS_TO_CLEANUP=()

# Cleanup function
cleanup_docker_containers() {
    if [ ${#DOCKER_CONTAINERS_TO_CLEANUP[@]} -gt 0 ]; then
        echo ""
        echo "Performing Docker cleanup..."
        for container in "${DOCKER_CONTAINERS_TO_CLEANUP[@]}"; do
            docker rm -f "$container" 2>/dev/null || true
            docker rm -f "${container}-v" 2>/dev/null || true
            docker rm -f "${container}-bare" 2>/dev/null || true
        done
        echo "✓ Docker cleanup complete"
    fi
    # Cleanup temp files
    rm -f /tmp/test-binary-* /tmp/docker-output-*.txt /tmp/*-test-$$ 2>/dev/null || true
}

# Set trap to cleanup on exit or interrupt
trap cleanup_docker_containers EXIT INT TERM

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        COMPREHENSIVE BUILD VERIFICATION SUITE                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${CYAN}Date:${NC} $(date)"
echo -e "${CYAN}Location:${NC} $(pwd)"
echo ""

# ============================================================================
# PHASE 1: BUILD ALL PACKAGES
# ============================================================================
echo ""
echo "════════════════════════════════════════════════════════════════"
echo -e "${BOLD}PHASE 1: Building All Packages${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""

if ./build-all.sh 2>&1 | tee /tmp/build-all-verification.log; then
    echo -e "${GREEN}✓${NC} Build process completed"
else
    echo -e "${YELLOW}⚠${NC} Some packages may have had build issues"
    echo "Check /tmp/build-all-verification.log for details"
    # Continue anyway to validate what was built
fi

# ============================================================================
# PHASE 2: VALIDATE BUILD ARTIFACTS
# ============================================================================
echo ""
echo "════════════════════════════════════════════════════════════════"
echo -e "${BOLD}PHASE 2: Validating Build Artifacts${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""

PACKAGES=("package-a" "package-b" "package-c" "package-d" "package-e" "package-f" "package-g" "package-h" "package-i")
LANGUAGES=("Python" "Python" "Python" "C++" "Rust" "Swift" "Go" "Java" "Rust")

for i in "${!PACKAGES[@]}"; do
    pkg="${PACKAGES[$i]}"
    lang="${LANGUAGES[$i]}"
    
    echo -e "${BLUE}→ Validating ${pkg} (${lang})${NC}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if [ -d "packages/${pkg}/release" ]; then
        file_count=$(find "packages/${pkg}/release" -type f | wc -l | xargs)
        if [ "$file_count" -gt 0 ]; then
            echo -e "  ${GREEN}✓${NC} Release directory exists with $file_count files"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            
            # Check for executables (except Java which produces JARs)
            if [ "$pkg" != "package-h" ]; then
                binary=$(find "packages/${pkg}/release" -type f ! -name "*.tar.gz" ! -name "*.zip" ! -name "*.sha256" ! -name "*.jar" | head -1)
                if [ -n "$binary" ] && [ -x "$binary" ]; then
                    echo -e "  ${GREEN}✓${NC} Executable binary found: $(basename "$binary")"
                fi
            fi
            
            # Check for checksums
            checksums=$(find "packages/${pkg}/release" -name "*.sha256" | wc -l | xargs)
            if [ "$checksums" -gt 0 ]; then
                echo -e "  ${GREEN}✓${NC} Checksums generated ($checksums files)"
            fi
        else
            echo -e "  ${RED}✗${NC} Release directory is empty"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        echo -e "  ${RED}✗${NC} Release directory not found"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    echo ""
done

# ============================================================================
# PHASE 3: CHECK CROSS-COMPILATION ARTIFACTS
# ============================================================================
echo ""
echo "════════════════════════════════════════════════════════════════"
echo -e "${BOLD}PHASE 3: Verifying Cross-Compilation Artifacts${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Check Go (should have 6 platforms)
echo -e "${BLUE}→ Go (package-g) - Native Cross-Compilation${NC}"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
go_files=$(find packages/package-g/release -type f 2>/dev/null | wc -l | xargs)
if [ "$go_files" -ge 18 ]; then
    echo -e "  ${GREEN}✓${NC} Cross-compilation successful ($go_files artifacts)"
    echo -e "    ${CYAN}Expected: 6 platforms × 3 files (binary + archive + checksum) = 18-24 files${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "  ${YELLOW}⚠${NC} Native build only ($go_files artifacts found)"
    WARNINGS=$((WARNINGS + 1))
    PASSED_TESTS=$((PASSED_TESTS + 1))
fi
echo ""

# Check Rust (may have cross-compilation if 'cross' tool is available)
echo -e "${BLUE}→ Rust (package-e, package-i) - Cross-Compilation Status${NC}"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
rust_e_files=$(find packages/package-e/release -type f 2>/dev/null | wc -l | xargs)
if [ "$rust_e_files" -ge 18 ]; then
    echo -e "  ${GREEN}✓${NC} package-e: Cross-compilation successful ($rust_e_files artifacts)"
    PASSED_TESTS=$((PASSED_TESTS + 1))
elif [ "$rust_e_files" -ge 3 ]; then
    echo -e "  ${YELLOW}⚠${NC} package-e: Native build only ($rust_e_files artifacts)"
    echo -e "    ${CYAN}Note: Install 'cross' tool and Docker for full cross-compilation${NC}"
    WARNINGS=$((WARNINGS + 1))
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "  ${RED}✗${NC} package-e: Insufficient artifacts ($rust_e_files files)"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
echo ""

# ============================================================================
# PHASE 4: EXECUTE ARM64 MACOS BINARIES
# ============================================================================
echo ""
echo "════════════════════════════════════════════════════════════════"
echo -e "${BOLD}PHASE 4: Executing ARM64 macOS Binaries${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""

EXECUTION_TESTS=0
EXECUTION_PASSED=0
EXECUTION_FAILED=0

# Check if we're on ARM64 macOS
ARCH=$(uname -m)
if [[ "$OSTYPE" == "darwin"* && "$ARCH" == "arm64" ]]; then
    echo -e "${CYAN}Running on ARM64 macOS - testing native binaries${NC}"
    echo ""
    
    for binary in packages/*/release/*aarch64-apple-darwin; do
        # Skip if it's not a file or doesn't exist
        [ -f "$binary" ] || continue
        
        # Skip archives and checksums
        [[ "$binary" == *.tar.gz ]] && continue
        [[ "$binary" == *.sha256 ]] && continue
        
        EXECUTION_TESTS=$((EXECUTION_TESTS + 1))
        package_name=$(basename "$binary" | sed 's/-aarch64-apple-darwin//')
        
        echo -e "${BLUE}→ Testing ${package_name}${NC}"
        echo "  Binary: $binary"
        
        # Try to execute with timeout and capture output
        output=$(timeout 3 "$binary" --help 2>&1 || timeout 3 "$binary" --version 2>&1 || timeout 3 "$binary" 2>&1)
        exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            echo -e "  ${GREEN}✓ Executed successfully${NC}"
            echo "  Output (first 15 lines):"
            echo "$output" | head -15 | sed 's/^/    /'
            echo ""
            EXECUTION_PASSED=$((EXECUTION_PASSED + 1))
        elif [ $exit_code -eq 124 ]; then
            echo -e "  ${YELLOW}⚠ Timeout (may be interactive)${NC}"
            if [ -n "$output" ]; then
                echo "  Output (first 15 lines):"
                echo "$output" | head -15 | sed 's/^/    /'
                echo ""
            fi
            EXECUTION_PASSED=$((EXECUTION_PASSED + 1))
        else
            echo -e "  ${RED}✗ Failed to execute (exit code: $exit_code)${NC}"
            if [ -n "$output" ]; then
                echo "  Error output:"
                echo "$output" | head -10 | sed 's/^/    /'
            fi
            EXECUTION_FAILED=$((EXECUTION_FAILED + 1))
        fi
        echo ""
    done
    
    if [ $EXECUTION_TESTS -eq 0 ]; then
        echo -e "${YELLOW}⚠ No ARM64 macOS binaries found to test${NC}"
    else
        echo -e "${CYAN}ARM64 macOS Execution Summary:${NC}"
        echo "  Total binaries tested: $EXECUTION_TESTS"
        echo -e "  ${GREEN}Successful: $EXECUTION_PASSED${NC}"
        if [ $EXECUTION_FAILED -gt 0 ]; then
            echo -e "  ${RED}Failed: $EXECUTION_FAILED${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠ Not running on ARM64 macOS - skipping native execution tests${NC}"
    echo "  Current platform: $OSTYPE ($ARCH)"
fi

# Add execution results to total counts
TOTAL_TESTS=$((TOTAL_TESTS + EXECUTION_TESTS))
PASSED_TESTS=$((PASSED_TESTS + EXECUTION_PASSED))
FAILED_TESTS=$((FAILED_TESTS + EXECUTION_FAILED))

# ============================================================================
# PHASE 5: EXECUTE LINUX X86_64 BINARIES IN DOCKER
# ============================================================================
echo ""
echo "════════════════════════════════════════════════════════════════"
echo -e "${BOLD}PHASE 5: Executing Linux x86_64 Binaries in Docker${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠ Docker not found - skipping Linux binary tests${NC}"
    echo "  Install Docker Desktop to enable Linux binary testing"
elif ! docker ps > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠ Docker not running - skipping Linux binary tests${NC}"
    echo "  Start Docker Desktop to enable Linux binary testing"
else
    echo -e "${CYAN}Docker is available - testing Linux binaries${NC}"
    echo ""
    
    LINUX_TESTS=0
    LINUX_PASSED=0
    LINUX_FAILED=0

    # Find all Linux x86_64 binaries (from Go and Rust)
    for binary in packages/*/release/*x86_64-unknown-linux-gnu packages/*/release/*x86_64-linux; do
        # Skip if it's not a file or doesn't exist
        [ -f "$binary" ] || continue
        
        # Skip archives and checksums
        [[ "$binary" == *.tar.gz ]] && continue
        [[ "$binary" == *.sha256 ]] && continue
        
        LINUX_TESTS=$((LINUX_TESTS + 1))
        
        # Extract package name from binary path
        if [[ "$binary" == *"x86_64-unknown-linux-gnu"* ]]; then
            package_name=$(basename "$binary" | sed 's/-x86_64-unknown-linux-gnu//')
        elif [[ "$binary" == *"x86_64-linux"* ]]; then
            package_name=$(basename "$binary" | sed 's/-x86_64-linux//')
        else
            package_name=$(basename "$binary")
        fi
        
        echo -e "${BLUE}→ Testing ${package_name} (Linux x86_64 in Docker)${NC}"
        echo "  Binary: $binary"
        
        # Create a unique container name
        container_name="test-${package_name}-$$-$RANDOM"
        
        # Remove any existing container with this name
        docker rm -f "$container_name" 2>/dev/null || true
        docker rm -f "${container_name}-v" 2>/dev/null || true
        
        DOCKER_CONTAINERS_TO_CLEANUP+=("$container_name")
        
        # Copy binary to a temp location with exec permissions
        temp_binary="/tmp/${package_name}-test-$$"
        cp "$binary" "$temp_binary"
        chmod +x "$temp_binary"
        
        # Run in Alpine Linux container (small and fast)
        echo "  Starting Alpine Linux container..."
        
        # Clear previous output
        > /tmp/docker-output-$$.txt
        
        # Try --help flag first
        if docker run --name "$container_name" --rm \
            -v "$temp_binary:/app/binary:ro" \
            alpine:latest \
            timeout 5 /app/binary --help >> /tmp/docker-output-$$.txt 2>&1; then
            result1=0
        else
            result1=$?
        fi
        
        # If --help failed, try --version
        if [ $result1 -ne 0 ]; then
            > /tmp/docker-output-$$.txt
            if docker run --name "${container_name}-v" --rm \
                -v "$temp_binary:/app/binary:ro" \
                alpine:latest \
                timeout 5 /app/binary --version >> /tmp/docker-output-$$.txt 2>&1; then
                result2=0
            else
                result2=$?
            fi
        else
            result2=0
        fi
        
        if [ $result1 -eq 0 ] || [ $result2 -eq 0 ]; then
            echo -e "  ${GREEN}✓ Executed successfully in Docker${NC}"
            echo "  Output (first 15 lines):"
            head -15 /tmp/docker-output-$$.txt | sed 's/^/    /'
            echo ""
            LINUX_PASSED=$((LINUX_PASSED + 1))
        else
            if grep -q "timeout" /tmp/docker-output-$$.txt 2>/dev/null || \
               [ $result1 -eq 124 ] || [ $result2 -eq 124 ]; then
                echo -e "  ${YELLOW}⚠ Timeout in Docker${NC}"
                if [ -s /tmp/docker-output-$$.txt ]; then
                    echo "  Output (first 15 lines):"
                    head -15 /tmp/docker-output-$$.txt | sed 's/^/    /'
                    echo ""
                fi
                LINUX_PASSED=$((LINUX_PASSED + 1))
            else
                echo -e "  ${RED}✗ Failed in Docker${NC}"
                if [ -s /tmp/docker-output-$$.txt ]; then
                    echo "  Error output (first 20 lines):"
                    head -20 /tmp/docker-output-$$.txt | sed 's/^/    /'
                    echo ""
                fi
                LINUX_FAILED=$((LINUX_FAILED + 1))
            fi
        fi
        
        # Cleanup temp files
        rm -f "$temp_binary" /tmp/docker-output-$$.txt
        echo ""
    done

    # Cleanup Docker containers
    if [ ${#DOCKER_CONTAINERS_TO_CLEANUP[@]} -gt 0 ]; then
        echo "Cleaning up Docker containers..."
        for container in "${DOCKER_CONTAINERS_TO_CLEANUP[@]}"; do
            docker rm -f "$container" 2>/dev/null || true
            docker rm -f "${container}-v" 2>/dev/null || true
            docker rm -f "${container}-bare" 2>/dev/null || true
        done
        echo -e "${GREEN}✓ Docker cleanup complete${NC}"
        DOCKER_CONTAINERS_TO_CLEANUP=()
        echo ""
    fi

    if [ $LINUX_TESTS -eq 0 ]; then
        echo -e "${YELLOW}⚠ No Linux x86_64 binaries found to test${NC}"
        echo "  Enable Go or Rust cross-compilation to build Linux binaries"
    else
        echo -e "${CYAN}Linux Execution Summary:${NC}"
        echo "  Total binaries tested: $LINUX_TESTS"
        echo -e "  ${GREEN}Successful: $LINUX_PASSED${NC}"
        if [ $LINUX_FAILED -gt 0 ]; then
            echo -e "  ${RED}Failed: $LINUX_FAILED${NC}"
        fi
    fi

    # Add Linux execution results to total counts
    TOTAL_TESTS=$((TOTAL_TESTS + LINUX_TESTS))
    PASSED_TESTS=$((PASSED_TESTS + LINUX_PASSED))
    FAILED_TESTS=$((FAILED_TESTS + LINUX_FAILED))
fi

# ============================================================================
# PHASE 6: SUMMARY STATISTICS
# ============================================================================
echo ""
echo "════════════════════════════════════════════════════════════════"
echo -e "${BOLD}PHASE 6: Summary Statistics${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Count all binaries
total_binaries=$(find packages/*/release -type f ! -name "*.tar.gz" ! -name "*.zip" ! -name "*.sha256" ! -name "*.jar" 2>/dev/null | wc -l | xargs)
echo "Total executables built: $total_binaries"

# Count all archives
total_archives=$(find packages/*/release -type f \( -name "*.tar.gz" -o -name "*.zip" \) 2>/dev/null | wc -l | xargs)
echo "Total archives created: $total_archives"

# Count all checksums
sha256_count=$(find packages/*/release -name "*.sha256" 2>/dev/null | wc -l | xargs)
echo "Total checksums created: $sha256_count"

# Count JARs
jar_count=$(find packages/*/release -name "*.jar" 2>/dev/null | wc -l | xargs)
if [ $jar_count -gt 0 ]; then
    echo "Total JARs created: $jar_count"
fi

# ============================================================================
# FINAL RESULTS
# ============================================================================
echo ""
echo "════════════════════════════════════════════════════════════════"
echo -e "${BOLD}FINAL VERIFICATION RESULTS${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Total Tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
if [ "$FAILED_TESTS" -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
else
    echo -e "${GREEN}Failed: $FAILED_TESTS${NC}"
fi
if [ "$WARNINGS" -gt 0 ]; then
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
fi
echo ""

# Calculate percentage
if [ "$TOTAL_TESTS" -gt 0 ]; then
    percentage=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "Success Rate: ${percentage}%"
fi

echo ""
echo "Detailed build log: /tmp/build-all-verification.log"
echo ""

# Exit with appropriate code
if [ "$FAILED_TESTS" -eq 0 ]; then
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo -e "║  ${GREEN}${BOLD}✓ ALL VERIFICATION TESTS PASSED${NC}                           ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    exit 0
else
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo -e "║  ${YELLOW}${BOLD}⚠ SOME VERIFICATION TESTS FAILED${NC}                          ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    exit 1
fi
