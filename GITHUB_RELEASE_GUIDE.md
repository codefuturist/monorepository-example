# 🚀 Complete GitHub Release Guide - The Frictionless Way

## Overview

This guide shows you **exactly** how to make a GitHub release using release-it with GitHub integration. Everything is configured for maximum frictionlessness!

---

## 🎯 Two Ways to Release

### Option 1: Fully Automated (Recommended)
Release-it creates the GitHub release directly:
- ✅ One command does everything
- ✅ Immediate GitHub release
- ✅ Requires GitHub token

### Option 2: GitHub Actions (Alternative)
Push tag, let GitHub Actions create release:
- ✅ No token needed locally
- ✅ Consistent with CI/CD
- ✅ Slightly delayed (workflow runs)

**We'll use Option 1 (Fully Automated) - The frictionless way!**

---

## 📋 One-Time Setup (2 minutes)

### Step 1: Create GitHub Token

1. Go to: https://github.com/settings/tokens/new
2. **Token name:** `release-it`
3. **Expiration:** 90 days (or custom)
4. **Scopes:** Select:
   - ✅ `repo` - Full control of repositories
5. Click **Generate token**
6. **Copy the token** (starts with `ghp_`)

### Step 2: Set Token in Terminal

```bash
# Set for current session
export GITHUB_TOKEN="ghp_your_token_here"

# Or add to ~/.zshrc for persistence
echo 'export GITHUB_TOKEN="ghp_your_token_here"' >> ~/.zshrc
source ~/.zshrc
```

### Step 3: Verify Setup

```bash
# Check token is set
echo $GITHUB_TOKEN

# Should show: ghp_...
```

✅ **Done! You're ready to release!**

---

## 🚀 The Frictionless Release Process

### Method 1: Interactive (Best for Learning)

```bash
# Run the demo script
./release-now.sh
```

This script will:
1. Show current state
2. Run dry-run preview
3. Ask for confirmation
4. Execute release
5. Push to GitHub
6. Create GitHub Release
7. Show results

### Method 2: One Command (Production)

```bash
npm run release
```

That's it! This will:
- ✅ Analyze commits (feat, fix, etc.)
- ✅ Determine version bump
- ✅ Update package.json
- ✅ Update CHANGELOG.md
- ✅ Create commit & tag
- ✅ Push to GitHub
- ✅ Create GitHub Release

### Method 3: Fully Automated (CI/CD Style)

```bash
npm run release -- --ci --increment=minor
```

No prompts, just does it!

---

## 📝 Step-by-Step Walkthrough

Let me show you **exactly** what happens:

### Step 1: Check Current State

```bash
git branch --show-current  # release/v1.1.0
cat package.json | grep version  # "version": "1.0.0"
git log --oneline -5  # See your commits
```

### Step 2: Dry Run (ALWAYS DO THIS FIRST!)

```bash
npm run release:dry
```

**What you'll see:**
```
🚀 Let's release monorepository-example (1.0.0)

Changelog:
  * feat(package-a): add logger utility with multiple log levels
  * feat(package-b): add string utility functions
  * feat(package-c): add division and percentage functions

? Select increment: minor (1.0.0 → 1.1.0)

✔ Changelog will be updated
✔ Will create commit: chore: release v1.1.0
✔ Will create tag: v1.1.0
✔ Will push to origin

🎉 Done (in dry-run mode)
```

👀 **Review this output carefully!**

### Step 3: Execute Release

```bash
npm run release
```

**Interactive prompts:**

```
? Select increment: (Use arrow keys)
❯ patch (1.0.1)
  minor (1.1.0)  ← Choose this!
  major (2.0.0)
  prepatch (1.0.1-0)
  preminor (1.1.0-0)
```

Press Enter on `minor`

```
? Commit (chore: release v1.1.0)? (Y/n) Y
```

Press Enter (Yes)

```
? Tag (v1.1.0)? (Y/n) Y
```

Press Enter (Yes)

```
? Push? (Y/n) Y
```

Press Enter (Yes)

```
? Create a release on GitHub (Release v1.1.0)? (Y/n) Y
```

Press Enter (Yes)

**Output:**
```
✔ Bumped version to 1.1.0
✔ Changelog updated
✔ Git commit
✔ Git tag
✔ Pushing to remote
✔ GitHub release created

🎉 Done! Released v1.1.0

🔗 https://github.com/YOUR_USERNAME/monorepository-example/releases/tag/v1.1.0
```

### Step 4: Verify on GitHub

Open the link and see:

```
Release v1.1.0
Latest • @your-username released this now

What's Changed
🎉 Features
• feat(package-a): add logger utility with multiple log levels
• feat(package-b): add string utility functions
• feat(package-c): add division and percentage functions

Full Changelog: v1.0.0...v1.1.0
```

---

## ✨ What Actually Happens

### Files Changed:

#### 1. `package.json`
```diff
{
  "name": "monorepository-example",
- "version": "1.0.0",
+ "version": "1.1.0",
```

#### 2. `CHANGELOG.md`
```markdown
# Changelog

## [1.1.0] - 2025-10-15

### Features

* **package-a:** add logger utility with multiple log levels
* **package-b:** add string utility functions
* **package-c:** add division and percentage functions

## [1.0.0] - 2025-10-15

### Added
- Initial monorepo setup
```

#### 3. Git Commits
```bash
* abc1234 (tag: v1.1.0) chore: release v1.1.0
* def5678 feat(package-c): add division and percentage functions
* ghi9012 feat(package-b): add string utility functions
* jkl3456 feat(package-a): add logger utility
```

#### 4. Git Tags
```bash
v1.1.0
v1.0.0
```

#### 5. GitHub Release
```
Created automatically at:
https://github.com/YOUR_USERNAME/monorepository-example/releases
```

