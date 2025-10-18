./verify-all-builds.sh# Quick Reference: Platform & Architecture Support

## Build Matrix (64-bit only)

| Language                                     | Linux x64                                             | Linux ARM64       | macOS x64 | macOS ARM64 | Windows x64 | Windows ARM64 | Cross-Compile                |
| -------------------------------------------- | ----------------------------------------------------- | ----------------- | --------- | ----------- | ----------- | ------------- | ---------------------------- |
| **Go** (package-g)                           | ✅                                                    | ✅                | ✅        | ✅          | ✅          | ✅            | ✅ Yes (native)              |
| **Rust** (package-e, package-i)              | ✅                                                    | ✅                | ✅        | ✅          | ✅          | ✅            | ✅ Yes (with targets)        |
| **Java** (package-h)                         | ✅ Universal JAR works on all platforms/architectures | ✅ Yes (bytecode) |
| **Swift** (package-f)                        | ❌                                                    | ❌                | ✅        | ✅          | ❌          | ❌            | ⚠️ Universal (macOS only)    |
| **Python** (package-a, package-b, package-c) | ✅                                                    | ✅                | ✅        | ✅          | ✅          | ✅            | ❌ No (must build on target) |
| **C++** (package-d)                          | ✅                                                    | ✅                | ✅        | ✅          | ✅          | ✅            | ❌ No (must build on target) |

## End User Requirements

| Language                 | Python Required?     | Java Required?   | System Libraries?     | Standalone Binary? |
| ------------------------ | -------------------- | ---------------- | --------------------- | ------------------ |
| Go                       | ❌ No                | ❌ No            | ❌ No                 | ✅ Yes             |
| Rust                     | ❌ No                | ❌ No            | ❌ No                 | ✅ Yes             |
| Java                     | ❌ No                | ✅ Yes (JRE/JDK) | ❌ No                 | ⚠️ Requires JVM    |
| Swift                    | ❌ No                | ❌ No            | ⚠️ Maybe              | ✅ Yes             |
| **Python (PyInstaller)** | ❌ **No (bundled!)** | ❌ No            | ❌ No                 | ✅ **Yes**         |
| C++                      | ❌ No                | ❌ No            | ⚠️ Maybe (if dynamic) | ✅ Yes (if static) |

### Key Points:

- **Python with PyInstaller**: Creates truly standalone executables - **Python interpreter is BUNDLED** inside!
- **Java**: Requires JVM but JAR works on all platforms
- **All others**: No runtime dependencies (if statically linked)

## Total Binaries per Package (Full Build)

| Package Type                | Binaries Generated | Notes                                       |
| --------------------------- | ------------------ | ------------------------------------------- |
| Go (package-g)              | 6                  | 2 architectures × 3 platforms               |
| Rust (package-e, package-i) | 6                  | 2 architectures × 3 platforms               |
| Java (package-h)            | 1                  | Universal JAR (platform-independent)        |
| Swift (package-f)           | 1                  | Universal binary (both macOS architectures) |
| Python (package-a/b/c)      | 6\*                | Must build on each platform/architecture    |
| C++ (package-d)             | 6\*                | Must build on each platform/architecture    |

\* Requires building on each target platform/architecture combination

## Build Strategy

### Single Build → Multiple Binaries (Cross-Compilation)

```bash
# Go - Build once, get 6 binaries
cd packages/package-g && ./build.sh
# Output: 6 binaries (all platforms/architectures)

# Rust - Build once, get 6 binaries
cd packages/package-e && ./build.sh
# Output: 6 binaries (all platforms/architectures)

# Java - Build once, get 1 universal JAR
cd packages/package-h && ./build.sh
# Output: 1 JAR (works everywhere)
```

### Multiple Builds → Multiple Binaries (Platform-Specific)

```bash
# Python - Must build on each target
# On Linux x64 machine:
cd packages/package-a && ./build.sh
# Output: 1 standalone binary (Linux x64 only)

# On macOS ARM64 machine:
cd packages/package-a && ./build.sh
# Output: 1 standalone binary (macOS ARM64 only)

# ... repeat for all 6 platform/architecture combinations
```

## CI/CD Quick Setup

### Option 1: Use Cross-Compilation (Recommended for Go/Rust/Java)

```yaml
- name: Build (creates all platform binaries automatically)
  run: cd packages/package-e && ./build.sh
```

### Option 2: Matrix Build (Required for Python/C++, Optional for Swift)

```yaml
strategy:
  matrix:
    os:
      [
        ubuntu-latest,
        ubuntu-arm,
        macos-13,
        macos-14,
        windows-latest,
        windows-arm,
      ]
steps:
  - name: Build for this platform
    run: cd packages/package-a && ./build.sh
```

## Verification

```bash
# Check what architectures are in your binaries
file release/*

# macOS: Check if truly universal
lipo -info release/*-universal-apple-darwin

# Check binary is standalone (no dynamic dependencies)
ldd release/*-linux    # Linux
otool -L release/*-darwin    # macOS
```

## Summary

✅ **Always 64-bit** - No 32-bit support  
✅ **Both architectures** - x86_64 and ARM64 for each platform  
✅ **Standalone executables** - No interpreter/runtime needed (except Java)  
✅ **Python is standalone too!** - PyInstaller bundles everything

This ensures end users can simply download and run binaries without installing dependencies!
