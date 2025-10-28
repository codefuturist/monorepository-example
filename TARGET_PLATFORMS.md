# Target Platforms and Architectures

## Overview

This monorepo builds release binaries for multiple platforms and architectures. For languages that support cross-compilation, we build for both **x86_64** (Intel/AMD) and **ARM64** (Apple Silicon, ARM servers) on all major platforms.

**No 32-bit builds** - We only target 64-bit architectures as they are the standard for modern systems.

## Target Matrix

### Supported Platforms and Architectures

| Platform    | x86_64 (AMD64) | ARM64 (AArch64) | Notes                        |
| ----------- | -------------- | --------------- | ---------------------------- |
| **Linux**   | ✅             | ✅              | Both architectures supported |
| **macOS**   | ✅             | ✅              | Intel + Apple Silicon        |
| **Windows** | ✅             | ✅              | x64 + ARM64                  |

## Language-Specific Support

### Go (Native Cross-Compilation)

**Target List**: 6 binaries per package

```
linux/amd64    → x86_64-unknown-linux-gnu
linux/arm64    → aarch64-unknown-linux-gnu
darwin/amd64   → x86_64-apple-darwin (Intel Macs)
darwin/arm64   → aarch64-apple-darwin (Apple Silicon)
windows/amd64  → x86_64-pc-windows-msvc
windows/arm64  → aarch64-pc-windows-msvc
```

**Package**: `package-g`

**Output**:

- ✅ Linux x86_64 binary
- ✅ Linux ARM64 binary
- ✅ macOS x86_64 binary (Intel)
- ✅ macOS ARM64 binary (Apple Silicon)
- ✅ Windows x86_64 binary
- ✅ Windows ARM64 binary

**End User Requirements**: None - standalone binaries

---

### Rust (Cross-Compilation with Targets)

**Target List**: 6 binaries per package

```
x86_64-unknown-linux-gnu      → Linux x86_64
aarch64-unknown-linux-gnu     → Linux ARM64
x86_64-apple-darwin           → macOS Intel
aarch64-apple-darwin          → macOS Apple Silicon
x86_64-pc-windows-gnu         → Windows x86_64
aarch64-pc-windows-gnullvm    → Windows ARM64
```

**Packages**: `package-e`, `package-i`

**Output**:

- ✅ Linux x86_64 binary
- ✅ Linux ARM64 binary
- ✅ macOS x86_64 binary (Intel)
- ✅ macOS ARM64 binary (Apple Silicon)
- ✅ Windows x86_64 binary
- ✅ Windows ARM64 binary

**End User Requirements**: None - standalone binaries

---

### Java (Platform-Independent)

**Target**: All platforms automatically supported

**Package**: `package-h`

**Output**:

- ✅ Universal JAR (works on ALL platforms)

**Supported Platforms**:

- ✅ Linux (x86_64, ARM64, ARM32, etc.)
- ✅ macOS (x86_64, ARM64)
- ✅ Windows (x86_64, ARM64)
- ✅ Any other platform with JVM

**End User Requirements**:

- Java Runtime Environment (JRE) or Java Development Kit (JDK)
- Compatible version as specified in `pom.xml`

---

### Swift (macOS Universal Binaries)

**Target**: macOS Universal Binary (combines both architectures)

**Package**: `package-f`

**Output**:

- ✅ macOS Universal Binary (contains both Intel + ARM64 code)

**Supported Platforms**:

- ✅ macOS x86_64 (Intel Macs)
- ✅ macOS ARM64 (Apple Silicon)

**End User Requirements**: None - standalone binary

**Note**: Single binary works on both Intel and Apple Silicon Macs automatically

---

### Python (PyInstaller - Platform-Specific)

**Target**: Platform and architecture where built

**Packages**: `package-a`, `package-b`, `package-c`

**Important**: PyInstaller creates **STANDALONE executables** - no Python interpreter required by end users!

**Output per build platform**:

- Build on Linux x86_64 → ✅ Linux x86_64 standalone binary
- Build on Linux ARM64 → ✅ Linux ARM64 standalone binary
- Build on macOS x86_64 → ✅ macOS x86_64 standalone binary
- Build on macOS ARM64 → ✅ macOS ARM64 standalone binary
- Build on Windows x86_64 → ✅ Windows x86_64 standalone binary
- Build on Windows ARM64 → ✅ Windows ARM64 standalone binary

**To get all 6 binaries**: Must build on each target platform/architecture

**End User Requirements**: None - PyInstaller bundles Python interpreter and all dependencies

**Recommended CI/CD Strategy**:

```yaml
matrix:
  os:
    [
      ubuntu-latest,
      ubuntu-latest-arm,
      macos-13,
      macos-14,
      windows-latest,
      windows-latest-arm,
    ]
```

---

### C++ (CMake - Platform-Specific)

**Target**: Platform and architecture where built

**Package**: `package-d`

**Output per build platform**:

- Build on Linux x86_64 → ✅ Linux x86_64 binary
- Build on Linux ARM64 → ✅ Linux ARM64 binary
- Build on macOS x86_64 → ✅ macOS x86_64 binary
- Build on macOS ARM64 → ✅ macOS ARM64 binary
- Build on Windows x86_64 → ✅ Windows x86_64 binary
- Build on Windows ARM64 → ✅ Windows ARM64 binary

**To get all 6 binaries**: Must build on each target platform/architecture (or use advanced cross-compilation toolchains)

**End User Requirements**:

