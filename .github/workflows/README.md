# GitHub Actions Workflows

This directory contains both reusable workflow templates and package-specific workflows for automated releases.

## 📁 Structure

### Reusable Workflows (Templates)

These are shared workflow templates that can be called by multiple packages:

- **`rust-package-release.yml`** - Reusable workflow for Rust packages
- **`go-package-release.yml`** - Reusable workflow for Go packages
- **`cpp-package-release.yml`** - Reusable workflow for C++ packages
- **`python-package-release.yml`** - Reusable workflow for Python packages ✨ NEW
- **`swift-binaries.yml`** - Workflow for Swift package binaries (to be refactored)
- **`java-binaries.yml`** - Workflow for Java package binaries (to be refactored)

### Package-Specific Workflows

These workflows call the reusable templates with package-specific configuration:

**Rust Packages:**
- **`package-e-release.yml`** - Rust package (uses `rust-package-release.yml`)
- **`package-i-release.yml`** - Rust package (uses `rust-package-release.yml`)

**Go Packages:**
- **`package-g-release.yml`** - Go package (uses `go-package-release.yml`)

**C++ Packages:**
- **`package-d-release.yml`** - C++ package (uses `cpp-package-release.yml`)

**Python Packages:** ✨ NEW
- **`package-a-release.yml`** - Python package (uses `python-package-release.yml`)
- **`package-b-release.yml`** - Python package (uses `python-package-release.yml`)
- **`package-c-release.yml`** - Python package (uses `python-package-release.yml`)

### Legacy Workflows (To Be Migrated)

These workflows should be refactored to use the reusable templates:

- `cpp-release.yml` → Replace with `package-d-release.yml`
- `rust-release.yml` → Replace with `package-e-release.yml`
- `go-release.yml` → Replace with `package-g-release.yml`
- `package-i-release.yml` → Replace with `package-i-release-new.yml`

## 🎯 Benefits of Reusable Workflows

### 1. **DRY Principle** (Don't Repeat Yourself)

- Single source of truth for build logic
- Update once, apply everywhere
- Consistent behavior across all packages

### 2. **Maintainability**

- Fix bugs in one place
- Add features to all packages simultaneously
- Easier to review and test changes

### 3. **Consistency**

- Same build steps for all packages
- Uniform release notes format
- Identical artifact naming conventions

### 4. **Reduced Complexity**

- Package workflows are just 20 lines vs 150+ lines
- Focus on package-specific metadata
- Clear separation of concerns

## 📝 Usage

### Adding a New Rust Package

Create a simple workflow file:

````yaml
name: My New Package Release

on:
  push:
    tags:
      - "package-x@v*.*.*"

jobs:
  release:
    uses: ./.github/workflows/rust-package-release.yml
    with:
      package-name: package-x
      package-description: Short description here
      package-features: |
        - Feature 1
        - Feature 2
        - Feature 3
      usage-examples: |
        ```bash
        ./package-x-<platform>
        ```
````

### Adding a New Go Package

````yaml
name: My Go Package Release

on:
  push:
    tags:
      - "my-go-package@v*.*.*"

jobs:
  release:
    uses: ./.github/workflows/go-package-release.yml
    with:
      package-name: my-go-package
      package-description: Go utilities for...
      package-features: |
        - Feature 1
        - Feature 2
      usage-examples: |
        ```bash
        my-go-package-<platform>
        ```
````

### Adding a New C++ Package

````yaml
name: My C++ Package Release

on:
  push:
    tags:
      - "my-cpp-package@v*.*.*"

jobs:
  release:
    uses: ./.github/workflows/cpp-package-release.yml
    with:
      package-name: my-cpp-package
      package-description: C++ library for...
      package-features: |
        - Feature 1
        - Feature 2
      usage-examples: |
        ```bash
        ./my-cpp-package-<platform>
        ```
````

### Adding a New Python Package

````yaml
name: My Python Package Release

on:
  push:
    tags:
      - "my-python-package@v*.*.*"

