# Pushing Tags to GitHub 🏷️

## The Issue

You've created local tags but they're not visible on GitHub. This happens when tags are created locally but haven't been pushed to the remote repository.

## Quick Fix

### Option 1: Use the Push Tags Script (Easiest)

```bash
./scripts/push-tags.sh
```

This script will:
- ✅ Check your remote configuration
- ✅ List all local tags
- ✅ Push all tags to GitHub
- ✅ Show you where to view them

### Option 2: Manual Push

```bash
# Push all tags
git push origin --tags

# Or push tags with a specific branch
git push origin main --follow-tags
```

### Option 3: Setup Remote First (If Not Configured)

If you haven't set up a GitHub remote yet:

```bash
./scripts/setup-github-remote.sh
```

This interactive script will:
1. Help you create a GitHub repository
2. Configure the remote (HTTPS or SSH)
3. Push all branches and tags
4. Show you where to view everything

## Why Tags Weren't Pushed

Tags are created locally by `release-it` but need to be explicitly pushed to GitHub. There are a few reasons why tags might not be on GitHub:

### 1. No Remote Configured Yet

**Check:**
```bash
git remote -v
```

**Fix:**
```bash
./scripts/setup-github-remote.sh
```

### 2. Released Without `--push` Flag

When you run release scripts without pushing:

```bash
# This creates tags locally but doesn't push
./scripts/quick-release.sh package-a minor

# Without --push flag, tags stay local
./scripts/release-package.sh package-a minor
```

**Fix:**
```bash
# Push tags now
git push origin --tags

# Or use the script
./scripts/push-tags.sh
```

### 3. Push Failed Due to Authentication

If you tried to push but got authentication errors:

**HTTPS users:**
- Need a Personal Access Token (PAT)
- Generate at: https://github.com/settings/tokens
- Use token as password when pushing

**SSH users:**
- Need SSH keys configured
- Test with: `ssh -T git@github.com`
- Setup guide: https://docs.github.com/en/authentication/connecting-to-github-with-ssh

## Ensuring Tags Are Always Pushed

### Use the `--push` Flag

Always use the `--push` or `-p` flag when releasing:

```bash
# Quick release with push
./scripts/quick-release.sh package-a minor --yes

# This automatically pushes main + tags + develop
```

Or with detailed release:

```bash
# Release with push
./scripts/release-package.sh package-a minor --push
```

### The Scripts Already Handle This

Both release scripts use `--follow-tags` when pushing:

```bash
git push origin main --follow-tags
```

This pushes:
- ✅ The main branch
- ✅ All tags reachable from main
- ✅ Triggers GitHub Actions

## Verifying Tags on GitHub

### Check Locally First

```bash
# List all local tags
git tag -l

# Show tag details
git show package-a@v1.1.0

# Check if tags are on remote
git ls-remote --tags origin
```

### Check on GitHub

Visit these URLs (replace USERNAME and REPO):

**Tags page:**
```
https://github.com/USERNAME/monorepository-example/tags
```

**Releases page:**
```
https://github.com/USERNAME/monorepository-example/releases
```

**Specific tag:**
```
https://github.com/USERNAME/monorepository-example/releases/tag/package-a@v1.1.0
```

## Complete Setup Example

### First Time Setup

```bash
# 1. Setup GitHub remote (one-time)
./scripts/setup-github-remote.sh

# Follow prompts:
# - Create repo on GitHub
# - Choose HTTPS or SSH
# - Enter username
# - Push everything

# 2. Verify on GitHub
# Visit: https://github.com/USERNAME/monorepository-example/tags

# 3. Done! All future releases will push automatically (with --push flag)
```

### If You Already Have Tags Locally

```bash
# 1. Check what tags you have
git tag -l

# 2. Push them to GitHub
./scripts/push-tags.sh

# 3. Verify on GitHub
# Visit: https://github.com/USERNAME/monorepository-example/tags
```

## Automation Best Practices

### Always Use `--yes` for Full Automation

```bash
# This handles everything automatically:
./scripts/quick-release.sh package-a minor --yes

# It will:
# 1. Create release branch
# 2. Bump version
# 3. Generate CHANGELOG
# 4. Create tag
# 5. Merge to main and develop
# 6. PUSH TO GITHUB (including tags) ✨
# 7. Trigger GitHub Actions
```

### For CI/CD

In GitHub Actions or other CI/CD:

```yaml
- name: Release
  run: |
    ./scripts/quick-release.sh package-a patch --yes
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

This ensures tags are always pushed.

## Troubleshooting

### "No tags found locally"

You haven't created any releases yet:

```bash
# Create a release first
./scripts/quick-release.sh package-a patch --yes
```

### "Failed to push tags"

**Check authentication:**

For HTTPS:
```bash
# Test with GitHub CLI
gh auth status

# Or re-authenticate
gh auth login
```

For SSH:
```bash
# Test SSH connection
ssh -T git@github.com

# Should see: "Hi USERNAME! You've successfully authenticated..."
```

### "Remote not configured"

Add the remote:

```bash
# Easy way (interactive)
./scripts/setup-github-remote.sh

# Or manually
git remote add origin https://github.com/USERNAME/monorepository-example.git
```

### "Everything rejected"

The remote repository might have commits you don't have locally:

```bash
# Fetch first
git fetch origin

# Check differences
git log origin/main..main

# If safe, force push (careful!)
git push origin main --force-with-lease

# Push tags
git push origin --tags
```

## Scripts Reference

### push-tags.sh

Push all local tags to GitHub:

```bash
./scripts/push-tags.sh
```

**Features:**
- Lists all local tags
- Confirms before pushing
- Shows where to view on GitHub
- Helpful error messages

### setup-github-remote.sh

Interactive remote setup:

```bash
./scripts/setup-github-remote.sh
```

**Features:**
- Detects existing remote
- Helps create GitHub repository
- Configures HTTPS or SSH
- Pushes everything (branches + tags)
- Shows GitHub URLs

### quick-release.sh with --yes

Fully automated release:

```bash
./scripts/quick-release.sh package-a minor --yes
```

**Pushes automatically:**
- ✅ Main branch
- ✅ All tags (with --follow-tags)
- ✅ Develop branch
- ✅ Triggers GitHub Actions

## Summary

### To Push Existing Tags

```bash
# Easiest
./scripts/push-tags.sh

# Or manually
git push origin --tags
```

### To Setup GitHub Remote

```bash
# Interactive setup
./scripts/setup-github-remote.sh
```

### For Future Releases

```bash
# Always use --yes for automatic pushing
./scripts/quick-release.sh package-a minor --yes

# This pushes everything including tags!
```

### Verify on GitHub

```bash
# Open in browser
./scripts/watch-actions.sh open

# Or visit directly
# https://github.com/USERNAME/monorepository-example/tags
```

---

**Remember:** Tags are created locally by release-it, but you must push them to GitHub to see them online! 🏷️✨

Use `./scripts/quick-release.sh <package> <bump> --yes` to automate everything! 🚀

