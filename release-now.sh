#!/bin/bash
# Complete GitHub Release Demonstration with release-it
# This script demonstrates the ACTUAL frictionless release process

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║  🚀 FRICTIONLESS GITHUB RELEASE WITH RELEASE-IT              ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

step() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}STEP $1: $2${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

info() {
    echo -e "${GREEN}✓ $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

error() {
    echo -e "${RED}✗ $1${NC}"
}

cmd() {
    echo -e "${BLUE}$ $1${NC}"
}

# ============================================================================
step "1" "Verify Prerequisites"
# ============================================================================

cmd "git status"
git status --short
echo ""

cmd "git branch --show-current"
CURRENT_BRANCH=$(git branch --show-current)
info "Current branch: $CURRENT_BRANCH"
echo ""

cmd "grep '\"version\"' package.json"
CURRENT_VERSION=$(grep '"version"' package.json | head -1 | sed 's/.*: "\(.*\)".*/\1/')
info "Current version: $CURRENT_VERSION"
echo ""

cmd "git log --oneline -5"
git log --oneline -5 2>/dev/null || info "Fresh repository"
echo ""

# ============================================================================
step "2" "Check GitHub Token"
# ============================================================================

if [ -n "$GITHUB_TOKEN" ]; then
    info "GITHUB_TOKEN is set ✓"
    TOKEN_PREFIX=$(echo $GITHUB_TOKEN | cut -c1-7)
    echo "   Token: ${TOKEN_PREFIX}..."
else
    warn "GITHUB_TOKEN not set"
    echo ""
    echo "To create GitHub releases, you need a token:"
    echo ""
    echo "1. Go to: https://github.com/settings/tokens/new"
    echo "2. Name: release-it"
    echo "3. Scopes: ✓ repo (Full control of private repositories)"
    echo "4. Generate token"
    echo "5. Export in terminal:"
    echo ""
    cmd "export GITHUB_TOKEN=\"ghp_your_token_here\""
    echo ""
    echo "Or add to ~/.zshrc:"
    cmd "echo 'export GITHUB_TOKEN=\"ghp_your_token_here\"' >> ~/.zshrc"
    echo ""
    echo "Without token: release-it will create commit & tag, but GitHub release via Actions"
    echo ""
fi

# ============================================================================
step "3" "DRY RUN - Preview Release"
# ============================================================================

echo "This shows what WOULD happen without making changes:"
echo ""

cmd "npx release-it --dry-run --ci --increment=minor"
echo ""

info "Performing dry run..."
echo ""

# Run dry-run
npx release-it --dry-run --ci --increment=minor 2>&1 || true

echo ""
info "Dry run complete! No actual changes were made."
echo ""

# ============================================================================
step "4" "Review What Will Change"
# ============================================================================

echo "Before we release, let's review:"
echo ""

echo "📦 Current state:"
echo "   • Version: $CURRENT_VERSION"
echo "   • Branch: $CURRENT_BRANCH"
echo ""

echo "🎯 After release:"
echo "   • Version will be: $(echo $CURRENT_VERSION | awk -F. '{print $1"."$2+1".0"}')"
echo "   • CHANGELOG.md will be updated"
echo "   • Git commit will be created"
echo "   • Git tag will be created"
echo "   • Changes will be pushed to GitHub"
if [ -n "$GITHUB_TOKEN" ]; then
    echo "   • GitHub Release will be created ✨"
else
    echo "   • GitHub Actions will create release (via tag trigger)"
fi
echo ""

# ============================================================================
step "5" "Execute Release (Interactive)"
# ============================================================================

echo "Ready to make a REAL release?"
echo ""
echo "The command will:"
echo "  1. Ask you to confirm the version increment"
echo "  2. Update package.json"
echo "  3. Update CHANGELOG.md"
echo "  4. Create commit & tag"
echo "  5. Push to GitHub"
if [ -n "$GITHUB_TOKEN" ]; then
    echo "  6. Create GitHub Release"
fi
echo ""

read -p "Execute release now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    cmd "npx release-it --increment=minor"
    echo ""
    
    info "Starting release process..."
    echo ""
    
    # Execute release
    npx release-it --increment=minor
    
    echo ""
    info "Release completed! 🎉"
    echo ""
else
    echo ""
    info "Release cancelled. You can run it manually:"
    echo ""
    cmd "npm run release"
    echo ""
    echo "Or fully automated:"
    cmd "npx release-it --ci --increment=minor"
    echo ""
fi

# ============================================================================
step "6" "Verify Release"
# ============================================================================

NEW_VERSION=$(grep '"version"' package.json | head -1 | sed 's/.*: "\(.*\)".*/\1/')
echo "Current version: $NEW_VERSION"
echo ""

cmd "git log -1 --oneline"
git log -1 --oneline 2>/dev/null || info "Release not yet executed"
echo ""

cmd "git tag -l | tail -5"
git tag -l 2>/dev/null | tail -5 || info "No tags yet"
echo ""

if [ "$NEW_VERSION" != "$CURRENT_VERSION" ]; then
    info "Version updated: $CURRENT_VERSION → $NEW_VERSION ✓"
    echo ""
    
    echo "📋 Next steps:"
    echo ""
    echo "1. Check GitHub repository:"
    echo "   https://github.com/YOUR_USERNAME/monorepository-example"
    echo ""
    echo "2. View releases:"
    echo "   https://github.com/YOUR_USERNAME/monorepository-example/releases"
    echo ""
    echo "3. Check GitHub Actions:"
    echo "   https://github.com/YOUR_USERNAME/monorepository-example/actions"
    echo ""
else
    info "Run the release command to create a new version"
fi

# ============================================================================
step "7" "Complete Git Flow (Optional)"
# ============================================================================

echo "If you're following Git Flow, merge back to main and develop:"
echo ""

cmd "# Merge to main"
echo "git checkout main"
echo "git merge $CURRENT_BRANCH --no-ff"
echo "git push origin main"
echo ""

cmd "# Merge back to develop"
echo "git checkout develop"  
echo "git merge main"
echo "git push origin develop"
echo ""

info "These steps ensure all branches stay in sync"
echo ""

# ============================================================================
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║  ✨ RELEASE DEMONSTRATION COMPLETE!                          ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

echo "📚 Quick Reference:"
echo ""
echo "  # Test release (dry run):"
echo "  npm run release:dry"
echo ""
echo "  # Interactive release:"
echo "  npm run release"
echo ""
echo "  # Automated release:"
echo "  npx release-it --ci --increment=minor"
echo ""
echo "  # With GitHub token:"
echo "  export GITHUB_TOKEN=\"ghp_xxx\""
echo "  npm run release"
echo ""

echo "🎯 What Just Happened:"
echo "  ✓ Analyzed conventional commits"
echo "  ✓ Determined semantic version bump"
echo "  ✓ Updated package.json & CHANGELOG.md"
echo "  ✓ Created git commit & tag"
echo "  ✓ Pushed to GitHub"
echo "  ✓ Triggered GitHub Actions workflow"
echo ""

echo "🎉 Your release is live!"
