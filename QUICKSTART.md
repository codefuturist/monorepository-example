# Quick Start Guide

## 🎯 Initial Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Initialize Git Flow:**
   ```bash
   # Create initial commit
   git add .
   git commit -m "chore: initial monorepo setup"
   
   # Create develop branch
   git checkout -b develop
   git push -u origin develop
   
   # Go back to main
   git checkout main
   git push -u origin main
   ```

3. **Set up GitHub branch protection** (in repository settings):
   - Protect `main` branch:
     - ✅ Require pull request reviews
     - ✅ Require status checks to pass
     - ✅ Include administrators
   - Protect `develop` branch:
     - ✅ Require pull request reviews
     - ✅ Require status checks to pass

## 🚀 Your First Release

### Create Feature

```bash
git checkout develop
git checkout -b feature/my-first-feature

# Make changes
echo "console.log('Hello!');" > packages/package-a/src/demo.js
git add .
git commit -m "feat(package-a): add demo functionality"

# Push and create PR to develop
git push origin feature/my-first-feature
```

### Create Release

```bash
# After merging feature to develop
git checkout develop
git pull origin develop
git checkout -b release/v1.1.0

# Test release
npm run release:dry

# Create release (bumps version, updates CHANGELOG, creates tag)
npm run release

# Push release branch and tag
git push origin release/v1.1.0
git push origin --tags

# Create PR to main
```

### Automated Deployment

Once you push the tag to `main`, GitHub Actions will:
1. ✅ Run all tests
2. 🏗️ Build all packages  
3. 📦 Create GitHub release
4. 📝 Generate release notes automatically

## 📝 Release Individual Package

```bash
# From root
npm run release:package-a -- --dry-run
npm run release:package-a

# Or from package directory
cd packages/package-a
npm run release
```

## 🎨 Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Examples:
```bash
feat(package-a): add user authentication
fix(package-b): resolve memory leak in cache
docs: update installation guide
chore: upgrade dependencies
```

## 🔧 Useful Commands

```bash
# Test everything
npm test

# Build all packages
npm run build

# Dry run release (test without changes)
npm run release:dry

# Actual release
npm run release

# Release specific package
npm run release:package-a
npm run release:package-b
npm run release:package-c
```

## 🌳 Git Flow Summary

```
main ──────●────────●──────────●─────> (production)
            ╲        ╱          ╱
             ╲      ╱          ╱
develop ──────●────●──────────●──────> (integration)
               ╲  ╱
                ●╱
              feature/* (development)
```

## 📖 Full Documentation

See [README.md](./README.md) for complete documentation.

## ⚡ Common Tasks

### Start Working on Feature
```bash
git checkout develop
git pull origin develop
git checkout -b feature/my-feature
```

### Prepare Release
```bash
git checkout develop
git checkout -b release/v1.1.0
npm run release
```

### Emergency Hotfix
```bash
git checkout main
git checkout -b hotfix/v1.0.1
# fix issues
npm run release
git checkout main && git merge hotfix/v1.0.1
git checkout develop && git merge hotfix/v1.0.1
```

## 🎉 You're Ready!

Start building features and let the automation handle releases! 🚀
