# Release Artifact Pattern

This monorepo follows the **Starship-style release pattern** for consistent, professional binary distribution across all platforms and languages.

## 🎯 Pattern Overview

Each release includes multiple files following this naming convention:

```
package-name-<platform-triple>.<archive-ext>
package-name-<platform-triple>.<archive-ext>.sha256
package-name-<platform-triple>[.exe]
package-name-<platform-triple>[.exe].sha256
```

## 📋 Platform Triple Naming

We use **Rust-style target triples** for consistency:

| Platform | Architecture | Target Triple |
|----------|--------------|---------------|
| Linux | x86_64 | `x86_64-unknown-linux-gnu` |
| Linux | aarch64 (ARM64) | `aarch64-unknown-linux-gnu` |
| macOS | x86_64 (Intel) | `x86_64-apple-darwin` |
| macOS | aarch64 (Apple Silicon) | `aarch64-apple-darwin` |
| Windows | x86_64 | `x86_64-pc-windows-msvc` |
| Windows | aarch64 (ARM64) | `aarch64-pc-windows-msvc` |
| Java | Universal | `universal` (platform-independent) |

## 📦 Artifact Types

### For each platform, we generate:

1. **Binary Executable**
   - Name: `package-name-<platform-triple>[.exe]`
   - Example: `package-g-x86_64-apple-darwin`
   - Windows: `package-g-x86_64-pc-windows-msvc.exe`

2. **Compressed Archive**
   - Unix/Linux/macOS: `package-name-<platform-triple>.tar.gz`
   - Windows: `package-name-<platform-triple>.zip`
   - Example: `package-g-x86_64-apple-darwin.tar.gz`

3. **SHA256 Checksums**
   - Binary: `package-name-<platform-triple>[.exe].sha256`
   - Archive: `package-name-<platform-triple>.<archive-ext>.sha256`

## 🗂️ Example Release Structure

```
package-g@v1.0.0/
├── package-g-x86_64-unknown-linux-gnu
├── package-g-x86_64-unknown-linux-gnu.sha256
├── package-g-x86_64-unknown-linux-gnu.tar.gz
├── package-g-x86_64-unknown-linux-gnu.tar.gz.sha256
├── package-g-aarch64-unknown-linux-gnu
├── package-g-aarch64-unknown-linux-gnu.sha256
├── package-g-aarch64-unknown-linux-gnu.tar.gz
├── package-g-aarch64-unknown-linux-gnu.tar.gz.sha256
├── package-g-x86_64-apple-darwin
├── package-g-x86_64-apple-darwin.sha256
├── package-g-x86_64-apple-darwin.tar.gz
├── package-g-x86_64-apple-darwin.tar.gz.sha256
├── package-g-aarch64-apple-darwin
├── package-g-aarch64-apple-darwin.sha256
├── package-g-aarch64-apple-darwin.tar.gz
├── package-g-aarch64-apple-darwin.tar.gz.sha256
├── package-g-x86_64-pc-windows-msvc.exe
├── package-g-x86_64-pc-windows-msvc.exe.sha256
├── package-g-x86_64-pc-windows-msvc.zip
└── package-g-x86_64-pc-windows-msvc.zip.sha256
```

## 🔧 Build Script Pattern

Each package includes a `build.sh` script that:

1. **Detects platform** - Automatically determines OS and architecture
2. **Sets target triple** - Uses consistent Rust-style naming
3. **Builds binary** - Compiles for the current platform
4. **Creates archives** - tar.gz for Unix, zip for Windows
5. **Generates checksums** - SHA256 for all artifacts
6. **Organizes output** - Places everything in `release/` directory

### Example Usage

```bash
cd packages/package-g
./build.sh
```

Output:
```
Release artifacts in: release/
package-g-x86_64-apple-darwin
package-g-x86_64-apple-darwin.sha256
package-g-x86_64-apple-darwin.tar.gz
package-g-x86_64-apple-darwin.tar.gz.sha256
```

