# 🚀 Python Package Release - Quick Reference Card

> Keep this handy while working with your Python packages

---

## ⚡ The 5-Step Release Process

```
1. TEST     pytest
2. BUILD    python -m build
3. TAG      git tag -a package-a@v1.2.0 -m "Release"
4. PUSH     git push origin --tags
5. RELEASE  GitHub Action runs automatically
```

---

## 🔧 Essential Commands

### Testing

```bash
cd packages/package-a
pip install -e ".[test]"      # Install with test deps
pytest                        # Run all tests
pytest -v                     # Verbose output
pytest --cov=src             # With coverage
pytest -k test_name          # Run specific test
```

### Building

```bash
python -m build              # Create wheel + sdist
ls -lh dist/                 # Check output
python -m build --wheel      # Wheel only
python -m build --sdist      # Source only
```

### Git Flow

```bash
git flow feature start name        # Start feature
git flow feature finish name       # Finish feature
git flow release start 1.2.0       # Start release
git flow release finish 1.2.0      # Finish release
git flow hotfix start 1.2.1        # Emergency fix
git flow hotfix finish 1.2.1       # Complete hotfix
```

### Tagging

```bash
git tag -a package-a@v1.2.0 -m "Release"    # Create tag
git tag -l                                   # List tags
git tag -l "package-a@*"                     # Filter tags
git show package-a@v1.2.0                    # Show tag
git push origin package-a@v1.2.0             # Push tag
git push origin --tags                       # Push all tags
git tag -d package-a@v1.2.0                  # Delete local
git push origin :refs/tags/package-a@v1.2.0 # Delete remote
```

### Version Updates

```bash
# Edit src/__version__.py
sed -i '' 's/"1.1.0"/"1.2.0"/' src/__version__.py

# Edit pyproject.toml
sed -i '' 's/version = "1.1.0"/version = "1.2.0"/' pyproject.toml

# Verify
grep version src/__version__.py
grep version pyproject.toml
```

---

## 📋 Release Checklist

Before pushing tag:

- [ ] Tests pass locally: `pytest`
- [ ] Build succeeds: `python -m build`
- [ ] Version updated in `src/__version__.py`
- [ ] Version updated in `pyproject.toml`
- [ ] Changes committed: `git add . && git commit -m "..."`
- [ ] On main branch: `git branch` (should show main)
- [ ] No uncommitted changes: `git status` (clean)

---

## 🎯 Release Workflow

### Step 1: Start Feature

```bash
git flow feature start my-feature
cd packages/package-a
# Make code changes
git commit -m "feat(package-a): description"
cd ../..
git flow feature finish my-feature
```

### Step 2: Prepare Release

```bash
git flow release start 1.2.0
cd packages/package-a
sed -i '' 's/"1.1.0"/"1.2.0"/' src/__version__.py
sed -i '' 's/version = "1.1.0"/version = "1.2.0"/' pyproject.toml
git add -A
git commit -m "chore(package-a): bump to 1.2.0"
cd ../..
git flow release finish 1.2.0 -m "Release 1.2.0"
```

### Step 3: Tag and Push

```bash
git tag -a package-a@v1.2.0 -m "Release package-a v1.2.0"
git push origin main develop --tags
```

### Step 4: Monitor GitHub Action

Visit: `GitHub Repo → Actions → Python Release`

Watch:

1. build-and-test starts
2. Tests run on 3.9, 3.10, 3.11, 3.12
3. Distribution built
4. publish job runs
5. GitHub release created

### Step 5: Verify Release

Visit: `GitHub Repo → Releases`

Check:

- Release created: `package-a v1.2.0`
- Assets uploaded: `.whl`, `.tar.gz`
- Release notes generated

---

## 🐛 Quick Fixes

### Tests failing

```bash
cd packages/package-a
pip install -e ".[test]"
pytest -v
```

### Import errors

