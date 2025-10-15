# ⚡ Quick Release Guide

## 🎯 Current Status

Your release system is **99% ready**! Here's what's done:

- ✅ Complete monorepo structure
- ✅ release-it configured
- ✅ GitHub Actions workflows
- ✅ Git Flow branches
- ✅ Conventional commits
- ✅ Demo scripts

**Missing:** GitHub remote repository

---

## 🚀 Two Ways to Release

### Option A: With GitHub (Full Automation)

#### 1. Create GitHub Repository

```bash
# On GitHub.com, create new repository: monorepository-example
# Then connect it:

git remote add origin https://github.com/YOUR_USERNAME/monorepository-example.git
```

#### 2. Get GitHub Token (Optional but Recommended)

Visit: https://github.com/settings/tokens/new

- Name: `release-it`
- Expiration: 90 days
- Scope: ✅ `repo` (full control)
- Generate & copy token

```bash
export GITHUB_TOKEN="ghp_your_token_here"
```

#### 3. Release!

```bash
# Preview first
npm run release:dry

# Execute release
npm run release
```

**Result:** Version bumped, changelog updated, GitHub release created! 🎉

---

### Option B: Local Only (No GitHub Needed)

You can still use release-it locally without GitHub:

```bash
# Dry run
npx release-it --dry-run --ci --increment=minor --no-git.push --no-github.release

# Actual release (local only)
npx release-it --ci --increment=minor --no-git.push --no-github.release
```

**Result:** Version and changelog updated locally, no push to GitHub.

---

## 📋 Complete Workflow Example

### Scenario: You've Added Features and Want to Release v1.1.0

```bash
# 1. Check current state
git branch
# You're on: release/v1.1.0

# 2. Connect to GitHub (one-time)
git remote add origin https://github.com/YOUR_USERNAME/monorepository-example.git

# 3. Set GitHub token (optional, one-time)
export GITHUB_TOKEN="ghp_your_token_here"

# 4. Preview release
npm run release:dry

# Output shows:
# - Version: 1.0.0 → 1.1.0
# - Changelog will be updated
# - Commit and tag will be created

# 5. Execute release
npm run release

# Prompts you for:
# • Version increment? [minor] (already v1.1.0)
# • Continue? [Y/n]

# Then automatically:
# ✓ Updates package.json
# ✓ Updates CHANGELOG.md
# ✓ Creates commit: "chore: release v1.1.0"
# ✓ Creates tag: v1.1.0
# ✓ Pushes to GitHub
# ✓ Creates GitHub Release

# 6. Complete Git Flow
git checkout main
git merge release/v1.1.0
git push origin main

git checkout develop
git merge main
git push origin develop

# 7. Check GitHub
# Visit: https://github.com/YOUR_USERNAME/monorepository-example/releases
# Your release is live! 🎉
```

---

## 🎮 Try It Right Now

### Without GitHub (Test Locally)

```bash
# This won't push anything, just shows you how it works
npx release-it --dry-run --ci --increment=minor --no-git.push --no-github.release
```

### With GitHub (Full Experience)

1. Create repo on GitHub
2. Add remote:
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/monorepository-example.git
   ```
3. Run:
   ```bash
   npm run release
   ```

---

## 🔧 Troubleshooting

### "Could not get remote Git url"

```bash
# Check remotes
git remote -v

# If empty, add GitHub remote
git remote add origin https://github.com/YOUR_USERNAME/monorepository-example.git
```

### "Permission denied (publickey)"

```bash
# Use HTTPS instead of SSH
git remote set-url origin https://github.com/YOUR_USERNAME/monorepository-example.git

# Or set up SSH keys: https://docs.github.com/en/authentication
```

### "GitHub token required"

```bash
# Either set token:
export GITHUB_TOKEN="ghp_your_token"

# Or rely on GitHub Actions (release created when tag is pushed)
```

---

## ⚡ Commands Cheat Sheet

| Command | What It Does |
|---------|-------------|
| `npm run release:dry` | Preview without changes |
| `npm run release` | Interactive release |
| `npm run release -- --ci` | Automated release (no prompts) |
| `npm run release -- --increment=patch` | Force patch version (1.0.1) |
| `npm run release -- --increment=minor` | Force minor version (1.1.0) |
| `npm run release -- --increment=major` | Force major version (2.0.0) |
| `npm run release -- --preRelease=beta` | Pre-release (1.1.0-beta.0) |

---

## 📦 What You Have

```
monorepository-example/
├── 📄 Complete configuration
│   ├── .release-it.json ← Configured for GitHub
│   ├── package.json ← Scripts ready
│   └── .github/workflows/release.yml ← GitHub Actions
│
├── 📦 Three packages ready to release
│   ├── package-a (Logger)
│   ├── package-b (String utilities)
│   └── package-c (Math helpers)
│
├── 📝 Comprehensive documentation
│   ├── RELEASE_SUMMARY.md ← Complete guide
│   ├── GITHUB_RELEASE_GUIDE.md ← Detailed walkthrough
│   ├── RELEASE_DEMO.md ← Examples
│   └── QUICK_RELEASE.md ← This file!
│
└── 🎬 Demo scripts
    ├── release-now.sh ← Interactive demo
    └── demo-release.sh ← Educational script
```

---

## 🎯 Next Steps

### To Release RIGHT NOW:

1. **Create GitHub repository** (2 minutes)
   - Go to: https://github.com/new
   - Name: `monorepository-example`
   - Public or Private
   - Don't initialize (we have files)
   - Create repository

2. **Connect repository** (30 seconds)
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/monorepository-example.git
   ```

3. **Release!** (30 seconds)
   ```bash
   npm run release
   ```

**Total time:** 3 minutes to first GitHub release! ⚡

---

### To Test Locally (No GitHub):

```bash
npx release-it --dry-run --ci --increment=minor --no-git.push --no-github.release
```

**Time:** 10 seconds ⚡

---

## ✨ What Makes This Special

1. **One Command:** `npm run release` does everything
2. **Automatic Versioning:** Based on your commit messages
3. **Automatic Changelog:** Generated from commits
4. **Git Flow Integrated:** Works seamlessly with branching
5. **GitHub Integration:** Creates releases automatically
6. **Monorepo Ready:** Release root or individual packages
7. **Zero Configuration:** Already set up, just use it

---

## 🎉 Summary

**Setup Status:** ✅ Complete  
**Configuration:** ✅ Done  
**Documentation:** ✅ Comprehensive  
**Ready to Release:** ✅ Yes!

**Missing:** GitHub remote (optional, 2 minutes to add)

**Command to Release:**
```bash
npm run release
```

That's it! 🚀

---

**Questions?** Read:
- `RELEASE_SUMMARY.md` - Overview
- `GITHUB_RELEASE_GUIDE.md` - Detailed guide
- `RELEASE_DEMO.md` - Examples

**Want to practice?** Run:
```bash
./release-now.sh
```

🎊 **You're ready to release!**
