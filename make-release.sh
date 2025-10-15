#!/bin/bash

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🚀 MAKING A MINOR RELEASE FOR PACKAGE-A"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd packages/package-a

echo "📦 Current version:"
grep '"version"' package.json | head -1
echo ""

echo "📋 Recent commits:"
git log --oneline -5 | head -5
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔍 DRY RUN - Preview"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

npx release-it --dry-run minor --no-git.push --no-github.release

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ EXECUTE RELEASE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Ready to execute? This will:"
echo "  • Bump version: 1.0.0 → 1.1.0"
echo "  • Update CHANGELOG.md"
echo "  • Create commit: chore(package-a): release v1.1.0"
echo "  • Create tag: package-a@v1.1.0"
echo "  • (Won't push to GitHub - local only)"
echo ""

read -p "Execute release? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Executing release..."
    echo ""
    
    npx release-it minor --no-git.push --no-github.release --ci
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  ✨ RELEASE COMPLETE!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    cd ../..
    
    echo "📦 New version:"
    grep '"version"' packages/package-a/package.json | head -1
    echo ""
    
    echo "📝 Latest commit:"
    git log --oneline -1
    echo ""
    
    echo "🏷️  Latest tag:"
    git tag | tail -1
    echo ""
    
    echo "✅ Done! Tag created: package-a@v1.1.0"
    echo ""
    echo "To verify:"
    echo "  $ git log --oneline -1"
    echo "  $ git tag"
    echo "  $ cat packages/package-a/CHANGELOG.md"
    echo ""
else
    echo ""
    echo "❌ Release cancelled"
    echo ""
fi
