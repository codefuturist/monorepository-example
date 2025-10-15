# 🏷️ Tag Naming Convention in Your Setup

## Overview

Your release-it configuration uses **different tag naming conventions** for root releases vs package-specific releases.

---

## 🎯 Root Level Releases

### Configuration
```json
{
  "git": {
    "tagName": "v${version}"
  }
}
```

### Tag Names Created

| Current Version | Release Type | New Version | Tag Name |
|----------------|--------------|-------------|----------|
| `1.0.0` | Minor | `1.1.0` | **`v1.1.0`** |
| `1.1.0` | Minor | `1.2.0` | **`v1.2.0`** |
| `1.2.0` | Major | `2.0.0` | **`v2.0.0`** |
| `2.0.0` | Patch | `2.0.1` | **`v2.0.1`** |
| `1.0.0` | Pre-release (beta) | `1.1.0-beta.0` | **`v1.1.0-beta.0`** |

### Command
```bash
npm run release
# or
cd /path/to/root && npx release-it
```

### Git Tags
```bash
$ git tag
v1.0.0
v1.1.0  ← Root release
v1.2.0
v2.0.0
```

---

## 📦 Package-Specific Releases

### Configuration
```json
{
  "git": {
    "tagName": "package-a@v${version}"
  }
}
```

### Tag Names Created

| Package | Current Version | New Version | Tag Name |
|---------|----------------|-------------|----------|
| `package-a` | `1.0.0` | `1.0.1` | **`package-a@v1.0.1`** |
| `package-b` | `1.0.0` | `1.1.0` | **`package-b@v1.1.0`** |
| `package-c` | `1.0.0` | `2.0.0` | **`package-c@v2.0.0`** |
| `package-a` | `1.0.1` | `1.0.2` | **`package-a@v1.0.2`** |
| `package-b` | `1.1.0` | `1.2.0-rc.0` | **`package-b@v1.2.0-rc.0`** |

### Commands
```bash
# Package A
npm run release:package-a
# or
cd packages/package-a && npx release-it

# Package B
npm run release:package-b
# or
cd packages/package-b && npx release-it

# Package C
npm run release:package-c
# or
cd packages/package-c && npx release-it
```

### Git Tags
```bash
$ git tag
v1.0.0                    ← Root release
v1.1.0                    ← Root release
package-a@v1.0.1          ← Package A release
package-a@v1.0.2          ← Package A release
package-b@v1.1.0          ← Package B release
package-c@v2.0.0          ← Package C release
```

---

## 🎨 Complete Example

### Scenario: You release everything

```bash
# 1. Release root monorepo
npm run release
# Creates: v1.1.0

# 2. Release package-a
npm run release:package-a
# Creates: package-a@v1.0.1

# 3. Release package-b
npm run release:package-b
# Creates: package-b@v1.1.0

# 4. Release package-c
npm run release:package-c
# Creates: package-c@v2.0.0
```

### Resulting Git Tags
```bash
$ git tag --sort=-version:refname
package-c@v2.0.0
package-b@v1.1.0
package-a@v1.0.1
v1.1.0
v1.0.0
```

### GitHub Releases Page
```
Your Releases:

📦 package-c@v2.0.0          (Latest)
   Release package-c v2.0.0
   
📦 package-b@v1.1.0
   Release package-b v1.1.0
   
📦 package-a@v1.0.1
   Release package-a v1.0.1
   
🏷️  v1.1.0
   Release v1.1.0
   
🏷️  v1.0.0
   Release v1.0.0
```

---

## 🔍 Tag Format Breakdown

### Root Tags: `v${version}`

**Format:** `v` + semantic version

**Examples:**
- `v1.0.0` - Major version 1
- `v1.1.0` - Minor update
- `v1.1.1` - Patch update
- `v2.0.0-beta.0` - Pre-release
- `v2.0.0-rc.1` - Release candidate

**Pattern:** Simple version with `v` prefix

---

### Package Tags: `package-name@v${version}`

**Format:** `package-name` + `@v` + semantic version

**Examples:**
- `package-a@v1.0.0` - Package A version 1.0.0
- `package-b@v1.2.3` - Package B version 1.2.3
- `package-c@v2.0.0-beta.0` - Package C pre-release

**Pattern:** npm-style scoped versioning

**Why this format?**
- ✅ Clearly identifies which package
- ✅ Follows npm convention (`@scope/package@version`)
- ✅ Easy to filter: `git tag | grep package-a@`
- ✅ GitHub Actions can parse easily
- ✅ Prevents tag name conflicts

---

## 🎯 Version Bump Examples

### Based on Conventional Commits

| Commit Message | Type | Bump | Example Tag |
|----------------|------|------|-------------|
| `feat: add new feature` | Feature | Minor | `v1.0.0` → `v1.1.0` |
| `fix: resolve bug` | Bug fix | Patch | `v1.1.0` → `v1.1.1` |
| `feat!: breaking change` | Breaking | Major | `v1.1.1` → `v2.0.0` |
| `feat(package-a): new API` | Feature | Minor | `package-a@v1.0.0` → `package-a@v1.1.0` |
| `fix(package-b): bug fix` | Bug fix | Patch | `package-b@v1.1.0` → `package-b@v1.1.1` |
| `chore: update deps` | Chore | None | No release |

---

## 📊 Real-World Timeline

### Your Project's Potential Release History

