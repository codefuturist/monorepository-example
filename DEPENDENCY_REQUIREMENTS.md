# Dependency Installation Requirements Analysis

This document provides a comprehensive analysis of dependency management requirements for each language/package in this monorepository.

## Executive Summary

**Languages Requiring Manual Dependency Installation:**

- **Node.js/JavaScript** ✓ Requires `npm install`
- **Python** ✓ Requires virtual environment setup and `pip install`

**Languages with Automatic Dependency Management:**

- **C++/CMake** ✗ Dependencies fetched automatically via FetchContent
- **Rust/Cargo** ✗ Dependencies downloaded automatically during build
- **Swift/SPM** ✗ Dependencies resolved automatically during build
- **Go/Modules** ✗ Dependencies fetched automatically during build
- **Java/Maven** ✗ Dependencies downloaded automatically from Maven Central

---

## Detailed Analysis by Language

### 1. Node.js/JavaScript (Packages A, B, C)

**Status:** ✓ **REQUIRES MANUAL DEPENDENCY INSTALLATION**

**Why:**

- npm packages require `node_modules/` to be populated before build
- Even with placeholder build scripts, dependencies declared in `package.json` may be imported
- Workspace dependencies (like `commitizen`) must be installed at root level

**How to Install:**

```bash
# At repository root
npm install

# Or for a specific package
cd packages/package-a
npm install
```

**Build Command:**

```bash
npm run build
```

**Verified Dependencies:**

- `release-it` - Release automation tool
- `@release-it/conventional-changelog` - Changelog generation

---

### 2. Python (Packages A, B, C)

**Status:** ✓ **REQUIRES MANUAL DEPENDENCY INSTALLATION**

**Why:**

- `setuptools` needs dependencies available during package build process
- Runtime dependencies (colorama, rich, tabulate) must be installed before building
- Build tools and linting tools need to be available in the environment

**Package Dependencies:**

- **package-a:** `colorama>=0.4.6`
- **package-b:** `rich>=13.0.0`
- **package-c:** `tabulate>=0.9.0`

**How to Install:**

```bash
# For each package
cd packages/package-a
python3 -m venv venv
source venv/bin/activate
pip install -e .
# or
pip install -e ".[dev]"  # for development dependencies
```

**Build Command:**

```bash
python -m build
# or
pip install -e .
```

**Development Dependencies (Optional):**

- `pytest>=7.0`
- `pytest-cov>=4.0`
- `black>=23.0`
- `ruff>=0.1.0`
- `mypy>=1.0`

---

### 3. C++/CMake (Package D)

**Status:** ✗ **NO MANUAL DEPENDENCY INSTALLATION REQUIRED**

**Why:**

- CMake's `FetchContent` module automatically downloads external dependencies
- Dependencies are fetched during the CMake configure step
- Build system manages all external libraries

**External Dependencies:**

- `nlohmann/json` v3.11.3 - JSON library (fetched via FetchContent from GitHub)

**How Dependencies Are Managed:**

```cmake
include(FetchContent)
FetchContent_Declare(
    json
    GIT_REPOSITORY https://github.com/nlohmann/json.git
    GIT_TAG v3.11.3
)
FetchContent_MakeAvailable(json)
```

**Build Commands:**

```bash
cd packages/package-d
mkdir -p build-release && cd build-release
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build .
```

**Verification:**
Dependencies are automatically downloaded to `build-release/_deps/json-src/`

---

### 4. Rust (Packages E and I)

**Status:** ✗ **NO MANUAL DEPENDENCY INSTALLATION REQUIRED**

**Why:**

- Cargo automatically downloads and compiles dependencies during build
- Dependencies from `Cargo.toml` are fetched on-demand from crates.io
- Cargo manages the entire dependency tree automatically

**Package E Dependencies:**

- `colored = "2.1"` - Terminal colors
- `serde_json = "1.0"` - JSON serialization

**Package I Dependencies:**

- `serde = { version = "1.0", features = ["derive"] }`
- `serde_json = "1.0"`
- `colored = "2.1"`
- `clap = { version = "4.5", features = ["derive"] }` - CLI argument parsing
- `anyhow = "1.0"` - Error handling

**Build Commands:**

```bash
cd packages/package-e
cargo build --release

cd packages/package-i
cargo build --release
```

**Verification:**
During build, Cargo automatically:

1. Downloads dependencies from crates.io
2. Compiles all dependencies
3. Links them with your project

Example output: `Updating crates.io index`, `Locking 98 packages to latest compatible versions`

