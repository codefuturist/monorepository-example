# GitHub Actions Monitoring 🔍

This document explains how to monitor your GitHub Actions workflows in real-time after releasing packages.

## 🎯 What's New

After pushing a release to GitHub, you can now **watch the workflow status in real-time** directly from your terminal!

## 🚀 Quick Start

### Automatic Watching (During Release)

When you release a package, the scripts will offer to watch the workflow:

```bash
./scripts/quick-release.sh package-a minor --yes

# After push completes:
✅ Pushed to GitHub!

🎯 Check GitHub Actions:
   https://github.com/username/repo/actions

🔍 Watch GitHub Actions workflow? [y/N]: y

# Live status updates appear in your terminal! 🎉
```

### Manual Watching (Anytime)

Watch workflows at any time using the dedicated script:

```bash
# Watch most recent workflow
./scripts/watch-actions.sh

# Or just:
./scripts/watch-actions.sh watch
```

## 📚 Complete Feature Set

### watch-actions.sh Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `watch` | `w` | Watch most recent workflow (live updates) |
| `list` | `ls` | List recent workflow runs |
| `view [id]` | `v` | View details of a workflow run |
| `logs [id]` | `log` | View logs of a workflow run |
| `status` | `s` | Show status summary |
| `open` | `o` | Open GitHub Actions in browser |
| `help` | `h` | Show help message |

### Usage Examples

```bash
# Watch live (default)
./scripts/watch-actions.sh
./scripts/watch-actions.sh watch

# List recent runs
./scripts/watch-actions.sh list

# View specific run
./scripts/watch-actions.sh view 1234567

# View logs
./scripts/watch-actions.sh logs

# Check status
./scripts/watch-actions.sh status

# Open in browser
./scripts/watch-actions.sh open
```

## 🛠️ Setup Requirements

### Install GitHub CLI

The workflow monitoring uses GitHub CLI (`gh`). Install it:

**macOS:**
```bash
brew install gh
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt install gh
```

