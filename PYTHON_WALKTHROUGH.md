# 🚀 Python Package Release - Complete Walkthrough

> Step-by-step guide to test your Python packages and trigger an automated release via GitHub Actions

---

## 📋 Prerequisites

Before you begin, ensure you have:

```bash
# Python 3.9+
python3 --version

# Git and git-flow
git --version
git flow version 2>/dev/null || brew install git-flow-avh

# Package building tools
pip3 install build twine pytest pytest-cov
```

---

## 🎯 Complete Walkthrough (15 minutes)

### Step 1: Verify Python Package Structure (2 minutes)

```bash
# Navigate to repository
cd /Users/colin/Developer/Projects/personal/monorepository-example

# Check package structure
ls -la packages/package-a/
# Should see:
# ✅ src/          (source code)
# ✅ tests/        (test suite)
# ✅ pyproject.toml (package config)
# ✅ CHANGELOG.md
# ✅ .release-it.json

# Check src directory
ls -la packages/package-a/src/
# Should see:
# ✅ __init__.py
# ✅ __version__.py
# ✅ logger.py (or your modules)

# Check tests directory
ls -la packages/package-a/tests/
# Should see:
# ✅ test_logger.py (or your tests)
# ✅ conftest.py
```

### Step 2: Test Locally (3 minutes)

```bash
# Navigate to package
cd packages/package-a

# Install package in development mode with test dependencies
pip install -e ".[test]"

# Run tests
pytest

# Expected output:
# ===== test session starts =====
# packages/package-a/tests/test_logger.py::TestSetupLogger::test_setup_logger_creates_logger PASSED
# packages/package-a/tests/test_logger.py::TestSetupLogger::test_setup_logger_default_level PASSED
# ===== 6 passed in 0.15s =====
```

### Step 3: Build Distribution Package (2 minutes)

```bash
# From package-a directory (packages/package-a)
# or from root, but the build happens in each package

# Build wheel and source distribution
python -m build

# Check build output
ls -lh dist/
# Should see:
# ✅ package_a-1.1.0-py3-none-any.whl  (~15KB)
# ✅ package_a-1.1.0.tar.gz             (~5KB)

# Verify package contents
tar -tzf dist/package_a-1.1.0.tar.gz | head -20
```

### Step 4: Create Feature and Commit (2 minutes)

```bash
# Return to root
cd ../..

# Start feature branch
git flow feature start add-python-support

# Make a code change (optional)
cd packages/package-a

# Edit src/logger.py or add a new function
cat >> src/logger.py << 'EOF'


def get_logger_name(logger: logging.Logger) -> str:
    """Get logger name."""
    return logger.name
EOF

# Commit with conventional format
git add -A
git commit -m "feat(package-a): add get_logger_name helper function"

# Return to root
cd ../..

# Finish feature
git flow feature finish add-python-support

# Verify we're on develop
git branch
# Should show: * develop
```

### Step 5: Create Release with Git Flow (2 minutes)

```bash
# Start release process
git flow release start 1.2.0

# Update package version (automatic with release-it, but we can do manually)
cd packages/package-a

# Option A: Update manually
sed -i '' 's/__version__ = "1.1.0"/__version__ = "1.2.0"/' src/__version__.py
sed -i '' 's/"version": "1.1.0"/"version": "1.2.0"/' pyproject.toml

# Verify update
grep version src/__version__.py
# Should show: __version__ = "1.2.0"

# Commit the version bump
git add -A
git commit -m "chore(package-a): bump version to 1.2.0"

# Return to root
cd ../..

# Finish release
git flow release finish 1.2.0 -m "Release package-a v1.2.0"

# Verify you're back on develop
git branch
# Should show: * develop
```

### Step 6: Create and Push Tag (2 minutes)

```bash
# Create annotated tag (important for GitHub Actions to detect)
git tag -a package-a@v1.2.0 -m "Release package-a v1.2.0"

# Verify tag was created
git tag -l | grep package-a
# Should show: package-a@v1.2.0

# Show tag details
git show package-a@v1.2.0
# Should show tag message and commit

# Push everything to GitHub (this triggers the Action!)
git push origin main develop --tags

# Verify tag was pushed
git ls-remote --tags origin | grep package-a
# Should show: package-a@v1.2.0 pushed to remote
```

### Step 7: Watch GitHub Action Run (3 minutes)

```bash
# In your browser:
# 1. Go to: https://github.com/codefuturist/monorepository-example
# 2. Click "Actions" tab
# 3. Select "Python Release" workflow
# 4. Watch the build run in real-time

# You should see:
# ✅ build-and-test job
#    ├─ Checkout code
#    ├─ Setup Python 3.9, 3.10, 3.11, 3.12
#    ├─ Install build tools
#    ├─ Extract tag info
#    ├─ Install package dependencies
#    ├─ Run linting (optional)
#    ├─ Run type checking (optional)
#    ├─ Run pytest
#    ├─ Build distribution package
#    └─ Upload artifacts
#
# ✅ publish job
#    ├─ Download artifacts
#    ├─ Create GitHub Release
#    └─ Publish to PyPI (if configured)
```

---

## 📊 Expected Results

### GitHub Actions Output

When the workflow completes successfully:

```
✅ Build & Test Python Package
   ├─ Python 3.9: PASSED
   ├─ Python 3.10: PASSED
   ├─ Python 3.11: PASSED
   └─ Python 3.12: PASSED

✅ Publish Python Package
   ├─ Create GitHub Release: SUCCESS
   └─ Publish to PyPI: SKIPPED (no token configured)
```

### GitHub Release Created