---

### 5. Swift Package Manager (Package F)

**Status:** ✗ **NO MANUAL DEPENDENCY INSTALLATION REQUIRED**

**Why:**

- Swift Package Manager (SPM) automatically resolves and fetches dependencies
- Dependencies are downloaded from their Git repositories during build
- Package resolution happens before compilation

**Dependencies:**

- `Rainbow` 4.0.0+ - Terminal colors (fetched from GitHub: `https://github.com/onevcat/Rainbow.git`)

**Build Commands:**

```bash
cd packages/package-f
swift build -c release
```

**Verification:**
Dependencies are automatically downloaded to `.build/checkouts/Rainbow/`

**Requirements:**

- macOS 13+
- Swift 5.9+

---

### 6. Go Modules (Package G)

**Status:** ✗ **NO MANUAL DEPENDENCY INSTALLATION REQUIRED**

**Why:**

- Go modules automatically download dependencies during build
- `go build` fetches missing dependencies from their repositories
- Dependencies are cached in `$GOPATH/pkg/mod/`

**Dependencies (from go.mod):**

```go
require (
    github.com/fatih/color v1.16.0
    github.com/jedib0t/go-pretty/v6 v6.5.3
)
```

**Indirect Dependencies:**

- `github.com/mattn/go-colorable v0.1.13`
- `github.com/mattn/go-isatty v0.0.20`
- `github.com/mattn/go-runewidth v0.0.15`
- `github.com/rivo/uniseg v0.4.4`
- `golang.org/x/sys v0.16.0`

**Build Commands:**

```bash
cd packages/package-g
go mod tidy  # Optional: updates go.sum
go build     # Automatically fetches dependencies
```

**Requirements:**

- Go 1.21+

---

### 7. Java/Maven (Package H)

**Status:** ✗ **NO MANUAL DEPENDENCY INSTALLATION REQUIRED**

**Why:**

- Maven automatically downloads dependencies from Maven Central
- Dependencies declared in `pom.xml` are resolved during build
- Maven manages the entire dependency tree and transitive dependencies

**Dependencies (from pom.xml):**

```xml
<dependencies>
    <!-- JSON Processing -->
    <dependency>
        <groupId>com.google.code.gson</groupId>
        <artifactId>gson</artifactId>
        <version>2.10.1</version>
    </dependency>

    <!-- ANSI Colors -->
    <dependency>
        <groupId>com.diogonunes</groupId>
        <artifactId>JColor</artifactId>
        <version>5.5.1</version>
    </dependency>

    <!-- JUnit 5 (test scope) -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter-api</artifactId>
        <version>5.10.0</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

**Build Commands:**

```bash
cd packages/package-h
mvn clean package
# or quiet mode
mvn clean package -q
```

**Output:**

- `target/package-h-1.0.0.jar` - Regular JAR
- `target/package-h.jar` - Shaded JAR with dependencies

**Requirements:**

- Java 17+
- Maven 3.6+

---

## Build Order Recommendations

### For Local Development

1. **Install Node.js dependencies first** (required):

   ```bash
   npm install
   ```

2. **Set up Python virtual environments** (required for Python packages):

   ```bash
   cd packages/package-a
   python3 -m venv venv
   source venv/bin/activate
   pip install -e ".[dev]"
   deactivate
   ```

3. **Build other languages** (dependencies auto-managed):

   ```bash
   # C++
   cd packages/package-d
   ./build.sh

   # Rust
   cd packages/package-e && cargo build --release
   cd packages/package-i && cargo build --release

   # Swift
   cd packages/package-f && swift build -c release

   # Go
   cd packages/package-g && go build

   # Java
   cd packages/package-h && mvn clean package
   ```

### For CI/CD Pipelines

**Step 1: Install Required Dependencies**

```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: "20"
    cache: "npm"

- name: Install Node.js dependencies
  run: npm ci

- name: Setup Python
  uses: actions/setup-python@v4
  with:
    python-version: "3.9"

- name: Install Python dependencies
  run: |
    cd packages/package-a && pip install -e .
    cd ../package-b && pip install -e .
    cd ../package-c && pip install -e .
```

**Step 2: Build All Packages**

```yaml
- name: Build all packages
  run: |
    # Node.js packages
    npm run build

    # Languages with auto-managed dependencies
    cd packages/package-d && ./build.sh
    cd packages/package-e && cargo build --release
    cd packages/package-f && swift build -c release
    cd packages/package-g && go build
    cd packages/package-h && mvn clean package
    cd packages/package-i && cargo build --release
