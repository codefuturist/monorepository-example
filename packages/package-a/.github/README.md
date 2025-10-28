# Package A GitHub Workflows

This directory contains GitHub Actions workflows specific to `package-a`.

## Workflows

### `release.yml` - Package A Release Workflow

Triggered when tags matching `package-a@v*.*.*` are pushed.

**Features:**
- Builds Python binaries for multiple platforms
- Creates GitHub releases with binaries and checksums
- Generates release notes from changelog
- Supports cross-platform compilation (Linux, macOS, Windows)

**Usage:**
```bash
# Tag a new release
git tag package-a@v1.0.0
git push origin package-a@v1.0.0
```

**Configuration:**
- Uses the shared Python package release workflow from root `.github/workflows/python-package-release.yml`
- Package-specific metadata and descriptions are defined in this workflow
- Build configuration is handled by `packages/package-a/build.sh`

## Structure Benefits

Moving workflows to the package directory provides:

1. **Better Organization**: Each package manages its own CI/CD
2. **Independent Versioning**: Workflows version with the package
3. **Easier Maintenance**: Changes to package workflows don't affect others
4. **Clearer Ownership**: Package maintainers control their own workflows
5. **Modular Design**: Packages can be extracted to separate repos easily

## Related Files

- **Build Script**: `packages/package-a/build.sh`
- **Changelog**: `packages/package-a/CHANGELOG.md`
- **Package Config**: `packages/package-a/pyproject.toml`
- **Shared Workflow**: `.github/workflows/python-package-release.yml` (root)
