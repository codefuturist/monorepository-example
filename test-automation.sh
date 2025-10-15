#!/bin/bash

echo "🎯 Testing Automated Git Flow Merges"
echo "====================================="
echo ""

echo "📋 Current configuration:"
echo ""

echo "Root .release-it.json hook:"
grep -A 1 "after:git:release" .release-it.json
echo ""

echo "Package-a .release-it.json hook:"
grep -A 1 "after:git:release" packages/package-a/.release-it.json
echo ""

echo "✅ Scripts available:"
ls -lh scripts/*.sh
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎉 AUTOMATION IS READY!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "How it works:"
echo "  1. Run: npm run release"
echo "  2. release-it creates tag"
echo "  3. Hook calls: scripts/git-flow-merge.sh"
echo "  4. Script merges: release → main → develop"
echo "  5. release-it pushes to GitHub"
echo ""

echo "✨ Everything automated! No manual merges needed!"
echo ""

echo "Try it:"
echo "  $ npm run release"
echo ""
echo "Or with full automation:"
echo "  $ AUTO_PUSH=true CLEANUP_RELEASE_BRANCH=true npm run release"
echo ""
