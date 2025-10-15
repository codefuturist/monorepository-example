#!/bin/bash
# Quick Setup Script for Monorepo with release-it

echo "🚀 Setting up monorepo with automated releases..."

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Setup git branches (git flow)
echo "🌳 Setting up git flow branches..."

# Initial commit to main
git add .
git commit -m "chore: initial monorepo setup with release-it"

# Create develop branch
git checkout -b develop

echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "  1. Push to GitHub: git remote add origin <your-repo-url>"
echo "  2. Push main: git push -u origin main"
echo "  3. Push develop: git push -u origin develop"
echo "  4. Set up branch protection rules on GitHub"
echo ""
echo "🔖 To create your first release:"
echo "  git checkout -b release/v1.0.0"
echo "  npm run release:dry"
echo "  npm run release"
echo ""
echo "📖 See README.md for full documentation"
