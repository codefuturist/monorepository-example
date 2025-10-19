# Migration from release-it to Commitizen

**Date:** October 19, 2025  
**Status:** ✅ COMPLETE

---

## 📊 Summary

Successfully migrated the monorepo from JavaScript-based `release-it` to Python-based `commitizen` for version management, changelog generation, and release automation.

---

## 🎯 Why Commitizen?

### Advantages Over release-it

1. **Native Python Integration**
   - Direct integration with `pyproject.toml`
   - Updates Python version files automatically
   - No Node.js required for Python packages

2. **Unified Tooling**
   - Single tool for all packages
   - Consistent configuration format
   - Better monorepo support

3. **Enhanced Features**
   - Automatic changelog generation (incremental)
   - Version file synchronization
   - Conventional commit enforcement
   - Custom commit message templates

4. **Better Control**
   - Git operations are transparent
   - Easier to debug
   - More flexible configuration

---

## 🔧 Changes Made

### 1. Package Configuration

#### Added Commitizen Config to `pyproject.toml`

**packages/package-a/pyproject.toml** (and package-b, package-c):

```toml
[tool.commitizen]
name = "cz_conventional_commits"
version = "1.2.8"
tag_format = "package-a@v$version"
version_files = [
    "pyproject.toml:version",
    "src/__version__.py:__version__"
]
update_changelog_on_bump = true
changelog_file = "CHANGELOG.md"
changelog_incremental = true
changelog_start_rev = "package-a@v1.0.0"

[tool.commitizen.change_type_order]
order = ["BREAKING CHANGE", "feat", "fix", "refactor", "perf", "docs", "style", "build", "ci", "test", "chore"]

[dependency-groups]
dev = [
    "commitizen>=4.9.1",
]
```

#### Removed Files
- ❌ `packages/*/. release-it.json` (deleted)

---

### 2. NPM Configuration

#### Root `package.json`

**Before:**
```json
{
  "scripts": {
    "release": "release-it",
    "release:dry": "release-it --dry-run",
    "release:package-a": "npm run release --workspace=packages/package-a"
  },
  "devDependencies": {
    "@release-it/conventional-changelog": "^8.0.0",
    "release-it": "^17.0.0"
  }
}
```

**After:**
```json
{
  "scripts": {
    "cz": "cz",
    "release:package-a": "cd packages/package-a && cz bump --yes"
  },
  "devDependencies": {
    "commitizen": "^4.3.0"
  }
}
```

#### Package `package.json`

**Before:**
```json
{
  "scripts": {
    "release": "release-it"
  }
}
```

**After:**
```json
{
  "scripts": {
    "release": "cz bump --yes",
    "changelog": "cz changelog"
  }
}
```

---

### 3. Release Scripts

#### `scripts/release-package.sh`

**Changed:**
- Step 2: `release-it` → `cz bump`
- Removed `npx release-it` command
- Added commitizen increment logic

**Before:**
```bash
npx release-it "$VERSION_BUMP" \
    --ci \
    --no-git.requireUpstream \
    --no-git.push \
    --no-github.release
```

**After:**
```bash
case "$VERSION_BUMP" in
    patch|minor|major)
        INCREMENT="--increment $VERSION_BUMP"
        ;;
    *)
        INCREMENT="$NEW_VERSION"
        ;;
esac

cz bump --yes \
    --changelog \
    --git-output-to-stderr \
    $INCREMENT
```

#### `scripts/quick-release.sh`

Similar changes applied to the quick release script.

---

## 📚 Usage Guide

### Installation

#### System-wide (for development)
```bash
# Install via pip (in a virtual environment)
pip install commitizen

# Or via pipx (recommended for global installation)
pipx install commitizen

# Or via uv (fast!)
uv tool install commitizen
```

#### Project-level
```bash
# Node.js (for npm scripts)
npm install

# Python packages (per package)
cd packages/package-a
uv pip install commitizen  # or pip install commitizen
```

---

### Basic Commands

#### 1. Check Current Version
```bash
cd packages/package-a
cz version
```

#### 2. Bump Version (Automatic)
```bash
# Auto-detect version bump based on commits
cz bump --yes

# Specify increment type
cz bump --increment PATCH --yes
cz bump --increment MINOR --yes
cz bump --increment MAJOR --yes
```

#### 3. Generate Changelog
```bash
# Update changelog only (no version bump)
cz changelog

# Generate changelog during bump
cz bump --yes --changelog
```

#### 4. Dry Run
```bash
# See what would change without making changes
cz bump --dry-run
```

#### 5. Create Conventional Commit
```bash
# Interactive commit prompt
cz commit

# Or use the alias
cz c
```

---

### Release Workflow

#### Full Release Process

```bash
# 1. Ensure you're on the correct branch
git checkout develop
git pull origin develop

# 2. Navigate to package
cd packages/package-a

# 3. Run commitizen bump (dry run first)
cz bump --dry-run

# 4. If everything looks good, run actual bump
cz bump --yes --changelog

# 5. This will:
#    - Calculate version based on commits
#    - Update version in pyproject.toml
#    - Update version in src/__version__.py
#    - Generate/update CHANGELOG.md
#    - Create a git commit
#    - Create a git tag (package-a@v1.2.9)

# 6. Push changes
git push origin develop
git push origin package-a@v1.2.9
```

#### Using the Scripts

```bash
# Use the automated release script
./scripts/release-package.sh package-a patch

# Or the quick release script
./scripts/quick-release.sh package-a
```

---

## 🔍 Version Detection

Commitizen automatically determines the version bump based on conventional commits:

