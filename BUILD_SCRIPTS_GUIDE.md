# Reusable Build Scripts Guide

This repository contains production-ready, reusable build scripts for multiple programming languages. Each script follows a clear **CONFIGURATION** vs **IMPLEMENTATION** separation pattern, making them easy to adapt for your own projects.

## 📋 Table of Contents

- [Available Build Scripts](#available-build-scripts)
- [Design Philosophy](#design-philosophy)
- [Usage Instructions](#usage-instructions)
  - [C++ Projects](#c-projects-cmake)
  - [Rust Projects](#rust-projects-cargo)
  - [Go Projects](#go-projects)
  - [Python Projects](#python-projects-pyinstaller)
- [Configuration Reference](#configuration-reference)
- [Platform Support](#platform-support)
- [Best Practices](#best-practices)

## 🛠️ Available Build Scripts

| Language | Tool | Script Location | Use Case |
|----------|------|----------------|----------|
| **C++** | CMake | [`packages/package-d/build.sh`](packages/package-d/build.sh) | CMake-based C++ projects |
| **Rust** | Cargo | [`packages/package-e/build.sh`](packages/package-e/build.sh) | Cargo-based Rust projects |
| **Go** | Go toolchain | [`packages/package-g/build.sh`](packages/package-g/build.sh) | Go projects with multi-platform support |
| **Python** | PyInstaller | [`packages/package-a/build.sh`](packages/package-a/build.sh) | Python projects with standalone executables |

## 🎯 Design Philosophy

All build scripts follow the same pattern:

```bash
#!/usr/bin/env bash
# ==============================================================================
# CONFIGURATION - UPDATE THESE VALUES FOR YOUR PROJECT
# ==============================================================================
VERSION="1.0.0"
PACKAGE_NAME="my-package"
# ... other configurable values

# ==============================================================================
# IMPLEMENTATION - REUSABLE ACROSS ALL PROJECTS
# ==============================================================================
# ... platform detection, build logic, packaging
```

**Benefits:**
- ✅ **Easy to customize**: All project-specific values in one place
- ✅ **Reusable**: Implementation code works across projects
- ✅ **Maintainable**: Clear separation of concerns
- ✅ **Consistent**: Same naming conventions across languages
- ✅ **Production-ready**: Includes checksums, archives, error handling

## 📖 Usage Instructions

### C++ Projects (CMake)

**Script:** [`packages/package-d/build.sh`](packages/package-d/build.sh)

**Prerequisites:**
- CMake 3.10+
- C++ compiler (GCC, Clang, or MSVC)

**Configuration:**
```bash
VERSION="1.0.0"                    # Project version
PACKAGE_NAME="package-d"           # Package name (used for output files)
CMAKE_TARGET_NAME="package_d_cli"  # CMake executable target name
BUILD_TYPE="Release"               # CMake build type

BUILD_DIR="build-release"          # Where CMake builds
RELEASE_DIR="release"              # Where artifacts are stored
```

**To use in your project:**
1. Copy `build.sh` to your project root
2. Update the `CONFIGURATION` section
3. Ensure your `CMakeLists.txt` defines the executable target
4. Run: `./build.sh`

**Output:**
```
release/
  ├── my-package-x86_64-unknown-linux-gnu
  ├── my-package-x86_64-unknown-linux-gnu.tar.gz
  └── my-package-x86_64-unknown-linux-gnu.tar.gz.sha256
```

---

### Rust Projects (Cargo)

**Script:** [`packages/package-e/build.sh`](packages/package-e/build.sh)

**Prerequisites:**
- Rust toolchain (rustc, cargo)
- Optional: Additional target toolchains for cross-compilation

**Configuration:**
```bash
VERSION="1.0.0"              # Project version
PACKAGE_NAME="package-e"     # Binary name (from Cargo.toml)
RELEASE_DIR="release"        # Where artifacts are stored
CARGO_FLAGS=""               # Additional cargo build flags
```

**To use in your project:**
1. Copy `build.sh` to your Rust project root (where `Cargo.toml` is)
2. Update the `CONFIGURATION` section
3. Ensure `PACKAGE_NAME` matches the `[[bin]]` name in `Cargo.toml`
4. Run: `./build.sh`

**For cross-compilation:**
```bash
# Install additional targets
rustup target add aarch64-unknown-linux-gnu
rustup target add x86_64-pc-windows-msvc

# Build script will automatically use them if available
./build.sh
```

**Output:**
```
release/
  ├── my-app-x86_64-unknown-linux-gnu
  ├── my-app-x86_64-unknown-linux-gnu.tar.gz
  ├── my-app-x86_64-unknown-linux-gnu.tar.gz.sha256
  └── my-app-x86_64-unknown-linux-gnu.sha256
```

---

### Go Projects

**Script:** [`packages/package-g/build.sh`](packages/package-g/build.sh)

**Prerequisites:**
- Go 1.16+ (with module support)

**Configuration:**
```bash
VERSION="1.0.0"                # Project version
PACKAGE_NAME="package-g"       # Package name
MAIN_FILE="./cmd/main.go"      # Path to main.go
RELEASE_DIR="release"          # Where artifacts are stored
LDFLAGS="-s -w"                # Linker flags
BUILD_FLAGS=""                 # Additional go build flags

# Build targets (modify this array)
TARGETS=(
    "linux:amd64:x86_64-unknown-linux-gnu"
    "darwin:arm64:aarch64-apple-darwin"
    "windows:amd64:x86_64-pc-windows-msvc"
)
```

**To use in your project:**
1. Copy `build.sh` to your Go project root (where `go.mod` is)
2. Update the `CONFIGURATION` section
3. Modify `TARGETS` array to include/exclude platforms
4. Run: `./build.sh`

**Building for specific platforms:**
```bash
# Edit TARGETS array in build.sh
TARGETS=(
    "linux:amd64:x86_64-unknown-linux-gnu"
    "darwin:arm64:aarch64-apple-darwin"
)

./build.sh
```

**Output:**
```
release/
  ├── my-cli-x86_64-unknown-linux-gnu
  ├── my-cli-x86_64-unknown-linux-gnu.tar.gz
  ├── my-cli-aarch64-apple-darwin
  ├── my-cli-aarch64-apple-darwin.tar.gz
  └── ... (checksums for each)
```

---

### Python Projects (PyInstaller)

**Script:** [`packages/package-a/build.sh`](packages/package-a/build.sh)

**Prerequisites:**
- Python 3.7+
- pip

**Configuration:**
```bash
VERSION="1.2.0"                           # Project version
PACKAGE_NAME="package-a"                  # Package name
ENTRY_POINT="src/package_a/__main__.py"  # Main entry point
RELEASE_DIR="release"                     # Where artifacts are stored

PYINSTALLER_NAME="$PACKAGE_NAME"          # Executable name
PYINSTALLER_FLAGS="--onefile"             # PyInstaller flags

# Dependencies to collect
PYINSTALLER_DATA=(
    "--add-data src/package_a:package_a"
    "--collect-all colorama"
)

# Build dependencies to install
BUILD_DEPS="pyinstaller colorama"
```

**To use in your project:**
1. Copy `build.sh` to your Python project root
2. Update the `CONFIGURATION` section:
   - Set `ENTRY_POINT` to your main script
   - Update `PYINSTALLER_DATA` for your data files
   - Add runtime dependencies to `BUILD_DEPS`
3. Run: `./build.sh`

**Common PyInstaller configurations:**
```bash
# GUI application (no console)
PYINSTALLER_FLAGS="--onefile --windowed"

# Include icon
PYINSTALLER_FLAGS="--onefile --icon=app.ico"

# Add data files
PYINSTALLER_DATA=(
    "--add-data config.yaml:."
    "--add-data templates:templates"
    "--collect-all requests"
)
```

**Output:**
```
release/
  ├── my-app-x86_64-unknown-linux-gnu
  ├── my-app-x86_64-unknown-linux-gnu.tar.gz
  └── my-app-x86_64-unknown-linux-gnu.tar.gz.sha256
```

---

## ⚙️ Configuration Reference

### Common Configuration Options

All scripts support these common configurations:

| Variable | Description | Example |
|----------|-------------|---------|
| `VERSION` | Project version number | `"1.0.0"` |
| `PACKAGE_NAME` | Package/binary name | `"my-app"` |
| `RELEASE_DIR` | Output directory for artifacts | `"release"`, `"dist"` |

### Language-Specific Options

#### C++ (CMake)
- `CMAKE_TARGET_NAME`: CMake executable target name
- `BUILD_TYPE`: CMake build type (`Release`, `Debug`, `RelWithDebInfo`)
- `BUILD_DIR`: CMake build directory

#### Rust (Cargo)
- `CARGO_FLAGS`: Additional cargo build flags
  - Example: `"--features full"`, `"--no-default-features"`

#### Go
- `MAIN_FILE`: Path to main.go file
- `LDFLAGS`: Linker flags for size optimization
  - Default: `"-s -w"` (strip debug info)
- `BUILD_FLAGS`: Additional go build flags
- `TARGETS`: Array of platform targets

#### Python (PyInstaller)
- `ENTRY_POINT`: Main Python script path
- `PYINSTALLER_NAME`: Name of the output executable
- `PYINSTALLER_FLAGS`: PyInstaller command-line flags
- `PYINSTALLER_DATA`: Array of data files/packages to include
- `BUILD_DEPS`: Python packages to install before building

---

## 🌍 Platform Support

All scripts support the following platforms with consistent naming:

| Platform | Architecture | Target Triple |
|----------|--------------|---------------|
| **Linux** | x86_64 | `x86_64-unknown-linux-gnu` |
| **Linux** | aarch64 (ARM64) | `aarch64-unknown-linux-gnu` |
| **macOS** | x86_64 (Intel) | `x86_64-apple-darwin` |
| **macOS** | aarch64 (Apple Silicon) | `aarch64-apple-darwin` |
| **Windows** | x86_64 | `x86_64-pc-windows-msvc` |
| **Windows** | aarch64 (ARM64) | `aarch64-pc-windows-msvc` |

**Platform Detection:**
- Scripts automatically detect the current platform
- Output files include platform-specific naming
- Archives: `.tar.gz` for Unix, `.zip` for Windows

---

## ✨ Best Practices

### 1. Version Management
```bash
# Keep version in sync with package manifests
VERSION="1.0.0"  # Same as Cargo.toml, package.json, etc.
```

### 2. Build Directory Naming
```bash
# Use descriptive names to avoid confusion
BUILD_DIR="build-release"       # C++ CMake builds
RELEASE_DIR="release"           # Final artifacts
```

### 3. Checksums for Security
All scripts automatically generate SHA256 checksums:
```bash
# Verify downloads
sha256sum -c my-app-x86_64-unknown-linux-gnu.tar.gz.sha256
```

### 4. Cross-Platform Compatibility
```bash
# Use appropriate tools for checksums
if command -v sha256sum &> /dev/null; then
    sha256sum "$FILE" > "$FILE.sha256"
else
    shasum -a 256 "$FILE" > "$FILE.sha256"
fi
```

### 5. Error Handling
All scripts use `set -e` to fail fast on errors:
```bash
set -e  # Exit immediately if a command fails
```

### 6. Relative Paths
Scripts work regardless of where they're called from:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
```

---

## 🔄 Adapting for Your Project

### Quick Start Checklist

1. **Choose the right script** for your language
2. **Copy the script** to your project root
3. **Update CONFIGURATION section**:
   - [ ] Set `VERSION`
   - [ ] Set `PACKAGE_NAME`
   - [ ] Update language-specific settings
4. **Test locally**: `./build.sh`
5. **Verify output** in `release/` directory
6. **Check artifacts**:
   - [ ] Binary files created
   - [ ] Archives created (.tar.gz or .zip)
   - [ ] Checksums created (.sha256)

### Example: Adapting Rust Script

```bash
# Original configuration
VERSION="1.0.0"
PACKAGE_NAME="package-e"

# Your project configuration
VERSION="2.1.0"              # Your version
PACKAGE_NAME="my-rust-cli"  # Your binary name from Cargo.toml
CARGO_FLAGS="--features full"  # Enable all features
```

---

## 📦 CI/CD Integration

These scripts work seamlessly with GitHub Actions and other CI systems:

```yaml
# .github/workflows/release.yml
- name: Build release binaries
  run: |
    chmod +x build.sh
    ./build.sh

- name: Upload artifacts
  uses: actions/upload-artifact@v4
  with:
    name: binaries
    path: release/*
```

See [`.github/workflows/`](.github/workflows/) for complete examples.

---

## 🤝 Contributing

Found a way to improve these scripts? Contributions welcome!

1. Maintain the CONFIGURATION/IMPLEMENTATION separation
2. Keep scripts portable across platforms
3. Add comments for complex logic
4. Test on all supported platforms

---

## 📄 License

These build scripts are provided as-is and can be freely used in any project.

---

## 🔗 Related Documentation

- [GitHub Actions Workflows Guide](.github/workflows/README.md)
- [Monorepo Release Guide](MONOREPO_RELEASE_GUIDE.md)
- [Release Pattern](RELEASE_PATTERN.md)
