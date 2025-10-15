# 🚀 Frictionless GitHub Release Guide

## Complete Step-by-Step Release Process

This guide shows you **exactly** how to make a GitHub release using release-it with zero friction.

---

## 📋 Prerequisites (One-Time Setup)

### 1. Ensure Repository is on GitHub
```bash
# If not already pushed to GitHub:
git remote add origin https://github.com/YOUR_USERNAME/monorepository-example.git
git push -u origin main
git push -u origin develop
```

### 2. Verify Dependencies
```bash
npm install  # Already done ✓
```

### 3. Check GitHub Token (Optional for local releases)
```bash
# For GitHub release creation from CLI, set token:
export GITHUB_TOKEN="your_github_token"

# Or add to ~/.bashrc or ~/.zshrc:
echo 'export GITHUB_TOKEN="your_token"' >> ~/.zshrc
```

---

## 🎯 THE FRICTIONLESS RELEASE PROCESS

### Step 1: Ensure You're on the Right Branch ✓

```bash
# Check current branch
git branch --show-current

# Should be on: develop, release/*, or main
# For this demo, we're on: release/v1.1.0
```

**Current Status:** ✅ On release/v1.1.0

---

### Step 2: View What Will Be Released

```bash
# See all commits since last release
git log --oneline v1.0.0..HEAD

# Or if no tags yet:
git log --oneline
```

**Our commits:**
- ✅ feat(package-a): add logger utility
- ✅ feat(package-b): add string utility functions
- ✅ feat(package-c): add division and percentage functions

---

### Step 3: DRY RUN - Test Release (No Changes Made)

```bash
npm run release:dry
```

**What this shows:**
- Current version: `1.0.0`
- Next version: `1.1.0` (based on feat commits)
- Preview of CHANGELOG.md updates
- Commit and tag that would be created
- **NO ACTUAL CHANGES MADE!**

**Expected output:**
```
🚀 Let's release monorepository-example

? Select increment (next version): minor (1.1.0)

Changelog:
  * feat(package-a): add logger utility with multiple log levels
  * feat(package-b): add string utility functions
  * feat(package-c): add division and percentage functions

✔ Changelog updated
✔ Would create commit: chore: release v1.1.0
✔ Would create tag: v1.1.0

🎉 Done (in dry-run mode)
```

---

### Step 4: Execute the Release! 🚀

```bash
npm run release
```