## 🤖 GitHub Actions Integration

Our workflows automatically:

1. Build for multiple platforms in parallel (matrix strategy)
2. Test binaries on each platform
3. Collect all artifacts from matrix jobs
4. Create comprehensive GitHub release with:
   - Platform download table
   - Verification instructions
   - Usage examples
   - All binaries, archives, and checksums

### Workflow Structure

```yaml
jobs:
  build-and-test:
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            target: x86_64-unknown-linux-gnu
          - os: macos-13
            target: x86_64-apple-darwin
          - os: macos-latest
            target: aarch64-apple-darwin
          - os: windows-latest
            target: x86_64-pc-windows-msvc
    steps:
      - name: Build with script
        run: ./build.sh
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: package-name-${{ matrix.target }}
          path: release/*
```

## ✅ Verification

Users can verify downloads using SHA256 checksums:

### Linux/macOS
```bash
sha256sum -c package-name-<platform>.tar.gz.sha256
```

### Windows (PowerShell)
```powershell
CertUtil -hashfile package-name-<platform>.zip SHA256
```

Or compare with `.sha256` file contents manually.

## 📊 Per-Package Support

| Package | Python | C++ | Rust | Swift | Go | Java |
|---------|--------|-----|------|-------|----|----|
| **package-a** | ✅ | - | - | - | - | - |
| **package-b** | ✅ | - | - | - | - | - |
| **package-c** | ✅ | - | - | - | - | - |
| **package-d** | - | ✅ | - | - | - | - |
| **package-e** | - | - | ✅ | - | - | - |
| **package-f** | - | - | - | ✅ | - | - |
| **package-g** | - | - | - | - | ✅ | - |
| **package-h** | - | - | - | - | - | ✅ |

### Platform Coverage

- **Python (packages a, b, c)**: PyInstaller generates platform-specific binaries
- **C++ (package-d)**: CMake builds for Linux, macOS (Intel & ARM)
- **Rust (package-e)**: Cargo cross-compilation for Linux, macOS, Windows
- **Swift (package-f)**: SPM builds for macOS only (Intel & ARM)
- **Go (package-g)**: Native cross-compilation for 5 platform/arch combinations
- **Java (package-h)**: Universal JAR (platform-independent, requires JVM)

## 🎨 Benefits

1. **Consistency** - Same pattern across all languages
2. **Professional** - Follows industry standards (Rust/Starship model)
3. **Verifiable** - SHA256 checksums for security
4. **User-friendly** - Clear platform identification
5. **Automated** - GitHub Actions handle everything
6. **Complete** - Multiple formats (binary, archive, checksums)

## 📝 Release Notes Example

Each GitHub release includes a detailed table:

| Platform | Architecture | Archive |
|----------|--------------|---------|
| Linux | x86_64 | `package-g-x86_64-unknown-linux-gnu.tar.gz` |
| Linux | aarch64 | `package-g-aarch64-unknown-linux-gnu.tar.gz` |
| macOS | x86_64 (Intel) | `package-g-x86_64-apple-darwin.tar.gz` |
| macOS | aarch64 (Apple Silicon) | `package-g-aarch64-apple-darwin.tar.gz` |
| Windows | x86_64 | `package-g-x86_64-pc-windows-msvc.zip` |

## 🚀 Quick Start for Users

1. **Download** the appropriate archive for your platform
2. **Verify** using the SHA256 checksum
3. **Extract** the archive
4. **Run** the binary

```bash
# Example for macOS ARM
wget https://github.com/.../package-g-aarch64-apple-darwin.tar.gz
sha256sum -c package-g-aarch64-apple-darwin.tar.gz.sha256
tar -xzf package-g-aarch64-apple-darwin.tar.gz
./package-g-aarch64-apple-darwin
```

---

**Reference**: Inspired by [Starship](https://github.com/starship/starship) release patterns
