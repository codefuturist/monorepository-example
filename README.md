# Monorepo Example with Automated Releases

[![CI](https://github.com/codefuturist/monorepository-example/actions/workflows/ci.yml/badge.svg)](https://github.com/codefuturist/monorepository-example/actions/workflows/ci.yml)
[![Python CI](https://github.com/codefuturist/monorepository-example/actions/workflows/python-ci.yml/badge.svg)](https://github.com/codefuturist/monorepository-example/actions/workflows/python-ci.yml)
[![Release](https://github.com/codefuturist/monorepository-example/actions/workflows/release.yml/badge.svg)](https://github.com/codefuturist/monorepository-example/actions/workflows/release.yml)

**Package Releases:**

[![Python Release](https://github.com/codefuturist/monorepository-example/actions/workflows/python-release.yml/badge.svg)](https://github.com/codefuturist/monorepository-example/actions/workflows/python-release.yml)
[![C++ Package (D)](https://github.com/codefuturist/monorepository-example/actions/workflows/package-d-release.yml/badge.svg)](https://github.com/codefuturist/monorepository-example/actions/workflows/package-d-release.yml)
[![Rust Package (E)](https://github.com/codefuturist/monorepository-example/actions/workflows/package-e-release.yml/badge.svg)](https://github.com/codefuturist/monorepository-example/actions/workflows/package-e-release.yml)
[![Swift Package (F)](https://github.com/codefuturist/monorepository-example/actions/workflows/swift-release.yml/badge.svg)](https://github.com/codefuturist/monorepository-example/actions/workflows/swift-release.yml)
[![Go Package (G)](https://github.com/codefuturist/monorepository-example/actions/workflows/package-g-release.yml/badge.svg)](https://github.com/codefuturist/monorepository-example/actions/workflows/package-g-release.yml)
[![Java Package (H)](https://github.com/codefuturist/monorepository-example/actions/workflows/java-release.yml/badge.svg)](https://github.com/codefuturist/monorepository-example/actions/workflows/java-release.yml)
[![Rust Package (I)](https://github.com/codefuturist/monorepository-example/actions/workflows/package-i-release.yml/badge.svg)](https://github.com/codefuturist/monorepository-example/actions/workflows/package-i-release.yml)

Example monorepo demonstrating automated CD using `release-it`, GitHub Actions, and Git Flow.

> **🚀 NEW HERE?** Start with **[MONOREPO_RELEASE_GUIDE.md](./MONOREPO_RELEASE_GUIDE.md)** - The complete practical reference!
>
> **📚 DOCUMENTATION INDEX:** See **[INDEX.md](./INDEX.md)** for all available guides.

## 📦 Structure

```
monorepository-example/
├── packages/
│   ├── package-a/          # Core functionality
│   ├── package-b/          # Utilities
│   └── package-c/          # Helpers
├── .github/workflows/      # CI/CD workflows
└── .release-it.json        # Release configuration
```

## 🚀 Quick Start

### Install Dependencies

```bash
npm install
```

### Run Tests

```bash
npm test
```

### Build All Packages

```bash
npm run build
```

## 📋 Release Process (Git Flow)

### 1. Feature Development

```bash
# Create feature branch from develop
git checkout develop
git checkout -b feature/my-feature

# Make changes and commit using conventional commits
git commit -m "feat(package-a): add new feature"

# Push and create PR to develop
git push origin feature/my-feature
```

### 2. Start Release

```bash
# Create release branch from develop
git checkout develop
git pull origin develop
git checkout -b release/v1.1.0
```

### 3. Run release-it (Dry Run First)

```bash
# Test release process
npm run release:dry

# Actual release (creates commit, tag, and changelog)
npm run release
```

### 4. Merge to Main

```bash
# Push release branch
git push origin release/v1.1.0

# Create PR to main
# After approval and merge, the tag will trigger GitHub Actions
```

### 5. Tag Triggers GitHub Action

When you push a tag (e.g., `v1.1.0`), the GitHub Action automatically:

- ✅ Runs tests
- 🏗️ Builds packages
- 📦 Creates GitHub release
- 📝 Generates release notes

### 6. Merge Back to Develop

```bash
# After release is complete
git checkout develop
git merge main
git push origin develop
```

## 🔖 Release Individual Packages

```bash
# Navigate to package
cd packages/package-a

# Dry run
npm run release -- --dry-run

# Release with package-specific tag (e.g., package-a@v1.0.1)
npm run release

# Or from root
npm run release:package-a
```

## 🔄 Git Flow Branches

- `main` - Production releases only
- `develop` - Integration branch
- `feature/*` - Feature development
- `release/*` - Release preparation
- `hotfix/*` - Emergency fixes

## 📝 Conventional Commits

Use these prefixes for automatic changelog generation:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `chore:` - Maintenance
- `refactor:` - Code refactoring
- `test:` - Tests
- `perf:` - Performance improvement

**Examples:**

```bash
git commit -m "feat(package-a): add authentication"
git commit -m "fix(package-b): resolve memory leak"
git commit -m "chore: update dependencies"
```

## 🔐 GitHub Secrets (for npm publishing)

Add these secrets in GitHub repository settings:

- `NPM_TOKEN` - For publishing to npm (optional)

## 🛠️ Available Scripts

```bash
npm run release          # Release monorepo (root)
npm run release:dry      # Dry run release
npm run release:package-a # Release package-a
npm run release:package-b # Release package-b
npm run release:package-c # Release package-c
npm test                 # Run all tests
npm run build            # Build all packages
npm run lint             # Lint all packages
```

## 🎯 Versioning Strategy

This monorepo uses **independent versioning**:

- Root releases: `v1.0.0`
- Package releases: `package-a@v1.0.0`

Each package can be released independently with its own version.

## 📚 Resources

- [release-it Documentation](https://github.com/release-it/release-it)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [Semantic Versioning](https://semver.org/)

## 📄 License

MIT
