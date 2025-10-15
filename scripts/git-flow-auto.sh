#!/bin/bash
# Enhanced Git Flow automation with push support
# This runs after release-it creates the tag

set -e

CURRENT_BRANCH=$(git branch --show-current)
VERSION=$1
AUTO_PUSH=${AUTO_PUSH:-false}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔄 GIT FLOW: Automated Merge Process"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Version: $VERSION"
echo "Branch:  $CURRENT_BRANCH"
echo ""

# Detect if we're on a release branch
if [[ ! $CURRENT_BRANCH =~ ^release/ ]]; then
    echo "ℹ️  Not on a release branch - skipping Git Flow merges"
    echo ""
    exit 0
fi

RELEASE_BRANCH=$CURRENT_BRANCH

echo "✓ Detected release branch: $RELEASE_BRANCH"
echo ""

# Function to check if branch exists
branch_exists() {
    git show-ref --verify --quiet "refs/heads/$1"
}

# Function to merge with message
merge_branch() {
    local from=$1
    local to=$2
    local message=$3
    
    if ! branch_exists "$to"; then
        echo "⚠️  Branch '$to' does not exist - skipping merge"
        return 1
    fi
    
    echo "→ Switching to $to..."
    git checkout "$to" 2>/dev/null
    
    echo "→ Merging $from into $to..."
    git merge --no-ff "$from" -m "$message" 2>/dev/null
    
    echo "✅ Merged successfully"
    return 0
}

# Step 1: Merge release → main
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📦 STEP 1: Merge to main (production)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if merge_branch "$RELEASE_BRANCH" "main" "Merge $RELEASE_BRANCH into main"; then
    echo ""
    echo "📊 Main branch status:"
    git log --oneline -1
    git tag --points-at HEAD | sed 's/^/  Tag: /'
    echo ""
fi

# Step 2: Merge main → develop
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔄 STEP 2: Merge to develop (sync changes)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if merge_branch "main" "develop" "Merge main into develop after $RELEASE_BRANCH"; then
    echo ""
    echo "📊 Develop branch status:"
    git log --oneline -1
    echo ""
fi

# Return to main for any subsequent operations
if branch_exists "main"; then
    git checkout main 2>/dev/null
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ GIT FLOW MERGE COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Summary:"
echo "  ✓ Release branch: $RELEASE_BRANCH"
echo "  ✓ Version: $VERSION"
echo "  ✓ Main: updated with release"
echo "  ✓ Develop: synced with main"
echo ""

# Push if auto-push is enabled
if [[ "$AUTO_PUSH" == "true" ]]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🚀 AUTO-PUSH ENABLED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if branch_exists "main"; then
        echo "→ Pushing main with tags..."
        git push origin main --follow-tags 2>/dev/null || echo "⚠️  Push failed (remote may not exist)"
    fi
    
    if branch_exists "develop"; then
        echo "→ Pushing develop..."
        git checkout develop 2>/dev/null
        git push origin develop 2>/dev/null || echo "⚠️  Push failed (remote may not exist)"
    fi
    
    echo ""
    echo "✅ Pushed to remote"
    echo ""
fi

# Optionally clean up release branch
if [[ "$CLEANUP_RELEASE_BRANCH" == "true" ]]; then
    echo "🧹 Cleaning up release branch: $RELEASE_BRANCH"
    git branch -d "$RELEASE_BRANCH" 2>/dev/null || echo "⚠️  Could not delete release branch"
    echo ""
fi

echo "🎉 Git Flow automation complete!"
echo ""

# Show final state
echo "📊 Current state:"
git log --oneline --graph --all --decorate -5 2>/dev/null || git log --oneline -5
echo ""
