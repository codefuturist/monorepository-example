#!/bin/bash

# ========================================
# Install git-flow CLI Tool
# ========================================
# This script installs git-flow-avh (AVH Edition)
# which is the maintained version of git-flow

set -e

echo "🔧 Git-Flow CLI Installation"
echo "======================================"
echo ""

# Check if already installed
if command -v git-flow &>/dev/null || git flow version &>/dev/null 2>&1; then
    echo "✅ git-flow is already installed"
    git flow version || echo "Version detection not available"
    echo ""
    echo "You're all set! 🎉"
    exit 0
fi

echo "📦 Installing git-flow..."
echo ""

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)
        echo "🐧 Detected Linux"
        if command -v apt-get &>/dev/null; then
            echo "Using apt-get..."
            sudo apt-get update
            sudo apt-get install -y git-flow
        elif command -v yum &>/dev/null; then
            echo "Using yum..."
            sudo yum install -y gitflow
        elif command -v dnf &>/dev/null; then
            echo "Using dnf..."
            sudo dnf install -y gitflow
        else
            echo "❌ Could not detect package manager"
            echo "Please install git-flow manually:"
            echo "  https://github.com/petervanderdoes/gitflow-avh/wiki/Installation"
            exit 1
        fi
        ;;
    Darwin*)
        echo "🍎 Detected macOS"
        if command -v brew &>/dev/null; then
            echo "Using Homebrew..."
            brew install git-flow-avh
        else
            echo "❌ Homebrew not found"
            echo "Please install Homebrew first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            echo ""
            echo "Then run this script again."
            exit 1
        fi
        ;;
    CYGWIN*|MINGW*|MSYS*)
        echo "🪟 Detected Windows"
        echo "Please install git-flow manually:"
        echo "  - Download from: https://github.com/petervanderdoes/gitflow-avh/wiki/Installation"
        echo "  - Or use: choco install gitflow-avh (if you have Chocolatey)"
        exit 1
        ;;
    *)
        echo "❌ Unknown OS: ${OS}"
        echo "Please install git-flow manually:"
        echo "  https://github.com/petervanderdoes/gitflow-avh/wiki/Installation"
        exit 1
        ;;
esac

# Verify installation
echo ""
echo "✅ Verifying installation..."
if command -v git-flow &>/dev/null || git flow version &>/dev/null 2>&1; then
    echo "✅ git-flow installed successfully!"
    git flow version || echo "Installed!"
else
    echo "❌ Installation failed"
    echo "Please try manual installation:"
    echo "  https://github.com/petervanderdoes/gitflow-avh/wiki/Installation"
    exit 1
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "Next step: Initialize git-flow in your repository"
echo "  cd /path/to/repo"
echo "  git flow init -d"
echo ""
