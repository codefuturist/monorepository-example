# Monorepo Release Management Plan with release-it

## Overview
This plan outlines the implementation of an automated release process for a monorepo using:
- **release-it**: Version management and release automation
- **GitHub Actions**: CI/CD workflow automation
- **Git Flow**: Branching model for development and releases
- **Git Tags**: Trigger mechanism for automated releases

---

## 1. Repository Structure

### Monorepo Layout
```
monorepository-example/
├── packages/
│   ├── package-a/
│   │   ├── package.json
│   │   ├── CHANGELOG.md
│   │   └── src/
│   ├── package-b/
│   │   ├── package.json
│   │   ├── CHANGELOG.md
│   │   └── src/
│   └── package-c/
│       ├── package.json
│       ├── CHANGELOG.md
│       └── src/
├── .github/
│   └── workflows/
│       ├── release.yml
│       └── publish.yml
├── .release-it.json (or .release-it.js)
├── package.json (root)
├── lerna.json (optional, for monorepo management)
└── README.md
```

---

## 2. Git Flow Branching Model

### Branch Structure
- **main**: Production-ready code
- **develop**: Integration branch for features
- **feature/***: Feature development branches
- **release/***: Release preparation branches
- **hotfix/***: Emergency fixes for production

### Release Workflow
1. Development happens in `feature/*` branches
2. Features merge into `develop`
3. Create `release/*` branch from `develop`
4. Finalize release, run release-it
5. Merge `release/*` into `main` and `develop`
6. Tag `main` with version number
7. GitHub Action triggers on tag push

---

## 3. release-it Configuration

### Root Configuration (`.release-it.json`)
```json
{
  "git": {
    "commitMessage": "chore: release v${version}",
    "tagName": "v${version}",
    "tagAnnotation": "Release v${version}",
    "requireBranch": ["main", "release/*"],
    "requireCleanWorkingDir": true,
    "requireUpstream": true,
    "addUntrackedFiles": false
  },
  "github": {
    "release": true,
    "releaseName": "Release ${version}",
    "releaseNotes": "See CHANGELOG.md for details"
  },
  "npm": {
    "publish": false
  },
  "hooks": {
    "before:init": ["npm run test"],
    "after:bump": ["npm run build"],
    "after:release": "echo Successfully released ${name} v${version}"
  },
  "plugins": {
    "@release-it/conventional-changelog": {
      "preset": "angular",
      "infile": "CHANGELOG.md"
    }
  }
}
```

### Package-Specific Configuration
Each package can have its own `.release-it.json` for independent versioning:
```json
{
  "git": {
    "commitMessage": "chore(package-a): release v${version}",
    "tagName": "package-a@v${version}",
    "requireBranch": ["main", "release/*"]
  },
  "github": {
    "release": true,
    "releaseName": "package-a v${version}"
  },
  "npm": {
    "publish": true
  }
}
```

---

## 4. GitHub Actions Workflow

### Trigger: Tag-based Release (`.github/workflows/release.yml`)

#### Purpose
- Automatically create GitHub releases when a tag is pushed
- Build and publish packages
- Upload release artifacts
- Notify team of successful releases

#### Workflow Structure
```yaml
name: Release

on:
  push:
    tags:
      - 'v*.*.*'              # Root releases (v1.0.0)
      - 'package-*@v*.*.*'    # Package releases (package-a@v1.0.0)

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - Checkout code
      - Setup Node.js
      - Install dependencies
      - Run tests
      - Build packages
      - Create GitHub Release
      - Publish to npm (if applicable)
      - Upload artifacts
      - Send notifications
```

### Additional Workflow: Pre-release Checks (`.github/workflows/publish.yml`)

#### Purpose
- Validate release branch before tagging
- Run comprehensive tests
- Ensure changelog is updated
- Verify version bumps

---

## 5. Release Process

### For Monorepo Root Release
```bash
# 1. Switch to develop branch
git checkout develop
git pull origin develop

# 2. Create release branch
git checkout -b release/v1.2.0

# 3. Run release-it (bumps version, updates changelog)
npm run release -- --dry-run  # Test first
npm run release               # Actual release

# 4. Push release branch
git push origin release/v1.2.0

# 5. Create PR to main
# Review and merge PR

# 6. Tag will be pushed automatically or manually
git checkout main
git pull origin main
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0

# 7. GitHub Action triggers automatically
```

### For Individual Package Release
```bash
# 1. Navigate to package directory
cd packages/package-a

# 2. Create release branch
git checkout -b release/package-a-v1.2.0

# 3. Run release-it for specific package
npm run release:package-a -- --dry-run
npm run release:package-a

# 4. Follow same process as above
git tag -a package-a@v1.2.0 -m "Release package-a v1.2.0"
git push origin package-a@v1.2.0
```

---

## 6. Package.json Scripts

### Root package.json
```json
{
  "scripts": {
    "release": "release-it",
    "release:dry": "release-it --dry-run",
    "release:package-a": "cd packages/package-a && release-it",
    "release:package-b": "cd packages/package-b && release-it",
    "release:package-c": "cd packages/package-c && release-it",
    "test": "npm run test --workspaces",
    "build": "npm run build --workspaces"
  }
}
```

---

## 7. Dependencies Required

### Root Dependencies
```json
{
  "devDependencies": {
    "release-it": "^17.0.0",
    "@release-it/conventional-changelog": "^8.0.0",
    "conventional-changelog-cli": "^4.0.0"
  }
}
```

---

## 8. Versioning Strategies

### Option A: Unified Versioning
- All packages share the same version number
- Simpler to manage
- Release all packages together
- Tag format: `v1.2.3`

### Option B: Independent Versioning
- Each package has its own version
- More complex but flexible
- Release packages independently
- Tag format: `package-a@v1.2.3`

### Option C: Hybrid Approach
- Critical packages versioned together
- Utilities versioned independently
- Tag format: Mix of both above

---

## 9. GitHub Release Configuration

### Release Notes Generation
- Automatically generated from conventional commits
- Include contributors list
- Link to comparison view
- Highlight breaking changes
- List all changes by type (feat, fix, chore, etc.)

### Release Assets
- Built artifacts (dist/ files)
- Source code (auto-included by GitHub)
- Documentation PDFs
- Release signatures (optional)

---

## 10. Protected Branch Rules

### Main Branch Protection
- Require pull request reviews (at least 1)
- Require status checks to pass
- Require branches to be up to date
- Include administrators
- Restrict who can push (CI/CD bot + admins)

### Develop Branch Protection
- Require pull request reviews
- Require status checks to pass
- Allow force pushes (for maintainers only)

---

## 11. Conventional Commits

### Commit Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation only
- **style**: Code style changes
- **refactor**: Code refactoring
- **perf**: Performance improvements
- **test**: Adding tests
- **chore**: Maintenance tasks

### Examples
```bash
feat(package-a): add authentication module
fix(package-b): resolve memory leak in cache
chore: update dependencies
docs: update release process documentation
```

---

## 12. Automation Features

### Pre-release Checks
- Run all tests
- Lint code
- Verify no uncommitted changes
- Check for breaking changes
- Validate changelog format

### Post-release Actions
- Update dependent repositories
- Notify Slack/Discord channel
- Update documentation site
- Create announcement blog post
- Send email to stakeholders

---

## 13. Rollback Strategy

### If Release Fails
1. Delete the git tag: `git tag -d v1.2.3 && git push origin :refs/tags/v1.2.3`
2. Delete GitHub release through UI or API
3. Revert commits if necessary
4. Fix issues and retry

### If Published Package Has Issues
1. Publish a hotfix version
2. Deprecate broken version on npm
3. Update documentation
4. Notify users

---

## 14. Security Considerations

### GitHub Secrets Required
- `GITHUB_TOKEN`: Automatically provided
- `NPM_TOKEN`: For npm publishing (if applicable)
- `SLACK_WEBHOOK`: For notifications (optional)

### Permissions
- Workflow needs write access to:
  - Contents (for creating releases)
  - Pull requests (for release PRs)
  - Issues (for linking issues)

---

## 15. Testing Strategy

### Pre-release Testing
- Unit tests (all packages)
- Integration tests
- E2E tests (if applicable)
- Build verification
- Dependency compatibility

### Release Validation
- Dry run release-it before actual release
- Test in staging environment
- Verify changelog accuracy
- Check version bump correctness

---

## 16. Documentation Requirements

### Files to Maintain
- **CHANGELOG.md**: Auto-generated by release-it
- **README.md**: Installation and usage instructions
- **CONTRIBUTING.md**: How to contribute and release
- **RELEASE.md**: This plan document
- **package.json**: Scripts and metadata

### Documentation Updates
- Update version numbers
- Document breaking changes
- Update migration guides
- Keep API documentation current

---

## 17. Monitoring and Notifications

### Success Notifications
- GitHub release created
- Slack/Discord message
- Email to team
- Update status page

### Failure Notifications
- Detailed error logs
- Slack alert
- Rollback instructions
- Incident report

---

## 18. Implementation Phases

### Phase 1: Setup (Week 1)
- [ ] Initialize monorepo structure
- [ ] Install release-it and dependencies
- [ ] Configure release-it for root and packages
- [ ] Set up conventional commits

### Phase 2: Git Flow (Week 2)
- [ ] Establish branch protection rules
- [ ] Document git flow process
- [ ] Create branch templates
- [ ] Train team on workflow

### Phase 3: GitHub Actions (Week 3)
- [ ] Create release workflow
- [ ] Create publish workflow
- [ ] Set up secrets and permissions
- [ ] Test workflows in feature branch

### Phase 4: Testing (Week 4)
- [ ] Dry run releases for all packages
- [ ] Test tag-triggered workflows
- [ ] Verify GitHub releases creation
- [ ] Validate rollback procedures

### Phase 5: Production (Week 5)
- [ ] First production release
- [ ] Monitor and iterate
- [ ] Document lessons learned
- [ ] Optimize workflow

---

## 19. Maintenance

### Regular Tasks
- Review and merge dependabot PRs
- Update release-it configuration
- Audit GitHub Actions usage
- Review release notes quality
- Update documentation

### Quarterly Reviews
- Evaluate versioning strategy
- Assess automation effectiveness
- Gather team feedback
- Plan improvements

---

## 20. Resources and References

### Documentation
- [release-it Documentation](https://github.com/release-it/release-it)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Git Flow Workflow](https://nvie.com/posts/a-successful-git-branching-model/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)

### Community
- release-it GitHub Discussions
- GitHub Actions Community Forum
- Stack Overflow tags: release-it, github-actions, monorepo

---

## Appendix A: Example Commands Cheatsheet

```bash
# Start a new feature
git checkout develop
git checkout -b feature/my-feature

# Start a release
git checkout develop
git checkout -b release/v1.2.0

# Dry run release
npm run release:dry

# Actual release
npm run release

# Tag and push
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0

# Hotfix
git checkout main
git checkout -b hotfix/v1.2.1
# ... make fixes ...
npm run release
git checkout main
git merge hotfix/v1.2.1
git checkout develop
git merge hotfix/v1.2.1
```

---

## Appendix B: Troubleshooting

### Common Issues
1. **Tag already exists**: Delete and recreate tag
2. **Workflow not triggering**: Check tag format matches pattern
3. **Permission denied**: Verify GitHub token permissions
4. **npm publish fails**: Check NPM_TOKEN secret
5. **Tests fail on CI**: Ensure environment parity

### Debug Mode
```bash
# Run release-it with debug output
DEBUG=release-it:* npm run release -- --dry-run
```

---

## Success Metrics

- Time to release: < 10 minutes
- Failed releases: < 5%
- Rollbacks required: < 2%
- Developer satisfaction: > 80%
- Changelog accuracy: > 95%

---

**Document Version**: 1.0.0  
**Last Updated**: October 15, 2025  
**Status**: Planning Phase