```

---

## Testing Dependency Management

### Verify Node.js Dependencies

```bash
npm install
npm run build
# Should succeed without errors
```

### Verify Python Dependencies

```bash
cd packages/package-a
python3 -m venv test_venv
source test_venv/bin/activate
pip install -e .
python -c "import package_a; print('Success!')"
deactivate
rm -rf test_venv
```

### Verify Automatic Dependency Management

**C++ (CMake):**

```bash
cd packages/package-d
rm -rf build-release
mkdir -p build-release && cd build-release
cmake -DCMAKE_BUILD_TYPE=Release ..
# Check for: "-- Using the multi-header code from .../json-src/include/"
ls -la _deps/json-src/  # Should exist
```

**Rust (Cargo):**

```bash
cd packages/package-e
cargo clean
cargo build --release
# Check for: "Updating crates.io index"
# Check for: "Compiling colored v2.2.0"
```

**Swift (SPM):**

```bash
cd packages/package-f
rm -rf .build
swift build -c release
# Check for dependency resolution messages
ls -la .build/checkouts/Rainbow/  # Should exist
```

**Go (Modules):**

```bash
cd packages/package-g
go clean -modcache
go mod tidy
go build
# Check for: "go: downloading github.com/fatih/color"
```

**Java (Maven):**

```bash
cd packages/package-h
rm -rf target ~/.m2/repository/com/google/code/gson
mvn clean package
# Maven will download gson from Maven Central
ls -la target/*.jar  # Should show JAR files
```

---

## Summary Table

| Package   | Language         | Manual Install | Auto-Managed   | Build Command                        |
| --------- | ---------------- | -------------- | -------------- | ------------------------------------ |
| package-a | Node.js + Python | ✓              | -              | `npm run build` + `pip install -e .` |
| package-b | Node.js + Python | ✓              | -              | `npm run build` + `pip install -e .` |
| package-c | Node.js + Python | ✓              | -              | `npm run build` + `pip install -e .` |
| package-d | C++/CMake        | -              | ✓ FetchContent | `cmake --build .`                    |
| package-e | Rust             | -              | ✓ Cargo        | `cargo build --release`              |
| package-f | Swift            | -              | ✓ SPM          | `swift build -c release`             |
| package-g | Go               | -              | ✓ Go Modules   | `go build`                           |
| package-h | Java             | -              | ✓ Maven        | `mvn clean package`                  |
| package-i | Rust             | -              | ✓ Cargo        | `cargo build --release`              |

---

## Recommendations for Release Workflows

### Pre-build Step (Required)

```bash
# Install dependencies for languages that require it
npm install  # Node.js packages
cd packages/package-a && pip install -e . && cd ../..
cd packages/package-b && pip install -e . && cd ../..
cd packages/package-c && pip install -e . && cd ../..
```

### Build Step

```bash
# All languages can now build
# Languages with auto-managed dependencies will download during build
npm run build
cd packages/package-d && ./build.sh
cd packages/package-e && ./build.sh
cd packages/package-f && ./build.sh
cd packages/package-g && ./build.sh
cd packages/package-h && mvn clean package
cd packages/package-i && ./build.sh
```

---

## Troubleshooting

### Node.js: "Cannot find module"

**Solution:** Run `npm install` at the root of the repository.

### Python: "ModuleNotFoundError"

**Solution:** Create a virtual environment and install dependencies:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -e .
```

### C++: "Could not find json"

**Solution:** This should not happen with FetchContent. Check CMake configuration and internet connectivity.

### Rust: "could not find `Cargo.toml`"

**Solution:** Ensure you're in the package directory. Cargo automatically handles dependencies.

### Swift: "missing package product"

**Solution:** SPM should resolve this automatically. Try: `swift package resolve`

### Go: "missing go.sum entry"

**Solution:** Run `go mod tidy` to update go.sum.

### Java: "Could not resolve dependencies"

**Solution:** Check Maven configuration and internet connectivity to Maven Central.

---

## Conclusion

**Key Takeaway:** Only Node.js and Python packages require manual dependency installation before building. All other languages (C++, Rust, Swift, Go, Java) have modern build tools that automatically manage dependencies during the build process.

This design pattern ensures:

- ✓ Reproducible builds
- ✓ Minimal manual setup
- ✓ Clear separation between languages that need pre-build setup vs. auto-managed dependencies
- ✓ Easier CI/CD pipeline configuration
