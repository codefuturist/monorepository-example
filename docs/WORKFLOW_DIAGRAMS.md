# Workflow Diagrams

This directory contains a Python script to generate visual diagrams of the CI/CD workflows used in this monorepository.

## Prerequisites

Install the required Python package:

```bash
pip install diagrams
```

The `diagrams` library also requires Graphviz to be installed:

**macOS:**
```bash
brew install graphviz
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install graphviz
```

**Windows:**
Download and install from https://graphviz.org/download/

## Generating Diagrams

Run the script to generate all workflow diagrams:

```bash
python3 scripts/generate-workflow-diagrams.py
```

Or make it executable and run directly:

```bash
chmod +x scripts/generate-workflow-diagrams.py
./scripts/generate-workflow-diagrams.py
```

## Generated Diagrams

The script generates the following diagrams in the `docs/diagrams/` directory:

**Note:** All diagrams are also available in Mermaid format (`.mmd` files) in `docs/diagrams/mermaid/` for easy inline viewing and editing. See [Mermaid Diagrams README](diagrams/mermaid/README.md) for details.

### 1. CI Workflow (`ci_workflow.png`)
Shows the continuous integration workflow that runs on every push or pull request to main/develop branches:
- Checkout code
- Setup Node.js environment
- Install dependencies
- Run linter
- Run tests
- Build packages

### 2. Release Workflow (`release_workflow.png`)
Illustrates the root monorepo release workflow triggered by version tags (v*.*.*):
- Build and test verification
- Tag extraction
- GitHub release creation
- Optional npm publishing

### 3. Package Release Workflow (`package_release_workflow.png`)
Displays the individual package release workflows for different language ecosystems:
- Python packages (a, b, c)
- Rust packages (e, i)
- Go package (g)
- C++ package (d)
- Java package (h)
- Swift package (f)

Each language-specific workflow uses a reusable workflow template for consistency.

### 4. Complete Workflow (`complete_workflow.png`)
Provides a high-level overview of the entire development and release process:
- Development branches trigger CI
- Tag creation branches to appropriate release workflows
- All workflows produce GitHub releases with artifacts

### 5. Package Build Pipeline (`package_build_pipeline.png`)
Details the build matrix and artifact generation process for package releases:
- Multi-platform build matrix (Linux, macOS, Windows)
- Binary compilation and testing
- Artifact packaging
- Checksum generation
- Release artifact upload

### 6. Git Flow Branching Strategy (`git_flow.png`)
Visualizes the Git Flow branching model used in this repository:
- main (production)
- develop (integration)
- feature/* (new features)
- release/* (release preparation)
- hotfix/* (urgent fixes)

Shows how branches interact and which CI/CD workflows are triggered by each branch.

### 7. Automated Release Workflow (`automated_release_workflow.png`)
Comprehensive end-to-end diagram showing the complete automated release process with Git Flow and Commitizen, **organized by branch**:

**feature/* branch:**
- Start feature with `git flow feature start`
- Write code with conventional commits using `git cz`
- Push and create pull request

**develop branch:**
- CI tests run automatically
- Merge approved features
- Prepare for release

**release/* branch:**
- Start release with `git flow release start`
- Run `cz bump` for automated version calculation
- Update CHANGELOG.md and version files automatically
- Create release commit and tag

**main branch:**
- Finish release with `git flow release finish`
- Push tag triggers GitHub Actions
- Automated GitHub release creation with artifacts

**Back to develop:**
- Changes automatically merged back to develop
- Release cycle complete

This diagram clearly shows which branch each step occurs on, making it easy to understand the git flow process with commitizen automation.

## Workflow Details

### Continuous Integration
- **Trigger**: Push or PR to main, develop, release/*, feature/* branches
- **Purpose**: Ensure code quality and prevent regressions
- **Actions**: Lint, test, and build all packages

### Root Release
- **Trigger**: Tag matching `v*.*.*` (e.g., v1.0.0)
- **Purpose**: Release the entire monorepo
- **Actions**: Build, test, create GitHub release

### Package-Specific Releases
- **Trigger**: Tag matching `package-{name}@v*.*.*` (e.g., package-a@v1.2.3)
- **Purpose**: Release individual packages with language-specific builds
- **Actions**: 
  - Build for multiple platforms/architectures
  - Generate checksums
  - Create GitHub release with platform binaries
  - Attach all artifacts to release

## Package Types and Build Systems

| Package | Language | Build System | Platforms |
|---------|----------|--------------|-----------|
| package-a, b, c | Python | PyInstaller | Linux, macOS, Windows (x64, ARM64) |
| package-e, i | Rust | Cargo | Linux, macOS, Windows (x64, ARM64) |
| package-g | Go | go build | Linux, macOS, Windows (x64, ARM64) |
| package-d | C++ | CMake | Linux, macOS, Windows |
| package-h | Java | Maven | Cross-platform JAR |
| package-f | Swift | SPM | macOS (x64, ARM64) |

## Customization

To modify or add new diagrams, edit `scripts/generate-workflow-diagrams.py`:

1. Import required diagram components from the `diagrams` library
2. Create a new function following the pattern of existing diagram functions
3. Add the function call in the `__main__` section
4. Run the script to generate updated diagrams

## Resources

- [Diagrams Library Documentation](https://diagrams.mingrammer.com/)
- [GitHub Actions Workflows](../.github/workflows/)
- [Git Flow Guide](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
