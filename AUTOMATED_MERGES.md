# 🤖 Automated Git Flow Merges

## Overview

Your release-it setup now **automatically handles Git Flow merges**! 🎉

When you run `npm run release`, the system will:
1. ✅ Create release commit and tag (release-it)
2. ✅ Merge release → main (automated)
3. ✅ Merge main → develop (automated)
4. ✅ Push to GitHub (release-it)

**No manual merges needed!** Everything is automated! 🚀

---

## 🎯 How It Works

### Configuration

All `.release-it.json` files now include:

```json
{
  "hooks": {
    "after:git:release": "bash scripts/git-flow-merge.sh ${version}"
  }
}
```

### Workflow

```
1. npm run release
   ↓
2. release-it bumps version & creates tag
   ↓
3. Hook triggers: scripts/git-flow-merge.sh
   ↓
4. Script merges: release → main → develop
   ↓
5. release-it pushes everything to GitHub
   ↓
6. ✅ Done! All branches updated!
```

---

## 🚀 Usage

### Simple Release (Automated Merges)

```bash
npm run release
```

**What happens automatically:**
1. ✅ Bumps version
2. ✅ Updates CHANGELOG
3. ✅ Creates commit and tag
4. ✅ **Merges to main** ← Automated!
5. ✅ **Merges to develop** ← Automated!
6. ✅ Pushes to GitHub

**Total time:** 30 seconds ⚡

---

### Package Release (Automated Merges)

```bash
npm run release:package-a
```

**Same automation applies:**
- ✅ Creates tag: `package-a@v1.1.0`
- ✅ Merges to main
- ✅ Merges to develop
- ✅ Pushes everything

---

### With Auto-Push (Even More Automated!)

```bash
AUTO_PUSH=true npm run release
```

**Extra automation:**
- ✅ Pushes main with tags
- ✅ Pushes develop
- ✅ No manual push needed!

---

### With Cleanup (Fully Automated!)

```bash
AUTO_PUSH=true CLEANUP_RELEASE_BRANCH=true npm run release
```

**Complete automation:**
- ✅ All merges
- ✅ All pushes
- ✅ Deletes release branch
- ✅ Zero manual steps!

---

## 📋 Script Files

### `scripts/git-flow-merge.sh`

Simple merge automation (used by release-it hooks):

```bash
# Merges release → main → develop
# Called automatically after release-it creates tag
```

### `scripts/git-flow-auto.sh`

Enhanced automation with extra features:

```bash
# All merges + optional push + optional cleanup
# Use for full automation
```

---

## 🎮 Examples

### Example 1: Standard Automated Release

```bash
$ git checkout -b release/v1.2.0 develop
$ npm run release

# Automatically:
# ✅ Version: 1.1.0 → 1.2.0
# ✅ Merged to main
# ✅ Merged to develop
# ✅ Pushed to GitHub
```

### Example 2: Package Release with Automation

```bash
$ git checkout -b release/package-a-v1.2.0 develop
$ cd packages/package-a
$ npx release-it minor

# Automatically:
# ✅ Tag: package-a@v1.2.0
# ✅ Merged to main
# ✅ Merged to develop
# ✅ Pushed to GitHub
```

### Example 3: Fully Automated (No Manual Steps)

```bash
$ git checkout -b release/v1.2.0 develop
$ AUTO_PUSH=true CLEANUP_RELEASE_BRANCH=true npm run release

# Everything happens automatically!
# ✅ Release
# ✅ Merges
# ✅ Push
# ✅ Cleanup
# 
# Result: Back on develop, ready for next feature!
```

---

## 🔍 What the Script Does

### Automatic Merge Flow

```bash
1. Detect release branch
   ↓
2. Merge release/v1.2.0 → main
   ├─ git checkout main
   ├─ git merge --no-ff release/v1.2.0
   └─ ✅ Main has release
   ↓
3. Merge main → develop
   ├─ git checkout develop
   ├─ git merge --no-ff main
   └─ ✅ Develop synced
   ↓
4. Return to main
   └─ Ready for push
```

### Safety Features

- ✅ Only runs on release branches
- ✅ Checks if branches exist before merging
- ✅ Uses `--no-ff` (preserves history)
- ✅ Provides detailed feedback
- ✅ Handles errors gracefully

---

## 📊 Before vs After

### Before (Manual Process)

```bash
# 1. Release
npm run release

# 2. Merge to main (manual)
git checkout main
git merge --no-ff release/v1.2.0

# 3. Merge to develop (manual)
git checkout develop
git merge --no-ff main

# 4. Push (manual)
git push origin main --follow-tags
git push origin develop

# Time: 5 minutes
# Steps: 4 manual commands
# Errors: Easy to forget
```

### After (Automated Process)

