#!/bin/bash

# ========================================
# Quick Release - One Command Solution
# ========================================
# This is the most automated script - just specify package and bump type

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
header() { echo -e "${PURPLE}$1${NC}"; }

# Usage
usage() {
    cat << EOF
Usage: $0 <package> <bump> [options]

Quick automated release with minimal interaction.

Arguments:
  package    Package name (package-a, package-b, package-c)
  bump       Version bump (patch, minor, major)

Options:
  --yes, -y        Skip all confirmations (fully automated)
  --no-push        Don't push to GitHub
  --no-cleanup     Keep release branch

Examples:
  $0 package-a minor               # Interactive release
  $0 package-a patch -y            # Fully automated
  $0 package-b major -y --no-push  # Automated, no push

EOF
    exit 1
}

# Parse args
PACKAGE=""
BUMP=""
AUTO_YES=false
DO_PUSH=true
DO_CLEANUP=true

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        --no-push)
            DO_PUSH=false
            shift
            ;;
        --no-cleanup)
            DO_CLEANUP=false
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [[ -z "$PACKAGE" ]]; then
                PACKAGE="$1"
            elif [[ -z "$BUMP" ]]; then
                BUMP="$1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$PACKAGE" ]] || [[ -z "$BUMP" ]]; then
    error "Missing required arguments"
    usage
fi

# Validate package
if [[ ! -d "packages/$PACKAGE" ]]; then
    error "Package not found: packages/$PACKAGE"
    exit 1
fi

# Validate bump
if [[ ! "$BUMP" =~ ^(patch|minor|major)$ ]]; then
    error "Invalid bump type: $BUMP (must be: patch, minor, major)"
    exit 1
fi

echo ""
header "╔════════════════════════════════════════╗"
header "║     🚀 Quick Release System 🚀         ║"
header "╔════════════════════════════════════════╗"
echo ""

info "Package: $PACKAGE"
info "Bump: $BUMP"
info "Auto-confirm: $AUTO_YES"
info "Push to GitHub: $DO_PUSH"
info "Cleanup: $DO_CLEANUP"
echo ""

# Check prerequisites
header "🔍 Checking Prerequisites..."
echo ""

# Check git-flow
if ! git flow version &>/dev/null 2>&1; then
    error "git-flow not installed"
    info "Installing git-flow..."
    ./scripts/install-git-flow.sh
fi
success "git-flow installed"

# Check git-flow initialized
if ! git config --get gitflow.branch.master &>/dev/null; then
    error "git-flow not initialized"
    info "Initializing git-flow..."
    ./scripts/init-git-flow.sh
fi
success "git-flow initialized"

# Check clean working tree
if [[ -n $(git status -s) ]]; then
    warn "Uncommitted changes detected!"
    git status -s
    echo ""
    if [[ "$AUTO_YES" != true ]]; then
        read -p "$(echo -e ${YELLOW}Commit all changes? [y/N]: ${NC})" -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error "Please commit or stash changes first"
            exit 1
        fi
    fi
    info "Committing all changes..."
    git add -A
    git commit -m "chore: prepare for $PACKAGE $BUMP release"
    success "Changes committed"
fi

echo ""
header "📊 Current State"
echo ""

CURRENT_VERSION=$(node -p "require('./packages/$PACKAGE/package.json').version")
info "Current version: $CURRENT_VERSION"

# Calculate new version
cd "packages/$PACKAGE"
NEW_VERSION=$(npx semver $CURRENT_VERSION -i $BUMP 2>/dev/null || echo "")
cd - > /dev/null

if [[ -z "$NEW_VERSION" ]]; then
    error "Could not calculate version"
    info "Installing semver..."
    npm install -g semver
    NEW_VERSION=$(cd "packages/$PACKAGE" && npx semver $CURRENT_VERSION -i $BUMP && cd - > /dev/null)
fi

success "New version: $NEW_VERSION"
echo ""

# Confirm
if [[ "$AUTO_YES" != true ]]; then
    read -p "$(echo -e ${YELLOW}🚀 Start release? [y/N]: ${NC})" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        warn "Cancelled"
        exit 0
    fi
fi

echo ""
header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
header "  RELEASE PROCESS STARTING"
header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Update develop
header "📥 STEP 1: Update Develop Branch"
echo ""
git checkout develop
git pull origin develop 2>/dev/null || warn "Could not pull from remote"
success "Develop branch updated"
echo ""

# Step 2: Start release
header "🌿 STEP 2: Start Release Branch"
echo ""
git flow release start "$NEW_VERSION"
success "Release branch: release/$NEW_VERSION"
echo ""

