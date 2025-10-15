#!/bin/bash
# Git Flow automation script for release-it
# This script handles the merge process after a release

set -e

CURRENT_BRANCH=$(git branch --show-current)
VERSION=$1

echo "🔄 Git Flow: Automating merge process..."
echo ""

# Only run if we're on a release branch
if [[ ! $CURRENT_BRANCH =~ ^release/ ]]; then
    echo "⚠️  Not on a release branch, skipping Git Flow merges"
    exit 0
fi

echo "📋 Current branch: $CURRENT_BRANCH"
echo "📦 Version: $VERSION"
echo ""

# Store current branch
RELEASE_BRANCH=$CURRENT_BRANCH

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  STEP 1: Merge to main"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if main branch exists
if git show-ref --verify --quiet refs/heads/main; then
    echo "✓ Switching to main..."
    git checkout main
    
    echo "✓ Merging $RELEASE_BRANCH into main..."
    git merge --no-ff "$RELEASE_BRANCH" -m "Merge $RELEASE_BRANCH into main"
    
    echo "✅ Merged to main"
    echo ""
else
    echo "⚠️  Main branch not found, skipping"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  STEP 2: Merge to develop"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if develop branch exists
if git show-ref --verify --quiet refs/heads/develop; then
    echo "✓ Switching to develop..."
    git checkout develop
    
    echo "✓ Merging main into develop..."
    git merge --no-ff main -m "Merge main into develop after $RELEASE_BRANCH"
    
    echo "✅ Merged to develop"
    echo ""
else
    echo "⚠️  Develop branch not found, skipping"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Git Flow merge complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Return to main for pushing
git checkout main

echo "📊 Branches updated:"
echo "  • main    - has release $VERSION"
echo "  • develop - synced with main"
echo ""

echo "🎯 Next: release-it will push tags to GitHub"