jobs:
  release:
    uses: ./.github/workflows/python-package-release.yml
    with:
      package-name: my-python-package
      package-description: Python utilities for...
      package-features: |
        - Feature 1
        - Feature 2
      usage-examples: |
        ```bash
        ./my-python-package-<platform>
        ```
````

## 🔧 Reusable Workflow Inputs

### Common Inputs (All Languages)

| Input                 | Required | Description                         | Example              |
| --------------------- | -------- | ----------------------------------- | -------------------- |
| `package-name`        | ✅ Yes   | Package name (must match directory) | `package-i`          |
| `package-description` | ✅ Yes   | Short description                   | `Rust CLI utilities` |
| `package-features`    | ✅ Yes   | Markdown list of features           | See examples above   |
| `usage-examples`      | ⬜ No    | Markdown usage examples             | See examples above   |

### Platform Matrix

All reusable workflows build for:

- **Linux**: x86_64, aarch64 (ARM64)
- **macOS**: x86_64 (Intel), aarch64 (Apple Silicon)
- **Windows**: x86_64, aarch64 (ARM64)

## 🚀 Workflow Steps

### Rust Package Workflow

1. **Build & Test Job** (6 platforms in parallel)

   - Checkout code
   - Setup Rust toolchain with target
   - Extract version from tag
   - Build with `build.sh` script
   - Test binary execution
   - Upload artifacts

2. **Publish Job**
   - Download all artifacts
   - Organize release files
   - Create GitHub release with:
     - Version info
     - Feature list
     - Platform download table
     - SHA256 checksums
     - Usage examples

### Go Package Workflow

Similar to Rust, but with:

- Go setup instead of Rust
- `go test` before build
- Go-specific build process

### C++ Package Workflow

Similar structure with:

- CMake installation
- C++ compilation
- Platform-specific executables

## 🔒 Security & Best Practices

### Permissions

All workflows use minimal permissions:

```yaml
permissions:
  contents: write # Only for creating releases
```

### Artifact Verification

- SHA256 checksums generated for all artifacts
- Binaries and archives both checksummed
- Verification instructions in release notes

### Platform-Native Builds

- No cross-compilation (except where natively supported)
- Native builds on each platform's runner
- Maximum performance and compatibility

## 📊 Metrics

### Lines of Code Saved

| Package   | Old Workflow | New Workflow | Savings         |
| --------- | ------------ | ------------ | --------------- |
| package-d | 147 lines    | 20 lines     | 127 lines (86%) |
| package-e | 147 lines    | 25 lines     | 122 lines (83%) |
| package-g | 165 lines    | 18 lines     | 147 lines (89%) |
| package-i | 170 lines    | 40 lines     | 130 lines (76%) |

**Total Savings**: ~526 lines of YAML across 4 packages!

## 🔄 Migration Plan

### Phase 1: Create Reusable Workflows ✅

- [x] Create `rust-package-release.yml`
- [x] Create `go-package-release.yml`
- [x] Create `cpp-package-release.yml`

### Phase 2: Create New Package Workflows ✅

- [x] Create `package-d-release.yml`
- [x] Create `package-e-release.yml`
- [x] Create `package-g-release.yml`
- [x] Create `package-i-release-new.yml`

### Phase 3: Test & Validate

- [ ] Test package-d release
- [ ] Test package-e release
- [ ] Test package-g release
- [ ] Test package-i release

### Phase 4: Remove Legacy Workflows

- [ ] Delete `cpp-release.yml`
- [ ] Delete `rust-release.yml`
- [ ] Delete `go-release.yml`
- [ ] Rename `package-i-release-new.yml` → `package-i-release.yml`

### Phase 5: Migrate Remaining Packages

- [ ] Migrate Python workflows
- [ ] Migrate Swift workflows
- [ ] Migrate Java workflows

## 🎓 Learning Resources

- [Reusing Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions Best Practices](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)

## 📞 Support

For questions or issues with workflows:

1. Check the reusable workflow documentation above
2. Review existing package workflows for examples
3. Test locally with `act` before pushing
4. Check GitHub Actions logs for debugging

---

**Last Updated**: October 18, 2025
**Maintained by**: @codefuturist