```bash
# Ensure conftest.py exists
ls -la packages/package-a/tests/conftest.py

# Check src path is added
cat packages/package-a/tests/conftest.py
```

### Tag not pushed

```bash
git push origin package-a@v1.2.0 --force
```

### Version mismatch

```bash
# Check version in both files
grep version packages/package-a/src/__version__.py
grep version packages/package-a/pyproject.toml

# Should match!
```

### Action not triggering

```bash
# Verify tag format
git tag -l | grep package-a
# Should be: package-a@v1.2.0 (not v1.2.0)

# Check it was pushed
git ls-remote --tags origin | grep package-a
```

---

## 📚 File Locations

```
Package A:
  Source:        packages/package-a/src/
  Version:       packages/package-a/src/__version__.py
  Config:        packages/package-a/pyproject.toml
  Tests:         packages/package-a/tests/
  Config:        packages/package-a/tests/conftest.py

Workflows:
  Python Release: .github/workflows/python-release.yml
  Python CI:      .github/workflows/python-ci.yml

Documentation:
  Guide:         PYTHON_RELEASE_GUIDE.md
  Walkthrough:   PYTHON_WALKTHROUGH.md
  Summary:       PYTHON_SETUP_SUMMARY.md
  This Card:     PYTHON_QUICK_REFERENCE.md
```

---

## 🔗 Important Links

### Repo

- Tests: `GitHub Repo → Actions → Python CI`
- Releases: `GitHub Repo → Releases`
- Tags: `GitHub Repo → Tags`
- Workflows: `GitHub Repo → .github/workflows/`

### Documentation

- [PYTHON_RELEASE_GUIDE.md](./PYTHON_RELEASE_GUIDE.md)
- [PYTHON_WALKTHROUGH.md](./PYTHON_WALKTHROUGH.md)
- [PYTHON_SETUP_SUMMARY.md](./PYTHON_SETUP_SUMMARY.md)

---

## 💡 Pro Tips

1. **Always use annotated tags**: `git tag -a` (not `git tag`)
2. **Tag format matters**: `package-a@v1.2.0` (not `v1.2.0`)
3. **Test locally first**: `pytest` before pushing
4. **Build locally**: `python -m build` before tagging
5. **Push branches first**: `git push origin develop` before tags
6. **Monitor Action**: Check it completes before announcing release
7. **Download artifact**: Test it works: `pip install <package>`

---

## 📊 Tag Patterns

```
✅ Correct Patterns:
   package-a@v1.2.0
   package-b@v2.0.0
   package-c@v1.0.1

❌ Wrong Patterns:
   v1.2.0              (missing package name)
   package-a@1.2.0     (missing 'v')
   package-a-v1.2.0    (should use @)
   packageA@v1.2.0     (should be kebab-case)
```

---

## 🎓 Version Bumping

```
Current: 1.0.0

patch:  1.0.1  (bug fixes, small changes)
minor:  1.1.0  (new features, backward compatible)
major:  2.0.0  (breaking changes)

Examples:
  1.0.0 → 1.0.1 (patch)
  1.0.1 → 1.1.0 (minor)
  1.1.0 → 2.0.0 (major)
```

---

## ✨ Remember

- **Test before push** → `pytest`
- **Build before tag** → `python -m build`
- **Tag before GitHub** → `git tag -a`
- **Push to trigger** → `git push origin --tags`
- **Monitor workflow** → GitHub Actions tab
- **Verify release** → GitHub Releases tab

---

## 📞 Need Help?

| Problem            | Solution                                            |
| ------------------ | --------------------------------------------------- |
| Tests fail         | `pytest -v` to debug                                |
| Import error       | Check `conftest.py` exists                          |
| Version mismatch   | Update both files                                   |
| Tag not detected   | Check format: `package-a@v1.2.0`                    |
| Action not running | Check tag was pushed: `git ls-remote --tags origin` |

---

**Print this card and keep it at your desk! 📌**

_Updated: October 18, 2025_
