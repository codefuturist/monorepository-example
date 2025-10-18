#!/bin/bash

# ========================================
# Start a New Feature with Git Flow
# ========================================
# Automates feature branch creation using git-flow

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

# Usage
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <feature-name>"
    echo ""
    echo "Examples:"
    echo "  $0 add-logger"
    echo "  $0 fix-math-bug"
    echo "  $0 refactor-api"
    exit 1
fi

FEATURE_NAME="$1"

echo ""
info "🌿 Starting New Feature"
echo "======================================"
info "Feature: $FEATURE_NAME"
echo ""

# Check git-flow
if ! git flow version &>/dev/null 2>&1; then
    error "git-flow not installed. Run: ./scripts/install-git-flow.sh"
    exit 1
fi

# Check git-flow initialized
if ! git config --get gitflow.branch.master &>/dev/null; then
    error "git-flow not initialized. Run: ./scripts/init-git-flow.sh"
    exit 1
fi

# Ensure develop is up to date
info "Updating develop branch..."
git checkout develop
git pull origin develop 2>/dev/null || warn "Could not pull (no remote?)"

# Start feature
info "Creating feature branch..."
git flow feature start "$FEATURE_NAME"

success "Feature branch created: feature/$FEATURE_NAME"
echo ""
info "You're now on branch: $(git branch --show-current)"
echo ""
info "Next steps:"
echo "  1. Make your changes"
echo "  2. Commit with: git commit -m 'feat: your message'"
echo "  3. Finish with: ./scripts/finish-feature.sh $FEATURE_NAME"
echo ""
