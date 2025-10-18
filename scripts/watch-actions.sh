#!/bin/bash

# ========================================
# Watch GitHub Actions Workflows
# ========================================
# This script watches the status of GitHub Actions
# workflows in real-time using the GitHub CLI

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
info "🔍 GitHub Actions Workflow Monitor"
echo "======================================"
echo ""

# Check if gh CLI is installed
if ! command -v gh &>/dev/null; then
    error "GitHub CLI (gh) is not installed"
    echo ""
    info "Install it with:"
    echo ""
    echo "  # macOS"
    echo "  brew install gh"
    echo ""
    echo "  # Linux (Ubuntu/Debian)"
    echo "  sudo apt install gh"
    echo ""
    echo "  # Or download from:"
    echo "  https://cli.github.com/"
    echo ""
    exit 1
fi

# Check authentication
if ! gh auth status &>/dev/null; then
    warn "You're not authenticated with GitHub"
    echo ""
    info "Authenticate now with:"
    echo "  gh auth login"
    echo ""
    read -p "$(echo -e ${CYAN}Authenticate now? [y/N]: ${NC})" -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gh auth login
    else
        error "Authentication required to watch workflows"
        exit 1
    fi
fi

success "GitHub CLI is ready"
echo ""

# Check if we're in a git repository
if [[ ! -d .git ]]; then
    error "Not in a git repository"
    exit 1
fi

# Check if remote is configured
if ! git remote get-url origin &>/dev/null; then
    error "No remote 'origin' configured"
    exit 1
fi

REMOTE_URL=$(git remote get-url origin)
REPO_PATH=$(echo "$REMOTE_URL" | sed 's/.*github.com[:/]\(.*\)\.git/\1/' | sed 's/.*github.com[:/]\(.*\)/\1/')

info "Repository: $REPO_PATH"
echo ""

# Parse command line arguments
COMMAND="${1:-watch}"

case "$COMMAND" in
    watch|w)
        info "Watching most recent workflow run..."
        echo ""
        info "💡 Tip: Press Ctrl+C to stop watching"
        echo ""
        sleep 1
        gh run watch || warn "No recent workflow runs found"
        ;;
        
    list|ls)
        info "Recent workflow runs:"
        echo ""
        gh run list --limit 10
        ;;
        
    view|v)
        if [[ -n "$2" ]]; then
            info "Viewing workflow run #$2..."
            echo ""
            gh run view "$2"
        else
            info "Viewing most recent workflow run..."
            echo ""
            gh run view
        fi
        ;;
        
    logs|log)
        if [[ -n "$2" ]]; then
            info "Fetching logs for workflow run #$2..."
            echo ""
            gh run view "$2" --log
        else
            info "Fetching logs for most recent workflow run..."
            echo ""
            gh run view --log
        fi
        ;;
        
    status|s)
        info "Current workflow status:"
        echo ""
        gh run list --limit 5 | head -6
        echo ""
        
        # Show detailed status of most recent run
        LATEST_RUN=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
        if [[ -n "$LATEST_RUN" ]]; then
            info "Latest run details:"
            echo ""
            gh run view "$LATEST_RUN" || true
        fi
        ;;
        
    open|o)
        info "Opening GitHub Actions in browser..."
        gh browse --repo "$REPO_PATH" -b "actions"
        ;;
        
    help|h|--help)
        cat << EOF
GitHub Actions Workflow Monitor

Usage: $0 [command] [options]

Commands:
  watch, w           Watch the most recent workflow run (default)
  list, ls           List recent workflow runs
  view, v [run-id]   View details of a workflow run
  logs, log [run-id] View logs of a workflow run
  status, s          Show status of recent workflows
  open, o            Open GitHub Actions page in browser
  help, h            Show this help message

Examples:
  $0                  # Watch most recent workflow
  $0 watch            # Same as above
  $0 list             # List recent runs
  $0 view 1234        # View specific run
  $0 logs             # View logs of latest run
  $0 status           # Show status summary
  $0 open             # Open in browser

GitHub CLI Features:
  gh run watch        # Watch interactively
  gh run list         # List all runs
  gh run view         # View run details
  gh run rerun        # Rerun a workflow
  gh run cancel       # Cancel a workflow

EOF
        ;;
        
    *)
        error "Unknown command: $COMMAND"
        echo ""
        info "Use '$0 help' for usage information"
        exit 1
        ;;
esac

echo ""