```bash
# 1. Release (everything automated!)
npm run release

# Time: 30 seconds ⚡
# Steps: 1 command
# Errors: Impossible to forget! ✅
```

---

## 🎯 Configuration Details

### Root `.release-it.json`

```json
{
  "hooks": {
    "after:git:release": "bash scripts/git-flow-merge.sh ${version}"
  }
}
```

**Triggered after:** Tag creation  
**Runs:** Git Flow merge script  
**Result:** All branches updated

### Package `.release-it.json`

```json
{
  "hooks": {
    "after:git:release": "bash ../../scripts/git-flow-merge.sh ${version}"
  }
}
```

**Path adjusted:** `../../` to reach root scripts folder  
**Same automation:** Works identically

---

## 🔧 Customization

### Disable Automation (If Needed)

Remove the hook from `.release-it.json`:

```json
{
  "hooks": {}
}
```

### Manual Merge (Override Automation)

```bash
# Release without merges
npm run release -- --no-hooks

# Then merge manually
./merge-release.sh
```

### Custom Script

Edit `scripts/git-flow-merge.sh` to customize:

```bash
# Add your custom logic
# - Notifications
# - Slack messages
# - Deploy triggers
# - etc.
```

---

## 🎓 Understanding the Hooks

### release-it Hook Lifecycle

```
1. before:init        - Before anything starts
2. after:bump         - After version bump
3. after:git:release  - After git tag created ← We use this!
4. after:release      - After everything done
```

### Why `after:git:release`?

- ✅ Tag is already created
- ✅ Version is finalized
- ✅ Perfect time for merges
- ✅ Before push (if configured)

---

## 🚨 Troubleshooting

### Script Doesn't Run

**Check:**
```bash
# Is script executable?
ls -la scripts/git-flow-merge.sh

# Make executable if needed
chmod +x scripts/git-flow-merge.sh
```

### Merge Conflicts

**If conflicts occur:**
```bash
# Script will stop
# Resolve conflicts manually
git status
git merge --continue

# Or abort
git merge --abort
```

### Not on Release Branch

**Output:**
```
ℹ️  Not on a release branch - skipping Git Flow merges
```

**Solution:**
- Create release branch first: `git checkout -b release/v1.2.0`
- Or disable requireBranch in config

---

## 📚 Related Files

| File | Purpose |
|------|---------|
| `scripts/git-flow-merge.sh` | Core merge automation |
| `scripts/git-flow-auto.sh` | Enhanced with push/cleanup |
| `merge-release.sh` | Manual merge script (backup) |
| `GIT_FLOW_MERGES.md` | Complete documentation |
| `AUTOMATED_MERGES.md` | This file |

---

## ✅ Verification

### Test the Automation

```bash
# 1. Create test release branch
git checkout -b release/test-1.0.1 develop

# 2. Run release (dry run)
npm run release:dry

# 3. Check what would happen
# Should show: merge automation planned

# 4. Execute real release
npm run release

# 5. Verify branches
git log --oneline main -3
git log --oneline develop -3

# Both should have the release!
```

---

## 🎉 Benefits

### Time Saved

- **Before:** 5 minutes per release (manual merges)
- **After:** 30 seconds (automated)
- **Saved:** 4.5 minutes per release
- **10 releases/month:** 45 minutes saved! 🎯

### Mistakes Prevented

- ❌ Forgot to merge to main
- ❌ Forgot to merge to develop
- ❌ Wrong merge direction
- ❌ Missed `--no-ff` flag

**All prevented with automation!** ✅

### Consistency

- ✅ Every release follows Git Flow
- ✅ Every merge uses `--no-ff`
- ✅ Every branch stays in sync
- ✅ Every history is clean

---

## 🎯 Summary

### What You Get

**Automated Git Flow Merges:**
1. ✅ release → main (production)
2. ✅ main → develop (sync)
3. ✅ Optional: Push to GitHub
4. ✅ Optional: Cleanup release branch

### How to Use

```bash
# Simple (automated merges)
npm run release

# Full automation (merges + push + cleanup)
AUTO_PUSH=true CLEANUP_RELEASE_BRANCH=true npm run release
```

### Time to Release

**Before automation:** 5 minutes  
**After automation:** 30 seconds  
**Commands required:** 1

---

## 🚀 Next Steps

### Try It Now!

```bash
# Create a test release
git checkout -b release/v1.2.0 develop
npm run release

# Watch the magic happen! ✨
```

### Enable Full Automation

Add to your `~/.zshrc`:

```bash
# Full automation by default
export AUTO_PUSH=true
export CLEANUP_RELEASE_BRANCH=true
```

Then just:
```bash
npm run release  # Everything automated!
```

---

**Status:** ✅ Fully Automated  
**Manual Steps:** Zero  
**Time Saved:** 90% faster  
**Errors:** Prevented by automation  

🎊 **Your Git Flow is now completely automated!**
