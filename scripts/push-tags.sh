#!/bin/bash

# ========================================
# Push Tags to GitHub
# ========================================
# This script ensures all local tags are pushed to GitHub

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

echo ""
info "🏷️  Push Tags to GitHub"
echo "======================================"
echo ""

# Check if in git repository
if [[ ! -d .git ]]; then
    error "Not in a git repository"
    exit 1
fi

# Check if remote is configured
if ! git remote get-url origin &>/dev/null; then
    error "No remote 'origin' configured"
    echo ""
    info "Please add a GitHub remote first:"
    echo ""
    echo "  git remote add origin https://github.com/USERNAME/monorepository-example.git"
    echo ""
    echo "Or with SSH:"
    echo "  git remote add origin git@github.com:USERNAME/monorepository-example.git"
    echo ""
    exit 1
fi

REMOTE_URL=$(git remote get-url origin)
info "Remote: $REMOTE_URL"
echo ""

# Get list of local tags
LOCAL_TAGS=$(git tag -l | wc -l | tr -d ' ')
info "Local tags: $LOCAL_TAGS"

if [[ "$LOCAL_TAGS" -eq 0 ]]; then
    warn "No local tags found"
    echo ""
    info "Create tags by releasing packages:"
    echo "  ./scripts/quick-release.sh package-a patch"
    exit 0
fi

echo ""
info "Tags to push:"
git tag -l | sed 's/^/  - /'
echo ""

# Confirm
read -p "$(echo -e ${CYAN}Push all tags to GitHub? [y/N]: ${NC})" -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    warn "Cancelled by user"
    exit 0
fi

echo ""
info "Pushing tags..."

# Push all tags
if git push origin --tags; then
    success "All tags pushed to GitHub!"
    echo ""
    
    # Show GitHub URL
    REPO_PATH=$(echo "$REMOTE_URL" | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/.*github.com[:/]\(.*\)/\1/')
    if [[ -n "$REPO_PATH" ]]; then
        info "View tags on GitHub:"
        echo "  https://github.com/$REPO_PATH/tags"
        echo ""
        info "View releases on GitHub:"
        echo "  https://github.com/$REPO_PATH/releases"
    fi
else
    error "Failed to push tags"
    echo ""
    info "This might be due to:"
    echo "  - Authentication issues"
    echo "  - Network problems"
    echo "  - Permission issues"
    echo ""
    info "Try authenticating:"
    echo "  gh auth login"
    echo ""
    info "Or check your SSH keys:"
    echo "  ssh -T git@github.com"
    exit 1
fi

echo ""
success "Done! 🎉"
echo ""
