#!/bin/bash
# Experienced Developer Workflow Demonstration
# This script shows the complete workflow for using this monorepo

set -e  # Exit on error

echo "🎓 EXPERIENCED DEVELOPER WORKFLOW DEMONSTRATION"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

command_demo() {
    echo -e "${YELLOW}$ $1${NC}"
    echo -e "${GREEN}→ $2${NC}"
    echo ""
}

section "1️⃣  INITIAL SETUP"

command_demo "npm install" \
    "Install all dependencies (release-it, conventional-changelog, etc.)"

command_demo "git init && git add . && git commit -m 'chore: initial setup'" \
    "Initialize git repository with all files"

command_demo "git branch -M main" \
    "Ensure we're on main branch"

command_demo "git checkout -b develop" \
    "Create develop branch for ongoing development"

section "2️⃣  FEATURE DEVELOPMENT (Git Flow)"

command_demo "git checkout develop" \
    "Always start from develop"

command_demo "git checkout -b feature/add-user-auth" \
    "Create feature branch with descriptive name"

echo "📝 Make your changes in the code..."
echo "   - Edit files in packages/package-a/src/"
echo "   - Add new features, fix bugs, etc."
echo ""

command_demo "npm test" \
    "Run tests to ensure nothing breaks"

command_demo "npm run build" \
    "Build to catch any compilation errors"

command_demo "git add ." \
    "Stage all changes"

command_demo "git commit -m 'feat(package-a): add user authentication module

- Implement JWT token generation
- Add password hashing with bcrypt
- Create login/logout endpoints
- Add user session management

Closes #123'" \
    "Commit with conventional format (feat, fix, docs, chore, etc.)"

section "3️⃣  MERGE FEATURE TO DEVELOP"

command_demo "git checkout develop" \
    "Switch back to develop"

command_demo "git merge feature/add-user-auth --no-ff" \
    "Merge with --no-ff to preserve feature branch history"

command_demo "git branch -d feature/add-user-auth" \
    "Delete feature branch (optional, keeps history clean)"

section "4️⃣  PREPARE RELEASE (Git Flow)"

command_demo "git checkout develop && git pull origin develop" \
    "Ensure develop is up to date"

command_demo "git checkout -b release/v1.1.0" \
    "Create release branch from develop"

command_demo "npm run release:dry" \
    "DRY RUN FIRST! Test release without making changes"

echo "Review output:"
echo "  ✓ Check version bump is correct (1.0.0 → 1.1.0)"
echo "  ✓ Check CHANGELOG.md will be updated properly"
echo "  ✓ Check commit message format"
echo "  ✓ Check tag name"
echo ""

command_demo "npm run release" \
    "Execute release (prompts for confirmation)"

echo "This will:"
echo "  1. Bump version in package.json"
echo "  2. Update CHANGELOG.md from conventional commits"
echo "  3. Create git commit with 'chore: release v1.1.0'"
echo "  4. Create git tag 'v1.1.0'"
echo ""

section "5️⃣  FINALIZE RELEASE TO MAIN"

command_demo "git checkout main" \
    "Switch to production branch"

command_demo "git merge release/v1.1.0 --no-ff" \
    "Merge release to main"

command_demo "git push origin main" \
    "Push main branch"

command_demo "git push origin v1.1.0" \
    "Push the tag → THIS TRIGGERS GITHUB ACTION! 🚀"

echo "🤖 GitHub Actions will now:"
echo "  ✓ Run all tests"
echo "  ✓ Build all packages"
echo "  ✓ Create GitHub Release"
echo "  ✓ Generate release notes automatically"
echo "  ✓ Publish to npm (if configured)"
echo ""

section "6️⃣  MERGE BACK TO DEVELOP"

command_demo "git checkout develop" \
    "Go back to develop"

command_demo "git merge main" \
    "Merge main back to develop to keep in sync"

command_demo "git push origin develop" \
    "Push updated develop"

command_demo "git branch -d release/v1.1.0" \
    "Delete release branch (optional)"

section "7️⃣  RELEASE INDIVIDUAL PACKAGE"

command_demo "cd packages/package-a" \
    "Navigate to specific package"

command_demo "npm run release -- --dry-run" \
    "Test package-specific release"

command_demo "npm run release" \
    "Release only package-a"

echo "This creates tag: package-a@v1.0.1"
echo "GitHub Actions will detect package-specific tag and release only that package"
echo ""

