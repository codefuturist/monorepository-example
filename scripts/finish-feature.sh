#!/bin/bash

# ========================================
# Finish a Feature with Git Flow
# ========================================
# Automates feature branch completion using git-flow

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

# Get feature name from current branch if not provided
if [[ $# -eq 0 ]]; then
    CURRENT_BRANCH=$(git branch --show-current)
    if [[ "$CURRENT_BRANCH" == feature/* ]]; then
        FEATURE_NAME="${CURRENT_BRANCH#feature/}"
    else
        error "Not on a feature branch and no feature name provided"
        echo ""
        echo "Usage: $0 [feature-name]"
        echo ""
        echo "Current branch: $CURRENT_BRANCH"
        exit 1
    fi
else
    FEATURE_NAME="$1"
fi

PUSH_TO_REMOTE=false
DELETE_REMOTE=false

# Parse options
while [[ $# -gt 1 ]]; do
    case $2 in
        --push|-p)
            PUSH_TO_REMOTE=true
            shift
            ;;
        --delete-remote|-d)
            DELETE_REMOTE=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo ""
info "🎯 Finishing Feature"
echo "======================================"
info "Feature: $FEATURE_NAME"
info "Push to remote: $PUSH_TO_REMOTE"
echo ""

# Check git-flow
if ! git flow version &>/dev/null 2>&1; then
    error "git-flow not installed. Run: ./scripts/install-git-flow.sh"
    exit 1
fi

# Ensure we're on the feature branch
if [[ "$(git branch --show-current)" != "feature/$FEATURE_NAME" ]]; then
    info "Switching to feature/$FEATURE_NAME..."
    git checkout "feature/$FEATURE_NAME"
fi

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    warn "You have uncommitted changes!"
    echo ""
    git status -s
    echo ""
    read -p "$(echo -e ${YELLOW}Commit changes first? [y/N]: ${NC})" -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add -A
        read -p "$(echo -e ${BLUE}Commit message: ${NC})" COMMIT_MSG
        git commit -m "$COMMIT_MSG"
        success "Changes committed"
    else
        error "Please commit or stash changes first"
        exit 1
    fi
fi

echo ""
info "Finishing feature branch..."

# Update develop before finishing
git checkout develop
git pull origin develop 2>/dev/null || warn "Could not pull develop (no remote?)"

# Finish feature with git-flow
git flow feature finish "$FEATURE_NAME" --no-ff

success "Feature finished!"
success "✅ Merged feature/$FEATURE_NAME → develop"
success "✅ Feature branch deleted locally"
echo ""

if [[ "$PUSH_TO_REMOTE" == true ]]; then
    info "Pushing develop to remote..."
    git push origin develop
    success "Pushed develop to remote"
fi

if [[ "$DELETE_REMOTE" == true ]]; then
    if git ls-remote --heads origin "feature/$FEATURE_NAME" &>/dev/null; then
        info "Deleting remote feature branch..."
        git push origin --delete "feature/$FEATURE_NAME"
        success "Remote branch deleted"
    fi
fi

echo ""
echo "======================================"
success "🎉 Feature Complete!"
echo "======================================"
echo ""
info "Feature '$FEATURE_NAME' merged into develop"
echo ""
info "Next steps:"
echo "  - Continue working: ./scripts/start-feature.sh <name>"
echo "  - Or make a release: ./scripts/release-package.sh <package> <bump>"
echo ""