- May require system libraries depending on linking (static vs dynamic)
- Best practice: static linking for standalone binaries

---

## Build Output Summary

### Cross-Compilation Languages (Build Once)

#### Go & Rust

Build once on any platform → Get binaries for all 6 targets:

```
release/
  ├── package-name-x86_64-unknown-linux-gnu
  ├── package-name-aarch64-unknown-linux-gnu
  ├── package-name-x86_64-apple-darwin
  ├── package-name-aarch64-apple-darwin
  ├── package-name-x86_64-pc-windows-*.exe
  ├── package-name-aarch64-pc-windows-*.exe
  └── (+ all .tar.gz/.zip and .sha256 files)
```

#### Java

Build once on any platform → Get universal JAR:

```
release/
  ├── package-name-universal.jar (works everywhere)
  └── (+ .tar.gz and .sha256 files)
```

### Platform-Specific Languages (Build on Each Platform)

#### Python, C++, Swift

Must build on each target platform:

**Linux x86_64 runner**:

```
release/
  └── package-name-x86_64-unknown-linux-gnu
```

**Linux ARM64 runner**:

```
release/
  └── package-name-aarch64-unknown-linux-gnu
```

**macOS Intel runner**:

```
release/
  └── package-name-x86_64-apple-darwin
```

**macOS Apple Silicon runner**:

```
release/
  └── package-name-aarch64-apple-darwin
      (or package-name-universal-apple-darwin for Swift)
```

**Windows x86_64 runner**:

```
release/
  └── package-name-x86_64-pc-windows-*.exe
```

**Windows ARM64 runner**:

```
release/
  └── package-name-aarch64-pc-windows-*.exe
```

---

## End User Requirements by Language

| Language             | Requires Interpreter/Runtime? | Standalone Binary? |
| -------------------- | ----------------------------- | ------------------ |
| Go                   | ❌ No                         | ✅ Yes             |
| Rust                 | ❌ No                         | ✅ Yes             |
| Python (PyInstaller) | ❌ No (bundled)               | ✅ Yes             |
| Swift                | ❌ No                         | ✅ Yes             |
| C++                  | ❌ No (if static)             | ✅ Yes (if static) |
| Java                 | ✅ Yes (JRE/JDK required)     | ❌ No              |

### Key Points:

1. **Go, Rust, Python (PyInstaller), Swift, C++ (static)**: End users just download and run the binary - no installation needed!

2. **Java**: End users need JRE/JDK installed, but the same JAR works on all platforms

3. **Python with PyInstaller**:
   - The binary is **completely standalone**
   - Python interpreter is **bundled inside** the executable
   - All dependencies are **bundled inside** the executable
   - End users **do NOT need Python installed**
   - Just download and run like any other application!

---

## CI/CD Strategy

### Recommended GitHub Actions Matrix

```yaml
name: Build All Platforms

on: [push, pull_request]

jobs:
  # Cross-compilation languages - build once
  cross-compile:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        package: [package-e, package-g, package-h]
    steps:
      - uses: actions/checkout@v4
      - name: Build (creates all platform binaries)
        run: cd packages/${{ matrix.package }} && ./build.sh

  # Platform-specific languages - matrix build
  platform-specific:
    strategy:
      matrix:
        include:
          # Linux
          - os: ubuntu-latest
            arch: x64
            packages: package-a package-b package-c package-d
          - os: ubuntu-latest-arm
            arch: arm64
            packages: package-a package-b package-c package-d

          # macOS
          - os: macos-13 # Intel
            arch: x64
            packages: package-a package-b package-c package-d
          - os: macos-14 # Apple Silicon
            arch: arm64
            packages: package-a package-b package-c package-d package-f

          # Windows
          - os: windows-latest
            arch: x64
            packages: package-a package-b package-c package-d
          - os: windows-latest
            arch: arm64
            packages: package-a package-b package-c package-d

    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Build packages
        run: |
          for pkg in ${{ matrix.packages }}; do
            cd packages/$pkg && ./build.sh && cd ../..
          done
```

---

## Verification Commands

### Check Binary Architecture

**Linux/macOS**:

```bash
# Check architecture
file package-name-*

# On macOS, check if universal
lipo -info package-name-universal-apple-darwin
```

**Windows**:

```powershell
# Check PE header
dumpbin /headers package-name.exe | findstr machine
```

### Test Cross-Platform Binaries

```bash
# Build with cross-compilation
cd packages/package-e && CROSS_COMPILE=true ./build.sh

# Check output
ls -lh release/
# Should see 6 binaries (2 per platform)

# Verify architectures
file release/*
```

---

## Summary

✅ **64-bit only** - No 32-bit builds (modern standard)

✅ **Both architectures per platform**:

- Linux: x86_64 + ARM64
- macOS: x86_64 (Intel) + ARM64 (Apple Silicon)
- Windows: x86_64 + ARM64

✅ **Standalone executables** where possible:

- Go, Rust: Native standalone
- Python (PyInstaller): Bundled interpreter + dependencies
- Swift: Native standalone
- C++: Standalone with static linking
- Java: Requires JRE but JAR is universal

✅ **Total binaries per package**:

- Go/Rust: 6 binaries (2 per platform × 3 platforms)
- Java: 1 JAR (works everywhere)
- Swift: 1 universal binary (both macOS architectures)
- Python/C++: 1 binary per build platform (6 total when built on all targets)

This ensures maximum compatibility and ease of distribution for end users!