Navigate to Releases: `https://github.com/codefuturist/monorepository-example/releases`

You should see:

```
📦 package-a v1.2.0

## Python Package Release

**Package:** package-a
**Version:** v1.2.0

Built for Python 3.9, 3.10, 3.11, 3.12

[View CHANGELOG]

## Assets
- package_a-1.2.0-py3-none-any.whl
- package_a-1.2.0.tar.gz
```

### Download and Verify Package

```bash
# Download from release (manual download via UI)
# OR from CI artifacts

# Install the wheel
pip install package_a-1.2.0-py3-none-any.whl

# Verify it works
python3 << 'EOF'
from src import __version__
print(f"Package A version: {__version__}")

from src.logger import setup_logger
logger = setup_logger("test")
logger.info("Hello from package-a!")
EOF

# Output:
# Package A version: 1.2.0
# 2025-10-18 14:30:45,123 - test - INFO - Hello from package-a!
```

---

## 🔄 Release Multiple Packages

### Release package-b

```bash
# Start feature
git flow feature start add-utils

# Make changes to package-b
cd packages/package-b
cat >> src/strings.py << 'EOF'


def capitalize_words(text: str) -> str:
    """Capitalize each word."""
    return ' '.join(word.capitalize() for word in text.split())
EOF

git add -A
git commit -m "feat(package-b): add capitalize_words function"

cd ../..
git flow feature finish add-utils

# Start release
git flow release start 1.1.0

# Update version
cd packages/package-b
sed -i '' 's/"version": "1.0.0"/"version": "1.1.0"/' pyproject.toml
sed -i '' 's/__version__ = "1.0.0"/__version__ = "1.1.0"/' src/__version__.py
git add -A
git commit -m "chore(package-b): bump version to 1.1.0"

cd ../..
git flow release finish 1.1.0 -m "Release package-b v1.1.0"

# Create and push tag
git tag -a package-b@v1.1.0 -m "Release package-b v1.1.0"
git push origin main develop --tags

# ✅ GitHub Action automatically releases package-b!
```

### Release All Packages Together

```bash
# Option: Coordinated monorepo release
# Create tags for all packages

# Tag all at once
git tag -a v2.0.0 -m "Release all packages v2.0.0"

# Or create individual tags in sequence
git tag -a package-a@v2.0.0 -m "Release package-a v2.0.0"
git tag -a package-b@v2.0.0 -m "Release package-b v2.0.0"
git tag -a package-c@v2.0.0 -m "Release package-c v2.0.0"

# Push all tags
git push origin main develop --tags

# Each tag triggers a separate GitHub Action job!
```

---

## ✅ Verification Checklist

Before considering the release complete:

- [ ] GitHub Action workflow started (check Actions tab)
- [ ] All Python versions tested (3.9, 3.10, 3.11, 3.12)
- [ ] Tests passed (pytest green)
- [ ] Build succeeded (wheel and sdist created)
- [ ] GitHub Release created (visible in Releases tab)
- [ ] Release has correct version number
- [ ] Release has package artifacts (.whl, .tar.gz)
- [ ] Release notes are auto-generated
- [ ] Tag visible on GitHub (Tags page)
- [ ] Can download and install package

---

## 🐛 Troubleshooting

### Issue: Action Didn't Trigger

**Check:**

```bash
# Verify tag exists locally
git tag -l | grep package-a

# Verify tag was pushed
git ls-remote --tags origin | grep package-a

# If not pushed, do it manually
git push origin package-a@v1.2.0

# Check Actions tab for recent runs
# May take 30-60 seconds to appear
```

### Issue: Tests Failing in GitHub

**Solution:**

```bash
# Run same tests locally first
cd packages/package-a
pip install -e ".[test]"
pytest -v

# If passing locally, check Python version
python3 --version

# Try with exact Python version in workflow
python3.9 -m pytest
```

### Issue: Import Errors in Tests

**Solution:**

```bash
# Check conftest.py exists in tests directory
ls -la packages/package-a/tests/conftest.py

# Should contain:
# import sys
# from pathlib import Path
# src_path = Path(__file__).parent.parent / "src"
# sys.path.insert(0, str(src_path))
```

### Issue: Package Not Found When Building

**Solution:**

```bash
# Check pyproject.toml has correct packages
cat packages/package-a/pyproject.toml | grep -A 2 'tool.setuptools'
# Should show:
# [tool.setuptools]
# packages = ["src"]

# Check __init__.py exists in src
touch packages/package-a/src/__init__.py
```

---

## 📚 Quick Reference Commands

```bash
# Local testing
cd packages/package-a
pip install -e ".[test]"
pytest --cov=src --cov-report=html

# Build package
python -m build
ls -lh dist/

# Create tags
git tag -a package-a@v1.2.0 -m "Release"
git tag -l

# Push and trigger
git push origin main develop --tags

# Monitor GitHub Action
# Browser: GitHub Repo → Actions → Python Release

# Download release
# Browser: GitHub Repo → Releases → Assets
```

---

## 🎉 Success!

Your Python package is now:

1. ✅ **Structured Properly** - Follows Python best practices
2. ✅ **Tested Automatically** - pytest runs on 4 Python versions
3. ✅ **Built Automatically** - Wheel and source distributions created
4. ✅ **Released Automatically** - GitHub Release created on tag push
5. ✅ **Published** - Artifacts available for download/installation

**Next Steps:**

1. Repeat the walkthrough for package-b and package-c
2. Configure PyPI token for automatic publishing (optional)
3. Set up branch protection rules on main
4. Share this guide with your team

---

**Happy releasing! 🚀**