**Other platforms:**
Visit [https://cli.github.com/](https://cli.github.com/)

### Authenticate

First time only:

```bash
gh auth login
```

Follow the prompts to authenticate with GitHub.

**Verification:**
```bash
gh auth status
```

## 🎨 What You See

### Live Workflow Watching

When you watch a workflow, you see real-time updates:

```
🔍 Watching workflow run #123456789

Release
  Started: 2 minutes ago
  Status:  in_progress

Jobs:
  ✓ build          completed (45s)
  ⋯ release        in_progress (1m 30s)
  - upload         pending

Refreshing every 3 seconds...
Press Ctrl+C to stop
```

### Workflow List

```bash
./scripts/watch-actions.sh list
```

Output:
```
STATUS  TITLE                   WORKFLOW  BRANCH    EVENT  ID         ELAPSED  AGE
✓       Release                 Release   main      push   123456789  2m 30s   5m
✓       CI                      CI        develop   push   123456788  1m 15s   10m
✗       Release                 Release   main      push   123456787  45s      1h
⋯       CI                      CI        feature   push   123456786  30s      2h
```

### Workflow Status

```bash
./scripts/watch-actions.sh status
```

Shows:
- ✓ Completed successfully
- ✗ Failed
- ⋯ In progress
- - Pending/Queued

## 🔄 Integration with Release Scripts

### quick-release.sh

Automatically offers to watch workflows after push:

```bash
./scripts/quick-release.sh package-a minor --yes

# After push:
✅ Pushed to GitHub!

🔍 Watch GitHub Actions workflow? [y/N]:
```

If you choose **yes**:
- Starts watching immediately
- Shows live updates
- You can stop with Ctrl+C

If you choose **no** or use `--yes` flag:
- Script completes
- Shows command to watch manually: `gh run watch`

### release-package.sh

Same workflow watching integration:

```bash
./scripts/release-package.sh package-a minor --push

# After push:
✅ Pushed to GitHub!

🔍 Watch GitHub Actions workflow? [y/N]:
```

## 💡 Pro Tips

### 1. Watch in Background

```bash
# Start release and watch later
./scripts/quick-release.sh package-a minor --yes

# In another terminal:
./scripts/watch-actions.sh watch
```

### 2. Check Status Without Watching

```bash
# Quick status check
./scripts/watch-actions.sh status

# No need to wait for completion
```

### 3. View Failed Workflow Logs

```bash
# List runs to find failed run ID
./scripts/watch-actions.sh list

# View logs of failed run
./scripts/watch-actions.sh logs 1234567
```

### 4. Open in Browser

```bash
# Quick browser view
./scripts/watch-actions.sh open

# Or use URL from release output
```

### 5. Native GitHub CLI Commands

You can also use `gh` directly:

```bash
# Watch
gh run watch

# List
gh run list

# View
gh run view

# Rerun failed workflow
gh run rerun <run-id>

# Cancel running workflow
gh run cancel <run-id>
```

## 🎯 Workflow Monitoring in Action

### Complete Release Example

```bash
# Start release
./scripts/quick-release.sh package-a minor --yes

# Output:
# ... release process ...
✅ Pushed to GitHub!

🎯 Check GitHub Actions:
   https://github.com/username/repo/actions

🔍 Watch GitHub Actions workflow? [y/N]: y

ℹ️  Watching GitHub Actions workflow...
💡 Tip: Press Ctrl+C to stop watching

# Live updates appear:
Release
  Started: just now
  Status:  in_progress
  
Jobs:
  ⋯ setup      in_progress (15s)
  - build      pending
  - release    pending

# ... updates continue ...

Jobs:
  ✓ setup      completed (45s)
  ⋯ build      in_progress (30s)
  - release    pending

# ... more updates ...

Jobs:
  ✓ setup      completed (45s)
  ✓ build      completed (1m 20s)
  ⋯ release    in_progress (40s)

# ... final result ...

✓ Workflow completed successfully!

Release
  Completed: 2 minutes ago
  Status:  success
  
All jobs completed successfully! 🎉
```

### Manual Monitoring

```bash
# After release completes, check anytime:

# Quick status
./scripts/watch-actions.sh status

# View details
./scripts/watch-actions.sh view

# Open in browser
./scripts/watch-actions.sh open
```

## 🐛 Troubleshooting

### "GitHub CLI not installed"

```bash
# macOS
brew install gh

# Ubuntu/Debian
sudo apt install gh

# Verify
gh --version
```

### "Not authenticated"

```bash
# Authenticate
gh auth login

# Follow prompts

# Verify
gh auth status
```

### "No workflows found"

Possible reasons:
1. **Workflow hasn't started yet**: Wait 10-30 seconds after push
2. **No remote configured**: Add remote with `git remote add origin <url>`
3. **Wrong repository**: Check with `git remote -v`

### "Permission denied"

```bash
# Re-authenticate with correct scopes
gh auth login --scopes repo,workflow
```

## 📊 Benefits

### Before (Manual)

```bash
# Push release
git push origin main --follow-tags

# Open browser
open https://github.com/username/repo/actions

# Refresh page manually... and again... and again...
# 😰 Did it succeed? Let me check again...
```

### After (Automated)

```bash
# Release with automatic watching
./scripts/quick-release.sh package-a minor --yes

# Press 'y' to watch
# ✨ Live updates in terminal!
# ✅ Know immediately when it succeeds!
```

**Benefits:**
- ✅ No manual browser refreshing
- ✅ Instant notifications
- ✅ Terminal-based workflow
- ✅ Know immediately when workflow completes
- ✅ See exactly which step is running
- ✅ Catch failures early

## 🎨 Complete Workflow

### Development → Release → Monitor

```bash
# 1. Develop feature
./scripts/start-feature.sh add-api
git commit -m "feat: add API"
./scripts/finish-feature.sh add-api --push

# 2. Release
./scripts/quick-release.sh package-a minor --yes

# 3. Watch deployment
# Script asks: Watch GitHub Actions workflow? [y/N]
# Press 'y'

# 4. See live updates
# ⋯ Release workflow running...
# ✓ Setup complete
# ⋯ Building...
# ✓ Build complete
# ⋯ Creating release...
# ✓ Release created!

# 5. Done! 🎉
✓ Workflow completed successfully!

# Total time: 2-3 minutes with instant feedback!
```

## 📚 Additional Resources

### GitHub CLI Documentation

- **Official docs**: [https://cli.github.com/manual/](https://cli.github.com/manual/)
- **Run commands**: [https://cli.github.com/manual/gh_run](https://cli.github.com/manual/gh_run)
- **Authentication**: [https://cli.github.com/manual/gh_auth](https://cli.github.com/manual/gh_auth)

### Related Scripts

- `quick-release.sh` - Automated release with optional watching
- `release-package.sh` - Detailed release with optional watching
- `push-to-github.sh` - Push to GitHub (could add watching here too)
- `watch-actions.sh` - Standalone workflow monitor

## 🌟 Summary

**What we added:**

✅ Real-time workflow monitoring in release scripts
✅ Standalone `watch-actions.sh` for anytime monitoring
✅ GitHub CLI integration
✅ Interactive watching prompts
✅ Complete command suite (watch, list, view, logs, status, open)
✅ Helpful error messages and setup instructions

**Result:**

- 🚀 Know immediately when release completes
- ⚡ No manual browser checking
- 🎯 Terminal-based workflow
- 😊 Better developer experience

**Try it now:**

```bash
# Install GitHub CLI
brew install gh

# Authenticate
gh auth login

# Try it!
./scripts/watch-actions.sh status
```

---

**Never wonder about your workflow status again!** 🎉

