#!/bin/bash

# ========================================
# Automated Package Release with Git Flow
# ========================================
# This script automates the entire release process:
# 1. Uses git-flow to start release
# 2. Runs commitizen for versioning and changelog
# 3. Uses git-flow to finish release
# 4. Pushes to GitHub automatically

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Usage information
usage() {
    cat << EOF
Usage: $0 [OPTIONS] <package-name> <version-bump>

Automated release process using git-flow CLI.

Arguments:
  package-name    Name of package to release (e.g., package-a, package-b)
  version-bump    Version bump type: patch, minor, major (or specific version)

Options:
  -p, --push      Automatically push to GitHub after release
  -c, --cleanup   Delete release branch after finishing
  -t, --tag-msg   Custom tag message (optional)
  -h, --help      Show this help message

Examples:
  $0 package-a minor              # Release package-a with minor bump
  $0 package-a patch --push       # Release and push to GitHub
  $0 package-b major --push --cleanup  # Full automated release

EOF
    exit 1
}

# Parse arguments
PACKAGE_NAME=""
VERSION_BUMP=""
AUTO_PUSH=false
CLEANUP_BRANCH=false
TAG_MESSAGE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--push)
            AUTO_PUSH=true
            shift
            ;;
        -c|--cleanup)
            CLEANUP_BRANCH=true
            shift
            ;;
        -t|--tag-msg)
            TAG_MESSAGE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [[ -z "$PACKAGE_NAME" ]]; then
                PACKAGE_NAME="$1"
            elif [[ -z "$VERSION_BUMP" ]]; then
                VERSION_BUMP="$1"
            else
                error "Unknown argument: $1"
                usage
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [[ -z "$PACKAGE_NAME" ]] || [[ -z "$VERSION_BUMP" ]]; then
    error "Missing required arguments"
    usage
fi

# Validate package exists
PACKAGE_DIR="packages/$PACKAGE_NAME"
if [[ ! -d "$PACKAGE_DIR" ]]; then
    error "Package not found: $PACKAGE_DIR"
    exit 1
fi

echo ""
info "🚀 Automated Release Process"
echo "======================================"
info "Package: $PACKAGE_NAME"
info "Version bump: $VERSION_BUMP"
info "Auto push: $AUTO_PUSH"
info "Cleanup: $CLEANUP_BRANCH"
echo ""

# Check git-flow is installed
if ! command -v git-flow &>/dev/null && ! git flow version &>/dev/null 2>&1; then
    error "git-flow is not installed"
    echo ""
    echo "Install it with: ./scripts/install-git-flow.sh"
    exit 1
fi

# Check git-flow is initialized
if ! git config --get gitflow.branch.master &>/dev/null; then
    error "git-flow is not initialized"
    echo ""
    echo "Initialize it with: ./scripts/init-git-flow.sh"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(node -p "require('./$PACKAGE_DIR/package.json').version")
info "Current version: $CURRENT_VERSION"

# Calculate new version
cd "$PACKAGE_DIR"
NEW_VERSION=$(npx semver $CURRENT_VERSION -i $VERSION_BUMP 2>/dev/null || echo "")
cd - > /dev/null

if [[ -z "$NEW_VERSION" ]]; then
    error "Could not calculate new version"
    echo "Make sure 'semver' is available: npm install -g semver"
    exit 1
fi

info "New version: $NEW_VERSION"
echo ""

# Confirm with user
read -p "$(echo -e ${YELLOW}🤔 Continue with release? [y/N]: ${NC})" -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    warn "Cancelled by user"
    exit 0
fi

echo ""
info "=========================================="
info "STEP 1: Start Git Flow Release"
info "=========================================="
echo ""

# Ensure we're on develop
git checkout develop
git pull origin develop 2>/dev/null || warn "Could not pull from origin (no remote?)"

# Start release using git-flow
info "Starting release branch: release/$NEW_VERSION"
git flow release start "$NEW_VERSION"

success "Release branch created: release/$NEW_VERSION"
echo ""

