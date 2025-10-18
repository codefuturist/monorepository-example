# Shared Build Scripts

This directory contains reusable build scripts for different programming languages. These scripts can be used in the monorepo or copied to external projects.

## Available Scripts

### C++ (CMake)
**File:** `cpp-cmake-build.sh`

Builds C++ projects using CMake with cross-platform support.

**Usage in monorepo:**
```bash
# In package directory
export VERSION="1.0.0"
export PACKAGE_NAME="my-package"
export CMAKE_TARGET_NAME="my_app"
source ../../scripts/build/cpp-cmake-build.sh
```

**Standalone usage:**
```bash
# Copy script to your project
cp scripts/build/cpp-cmake-build.sh ~/my-cpp-project/
cd ~/my-cpp-project

# Run with defaults
./cpp-cmake-build.sh

# Or override configuration
VERSION="2.0.0" PACKAGE_NAME="my-app" ./cpp-cmake-build.sh
```

**Configuration:**
- `VERSION` - Project version (default: `1.0.0`)
- `PACKAGE_NAME` - Package name (default: `my-cpp-project`)
- `CMAKE_TARGET_NAME` - CMake target name (default: `$PACKAGE_NAME`)
- `BUILD_TYPE` - Build type (default: `Release`)
- `BUILD_DIR` - Build directory (default: `build-release`)
- `RELEASE_DIR` - Output directory (default: `release`)

---

### Rust (Cargo)
**File:** `rust-cargo-build.sh`

Builds Rust projects using Cargo with cross-compilation support.

**Usage in monorepo:**
```bash
# In package directory
export VERSION="1.0.0"
export PACKAGE_NAME="my-package"
source ../../scripts/build/rust-cargo-build.sh
```

**Standalone usage:**
```bash
# Copy script to your project
cp scripts/build/rust-cargo-build.sh ~/my-rust-app/
cd ~/my-rust-app

# Run with defaults
./rust-cargo-build.sh

# Or override configuration
VERSION="2.0.0" PACKAGE_NAME="my-app" ./rust-cargo-build.sh
```

**Configuration:**
- `VERSION` - Project version (default: `1.0.0`)
- `PACKAGE_NAME` - Package/binary name (default: `my-rust-app`)
- `RELEASE_DIR` - Output directory (default: `release`)
- `CARGO_FLAGS` - Additional cargo flags (default: empty)

**Cross-compilation:**
```bash
# Install targets first
rustup target add aarch64-unknown-linux-gnu
rustup target add x86_64-pc-windows-msvc

# Script will try to cross-compile automatically
./rust-cargo-build.sh
```

---

### Go
**File:** `go-build.sh`

Builds Go projects for multiple platforms simultaneously.

**Usage in monorepo:**
```bash
# In package directory
export VERSION="1.0.0"
export PACKAGE_NAME="my-package"
export MAIN_FILE="./cmd/main.go"
export TARGETS=(
    "linux:amd64:x86_64-unknown-linux-gnu"
    "darwin:arm64:aarch64-apple-darwin"
    "windows:amd64:x86_64-pc-windows-msvc"
)
source ../../scripts/build/go-build.sh
```

**Standalone usage:**
```bash
# Copy script to your project
cp scripts/build/go-build.sh ~/my-go-app/
cd ~/my-go-app

# Run with defaults (builds 6 platforms)
./go-build.sh

# Custom targets
TARGETS=("linux:amd64:x86_64-unknown-linux-gnu") ./go-build.sh
```

**Configuration:**
- `VERSION` - Project version (default: `1.0.0`)
- `PACKAGE_NAME` - Package name (default: `my-go-app`)
- `MAIN_FILE` - Entry point (default: `./cmd/main.go`)
- `RELEASE_DIR` - Output directory (default: `release`)
- `LDFLAGS` - Linker flags (default: `-s -w`)
- `BUILD_FLAGS` - Additional build flags (default: empty)
- `TARGETS` - Array of `GOOS:GOARCH:TARGET_NAME` (default: 6 platforms)

**Default Targets:**
1. `linux:amd64:x86_64-unknown-linux-gnu`
2. `linux:arm64:aarch64-unknown-linux-gnu`
3. `darwin:amd64:x86_64-apple-darwin`
4. `darwin:arm64:aarch64-apple-darwin`
5. `windows:amd64:x86_64-pc-windows-msvc`
6. `windows:arm64:aarch64-pc-windows-msvc`

---

### Python (PyInstaller)
**File:** `python-pyinstaller-build.sh`

Builds Python projects into standalone executables using PyInstaller.

**Usage in monorepo:**
```bash
# In package directory
export VERSION="1.0.0"
export PACKAGE_NAME="my-package"
export ENTRY_POINT="src/main.py"
export PYINSTALLER_DATA=(
    "--add-data src/resources:resources"
    "--collect-all mylib"
)
source ../../scripts/build/python-pyinstaller-build.sh
```

**Standalone usage:**
```bash
# Copy script to your project
cp scripts/build/python-pyinstaller-build.sh ~/my-python-app/
cd ~/my-python-app

# Run with defaults
./python-pyinstaller-build.sh

# Or override configuration
VERSION="2.0.0" ENTRY_POINT="app.py" ./python-pyinstaller-build.sh
```

