#!/bin/bash

set -e

RELEASE_BRANCH="release/v1.1.0"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔄 GIT FLOW RELEASE MERGE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check current state
echo "📋 Current branch:"
git branch --show-current
echo ""

echo "📦 Current tags:"
git tag | tail -5
echo ""

echo "📊 Recent commits:"
git log --oneline --decorate -5
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Git Flow requires these merges:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1️⃣  Merge release/v1.1.0 → main (production)"
echo "  2️⃣  Merge main → develop (sync changes)"
echo ""
echo "Without these merges:"
echo "  ❌ Production won't have the release"
echo "  ❌ Develop will be out of sync"
echo "  ❌ Git Flow breaks"
echo ""

read -p "Execute Git Flow merges? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Merge cancelled"
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  STEP 1: Merge to main"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

git checkout main
echo "✓ Switched to main"

git merge --no-ff "$RELEASE_BRANCH" -m "Merge $RELEASE_BRANCH into main"
echo "✓ Merged $RELEASE_BRANCH into main"
echo ""

echo "📦 Main branch now has:"
git log --oneline -1
git tag --points-at HEAD
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  STEP 2: Merge to develop"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

git checkout develop
echo "✓ Switched to develop"

git merge --no-ff main -m "Merge main into develop after $RELEASE_BRANCH"
echo "✓ Merged main into develop"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ GIT FLOW MERGE COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📊 Final state:"
git log --oneline --graph --all --decorate -10
echo ""

echo "🎯 Next steps:"
echo ""
echo "  1. Push main with tags:"
echo "     $ git checkout main"
echo "     $ git push origin main --follow-tags"
echo ""
echo "  2. Push develop:"
echo "     $ git checkout develop"
echo "     $ git push origin develop"
echo ""
echo "  3. Clean up release branch (optional):"
echo "     $ git branch -d $RELEASE_BRANCH"
echo ""
echo "  4. GitHub Actions will create release when tags are pushed!"
echo ""

echo "✨ Done! Your release is ready to push to GitHub!"