info "=========================================="
info "STEP 2: Run commitizen bump"
info "=========================================="
echo ""

cd "$PACKAGE_DIR"

# Run commitizen bump with calculated version
info "Running commitizen bump for $PACKAGE_NAME..."

# Determine the increment type for commitizen
case "$VERSION_BUMP" in
    patch|minor|major)
        INCREMENT="--increment $VERSION_BUMP"
        ;;
    *)
        # Specific version provided
        INCREMENT="$NEW_VERSION"
        ;;
esac

# Run commitizen bump
cz bump --yes \
    --changelog \
    --git-output-to-stderr \
    $INCREMENT || true

success "commitizen bump completed"
cd - > /dev/null
echo ""

info "=========================================="
info "STEP 3: Finish Git Flow Release"
info "=========================================="
echo ""

# Prepare tag message
if [[ -z "$TAG_MESSAGE" ]]; then
    TAG_MESSAGE="Release $PACKAGE_NAME v$NEW_VERSION

$(cat $PACKAGE_DIR/CHANGELOG.md | head -20 || echo 'See CHANGELOG.md for details')"
fi

# Finish release using git-flow
info "Finishing release branch..."
git flow release finish "$NEW_VERSION" \
    -m "$TAG_MESSAGE" \
    -p # Push after finishing

success "Release finished!"
success "✅ Merged release/$NEW_VERSION → main"
success "✅ Merged main → develop"
success "✅ Created tag for release"
echo ""

if [[ "$AUTO_PUSH" == true ]]; then
    info "=========================================="
    info "STEP 4: Push to GitHub"
    info "=========================================="
    echo ""
    
    info "Pushing main branch..."
    git checkout main
    git push origin main --follow-tags
    
    info "Pushing develop branch..."
    git checkout develop
    git push origin develop
    
    success "Pushed to GitHub!"
    echo ""
    
    info "🎯 GitHub Actions should now be running!"
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ -n "$REMOTE_URL" ]]; then
        REPO_PATH=$(echo "$REMOTE_URL" | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/.*github.com[:/]\(.*\)/\1/')
        echo ""
        info "Check the results:"
        echo "  Actions:  https://github.com/$REPO_PATH/actions"
        echo "  Releases: https://github.com/$REPO_PATH/releases"
        echo "  Tags:     https://github.com/$REPO_PATH/tags"
        echo ""
        
        # Check if gh CLI is available for watching workflow
        if command -v gh &>/dev/null; then
            echo ""
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
            echo ""
            info "💡 Tip: Install GitHub CLI to watch workflows in real-time:"
            echo "  brew install gh"
            echo "  gh auth login"
            echo "  gh run watch"
        fi
    fi
fi

if [[ "$CLEANUP_BRANCH" == true ]]; then
    info "=========================================="
    info "STEP 5: Cleanup"
    info "=========================================="
    echo ""
    
    # Git flow already deletes the local branch, but clean remote if exists
    if git ls-remote --heads origin release/$NEW_VERSION &>/dev/null; then
        info "Deleting remote release branch..."
        git push origin --delete release/$NEW_VERSION
        success "Remote branch deleted"
    fi
fi

echo ""
echo "======================================"
success "🎉 Release Complete!"
echo "======================================"
echo ""
info "Released: $PACKAGE_NAME v$NEW_VERSION"
info "Tag created: $PACKAGE_NAME@v$NEW_VERSION"
echo ""

if [[ "$AUTO_PUSH" == true ]]; then
    success "✅ Pushed to GitHub"
    info "GitHub Actions should create the release automatically"
else
    warn "⚠️  Not pushed to GitHub yet"
    echo ""
    echo "Push manually with:"
    echo "  git checkout main"
    echo "  git push origin main --follow-tags"
    echo "  git push origin develop"
fi

echo ""
info "Next steps:"
echo "  - Check CHANGELOG.md in $PACKAGE_DIR"
echo "  - Verify version in $PACKAGE_DIR/package.json"
echo "  - Monitor GitHub Actions (if pushed)"
echo ""