**Configuration:**
- `VERSION` - Project version (default: `1.0.0`)
- `PACKAGE_NAME` - Package name (default: `my-python-app`)
- `ENTRY_POINT` - Main Python file (default: `src/main.py`)
- `RELEASE_DIR` - Output directory (default: `release`)
- `PYINSTALLER_NAME` - Executable name (default: `$PACKAGE_NAME`)
- `PYINSTALLER_FLAGS` - PyInstaller flags (default: `--onefile`)
- `PYINSTALLER_DATA` - Array of `--add-data` or `--collect-all` flags (default: empty)
- `BUILD_DEPS` - Dependencies to install (default: `pyinstaller`)

---

## Platform Support

All scripts support the following platforms:

| Platform | Architecture | Target Triple |
|----------|-------------|---------------|
| Linux | x86_64 | `x86_64-unknown-linux-gnu` |
| Linux | ARM64 | `aarch64-unknown-linux-gnu` |
| macOS | x86_64 | `x86_64-apple-darwin` |
| macOS | ARM64 | `aarch64-apple-darwin` |
| Windows | x86_64 | `x86_64-pc-windows-msvc` |
| Windows | ARM64 | `aarch64-pc-windows-msvc` |

## Output Format

All scripts produce consistent output:

### Binaries
- `{package-name}-{target-triple}` (Unix)
- `{package-name}-{target-triple}.exe` (Windows)

### Archives
- `{package-name}-{target-triple}.tar.gz` (Unix)
- `{package-name}-{target-triple}.zip` (Windows)

### Checksums
- `{package-name}-{target-triple}.tar.gz.sha256` (archive checksum)
- `{package-name}-{target-triple}.sha256` (binary checksum)

## Environment Variables Pattern

All scripts use the `${VARIABLE:-default}` pattern, which means:

1. **Sourced from package script:** Uses exported values
2. **Run standalone:** Uses default values
3. **Environment override:** `VAR=value ./script.sh`

Example:
```bash
# Default (if VERSION not set)
VERSION="${VERSION:-1.0.0}"  # Uses 1.0.0

# Exported from wrapper
export VERSION="2.0.0"
source script.sh  # Uses 2.0.0

# Environment override
VERSION="3.0.0" ./script.sh  # Uses 3.0.0
```

## Using in Monorepo Packages

Each package has a thin wrapper script that:
1. Exports package-specific configuration
2. Sources the shared script
3. Handles errors if script not found

Example wrapper (`packages/my-package/build.sh`):
```bash
#!/usr/bin/env bash
set -e

# Package configuration
export VERSION="1.0.0"
export PACKAGE_NAME="my-package"
# ... other config

# Use shared build script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_SCRIPT="$SCRIPT_DIR/../../scripts/build/LANGUAGE-build.sh"

if [[ -f "$SHARED_SCRIPT" ]]; then
    source "$SHARED_SCRIPT"
else
    echo "Error: Shared build script not found at $SHARED_SCRIPT"
    exit 1
fi
```

## Using in External Projects

Simply copy the script you need:

```bash
# Copy C++ build script
cp scripts/build/cpp-cmake-build.sh ~/my-project/

# Copy Python build script
cp scripts/build/python-pyinstaller-build.sh ~/my-app/

# Make executable
chmod +x cpp-cmake-build.sh

# Run with defaults or environment variables
VERSION="1.0.0" ./cpp-cmake-build.sh
```

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Build Package
  run: |
    cd packages/my-package
    ./build.sh
  env:
    VERSION: ${{ github.ref_name }}
```

### Environment Override Example

```yaml
- name: Build with Custom Config
  run: ./scripts/build/go-build.sh
  env:
    VERSION: "2.0.0"
    PACKAGE_NAME: "custom-name"
    MAIN_FILE: "./main.go"
    LDFLAGS: "-s -w -X main.version=${{ github.sha }}"
```

## Error Handling

All scripts use `set -e` to exit immediately on errors. They also:
- Validate required tools are installed
- Check for successful compilation
- Verify output files exist
- Generate checksums for verification

## Best Practices

1. **Keep scripts updated centrally** - Update shared scripts, all packages benefit
2. **Use environment variables** - Override defaults without editing scripts
3. **Test before releasing** - Run build scripts before tagging releases
4. **Version your outputs** - Always set `VERSION` environment variable
5. **Verify checksums** - Check `.sha256` files after builds

## Customization

To customize for your needs:

1. **Copy the script** to your project
2. **Modify the defaults** in the CONFIGURATION section
3. **Or** set environment variables when running

## Troubleshooting

### Script not found error
```
Error: Shared build script not found at ../../scripts/build/xxx-build.sh
```
**Solution:** Ensure you're running from the package directory and the path is correct.

### Permission denied
```
bash: ./build.sh: Permission denied
```
**Solution:** Make script executable: `chmod +x build.sh`

### Cross-compilation fails (Rust)
```
error: linker `cc` not found
```
**Solution:** Install cross-compilation toolchain or remove cross-compilation attempt from script.

### PyInstaller not found
```
pyinstaller: command not found
```
**Solution:** Install PyInstaller: `pip install pyinstaller`

## Further Documentation

For more detailed information about build scripts and their configuration, see:
- [BUILD_SCRIPTS_GUIDE.md](../../BUILD_SCRIPTS_GUIDE.md) - Comprehensive guide
- Package-specific build scripts in `packages/*/build.sh`
- GitHub Actions workflows in `.github/workflows/`
