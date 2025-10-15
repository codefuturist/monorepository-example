#!/bin/bash
# Frictionless GitHub Release Demonstration
# This script demonstrates the complete release process

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║  🚀 FRICTIONLESS GITHUB RELEASE DEMONSTRATION              ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}STEP $1: $2${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

cmd() {
    echo -e "${YELLOW}$ $1${NC}"
}

info() {
    echo -e "${GREEN}✓ $1${NC}"
}

warn() {
    echo -e "${RED}! $1${NC}"
}

step "1" "Check Prerequisites"

cmd "git status"
git status --short
echo ""

cmd "git log --oneline -5"
git log --oneline -5 || info "Fresh repository"
echo ""

info "Current branch: $(git branch --show-current)"
info "Repository initialized"
echo ""

step "2" "Stage All Changes"

cmd "git add ."
git add .
info "All changes staged"
echo ""

step "3" "View What Will Be Released"

cmd "git diff --cached --stat"
git diff --cached --stat || info "No changes to show (already committed)"
echo ""

step "4" "DRY RUN - Test Release Process"

echo "This will show what release-it WOULD do without actually doing it:"
echo ""

cmd "npm run release:dry -- --ci --no-git.requireCleanWorkingDir"
echo ""

if command -v npx &> /dev/null; then
    info "release-it available"
    echo ""
    echo "Expected output:"
    echo "  • Current version: 1.0.0"
    echo "  • Next version: 1.1.0 (based on commits)"
    echo "  • Changelog preview"
    echo "  • Changes to be made"
    echo ""
else
    warn "release-it not installed yet - run 'npm install' first"
fi

step "5" "Execute Release (For Real)"

echo "To execute the actual release, you would run:"
echo ""
cmd "npm run release -- --ci --no-git.requireCleanWorkingDir"
echo ""

echo "This will:"
echo "  1. ✅ Analyze commits (feat, fix, etc.)"
echo "  2. ✅ Determine version bump (patch/minor/major)"
echo "  3. ✅ Update package.json with new version"
echo "  4. ✅ Generate/update CHANGELOG.md"
echo "  5. ✅ Create git commit: 'chore: release vX.Y.Z'"
echo "  6. ✅ Create git tag: vX.Y.Z"
echo ""

step "6" "Push to GitHub"

echo "After release-it completes, push to GitHub:"
echo ""
cmd "git push origin $(git branch --show-current)"
echo ""
cmd "git push origin --tags"
echo ""
info "Pushing the tag triggers GitHub Actions workflow!"
echo ""

step "7" "GitHub Actions Automation"

echo "When tag is pushed, GitHub Actions will:"
echo "  🤖 Run tests"
echo "  🤖 Build packages"
echo "  🤖 Create GitHub Release"
echo "  🤖 Generate release notes from commits"
echo "  🤖 Upload artifacts"
echo ""

step "8" "Verify Release on GitHub"

echo "Check your release at:"
echo "  https://github.com/YOUR_USERNAME/monorepository-example/releases"
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║  ✨ READY TO RELEASE!                                      ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "📋 Quick Commands:"
echo ""
echo "  # Dry run first (ALWAYS!):"
echo "  npm run release:dry"
echo ""
echo "  # Execute release:"
echo "  npm run release"
echo ""
echo "  # Push to GitHub:"
echo "  git push origin main --tags"
echo ""

echo "🎯 Pro Tips:"
echo "  • Always run dry-run first to preview changes"
echo "  • Check CHANGELOG.md after release"
echo "  • Verify version in package.json"
echo "  • Tags trigger automation automatically"
echo ""

echo "🎉 Ready to release!"
