# Contributing Guide

Thank you for contributing to this project! This guide will help you understand our workflow.

## 🌳 Git Flow Workflow

We use Git Flow for branch management:

### Branch Types

- **main** - Production releases only (protected)
- **develop** - Integration branch (protected)
- **feature/** - New features
- **release/** - Release preparation
- **hotfix/** - Emergency production fixes

## 📝 Development Workflow

### 1. Create Feature Branch

```bash
git checkout develop
git pull origin develop
git checkout -b feature/my-feature-name
```

### 2. Make Changes

Write code following the project conventions.

### 3. Commit with Conventional Commits

```bash
# Format: <type>(<scope>): <description>
git commit -m "feat(package-a): add user authentication"
git commit -m "fix(package-b): resolve cache issue"
git commit -m "docs: update README"
```

#### Commit Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Code style (formatting, etc.)
- `refactor` - Code refactoring
- `test` - Adding tests
- `chore` - Maintenance tasks
- `perf` - Performance improvements

### 4. Push and Create Pull Request

```bash
git push origin feature/my-feature-name
```

Create PR to `develop` branch on GitHub.

### 5. Code Review

Wait for review and approval from maintainers.

## 🚀 Release Process

### Creating a Release

1. **Prepare Release Branch**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b release/v1.1.0
   ```

2. **Run Release (Dry Run First)**
   ```bash
   npm run release:dry
   npm run release
   ```

3. **Push and Create PR**
   ```bash
   git push origin release/v1.1.0
   # Create PR to main
   ```

4. **After Merge**
   - Tag on main triggers GitHub Action
   - Merge main back to develop

### Hotfix Process

For urgent production fixes:

```bash
git checkout main
git pull origin main
git checkout -b hotfix/v1.0.1

# Make fixes
git commit -m "fix: critical security patch"

# Release
npm run release

# Merge to both main and develop
git checkout main
git merge hotfix/v1.0.1
git push origin main

git checkout develop
git merge hotfix/v1.0.1
git push origin develop
```

## ✅ Pull Request Guidelines

- Target `develop` branch (unless hotfix)
- Follow conventional commit format
- Update tests if needed
- Update documentation if needed
- Ensure CI passes
- Request review from maintainers

## 🧪 Testing

Run tests before submitting PR:

```bash
npm test
npm run build
npm run lint
```

## 📦 Package Changes

When modifying a specific package:

```bash
# Use scope in commits
git commit -m "feat(package-a): add new function"

# Test specific package
cd packages/package-a
npm test
```

## 🤝 Code Review Process

1. Maintainer reviews code
2. Automated tests must pass
3. At least 1 approval required
4. Changes requested must be addressed
5. Squash merge to keep history clean

## ❓ Questions?

Open an issue for any questions or discussions.

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.