**Interactive prompts:**
1. Select increment: `minor` (1.0.0 → 1.1.0)
2. Commit? `Yes`
3. Tag? `Yes`
4. Push? `No` (we'll push manually)
5. GitHub release? `No` (handled by GitHub Actions)

**What happens:**
1. ✅ Bumps version in `package.json`: `1.0.0` → `1.1.0`
2. ✅ Updates `CHANGELOG.md` with all features
3. ✅ Creates commit: `chore: release v1.1.0`
4. ✅ Creates tag: `v1.1.0`

**Output:**
```
🚀 Let's release monorepository-example (1.0.0)

✔ Bumped to 1.1.0
✔ Changelog updated
✔ Git commit
✔ Git tag

🎉 Done! Created v1.1.0
```

---

### Step 5: Review Changes Before Pushing

```bash
# Check the new version
cat package.json | grep version

# Check the new CHANGELOG
head -20 CHANGELOG.md

# Check the new commit
git log -1 --oneline

# Check the new tag
git tag -l
```

**Verification:**
- ✅ package.json version: `1.1.0`
- ✅ CHANGELOG.md updated with features
- ✅ Commit created: `chore: release v1.1.0`
- ✅ Tag created: `v1.1.0`

---

### Step 6: Push to GitHub 🚀

```bash
# Push the branch
git push origin release/v1.1.0

# Push the tag (THIS TRIGGERS GITHUB ACTIONS!)
git push origin v1.1.0
```

**What happens:**
1. Branch and commits are pushed
2. Tag `v1.1.0` is pushed
3. 🤖 **GitHub Actions workflow triggers automatically!**

---

### Step 7: GitHub Actions Takes Over 🤖

**Triggered by:** Tag push `v1.1.0`

**Workflow runs automatically:**

```
GitHub Actions Workflow "Release"
├─ ✅ Checkout code
├─ ✅ Setup Node.js 20
├─ ✅ Install dependencies
├─ ✅ Run tests
├─ ✅ Build packages
├─ ✅ Create GitHub Release
│   ├─ Release name: "v1.1.0"
│   ├─ Auto-generate release notes from commits
│   └─ Attach build artifacts
└─ ✅ Success!
```

**Check status at:**
`https://github.com/YOUR_USERNAME/monorepository-example/actions`

---

### Step 8: Verify GitHub Release 🎉

**View your release:**
`https://github.com/YOUR_USERNAME/monorepository-example/releases`

**Release page shows:**
```
Release v1.1.0
Latest

What's Changed
• feat(package-a): add logger utility with multiple log levels
• feat(package-b): add string utility functions  
• feat(package-c): add division and percentage functions

Full Changelog: v1.0.0...v1.1.0
```

---

### Step 9: Complete Git Flow (Merge to Main)

```bash
# Merge release to main
git checkout main
git merge release/v1.1.0 --no-ff

# Push main
git push origin main

# Merge back to develop
git checkout develop
git merge main

# Push develop
git push origin develop

# Clean up release branch (optional)
git branch -d release/v1.1.0
```

---

## ⚡ QUICK REFERENCE - Complete Flow

```bash
# 1. Dry run (test)
npm run release:dry

# 2. Execute release
npm run release

# 3. Push (triggers automation)
git push origin release/v1.1.0
git push origin v1.1.0

# 4. Merge to main
git checkout main && git merge release/v1.1.0 --no-ff
git push origin main

# 5. Merge back to develop
git checkout develop && git merge main
git push origin develop

# Done! Check GitHub releases page 🎉
```

---

## 🎯 Even More Frictionless (One Command)

For releases without questions:

```bash
# Non-interactive release
npm run release -- --ci --increment=minor

# With all options
npm run release -- --ci --no-git.requireCleanWorkingDir --increment=minor
```

---

## 🔧 Configuration for Maximum Frictionlessness

### Option 1: Skip All Prompts (CI Mode)

Add to `package.json` scripts:
```json
{
  "scripts": {
    "release:auto": "release-it --ci --increment=minor"
  }
}
```

Then just run:
```bash
npm run release:auto
```

### Option 2: Release with One Command

```bash
# Combines dry-run review, release, and push
npm run release && git push --follow-tags
```

### Option 3: Alias for Ultimate Speed

Add to `~/.zshrc`:
```bash
alias release='npm run release:dry && read -q "REPLY?Execute release? (y/n) " && echo && npm run release && git push --follow-tags'
```

Then just type:
```bash
release
```

---

## 📦 Release Individual Package

```bash
# Release only package-a
npm run release:package-a

# This creates tag: package-a@v1.0.1
# GitHub Actions detects package-specific tag
```

---

## 🎨 Customizing Release Notes

### Add Custom Release Notes

Create `.github/release-template.md`:
```markdown
## 🎉 What's New

<!-- Auto-generated from commits -->

## 🐛 Bug Fixes

<!-- Auto-generated from commits -->

## 📝 Documentation

See full [CHANGELOG.md](./CHANGELOG.md)
```

---

## 🚨 Troubleshooting

### "No upstream configured"
```bash
git push --set-upstream origin $(git branch --show-current)
```

### "Tag already exists"
```bash
# Delete and recreate
git tag -d v1.1.0
git push origin :refs/tags/v1.1.0
npm run release
```

### "GitHub token required"
```bash
# Set token for GitHub release creation
export GITHUB_TOKEN="ghp_your_token_here"
```

### "Working directory not clean"
```bash
# Commit or stash changes
git add . && git commit -m "chore: prepare for release"

# Or disable check (not recommended)
npm run release -- --no-git.requireCleanWorkingDir
```

---

## 📊 What Gets Updated in Each Release

| File | Change | Example |
|------|--------|---------|
| `package.json` | Version bump | `1.0.0` → `1.1.0` |
| `CHANGELOG.md` | New section | `## [1.1.0] - 2025-10-15` |
| Git history | New commit | `chore: release v1.1.0` |
| Git tags | New tag | `v1.1.0` |
| GitHub | New release | Release v1.1.0 page |

---

## 🎓 Best Practices

1. **Always dry-run first**: `npm run release:dry`
2. **Review CHANGELOG**: Check auto-generated content
3. **Test before release**: Ensure code works
4. **Use semantic versioning**: Let commits determine version
5. **Push tags explicitly**: Makes automation clear
6. **Merge back to develop**: Keep branches in sync

---

## ✨ Summary: Frictionless Flow

```
Write code with conventional commits
         ↓
git checkout -b release/vX.Y.Z
         ↓
npm run release:dry (review)
         ↓
npm run release (execute)
         ↓
git push --follow-tags
         ↓
GitHub Actions → Automatic Release! 🎉
```

**Total time:** ~2 minutes  
**Manual steps:** 3 commands  
**Automation:** Everything else  

---

**Status:** ✅ Ready to release  
**Current branch:** release/v1.1.0  
**Next command:** `npm run release:dry`

🚀 **Let's make a release!**