---

## 🎯 Frictionless Tips

### Skip All Prompts
```bash
# Use CI mode
npm run release -- --ci
```

### Force Specific Version
```bash
# Minor bump (1.0.0 → 1.1.0)
npm run release -- --increment=minor

# Patch bump (1.0.0 → 1.0.1)
npm run release -- --increment=patch

# Major bump (1.0.0 → 2.0.0)
npm run release -- --increment=major
```

### Preview Only
```bash
# See what would happen
npm run release:dry
```

### Release Specific Package
```bash
# Release only package-a
npm run release:package-a
```

---

## 🔥 Ultra-Frictionless Alias

Add to `~/.zshrc`:

```bash
# One-word release command
alias release='npm run release:dry && echo "" && read -q "REPLY?Looks good? Execute release? (y/n) " && echo && npm run release'
```

Then just type:
```bash
release
```

It will:
1. Show dry-run
2. Ask for confirmation
3. Execute release
4. Done! 🎉

---

## 🎨 Customization Options

### Add More Release Notes

Edit `.release-it.json`:

```json
{
  "github": {
    "release": true,
    "releaseName": "🎉 Release ${version}",
    "releaseNotes": "## What's New\n\n${changelog}\n\n## Installation\n\n```bash\nnpm install\n```"
  }
}
```

### Auto-Push Without Asking

```json
{
  "git": {
    "push": true,
    "pushRepo": "origin"
  }
}
```

### Skip GitHub Release (Use Actions Instead)

```json
{
  "github": {
    "release": false
  },
  "git": {
    "push": true
  }
}
```

Then GitHub Actions workflow will create release when tag is pushed.

---

## 🚨 Troubleshooting

### "GitHub token required"

```bash
# Make sure token is set
echo $GITHUB_TOKEN

# If empty, export it:
export GITHUB_TOKEN="ghp_your_token_here"
```

### "Repository not found"

```bash
# Check remote URL
git remote -v

# Should show:
# origin  https://github.com/YOUR_USERNAME/monorepository-example.git

# If missing, add it:
git remote add origin https://github.com/YOUR_USERNAME/monorepository-example.git
```

### "No commits found"

```bash
# Make sure you have commits
git log --oneline

# If empty, make initial commit:
git add .
git commit -m "feat: initial release"
```

### "Tag already exists"

```bash
# Delete local and remote tag
git tag -d v1.1.0
git push origin :refs/tags/v1.1.0

# Try release again
npm run release
```

### "Permission denied (publickey)"

```bash
# Set up SSH key or use HTTPS with token
git remote set-url origin https://github.com/YOUR_USERNAME/monorepository-example.git
```

---

## 📊 Complete Flow Diagram

```
You type:
  npm run release
       ↓
release-it analyzes commits
       ↓
Shows version bump preview
       ↓
You confirm (or auto with --ci)
       ↓
Updates package.json (1.0.0 → 1.1.0)
       ↓
Updates CHANGELOG.md
       ↓
Creates commit: "chore: release v1.1.0"
       ↓
Creates tag: v1.1.0
       ↓
Pushes to GitHub
       ↓
Creates GitHub Release ✨
       ↓
GitHub Actions workflow triggers (optional)
       ↓
🎉 Done! Release is live!
```

**Total time:** ~30 seconds

---

## 🎓 Best Practices

1. **Always dry-run first**
   ```bash
   npm run release:dry
   ```

2. **Use conventional commits**
   ```bash
   git commit -m "feat: new feature"  # → minor bump
   git commit -m "fix: bug fix"       # → patch bump
   git commit -m "feat!: breaking"    # → major bump
   ```

3. **Review CHANGELOG before pushing**
   ```bash
   cat CHANGELOG.md | head -30
   ```

4. **Keep branches synced (Git Flow)**
   ```bash
   git checkout main && git merge release/v1.1.0
   git checkout develop && git merge main
   ```

5. **Tag consistently**
   - Use semantic versioning: v1.2.3
   - Tags trigger automation

---

## ⚡ Quick Commands Cheat Sheet

```bash
# Full process (3 commands)
npm run release:dry      # Preview
npm run release          # Execute
# Done! (pushes & creates GitHub release automatically)

# One command (no preview)
npm run release -- --ci

# Custom version
npm run release -- --increment=patch

# Package-specific
npm run release:package-a

# Check release
git tag -l
cat CHANGELOG.md
cat package.json | grep version
```

---

## 🎉 Success Metrics

After running `npm run release`, you should have:

- ✅ New version in package.json
- ✅ Updated CHANGELOG.md
- ✅ New git commit
- ✅ New git tag
- ✅ Pushed to GitHub
- ✅ GitHub Release created
- ✅ Release notes auto-generated
- ✅ GitHub Actions triggered (if configured)

**View at:** `https://github.com/YOUR_USERNAME/monorepository-example/releases`

---

## 📚 Additional Resources

- **RELEASE_DEMO.md** - Complete walkthrough
- **release-now.sh** - Interactive script
- **demo-workflow.sh** - Git Flow guide
- **README.md** - Project documentation
- **CONTRIBUTING.md** - Team guidelines

---

## 🎊 Summary

**Before:** Manual releases, forgotten changelogs, inconsistent versions

**After (with release-it):**
```bash
npm run release
```
**Everything happens automatically! 🚀**

- 🎯 Smart version bumps
- 📝 Auto-generated changelogs
- 🏷️ Git tags
- ☁️ GitHub releases
- 🤖 Trigger automation

**Total effort:** One command
**Total time:** 30 seconds
**Errors:** Nearly zero

---

**Status:** ✅ Ready to release  
**Setup time:** 2 minutes  
**Per-release time:** 30 seconds  
**Next command:** `npm run release:dry`

🚀 **Go make a release!**
