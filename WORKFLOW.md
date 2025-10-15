# Visual Workflow Guide

## 🔄 Complete Release Cycle

```
┌─────────────────────────────────────────────────────────────────┐
│                     GIT FLOW BRANCHES                           │
└─────────────────────────────────────────────────────────────────┘

main        ●─────────────────────●───────────────────────●────>
            │                     ↑                       ↑
            │                     │                       │
            │                     │ [PR & Merge]          │ [PR & Merge]
            │                     │                       │
develop     ●─────●───●───●───────●───────●───●───────────●────>
            │     ↑   ↑   ↑             ↑   ↑
            │     │   │   │             │   │
feature/*         ●───┘   │             ●───┘
                          │
release/*                 ●


┌─────────────────────────────────────────────────────────────────┐
│                   AUTOMATED RELEASE FLOW                         │
└─────────────────────────────────────────────────────────────────┘

1. DEVELOPMENT
   ┌──────────────┐
   │ feature/xyz  │
   └──────┬───────┘
          │ git commit -m "feat: add feature"
          ↓
   ┌──────────────┐
   │   develop    │ ──→ [CI: Test + Build]
   └──────────────┘


2. RELEASE PREPARATION
   ┌──────────────┐
   │ release/     │
   │   v1.1.0     │
   └──────┬───────┘
          │ npm run release
          │ • Bump version
          │ • Update CHANGELOG
          │ • Create commit
          │ • Create tag
          ↓
   ┌──────────────┐
   │ Push to      │
   │ remote       │
   └──────────────┘


3. MERGE TO MAIN
   ┌──────────────┐
   │ Pull Request │
   │ to main      │
   └──────┬───────┘
          │ Review & Approve
          ↓
   ┌──────────────┐
   │     main     │ ──→ [CI: Test + Build]
   └──────┬───────┘
          │
          │ Tag: v1.1.0 pushed
          ↓
   ┌──────────────┐
   │   TRIGGER    │
   │   GitHub     │
   │   Action     │
   └──────┬───────┘
          │
          ↓


4. AUTOMATED DEPLOYMENT
   
   GitHub Actions Workflow
   ┌─────────────────────────────────┐
   │  1. Checkout code               │
   │  2. Setup Node.js               │
   │  3. Install dependencies        │
   │  4. Run tests                   │
   │  5. Build packages              │
   │  6. Create GitHub Release       │
   │  7. Publish to npm (optional)   │
   └─────────────────────────────────┘
                  │
                  ↓
   ┌─────────────────────────────────┐
   │    ✅ Release Published!         │
   │                                 │
   │  • GitHub Release created       │
   │  • Release notes generated      │
   │  • Packages published           │
   │  • Team notified                │
   └─────────────────────────────────┘


5. MERGE BACK TO DEVELOP
   ┌──────────────┐
   │   develop    │ ←── merge main
   └──────────────┘
   
   Continue development...


┌─────────────────────────────────────────────────────────────────┐
│                    TAG PATTERNS & TRIGGERS                       │
└─────────────────────────────────────────────────────────────────┘

Root Monorepo Release:
  Tag: v1.2.3
  Pattern: v*.*.*
  Command: npm run release
  
Individual Package Release:
  Tag: package-a@v1.0.0
  Pattern: package-*@v*.*.*
  Command: npm run release:package-a


┌─────────────────────────────────────────────────────────────────┐
│              CONVENTIONAL COMMIT TYPES                           │
└─────────────────────────────────────────────────────────────────┘

feat:     New feature         → MINOR version bump (1.1.0)
fix:      Bug fix             → PATCH version bump (1.0.1)
docs:     Documentation       → No version bump
chore:    Maintenance         → No version bump
refactor: Code refactoring    → No version bump
test:     Adding tests        → No version bump
perf:     Performance         → PATCH version bump (1.0.1)

BREAKING CHANGE: in footer    → MAJOR version bump (2.0.0)


┌─────────────────────────────────────────────────────────────────┐
│                      PACKAGE STRUCTURE                           │
└─────────────────────────────────────────────────────────────────┘

monorepository-example/
│
├── Root Level
│   ├── .release-it.json     → Root release config
│   ├── package.json         → Workspaces definition
│   └── CHANGELOG.md         → Root changelog
│
└── Packages
    ├── package-a/
    │   ├── .release-it.json → Package config
    │   ├── package.json     → Package metadata
    │   ├── CHANGELOG.md     → Package changelog
    │   └── src/             → Source code
    │
    ├── package-b/           → Same structure
    └── package-c/           → Same structure


┌─────────────────────────────────────────────────────────────────┐
│                    QUICK COMMAND REFERENCE                       │
└─────────────────────────────────────────────────────────────────┘

Development:
  git checkout -b feature/xyz          # Start feature
  git commit -m "feat: description"    # Commit with conventional format
  git push origin feature/xyz          # Push feature

Release Preparation:
  git checkout -b release/v1.1.0       # Create release branch
  npm run release:dry                  # Test release (dry run)
  npm run release                      # Execute release
  git push origin release/v1.1.0       # Push branch
  git push origin --tags               # Push tags

Individual Package:
  npm run release:package-a            # Release package-a
  npm run release:package-b            # Release package-b
  npm run release:package-c            # Release package-c

Testing:
  npm test                             # Run all tests
  npm run build                        # Build all packages
  npm run lint                         # Lint all packages

Hotfix:
  git checkout -b hotfix/v1.0.1        # Create hotfix branch
  npm run release                      # Release hotfix
  git checkout main && git merge       # Merge to main
  git checkout develop && git merge    # Merge to develop


┌─────────────────────────────────────────────────────────────────┐
│                     SUCCESS INDICATORS                           │
└─────────────────────────────────────────────────────────────────┘

✅ CHANGELOG.md updated with new version
✅ package.json version bumped
✅ Git tag created (e.g., v1.1.0)
✅ GitHub Actions workflow triggered
✅ All tests passed
✅ Packages built successfully
✅ GitHub Release created
✅ Release notes auto-generated


┌─────────────────────────────────────────────────────────────────┐
│                    TROUBLESHOOTING                               │
└─────────────────────────────────────────────────────────────────┘

Tag already exists:
  git tag -d v1.0.0                    # Delete local
  git push origin :refs/tags/v1.0.0    # Delete remote

Workflow not triggering:
  • Check tag format matches pattern
  • Verify GitHub Actions enabled
  • Check workflow permissions

Release failed:
  • Check test failures
  • Verify clean working directory
  • Ensure on correct branch (main/release/*)

Rollback release:
  git tag -d v1.0.0                    # Delete tag
  git push origin :refs/tags/v1.0.0    # Delete remote tag
  # Delete GitHub release manually
  git revert <commit>                  # Revert changes
```

## 🎯 Remember

1. **Always commit with conventional format** for automatic changelog
2. **Run dry-run first** to test before actual release
3. **Tags trigger automation** - push carefully
4. **Merge back to develop** after releasing
5. **Review CHANGELOG** before publishing

## 📚 More Information

- See `README.md` for full documentation
- See `CONTRIBUTING.md` for contribution guidelines
- See `QUICKSTART.md` for getting started
- See `IMPLEMENTATION_SUMMARY.md` for what was created