```
2025-10-15  v1.0.0                    Initial release
            ↓
2025-10-20  package-a@v1.0.1          Fix logger issue
            ↓
2025-10-22  package-b@v1.1.0          Add new string utils
            ↓
2025-10-25  v1.1.0                    Monorepo update with all packages
            ↓
2025-11-01  package-c@v1.0.1          Math function fix
            ↓
2025-11-05  package-a@v1.1.0          Logger improvements
            ↓
2025-11-10  v1.2.0                    Monorepo minor update
            ↓
2025-12-01  v2.0.0                    Breaking change release
            ↓
2025-12-05  package-a@v2.0.0          Package A breaking change
```

---

## 🔧 How to Check Tags

### List All Tags
```bash
git tag
```

### List Root Tags Only
```bash
git tag | grep "^v[0-9]"
```

### List Package-Specific Tags
```bash
# All packages
git tag | grep "@v"

# Specific package
git tag | grep "package-a@"
```

### Show Latest Tag
```bash
# Latest root tag
git tag | grep "^v[0-9]" | sort -V | tail -1

# Latest package-a tag
git tag | grep "package-a@" | sort -V | tail -1
```

### Tag Details
```bash
# Show tag annotation
git show v1.1.0

# Show tag with commit
git log v1.1.0 -1
```

---

## 🎮 Interactive Examples

### Example 1: Your First Root Release

```bash
# Current state
$ cat package.json | grep version
  "version": "1.0.0",

# Run release
$ npm run release

# Choose: minor (1.1.0)
? Select increment: minor

# Result
✔ Creating git tag: v1.1.0

# Verify
$ git tag
v1.1.0  ← Created!

$ git log --oneline -1
abc1234 (HEAD -> main, tag: v1.1.0) chore: release v1.1.0
```

---

### Example 2: Package-Specific Release

```bash
# Current state
$ cat packages/package-a/package.json | grep version
  "version": "1.0.0",

# Run package release
$ npm run release:package-a

# Choose: patch (1.0.1)
? Select increment: patch

# Result
✔ Creating git tag: package-a@v1.0.1

# Verify
$ git tag | grep package-a
package-a@v1.0.1  ← Created!

$ git log --oneline -1
def5678 (HEAD -> main, tag: package-a@v1.0.1) chore(package-a): release v1.0.1
```

---

## 📋 GitHub Actions Integration

### How Tags Trigger Workflows

Your `.github/workflows/release.yml` is configured to trigger on these tag patterns:

```yaml
on:
  push:
    tags:
      - 'v*.*.*'              # Matches: v1.0.0, v1.1.0, v2.0.0
      - 'package-*@v*.*.*'    # Matches: package-a@v1.0.0, package-b@v1.1.0
```

### What Happens

| Tag Pushed | Workflow Triggered | Actions |
|------------|-------------------|---------|
| `v1.1.0` | ✅ Yes | Runs tests, builds, creates release |
| `package-a@v1.0.1` | ✅ Yes | Runs tests, builds, creates package release |
| `random-tag` | ❌ No | No workflow triggered |
| `v1.1.0-beta.0` | ✅ Yes | Matches `v*.*.*` pattern |

---

## 🎯 Summary

### Tag Naming Rules

1. **Root releases:**
   - Format: `v${version}`
   - Example: `v1.1.0`
   - When: `npm run release`

2. **Package releases:**
   - Format: `package-name@v${version}`
   - Example: `package-a@v1.0.1`
   - When: `npm run release:package-a`

3. **All tags:**
   - Follow semantic versioning
   - Include `v` prefix
   - Are annotated (not lightweight)
   - Trigger GitHub Actions
   - Create GitHub releases

### Quick Reference

| Command | Tag Created | Commit Message |
|---------|-------------|----------------|
| `npm run release` | `v1.1.0` | `chore: release v1.1.0` |
| `npm run release:package-a` | `package-a@v1.0.1` | `chore(package-a): release v1.0.1` |
| `npm run release:package-b` | `package-b@v1.1.0` | `chore(package-b): release v1.1.0` |
| `npm run release:package-c` | `package-c@v2.0.0` | `chore(package-c): release v2.0.0` |

---

## 💡 Pro Tips

### Tip 1: Preview Tags Before Creating
```bash
npm run release:dry
# Shows: "Will create tag: v1.1.0"
```

### Tip 2: Clean Up Tags
```bash
# Delete local tag
git tag -d v1.1.0

# Delete remote tag
git push origin :refs/tags/v1.1.0

# Delete GitHub release (via web interface)
```

### Tip 3: Find Tags by Date
```bash
git tag --sort=-creatordate
```

### Tip 4: Tag History
```bash
git log --tags --simplify-by-decoration --pretty="format:%ai %d"
```

---

## ✅ Checklist

When you run `npm run release`, you'll see:

- [x] Version bumped in package.json
- [x] CHANGELOG.md updated
- [x] Git commit created
- [x] **Git tag created: `v1.1.0`** ← This is your answer!
- [x] Changes pushed to GitHub
- [x] GitHub release created

When you run `npm run release:package-a`, you'll see:

- [x] Version bumped in packages/package-a/package.json
- [x] CHANGELOG.md updated in packages/package-a/
- [x] Git commit created
- [x] **Git tag created: `package-a@v1.0.1`** ← This is your answer!
- [x] Changes pushed to GitHub
- [x] GitHub release created

---

## 🎉 Your Answer

**For root releases:**
```
v1.0.0
v1.1.0
v1.2.0
v2.0.0
```

**For package releases:**
```
package-a@v1.0.0
package-a@v1.0.1
package-b@v1.1.0
package-c@v2.0.0
```

**Format:** Simple, clean, semantic versioning with package scoping! 🚀