| Commit Type | Version Bump | Example |
|-------------|--------------|---------|
| `fix:` | PATCH (0.0.1) | `fix: resolve memory leak` |
| `feat:` | MINOR (0.1.0) | `feat: add new API endpoint` |
| `BREAKING CHANGE:` or `feat!:` | MAJOR (1.0.0) | `feat!: redesign API` |
| `chore:`, `docs:`, etc. | None | `chore: update dependencies` |

### Manual Override

```bash
# Force a specific increment
cz bump --increment MAJOR --yes
cz bump --increment MINOR --yes
cz bump --increment PATCH --yes
```

---

## 📋 Configuration Reference

### Essential Settings

```toml
[tool.commitizen]
# Commit style (conventional commits)
name = "cz_conventional_commits"

# Current version (auto-updated by commitizen)
version = "1.2.8"

# Tag format (for git tags)
tag_format = "package-a@v$version"

# Files to update with new version
version_files = [
    "pyproject.toml:version",
    "src/__version__.py:__version__"
]

# Changelog settings
update_changelog_on_bump = true
changelog_file = "CHANGELOG.md"
changelog_incremental = true
changelog_start_rev = "package-a@v1.0.0"
```

### Changelog Customization

```toml
[tool.commitizen.change_type_order]
# Order of sections in changelog
order = [
    "BREAKING CHANGE",
    "feat",
    "fix",
    "refactor",
    "perf",
    "docs",
    "style",
    "build",
    "ci",
    "test",
    "chore"
]
```

---

## 🧪 Testing

### Test the Migration

```bash
# 1. Check version detection
cd packages/package-a
cz bump --dry-run

# 2. Verify configuration
cz version
cz --version  # commitizen version

# 3. Test changelog generation
cz changelog --dry-run

# 4. Check version files
grep version pyproject.toml
grep __version__ src/__version__.py
```

---

## 🔄 Comparison: release-it vs Commitizen

| Feature | release-it | commitizen | Winner |
|---------|-----------|------------|--------|
| **Language** | JavaScript/Node.js | Python | Python (for Python projects) |
| **Config File** | `.release-it.json` | `pyproject.toml` | Commitizen |
| **Version Files** | Manual scripts | Auto-sync | Commitizen |
| **Changelog** | Plugin required | Built-in | Commitizen |
| **Git Operations** | Automated (opaque) | Transparent | Commitizen |
| **Learning Curve** | Medium | Low | Commitizen |
| **Monorepo Support** | Good | Excellent | Commitizen |
| **Python Integration** | None | Native | Commitizen |
| **Speed** | Fast | Very Fast | Commitizen |

---

## 🐛 Troubleshooting

### Issue: "command not found: cz"

**Solution:**
```bash
# Install commitizen
pip install commitizen

# Or use pipx
pipx install commitizen

# Or use uv
uv tool install commitizen

# Verify installation
which cz
cz --version
```

### Issue: "No pattern found for version"

**Solution:** Ensure `version_files` in `pyproject.toml` matches your file structure:
```toml
version_files = [
    "pyproject.toml:version",          # Matches: version = "1.2.3"
    "src/__version__.py:__version__"   # Matches: __version__ = "1.2.3"
]
```

### Issue: "No commits found to bump version"

**Solution:** Ensure commits follow conventional format:
```bash
# Good commits
git commit -m "feat: add new feature"
git commit -m "fix: resolve bug"

# Bad commits (won't trigger bump)
git commit -m "update stuff"
git commit -m "WIP"
```

### Issue: Git tag already exists

**Solution:**
```bash
# Delete the tag locally
git tag -d package-a@v1.2.8

# Delete the tag remotely
git push origin :refs/tags/package-a@v1.2.8

# Then retry bump
cz bump --yes
```

---

## 📈 Migration Checklist

### Completed ✅

- [x] ✅ Created `.cz.toml` files for all packages
- [x] ✅ Added `[tool.commitizen]` to all `pyproject.toml` files
- [x] ✅ Updated root `package.json` (removed release-it, added commitizen)
- [x] ✅ Updated package `package.json` files (changed scripts)
- [x] ✅ Updated `scripts/release-package.sh`
- [x] ✅ Updated `scripts/quick-release.sh`
- [x] ✅ Updated `README.md` documentation
- [x] ✅ Removed `.release-it.json` files
- [x] ✅ Uninstalled `release-it` and `@release-it/conventional-changelog`
- [x] ✅ Installed `commitizen` (npm)
- [x] ✅ Created migration documentation

### Testing Required

- [ ] ⏳ Test version bump on package-a
- [ ] ⏳ Test changelog generation
- [ ] ⏳ Test full release workflow
- [ ] ⏳ Verify GitHub Actions compatibility
- [ ] ⏳ Test tag creation and pushing

---

## 🚀 Next Steps

### Immediate
1. ⏳ Install commitizen in Python virtual environments
2. ⏳ Test release process with package-a
3. ⏳ Verify changelog generation
4. ⏳ Update GitHub Actions workflows if needed

### Future Enhancements
1. Add pre-commit hooks for conventional commits
2. Create custom commitizen template
3. Add version bump automation via GitHub Actions
4. Integrate with semantic-release workflow

---

## 📚 Resources

### Official Documentation
- **Commitizen:** https://commitizen-tools.github.io/commitizen/
- **Conventional Commits:** https://www.conventionalcommits.org/
- **Semantic Versioning:** https://semver.org/

### Related Tools
- **pre-commit:** https://pre-commit.com/ (commit hooks)
- **semantic-release:** https://semantic-release.gitbook.io/
- **conventional-changelog:** https://github.com/conventional-changelog

---

**Migration Completed:** October 19, 2025  
**Tools Replaced:** release-it → commitizen  
**Next Review:** After first successful release with commitizen
