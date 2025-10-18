#!/bin/bash

# ========================================
# Initialize Git Flow in Repository
# ========================================
# This script initializes git-flow with standard branch names

set -e

echo "🌊 Git-Flow Initialization"
echo "======================================"
echo ""

# Check if git-flow is installed
if ! command -v git-flow &>/dev/null && ! git flow version &>/dev/null 2>&1; then
    echo "❌ git-flow is not installed"
    echo ""
    echo "Please install it first:"
    echo "  ./scripts/install-git-flow.sh"
    echo ""
    echo "Or manually:"
    echo "  macOS:   brew install git-flow-avh"
    echo "  Ubuntu:  sudo apt-get install git-flow"
    exit 1
fi

# Check if already initialized
if git config --get gitflow.branch.master &>/dev/null; then
    echo "✅ git-flow is already initialized"
    echo ""
    echo "Current configuration:"
    echo "  Production branch: $(git config --get gitflow.branch.master)"
    echo "  Development branch: $(git config --get gitflow.branch.develop)"
    echo "  Feature prefix: $(git config --get gitflow.prefix.feature)"
    echo "  Release prefix: $(git config --get gitflow.prefix.release)"
    echo "  Hotfix prefix: $(git config --get gitflow.prefix.hotfix)"
    echo ""
    exit 0
fi

echo "📋 Initializing with default settings:"
echo "  Production branch:  main"
echo "  Development branch: develop"
echo "  Feature prefix:     feature/"
echo "  Release prefix:     release/"
echo "  Hotfix prefix:      hotfix/"
echo "  Support prefix:     support/"
echo "  Version tag prefix: (none)"
echo ""

# Initialize with defaults (non-interactive)
git flow init -d

echo ""
echo "✅ Git-Flow initialized successfully!"
echo ""
echo "📊 Current branches:"
git branch -a
echo ""
echo "🎯 You can now use git-flow commands:"
echo "  git flow feature start <name>"
echo "  git flow feature finish <name>"
echo "  git flow release start <version>"
echo "  git flow release finish <version>"
echo ""
