# 🚀 Monorepo Release Automation Guide

> **The Complete Reference for Release-it + Git Flow + GitHub Actions**

A production-ready automated CD process for managing independent package releases in a monorepo using release-it, git-flow CLI, and GitHub Actions.

---

## 📑 Table of Contents

1. [Quick Start](#-quick-start)
2. [System Architecture](#-system-architecture)
3. [Repository Structure](#-repository-structure)
4. [Git Flow Workflow](#-git-flow-workflow)
5. [Release-it Configuration](#️-release-it-configuration)
6. [GitHub Actions CD Pipeline](#-github-actions-cd-pipeline)
7. [Tag-Based Release Triggers](#-tag-based-release-triggers)
8. [Practical Workflows](#-practical-workflows)
9. [Automation Scripts](#-automation-scripts)
10. [Best Practices](#-best-practices)
11. [Troubleshooting](#-troubleshooting)

---

## ⚡ Quick Start

### Prerequisites

```bash
# Install Node.js dependencies
npm install

# Install git-flow CLI (choose your OS)
brew install git-flow-avh              # macOS
sudo apt-get install git-flow          # Ubuntu/Debian
choco install gitflow-avh              # Windows

# Initialize git-flow
git flow init -d
```

### Your First Release

```bash
# 1. Start a new feature
git flow feature start my-new-feature

# 2. Make changes using conventional commits
git commit -m "feat(package-a): add new feature"

# 3. Finish feature (merges to develop)
git flow feature finish my-new-feature

# 4. Start release process
git flow release start 1.1.0

# 5. Run release-it for a specific package
cd packages/package-a
npm run release -- --ci

# 6. Finish release (merges to main and develop, creates tag)
git flow release finish 1.1.0

# 7. Push everything (this triggers GitHub Action)
git push origin main develop --tags

# ✅ GitHub Action creates release automatically!
```

---

## 🏗️ System Architecture

### Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Developer Workflow                      │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                   Git Flow Branches                          │
│  feature/* → develop → release/* → main (tagged)            │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                    Git Tag Push                              │
│         package-a@v1.2.0 → origin/tags                      │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│              GitHub Actions Trigger                          │
│         (on: push: tags: 'package-*@v*')                    │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                CI/CD Pipeline                                │
│  1. Checkout  2. Test  3. Build  4. Create Release         │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│              GitHub Release Created                          │
│         (with auto-generated release notes)                  │
└─────────────────────────────────────────────────────────────┘
```

### Key Components

1. **Git Flow CLI**: Manages branch operations and merging
2. **Release-it**: Handles versioning, changelogs, and tagging
3. **Git Tags**: Triggers for automated CD pipeline
4. **GitHub Actions**: Executes CI/CD on tag push
5. **Conventional Commits**: Generates meaningful changelogs

---

## 📦 Repository Structure

```
monorepository-example/
│
├── packages/                         # Independent packages
│   ├── package-a/
│   │   ├── .release-it.json         # Package-specific config
│   │   ├── package.json             # Package metadata
│   │   ├── CHANGELOG.md             # Auto-generated
│   │   └── src/                     # Source code
│   ├── package-b/
│   │   ├── .release-it.json
│   │   ├── package.json
│   │   ├── CHANGELOG.md
│   │   └── src/
│   └── package-c/
│       ├── .release-it.json
│       ├── package.json
│       ├── CHANGELOG.md
│       └── src/
│
├── .github/
│   └── workflows/
│       ├── ci.yml                   # Run tests on PR
│       └── release.yml              # Create GitHub releases
│
├── scripts/                          # Automation helpers
│   ├── quick-release.sh             # One-command releases
│   ├── start-feature.sh             # Create features
│   ├── finish-feature.sh            # Complete features
│   ├── install-git-flow.sh          # Setup git-flow
│   └── init-git-flow.sh             # Initialize git-flow
│
├── .release-it.json                 # Root config (optional)
├── package.json                     # Workspace config
└── README.md                        # Main documentation
```

---

## 🔄 Git Flow Workflow

### Branch Structure

| Branch      | Purpose         | Lifetime  | Protected |
| ----------- | --------------- | --------- | --------- |
| `main`      | Production code | Permanent | ✅ Yes    |
| `develop`   | Integration     | Permanent | ✅ Yes    |
| `feature/*` | New features    | Temporary | ❌ No     |
| `release/*` | Release prep    | Temporary | ❌ No     |
| `hotfix/*`  | Emergency fixes | Temporary | ❌ No     |

### Development Cycle

```bash
# 1. Start new feature from develop
git flow feature start user-authentication

# Current branch: feature/user-authentication
# Base: develop

# 2. Develop with conventional commits
git commit -m "feat(package-a): add user login"
git commit -m "test(package-a): add login tests"
git commit -m "docs(package-a): update auth docs"

# 3. Finish feature (merges to develop with --no-ff)
git flow feature finish user-authentication

# Current branch: develop
# feature/user-authentication deleted
# Changes merged into develop

# 4. Push develop
git push origin develop
```

### Release Cycle

```bash
# 1. Create release branch from develop
git flow release start 1.2.0

# Current branch: release/1.2.0
# Base: develop

# 2. Run release-it for each package to release
cd packages/package-a
npm run release -- --ci --no-git.push

# This will:
# - Bump version in package.json
# - Generate CHANGELOG.md
# - Create git commit
# - Create git tag (package-a@v1.2.0)

# 3. Return to root
cd ../..

# 4. Finish release (merges to main and develop)
git flow release finish 1.2.0 -m "Release 1.2.0"

# Current branch: develop
# release/1.2.0 deleted
# Changes merged to main and develop
# Tag created on main

# 5. Push everything to trigger GitHub Actions
git push origin main develop --tags

# GitHub Action triggers on tag push
# Creates GitHub release automatically
```

### Hotfix Cycle

```bash
# 1. Create hotfix branch from main
git flow hotfix start 1.2.1

# Current branch: hotfix/1.2.1
# Base: main

# 2. Fix the bug
git commit -m "fix(package-a): resolve critical bug"

# 3. Run release-it
cd packages/package-a
npm run release -- patch --ci --no-git.push

# 4. Finish hotfix (merges to main and develop)
git flow hotfix finish 1.2.1 -m "Hotfix 1.2.1"

# 5. Push
git push origin main develop --tags
```

---

## ⚙️ Release-it Configuration

### Root Configuration (Optional)

**File: `.release-it.json`**

```json
{
  "git": {
    "requireCleanWorkingDir": true,
    "requireUpstream": true,
    "requireBranch": ["main", "develop", "release/*"],
    "commitMessage": "chore: release v${version}",
    "tagName": "v${version}",
    "tagAnnotation": "Release v${version}",
    "push": true
  },
  "github": {
    "release": false,
    "comments": {
      "submit": false,
      "issue": false
    }
  },
  "npm": {
    "publish": false
  },
  "plugins": {
    "@release-it/conventional-changelog": {
      "preset": "angular",
      "infile": "CHANGELOG.md",
      "header": "# Changelog",
      "writerOpts": {
        "commitsSort": ["scope", "subject"]
      }
    }
  }
}
```

### Package Configuration (Per Package)

**File: `packages/package-a/.release-it.json`**

```json
{
  "git": {
    "requireCleanWorkingDir": true,
    "requireBranch": ["main", "release/*"],
    "commitMessage": "chore(package-a): release v${version}",
    "tagName": "package-a@v${version}",
    "tagAnnotation": "Release package-a v${version}",
    "push": false
  },
  "github": {
    "release": false,
    "releaseName": "package-a v${version}",
    "autoGenerate": false
  },
  "npm": {
    "publish": false
  },
  "hooks": {
    "before:init": ["npm test --if-present"],
    "after:bump": ["npm run build --if-present"],
    "after:git:release": "echo 'Tagged as ${git.tagName}'"
  },
  "plugins": {
    "@release-it/conventional-changelog": {
      "preset": "angular",
      "infile": "CHANGELOG.md",
      "header": "# Changelog\n\nAll notable changes to package-a will be documented in this file.",
      "ignoreRecommendedBump": false,
      "strictSemVer": true,
      "context": {
        "packageName": "package-a"
      }
    }
  }
}
```

### Key Configuration Options

| Option                       | Purpose                     | Recommended Value         |
| ---------------------------- | --------------------------- | ------------------------- |
| `git.requireCleanWorkingDir` | No uncommitted changes      | `true`                    |
| `git.requireBranch`          | Only from specific branches | `["main", "release/*"]`   |
| `git.tagName`                | Tag pattern                 | `"package-a@v${version}"` |
| `git.push`                   | Push after tagging          | `false` (manual)          |
| `github.release`             | Create via release-it       | `false` (use Actions)     |
| `npm.publish`                | Publish to npm              | `false` (or configure)    |

---

## 🤖 GitHub Actions CD Pipeline

### Workflow Configuration

**File: `.github/workflows/release.yml`**

```yaml
name: Release

# Trigger on tag pushes matching package patterns
on:
  push:
    tags:
      - "package-a@v*.*.*"
      - "package-b@v*.*.*"
      - "package-c@v*.*.*"
      - "v*.*.*" # Optional: root releases

permissions:
  contents: write # Create releases
  pull-requests: write # Comment on PRs (optional)
  issues: write # Close issues (optional)

jobs:
  release:
    name: Create GitHub Release
    runs-on: ubuntu-latest

    steps:
      # 1. Checkout code
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0 # Full history for changelogs

      # 2. Setup Node.js
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      # 3. Install dependencies
      - name: Install dependencies
        run: npm ci

      # 4. Run tests
      - name: Run tests
        run: npm test

      # 5. Build packages
      - name: Build packages
        run: npm run build

      # 6. Extract tag information
      - name: Extract tag info
        id: tag_info
        run: |
          TAG=${GITHUB_REF#refs/tags/}
          echo "tag=$TAG" >> $GITHUB_OUTPUT

          if [[ $TAG == *@v* ]]; then
            # Package-specific tag (e.g., package-a@v1.2.0)
            PACKAGE_NAME=$(echo $TAG | cut -d'@' -f1)
            VERSION=$(echo $TAG | cut -d'@' -f2)
            echo "package=$PACKAGE_NAME" >> $GITHUB_OUTPUT
            echo "version=$VERSION" >> $GITHUB_OUTPUT
            echo "is_package=true" >> $GITHUB_OUTPUT
            echo "release_name=$PACKAGE_NAME $VERSION" >> $GITHUB_OUTPUT
          else
            # Root tag (e.g., v1.0.0)
            echo "version=$TAG" >> $GITHUB_OUTPUT
            echo "is_package=false" >> $GITHUB_OUTPUT
            echo "release_name=Release $TAG" >> $GITHUB_OUTPUT
          fi

      # 7. Get changelog content
      - name: Get changelog
        id: changelog
        run: |
          TAG=${{ steps.tag_info.outputs.tag }}
          if [[ "${{ steps.tag_info.outputs.is_package }}" == "true" ]]; then
            PACKAGE=${{ steps.tag_info.outputs.package }}
            CHANGELOG_PATH="packages/$PACKAGE/CHANGELOG.md"
          else
            CHANGELOG_PATH="CHANGELOG.md"
          fi

          if [ -f "$CHANGELOG_PATH" ]; then
            # Extract latest version section from CHANGELOG
            CHANGELOG_CONTENT=$(sed -n "/^## \[/,/^## \[/p" "$CHANGELOG_PATH" | sed '$d' | tail -n +2)
            echo "content<<EOF" >> $GITHUB_OUTPUT
            echo "$CHANGELOG_CONTENT" >> $GITHUB_OUTPUT
            echo "EOF" >> $GITHUB_OUTPUT
          else
            echo "content=See commits for details." >> $GITHUB_OUTPUT
          fi

      # 8. Create GitHub Release
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          tag_name: ${{ steps.tag_info.outputs.tag }}
          name: ${{ steps.tag_info.outputs.release_name }}
          body: ${{ steps.changelog.outputs.content }}
          draft: false
          prerelease: false
          generate_release_notes: true # Auto-generate from commits
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      # 9. Optional: Publish to npm
      - name: Publish to npm
        if: steps.tag_info.outputs.is_package == 'true'
        run: |
          PACKAGE=${{ steps.tag_info.outputs.package }}
          echo "Would publish $PACKAGE to npm"
          # Uncomment when ready:
          # echo "//registry.npmjs.org/:_authToken=${{ secrets.NPM_TOKEN }}" > .npmrc
          # npm publish --workspace=packages/$PACKAGE
        continue-on-error: true
```

### CI Workflow (Optional)

**File: `.github/workflows/ci.yml`**

```yaml
name: CI

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"
      - run: npm ci
      - run: npm test
      - run: npm run build
```

---

## 🏷️ Tag-Based Release Triggers

### Tag Naming Convention

| Tag Pattern        | Triggers          | Example            | Use Case                            |
| ------------------ | ----------------- | ------------------ | ----------------------------------- |
| `package-a@v*.*.*` | Package A release | `package-a@v1.2.3` | Independent package release         |
| `package-b@v*.*.*` | Package B release | `package-b@v2.0.0` | Independent package release         |
| `package-c@v*.*.*` | Package C release | `package-c@v1.1.0` | Independent package release         |
| `v*.*.*`           | Monorepo release  | `v1.0.0`           | Coordinated release of all packages |

### How Tags Trigger Actions

```bash
# When you push a tag:
git push origin package-a@v1.2.0

# GitHub detects tag push → Matches pattern in workflow
on:
  push:
    tags:
      - 'package-a@v*.*.*'

# → Workflow runs → Creates release
```

### Manual Tag Creation (Not Recommended)

```bash
# Create tag manually
git tag -a package-a@v1.2.0 -m "Release package-a v1.2.0"

# Push tag
git push origin package-a@v1.2.0

# GitHub Action triggers
```

### Listing Tags

```bash
# Show all tags
git tag -l

# Show tags for specific package
git tag -l "package-a@*"

# Show tag with annotation
git show package-a@v1.2.0

# Delete tag (local and remote)
git tag -d package-a@v1.2.0
git push origin :refs/tags/package-a@v1.2.0
```

---

## 🎯 Practical Workflows

### Scenario 1: Single Package Feature Release

**Goal**: Release a new feature for package-a

```bash
# 1. Start feature
git flow feature start add-caching

# 2. Develop (in packages/package-a)
cd packages/package-a/src
# ... make changes ...
git commit -m "feat(package-a): add response caching"
git commit -m "test(package-a): add caching tests"
cd ../../..

# 3. Finish feature
git flow feature finish add-caching
git push origin develop

# 4. Start release
git flow release start 1.3.0

# 5. Bump package-a version
cd packages/package-a
npm run release -- minor --ci --no-git.push
cd ../..

# 6. Finish release
git flow release finish 1.3.0 -m "Release 1.3.0"

# 7. Push (triggers CD)
git push origin main develop --tags

# ✅ GitHub creates release for package-a@v1.3.0
```

### Scenario 2: Multi-Package Release

**Goal**: Release changes across multiple packages

```bash
# Features already merged to develop...

# 1. Start release
git flow release start 2.0.0

# 2. Bump package-a
cd packages/package-a
npm run release -- major --ci --no-git.push
cd ../..

# 3. Bump package-b
cd packages/package-b
npm run release -- minor --ci --no-git.push
cd ../..

# 4. Bump package-c
cd packages/package-c
npm run release -- patch --ci --no-git.push
cd ../..

# 5. Finish release
git flow release finish 2.0.0 -m "Release 2.0.0"

# 6. Push all tags
git push origin main develop --tags

# ✅ Three separate GitHub releases created:
#    - package-a@v2.0.0
#    - package-b@v1.5.0
#    - package-c@v1.2.1
```

### Scenario 3: Hotfix for Production

**Goal**: Fix critical bug in package-b

```bash
# 1. Start hotfix from main
git flow hotfix start fix-critical-bug

# 2. Fix the bug
cd packages/package-b/src
# ... fix bug ...
git commit -m "fix(package-b): resolve memory leak"
cd ../../..

# 3. Bump version
cd packages/package-b
npm run release -- patch --ci --no-git.push
cd ../..

# 4. Finish hotfix
git flow hotfix finish fix-critical-bug -m "Hotfix: memory leak"

# 5. Push
git push origin main develop --tags

# ✅ Hotfix deployed via GitHub Action
```

### Scenario 4: Coordinated Monorepo Release

**Goal**: Release all packages together with same version

```bash
# 1. Start release
git flow release start 3.0.0

# 2. Update root version
npm version 3.0.0 --no-git-tag-version

# 3. Update all packages to same version
for pkg in packages/*; do
  cd $pkg
  npm version 3.0.0 --no-git-tag-version
  cd ../..
done

# 4. Create unified changelog
git commit -am "chore: release v3.0.0"
git tag -a v3.0.0 -m "Release v3.0.0"

# 5. Finish release
git flow release finish 3.0.0 -m "Release v3.0.0"

# 6. Push
git push origin main develop --tags

# ✅ Single monorepo release created
```

---

## 🛠️ Automation Scripts

### Quick Release Script

**File: `scripts/quick-release.sh`**

```bash
#!/bin/bash
set -e

PACKAGE=$1
BUMP=$2
AUTO=${3:-""}

if [ -z "$PACKAGE" ] || [ -z "$BUMP" ]; then
  echo "Usage: $0 <package> <bump> [--yes]"
  echo "Example: $0 package-a minor --yes"
  exit 1
fi

echo "🚀 Quick Release: $PACKAGE ($BUMP)"

# Get current version
CURRENT=$(node -p "require('./packages/$PACKAGE/package.json').version")
echo "Current version: $CURRENT"

# Start release branch
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RELEASE_BRANCH="release/$PACKAGE-$TIMESTAMP"
git flow release start $RELEASE_BRANCH

# Run release-it
cd packages/$PACKAGE
if [ "$AUTO" = "--yes" ]; then
  npm run release -- $BUMP --ci --no-git.push
else
  npm run release -- $BUMP --no-git.push
fi
cd ../..

# Get new version
NEW=$(node -p "require('./packages/$PACKAGE/package.json').version")
echo "New version: $NEW"

# Finish release
git flow release finish $RELEASE_BRANCH -m "Release $PACKAGE $NEW"

# Push
echo "Pushing to remote..."
git push origin main develop --tags

echo "✅ Release complete! Check GitHub Actions for deployment."
```

### Start Feature Script

**File: `scripts/start-feature.sh`**

```bash
#!/bin/bash
set -e

FEATURE_NAME=$1

if [ -z "$FEATURE_NAME" ]; then
  echo "Usage: $0 <feature-name>"
  echo "Example: $0 add-user-auth"
  exit 1
fi

echo "🎯 Starting feature: $FEATURE_NAME"
git flow feature start $FEATURE_NAME
echo "✅ Created branch: feature/$FEATURE_NAME"
echo "💡 Make changes and commit using conventional commits"
```

### Finish Feature Script

**File: `scripts/finish-feature.sh`**

```bash
#!/bin/bash
set -e

FEATURE_NAME=$1
PUSH=${2:-""}

if [ -z "$FEATURE_NAME" ]; then
  echo "Usage: $0 <feature-name> [--push]"
  exit 1
fi

echo "🏁 Finishing feature: $FEATURE_NAME"
git flow feature finish $FEATURE_NAME

if [ "$PUSH" = "--push" ]; then
  echo "📤 Pushing to remote..."
  git push origin develop
fi

echo "✅ Feature merged to develop"
```

---

## 📋 Best Practices

### 1. Conventional Commits

Use structured commit messages for automatic changelog generation:

```bash
# Features
git commit -m "feat(package-a): add user authentication"

# Bug fixes
git commit -m "fix(package-b): resolve validation error"

# Breaking changes
git commit -m "feat(package-a)!: redesign API interface

BREAKING CHANGE: API endpoints have changed"

# Other types
git commit -m "docs(package-a): update README"
git commit -m "test(package-b): add integration tests"
git commit -m "chore: update dependencies"
git commit -m "refactor(package-c): simplify logic"
git commit -m "perf(package-a): optimize query performance"
```

### 2. Version Bump Guidelines

| Bump    | When                               | Example       |
| ------- | ---------------------------------- | ------------- |
| `patch` | Bug fixes, minor changes           | 1.0.0 → 1.0.1 |
| `minor` | New features (backward compatible) | 1.0.1 → 1.1.0 |
| `major` | Breaking changes                   | 1.1.0 → 2.0.0 |

### 3. Branch Protection Rules

Configure on GitHub:

**For `main` branch:**

- ✅ Require pull request reviews
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ✅ Require conversation resolution
- ❌ Allow force pushes (never!)
- ❌ Allow deletions (never!)

**For `develop` branch:**

- ✅ Require pull request reviews
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ❌ Allow force pushes (never!)

### 4. Release Checklist

Before running release-it:

- [ ] All tests pass (`npm test`)
- [ ] Code builds successfully (`npm run build`)
- [ ] Commits follow conventional format
- [ ] CHANGELOG reviewed (will be auto-generated)
- [ ] Version bump is correct (patch/minor/major)
- [ ] On correct branch (`release/*` or `main`)
- [ ] Working directory is clean (`git status`)

### 5. Secrets Management

**Required GitHub Secrets:**

```bash
# For GitHub releases (automatic)
GITHUB_TOKEN  # Provided by default

# For npm publishing (if enabled)
NPM_TOKEN     # Create at npmjs.com
```

**Set secrets:**

1. Go to GitHub repo → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add `NPM_TOKEN` if publishing to npm

### 6. Monorepo Best Practices

- **Independent Versioning**: Each package has own version
- **Selective Releases**: Release only changed packages
- **Consistent Commits**: Use conventional commits everywhere
- **Automated Tests**: Test all packages on every PR
- **Shared Dependencies**: Use workspace references
- **Documentation**: Keep each package's README updated

---

## ⚠️ Troubleshooting

### Issue: "Not on required branch"

**Error:**

```
ERROR Release-it requires branch "main" or "release/*"
```

**Solution:**

```bash
# Check current branch
git branch

# Switch to correct branch
git checkout main
# or
git flow release start my-release
```

### Issue: "Working directory not clean"

**Error:**

```
ERROR Working directory is not clean
```

**Solution:**

```bash
# Check status
git status

# Commit or stash changes
git add .
git commit -m "chore: prepare for release"
# or
git stash
```

### Issue: Tag already exists

**Error:**

```
ERROR Tag package-a@v1.2.0 already exists
```

**Solution:**

```bash
# Delete tag locally
git tag -d package-a@v1.2.0

# Delete tag remotely
git push origin :refs/tags/package-a@v1.2.0

# Re-run release-it
npm run release
```

### Issue: GitHub Action not triggering

**Checklist:**

1. ✅ Tag pushed to remote? (`git push --tags`)
2. ✅ Tag pattern matches workflow? (`package-a@v*.*.*`)
3. ✅ Workflow file exists? (`.github/workflows/release.yml`)
4. ✅ Actions enabled? (Repo Settings → Actions)
5. ✅ Recent commits? (Actions tab → Check runs)

**Debug:**

```bash
# Verify tag pushed
git ls-remote --tags origin

# Check workflow syntax
cat .github/workflows/release.yml

# Re-push tag
git push origin package-a@v1.2.0 --force
```

### Issue: Release-it fails to bump version

**Error:**

```
ERROR Cannot bump package.json version
```

**Solution:**

```bash
# Ensure package.json has version field
cd packages/package-a
cat package.json | grep version

# Fix if missing
npm init -y

# Or manually add:
# "version": "1.0.0"
```

### Issue: Changelog not generating

**Problem:** CHANGELOG.md empty or not updating

**Solution:**

```bash
# 1. Check conventional commits exist
git log --oneline --grep="^feat\|^fix"

# 2. Verify plugin installed
npm list @release-it/conventional-changelog

# 3. Install if missing
npm install -D @release-it/conventional-changelog

# 4. Check .release-it.json has plugin config
cat .release-it.json | grep conventional-changelog
```

### Issue: Git Flow not installed

**Error:**

```
git: 'flow' is not a git command
```

**Solution:**

```bash
# macOS
brew install git-flow-avh

# Ubuntu/Debian
sudo apt-get install git-flow

# Windows
choco install gitflow-avh

# Verify
git flow version
```

---

## 📚 Additional Resources

### Official Documentation

- [Release-it Documentation](https://github.com/release-it/release-it)
- [Git Flow Cheatsheet](https://danielkummer.github.io/git-flow-cheatsheet/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)

### Related Files in This Repo

- [`README.md`](./README.md) - Main project documentation
- [`CONTRIBUTING.md`](./CONTRIBUTING.md) - Contribution guidelines
- [`package.json`](./package.json) - Workspace configuration
- [`.github/workflows/release.yml`](./.github/workflows/release.yml) - Release workflow
- [`packages/package-a/.release-it.json`](./packages/package-a/.release-it.json) - Example config

### Quick Reference Commands

```bash
# Git Flow
git flow init -d                              # Initialize
git flow feature start <name>                 # Start feature
git flow feature finish <name>                # Finish feature
git flow release start <version>              # Start release
git flow release finish <version>             # Finish release
git flow hotfix start <version>               # Start hotfix
git flow hotfix finish <version>              # Finish hotfix

# Release-it
npm run release                               # Interactive
npm run release -- minor --ci                 # Automated minor bump
npm run release -- --dry-run                  # Test without changes
npm run release -- --no-git.push              # Don't push

# Git Tags
git tag -l                                    # List all tags
git tag -l "package-a@*"                      # List package tags
git push --tags                               # Push all tags
git push origin package-a@v1.2.0              # Push specific tag

# Workspace
npm test                                      # Test all packages
npm run build                                 # Build all packages
npm test --workspace=packages/package-a       # Test one package
```

---

## ✅ Summary

This guide provides a complete, production-ready setup for:

1. **Automated CD Pipeline**: GitHub Actions creates releases on tag push
2. **Git Flow Integration**: Structured branching with git-flow CLI
3. **Independent Versioning**: Each package releases independently
4. **Conventional Commits**: Auto-generated changelogs
5. **Tag-Based Triggers**: Push tags to deploy
6. **Zero-Config Publishing**: Optional npm publishing
7. **Best Practices**: Industry-standard workflows

**Next Steps:**

1. Review configuration files in your repo
2. Run a test release with `--dry-run`
3. Create your first feature with git flow
4. Release a package and watch GitHub Action run
5. Share this guide with your team

---

**Happy Releasing! 🚀**

_Last updated: October 2025_
