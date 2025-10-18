#!/bin/bash

# ========================================
# Setup GitHub Remote
# ========================================
# Interactive script to set up GitHub remote for the first time

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
header() { echo -e "${PURPLE}$1${NC}"; }
prompt() { echo -e "${CYAN}$1${NC}"; }

clear

cat << "EOF"
╔═══════════════════════════════════════════════════════╗
║                                                       ║
║     🔗 GitHub Remote Setup                            ║
║                                                       ║
╚═══════════════════════════════════════════════════════╝
EOF

echo ""
info "This script will help you connect your local repo to GitHub"
echo ""

# Check if in git repository
if [[ ! -d .git ]]; then
    error "Not in a git repository"
    exit 1
fi

# Check if remote already exists
if git remote get-url origin &>/dev/null; then
    success "Remote 'origin' is already configured!"
    echo ""
    REMOTE_URL=$(git remote get-url origin)
    info "Current remote: $REMOTE_URL"
    echo ""
    
    read -p "$(prompt 'Do you want to change it? [y/N]: ')" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Keeping existing remote"
        
        # Check if we should push
        echo ""
        read -p "$(prompt 'Push all branches and tags to GitHub now? [y/N]: ')" -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo ""
            info "Pushing to GitHub..."
            
            # Push main
            if git show-ref --verify --quiet refs/heads/main; then
                info "Pushing main branch..."
                git push -u origin main --follow-tags || warn "Could not push main"
            fi
            
            # Push develop
            if git show-ref --verify --quiet refs/heads/develop; then
                info "Pushing develop branch..."
                git push -u origin develop || warn "Could not push develop"
            fi
            
            # Push all tags
            info "Pushing all tags..."
            git push origin --tags || warn "Could not push tags"
            
            echo ""
            success "Pushed to GitHub!"
        fi
        
        exit 0
    fi
    
    # Remove old remote
    info "Removing old remote..."
    git remote remove origin
fi

echo ""
header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
header "  Step 1: Create GitHub Repository"
header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

info "First, create a repository on GitHub:"
echo ""
echo "  1. Go to: https://github.com/new"
echo "  2. Repository name: monorepository-example"
echo "  3. DO NOT initialize with README, .gitignore, or license"
echo "  4. Click 'Create repository'"
echo ""

read -p "$(prompt 'Have you created the repository? [y/N]: ')" -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    warn "Please create the repository first, then run this script again"
    exit 0
fi

echo ""
header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
header "  Step 2: Choose Connection Method"
header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

info "How do you want to connect?"
echo ""
echo "  1. HTTPS (easier, uses token)"
echo "  2. SSH (better for automation, uses keys)"
echo ""

read -p "$(prompt 'Choose [1/2]: ')" -n 1 -r
echo ""

if [[ $REPLY == "1" ]]; then
    CONNECTION_METHOD="https"
    echo ""
    info "Using HTTPS connection"
    echo ""
    
    # Get GitHub username
    read -p "$(prompt 'Enter your GitHub username: ')" GITHUB_USER
    
    if [[ -z "$GITHUB_USER" ]]; then
        error "Username cannot be empty"
        exit 1
    fi
    
    REMOTE_URL="https://github.com/${GITHUB_USER}/monorepository-example.git"
    
    echo ""
    info "You'll need a Personal Access Token (PAT) to push"
    echo ""
    info "Generate one at: https://github.com/settings/tokens"
    echo "  Scopes needed: repo (full control)"
    echo ""
    info "When you push, use the token as your password"
    echo ""
    
elif [[ $REPLY == "2" ]]; then
    CONNECTION_METHOD="ssh"
    echo ""
    info "Using SSH connection"
    echo ""
    
    # Get GitHub username
    read -p "$(prompt 'Enter your GitHub username: ')" GITHUB_USER
    
    if [[ -z "$GITHUB_USER" ]]; then
        error "Username cannot be empty"
        exit 1
    fi
    
    REMOTE_URL="git@github.com:${GITHUB_USER}/monorepository-example.git"
    
    echo ""
    info "Make sure you have SSH keys configured"
    echo ""
    info "Test SSH connection:"
    echo "  ssh -T git@github.com"
    echo ""
    info "If not set up, see: https://docs.github.com/en/authentication/connecting-to-github-with-ssh"
    echo ""
    
else
    error "Invalid choice"
    exit 1
fi

echo ""
header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
header "  Step 3: Add Remote"
header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

info "Adding remote: $REMOTE_URL"

if git remote add origin "$REMOTE_URL"; then
    success "Remote added successfully!"
else
    error "Failed to add remote"
    exit 1
fi

echo ""
header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
header "  Step 4: Push to GitHub"
header "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "$(prompt 'Push everything to GitHub now? [y/N]: ')" -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    warn "Skipping push"
    echo ""
    info "You can push later with:"
    echo "  git push -u origin main --follow-tags"
    echo "  git push -u origin develop"
    exit 0
fi

echo ""
info "Pushing to GitHub..."
echo ""

# Push main branch
if git show-ref --verify --quiet refs/heads/main; then
    info "Pushing main branch with tags..."
    if git push -u origin main --follow-tags; then
        success "Main branch pushed"
    else
        error "Failed to push main branch"
        echo ""
        info "This might be due to:"
        echo "  - Authentication issues (check your PAT or SSH keys)"
        echo "  - Network problems"
        echo "  - Repository not empty (conflicts)"
        echo ""
        exit 1
    fi
else
    warn "Main branch doesn't exist yet"
fi

echo ""

# Push develop branch
if git show-ref --verify --quiet refs/heads/develop; then
    info "Pushing develop branch..."
    if git push -u origin develop; then
        success "Develop branch pushed"
    else
        warn "Could not push develop branch (this is OK if it doesn't exist)"
    fi
else
    warn "Develop branch doesn't exist yet"
fi

echo ""

# Push all tags explicitly
LOCAL_TAGS=$(git tag -l | wc -l | tr -d ' ')
if [[ "$LOCAL_TAGS" -gt 0 ]]; then
    info "Pushing $LOCAL_TAGS tags..."
    if git push origin --tags; then
        success "All tags pushed"
    else
        warn "Could not push tags"
    fi
else
    info "No tags to push yet"
fi

echo ""
header "╔═══════════════════════════════════════════════════════╗"
header "║        ✨ Setup Complete! ✨                          ║"
header "╚═══════════════════════════════════════════════════════╝"
echo ""

success "Your repository is now connected to GitHub!"
echo ""

REPO_PATH="${GITHUB_USER}/monorepository-example"
info "View on GitHub:"
echo "  Repository: https://github.com/$REPO_PATH"
echo "  Branches:   https://github.com/$REPO_PATH/branches"
echo "  Tags:       https://github.com/$REPO_PATH/tags"
echo "  Releases:   https://github.com/$REPO_PATH/releases"
echo "  Actions:    https://github.com/$REPO_PATH/actions"
echo ""

info "Next steps:"
echo "  1. Check your repository on GitHub"
echo "  2. Verify tags are visible"
echo "  3. Make a release: ./scripts/quick-release.sh package-a patch --yes"
echo ""

success "Happy coding! 🚀"
echo ""
