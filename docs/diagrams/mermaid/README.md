# Mermaid Workflow Diagrams

This directory contains Mermaid (`.mmd`) versions of all workflow diagrams. These are text-based diagram definitions that can be:
- Embedded directly in Markdown files
- Rendered automatically in GitHub, GitLab, and VS Code
- Converted to PNG/SVG images using mermaid-cli

## Files

- `ci_workflow.mmd` - Continuous Integration workflow
- `release_workflow.mmd` - Root release workflow
- `package_release_workflow.mmd` - Language-specific package releases
- `complete_workflow.mmd` - Complete workflow overview
- `package_build_pipeline.mmd` - Detailed build pipeline
- `git_flow.mmd` - Git Flow branching strategy
- `automated_release_workflow.mmd` - Automated release with Git Flow + Commitizen

## Viewing Diagrams

### In GitHub/GitLab
Wrap the content in a markdown code block with `mermaid` syntax:

\`\`\`mermaid
flowchart LR
    A[Start] --> B[End]
\`\`\`

### In VS Code
1. Install the "Markdown Preview Mermaid Support" extension
2. Open any `.mmd` file or markdown with mermaid blocks
3. Preview renders diagrams automatically

### Online Editor
Visit [Mermaid Live Editor](https://mermaid.live/) and paste the content

## Generating Images

Install mermaid-cli:
```bash
npm install -g @mermaid-js/mermaid-cli
```

Generate PNG:
```bash
mmdc -i ci_workflow.mmd -o ci_workflow.png
```

Generate SVG:
```bash
mmdc -i ci_workflow.mmd -o ci_workflow.svg
```

Generate all diagrams as PNG:
```bash
for file in *.mmd; do
  mmdc -i "$file" -o "${file%.mmd}.png"
done
```

Generate all diagrams as SVG:
```bash
for file in *.mmd; do
  mmdc -i "$file" -o "${file%.mmd}.svg"
done
```

## Embedding in Markdown

To embed a diagram in a README or documentation:

1. **Direct embed** (recommended for GitHub):
```markdown
## Workflow Diagram

\`\`\`mermaid
flowchart LR
    A[Start] --> B[Process] --> C[End]
\`\`\`
```

2. **Include from file** (for complex diagrams):
```markdown
## Workflow Diagram

See [mermaid diagram source](diagrams/mermaid/ci_workflow.mmd)

\`\`\`mermaid
<!-- Paste content of ci_workflow.mmd here -->
\`\`\`
```

## Advantages of Mermaid

✅ **Text-based** - Easy to version control and review in PRs  
✅ **No compilation** - Renders directly in GitHub/GitLab  
✅ **Simple syntax** - Easier to edit than images  
✅ **No dependencies** - No need for Python/Graphviz for viewing  
✅ **Inline rendering** - See diagrams without leaving markdown  

## Comparison with Python Diagrams

| Feature | Python + Diagrams | Mermaid |
|---------|------------------|---------|
| Icons | ✅ GitHub, CI, Language | ❌ Text only |
| GitHub Preview | ❌ Image files only | ✅ Inline rendering |
| Editing | ❌ Requires script | ✅ Edit directly |
| Quality | ✅ Professional | ⚠️ Basic |
| Installation | ❌ Python + Graphviz | ✅ None for viewing |

## Updating Diagrams

To regenerate all Mermaid diagrams:
```bash
./scripts/generate-mermaid-diagrams.sh
```

## Example: Automated Release Workflow

Here's what the automated release workflow looks like embedded:

\`\`\`mermaid
flowchart LR
    subgraph feature["feature/* Branch"]
        A[git flow<br/>feature start]
        B[Write Code]
        C[git cz<br/>conventional commits]
        D[Push & Create PR]
    end
    
    subgraph develop["develop Branch"]
        E[CI Tests]
        F[Merge Feature]
        G[Ready for Release]
    end
    
    subgraph release["release/* Branch"]
        H[git flow<br/>release start]
        I[cz bump<br/>auto version]
        J[Update CHANGELOG<br/>& versions]
        K[Commit & Tag<br/>v*.*.*]
    end
    
    subgraph main["main Branch"]
        L[git flow<br/>release finish]
        M[Push Tag]
        N[Release Workflow]
        O[GitHub Release]
    end
    
    subgraph back["Back to develop"]
        P[Auto-merge<br/>to develop]
        Q[Release Complete]
    end
    
    A --> B --> C --> D
    D --> E --> F --> G
    G --> H --> I --> J --> K
    K --> L --> M --> N --> O
    O --> P --> Q
    
    style feature fill:#e1f5ff,stroke:#01579b
    style develop fill:#d4edda,stroke:#155724
    style release fill:#fff3cd,stroke:#856404
    style main fill:#f8d7da,stroke:#721c24
    style back fill:#d1ecf1,stroke:#0c5460
\`\`\`

## Resources

- [Mermaid Documentation](https://mermaid.js.org/)
- [Mermaid Live Editor](https://mermaid.live/)
- [Mermaid CLI](https://github.com/mermaid-js/mermaid-cli)
- [GitHub Mermaid Support](https://github.blog/2022-02-14-include-diagrams-markdown-files-mermaid/)