section "8️⃣  HOTFIX WORKFLOW (Emergency Production Fix)"

command_demo "git checkout main" \
    "Hotfixes branch from main, not develop"

command_demo "git checkout -b hotfix/v1.1.1" \
    "Create hotfix branch"

echo "🔧 Fix the critical bug..."
echo ""

command_demo "git commit -m 'fix: resolve critical security vulnerability in auth

- Patch XSS vulnerability in login form
- Update input sanitization
- Add security tests

SECURITY: Fixes CVE-2025-12345'" \
    "Commit the fix"

command_demo "npm run release" \
    "Release the hotfix (will bump to v1.1.1)"

command_demo "git checkout main && git merge hotfix/v1.1.1" \
    "Merge to main"

command_demo "git checkout develop && git merge hotfix/v1.1.1" \
    "IMPORTANT: Also merge to develop!"

command_demo "git push origin main develop --tags" \
    "Push both branches and tags"

section "9️⃣  BEST PRACTICES & PRO TIPS"

echo "✨ COMMIT MESSAGE FORMAT:"
echo "   feat:     New feature → MINOR version bump (1.0.0 → 1.1.0)"
echo "   fix:      Bug fix → PATCH version bump (1.0.0 → 1.0.1)"
echo "   docs:     Documentation → No version bump"
echo "   chore:    Maintenance → No version bump"
echo "   refactor: Code refactoring → No version bump"
echo "   perf:     Performance → PATCH bump"
echo "   test:     Tests → No version bump"
echo "   BREAKING CHANGE: → MAJOR bump (1.0.0 → 2.0.0)"
echo ""

echo "🎯 WORKFLOW TIPS:"
echo "   • Always run 'npm run release:dry' before actual release"
echo "   • Use --no-ff for merges to preserve branch history"
echo "   • Delete feature branches after merging (keeps repo clean)"
echo "   • Always merge hotfixes to BOTH main AND develop"
echo "   • Push tags explicitly to trigger GitHub Actions"
echo "   • Review CHANGELOG.md before releasing"
echo ""

echo "📋 USEFUL COMMANDS:"
command_demo "git log --oneline --graph --all" \
    "Visualize branch structure"

command_demo "git log --grep='feat'" \
    "Find commits by type"

command_demo "npm run release -- --preRelease=beta" \
    "Create pre-release (v1.1.0-beta.0)"

command_demo "npm run release -- --increment=major" \
    "Force major version bump"

command_demo "git tag -l" \
    "List all tags"

command_demo "git tag -d v1.0.0 && git push origin :refs/tags/v1.0.0" \
    "Delete tag (local and remote)"

section "🎉 COMPLETE WORKFLOW EXAMPLE"

cat << 'EOF'
# Day-to-day workflow:

1. Pull latest develop
   $ git checkout develop && git pull

2. Create feature branch
   $ git checkout -b feature/my-feature

3. Develop & commit (multiple commits OK)
   $ git commit -m "feat: ..."
   $ git commit -m "fix: ..."
   $ git commit -m "docs: ..."

4. Merge to develop
   $ git checkout develop
   $ git merge feature/my-feature --no-ff
   $ git push origin develop

5. When ready to release (usually weekly/monthly)
   $ git checkout -b release/v1.x.0
   $ npm run release:dry  # CHECK OUTPUT!
   $ npm run release      # Execute

6. Merge to main
   $ git checkout main
   $ git merge release/v1.x.0
   $ git push origin main --tags  # ← Triggers automation!

7. Merge back to develop
   $ git checkout develop
   $ git merge main
   $ git push origin develop

8. Continue development
   $ git checkout -b feature/next-feature
   ... repeat ...
EOF

echo ""
section "✅ YOU'RE NOW AN EXPERT!"

echo "📚 Quick Reference:"
echo "   • GETTING_STARTED.md  - 5-minute setup"
echo "   • README.md           - Complete documentation"
echo "   • WORKFLOW.md         - Visual diagrams"
echo "   • CONTRIBUTING.md     - Detailed contribution guide"
echo ""

echo "🚀 Ready to release? Follow this flow:"
echo "   develop → feature/* → develop → release/* → main → [TAG] → 🤖 AUTOMATION"
echo ""

echo "💡 Remember:"
echo "   • Tags trigger GitHub Actions"
echo "   • Conventional commits generate changelogs"
echo "   • Git Flow keeps history clean"
echo "   • Dry run before releasing"
echo ""

echo "🎊 Happy releasing!"