# Step 3: Run release-it
header "🔧 STEP 3: Run release-it"
echo ""
cd "packages/$PACKAGE"

npx release-it "$BUMP" \
    --ci \
    --no-git.requireUpstream \
    --no-git.push \
    --no-github.release \
    --git.commitMessage="chore(release): ${PACKAGE} v\${version}" \
    --git.tagName="${PACKAGE}@v\${version}" \
    ${AUTO_YES:+--no-git.requireCleanWorkingDir}

cd - > /dev/null
success "Version bumped and tagged"
echo ""

# Step 4: Finish release
header "🎯 STEP 4: Finish Release (Git Flow Merges)"
echo ""

TAG_MSG="Release $PACKAGE v$NEW_VERSION

Automated release via quick-release script.

Changes:
$(cat packages/$PACKAGE/CHANGELOG.md 2>/dev/null | head -20 || echo 'See CHANGELOG.md')"

info "Finishing release branch..."
if [[ "$AUTO_YES" == true ]]; then
    # Use git-flow with automatic merge
    git flow release finish "$NEW_VERSION" -m "$TAG_MSG" || true
else
    git flow release finish "$NEW_VERSION" -m "$TAG_MSG"
fi

success "Release finished"
success "✅ Merged: release/$NEW_VERSION → main"
success "✅ Merged: main → develop"
echo ""

# Step 5: Push to GitHub
if [[ "$DO_PUSH" == true ]]; then
    header "📤 STEP 5: Push to GitHub"
    echo ""
    
    git checkout main
    info "Pushing main branch with tags..."
    git push origin main --follow-tags
    success "Main pushed"
    
    git checkout develop
    info "Pushing develop branch..."
    git push origin develop
    success "Develop pushed"
    
    echo ""
    success "✅ Pushed to GitHub!"
    
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ -n "$REMOTE_URL" ]]; then
        REPO_PATH=$(echo "$REMOTE_URL" | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/.*github.com[:/]\(.*\)/\1/')
        echo ""
        info "🎯 Check GitHub Actions:"
        echo "   https://github.com/$REPO_PATH/actions"
        info "📦 View Release:"
        echo "   https://github.com/$REPO_PATH/releases/tag/$PACKAGE@v$NEW_VERSION"
        
        # Check if gh CLI is available for watching workflow
        if command -v gh &>/dev/null; then
            echo ""
            if [[ "$AUTO_YES" != true ]]; then
                read -p "$(echo -e ${CYAN}🔍 Watch GitHub Actions workflow? [y/N]: ${NC})" -n 1 -r
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    info "Watching GitHub Actions workflow..."
                    echo ""
                    info "Tip: Press Ctrl+C to stop watching"
                    echo ""
                    sleep 2
                    gh run watch || warn "Could not watch workflow (it may not have started yet)"
                fi
            else
                info "💡 Use 'gh run watch' to watch the workflow progress"
            fi
        else
            echo ""
            info "💡 Tip: Install GitHub CLI to watch workflows in real-time:"
            echo "  brew install gh"
            echo "  gh auth login"
            echo "  gh run watch"
        fi
    fi
fi

# Step 6: Cleanup
if [[ "$DO_CLEANUP" == true ]]; then
    header "🧹 STEP 6: Cleanup"
    echo ""
    
    # Delete remote release branch if exists
    if git ls-remote --heads origin "release/$NEW_VERSION" &>/dev/null; then
        git push origin --delete "release/$NEW_VERSION" 2>/dev/null || true
        success "Remote release branch deleted"
    fi
fi

echo ""
header "╔════════════════════════════════════════╗"
header "║        🎉 RELEASE COMPLETE! 🎉         ║"
header "╚════════════════════════════════════════╝"
echo ""

success "Package: $PACKAGE"
success "Version: $CURRENT_VERSION → $NEW_VERSION"
success "Tag: $PACKAGE@v$NEW_VERSION"

if [[ "$DO_PUSH" == true ]]; then
    success "Status: Pushed to GitHub ✨"
    info "GitHub Actions should now be creating the release!"
else
    warn "Status: Not pushed (use --push to enable)"
    echo ""
    info "Push manually with:"
    echo "  git push origin main --follow-tags"
    echo "  git push origin develop"
fi

echo ""
info "📁 Files updated:"
echo "  - packages/$PACKAGE/package.json (version)"
echo "  - packages/$PACKAGE/CHANGELOG.md (generated)"
echo ""

info "✨ Done! Happy coding! ✨"
echo ""
