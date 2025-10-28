#!/bin/bash
# Generate Mermaid diagram files for all workflows

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/../docs/diagrams/mermaid"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Generating Mermaid diagram files..."

# 1. CI Workflow
cat > "$OUTPUT_DIR/ci_workflow.mmd" << 'EOF'
flowchart TB
    Start[Push/PR to<br/>main/develop]
    
    subgraph ci["CI Pipeline"]
        Job[CI Job]
        
        subgraph steps["Build & Test Steps"]
            Checkout[Checkout Code]
            Setup[Setup Node.js 20]
            Install[Install Dependencies]
            Lint[Run Linter]
            Test[Run Tests]
            Build[Build Packages]
        end
    end
    
    Start --> Job
    Job --> Checkout --> Setup --> Install
    Install --> Lint --> Test --> Build
    
    style ci fill:#e3f2fd,stroke:#1976d2
    style steps fill:#fff3e0,stroke:#f57c00
EOF

echo "  ✓ Created ci_workflow.mmd"

# 2. Release Workflow
cat > "$OUTPUT_DIR/release_workflow.mmd" << 'EOF'
flowchart TB
    Trigger[Push Tag<br/>v*.*.*]
    
    subgraph release["Release Pipeline"]
        Job[Release Job]
        
        subgraph steps["Build & Release Steps"]
            Checkout[Checkout Code]
            Setup[Setup Node.js 20]
            Install[Install Dependencies]
            Tests[Run Tests]
            Build[Build Packages]
            ExtractTag[Extract Tag Info]
            CreateRelease[Create GitHub Release]
            PublishNPM[Publish to npm<br/>optional]
        end
    end
    
    Trigger --> Job
    Job --> Checkout --> Setup --> Install
    Install --> Tests --> Build --> ExtractTag
    ExtractTag --> CreateRelease --> PublishNPM
    
    style release fill:#f3e5f5,stroke:#7b1fa2
    style steps fill:#fff3e0,stroke:#f57c00
EOF

echo "  ✓ Created release_workflow.mmd"

# 3. Package Release Workflow
cat > "$OUTPUT_DIR/package_release_workflow.mmd" << 'EOF'
flowchart TB
    subgraph triggers["Package Release Triggers"]
        Python[package-a,b,c@v*.*.*]
        Rust[package-e,i@v*.*.*]
        Go[package-g@v*.*.*]
        Cpp[package-d@v*.*.*]
        Java[package-h@v*.*.*]
        Swift[package-f@v*.*.*]
    end
    
    subgraph workflows["Reusable Workflows"]
        direction TB
        subgraph py["Python Release"]
            PythonWF[python-package-release.yml]
            PythonBuild[Build for multiple platforms]
        end
        subgraph rs["Rust Release"]
            RustWF[rust-package-release.yml]
            RustBuild[Cross-compile for targets]
        end
        subgraph go["Go Release"]
            GoWF[go-package-release.yml]
            GoBuild[Build binaries]
        end
        subgraph cpp["C++ Release"]
            CppWF[cpp-package-release.yml]
            CppBuild[CMake build]
        end
        subgraph java["Java Release"]
            JavaWF[java-release.yml]
            JavaBuild[Maven build]
        end
        subgraph swift["Swift Release"]
            SwiftWF[swift-release.yml]
            SwiftBuild[SPM build]
        end
    end
    
    Release[GitHub Release]
    
    Python --> PythonWF --> PythonBuild --> Release
    Rust --> RustWF --> RustBuild --> Release
    Go --> GoWF --> GoBuild --> Release
    Cpp --> CppWF --> CppBuild --> Release
    Java --> JavaWF --> JavaBuild --> Release
    Swift --> SwiftWF --> SwiftBuild --> Release
    
    style triggers fill:#e8f5e9,stroke:#388e3c
    style workflows fill:#fff3e0,stroke:#f57c00
    style py fill:#e3f2fd,stroke:#1976d2
    style rs fill:#fce4ec,stroke:#c2185b
    style go fill:#e0f2f1,stroke:#00796b
    style cpp fill:#f3e5f5,stroke:#7b1fa2
    style java fill:#fff9c4,stroke:#f57f17
    style swift fill:#ffebee,stroke:#c62828
EOF

echo "  ✓ Created package_release_workflow.mmd"

# 4. Complete Workflow
cat > "$OUTPUT_DIR/complete_workflow.mmd" << 'EOF'
flowchart LR
    subgraph dev["Development"]
        DevPush[Push to<br/>feature/develop]
        CI[CI Workflow]
    end
    
    subgraph prep["Release Preparation"]
        CreateTag[Create Release Tag]
        TagTypes[Tag Type:<br/>v*.*.* or<br/>package-*@v*.*.*]
    end
    
    subgraph releases["Release Workflows"]
        subgraph root["Root Release"]
            RootRelease[release.yml]
        end
        subgraph lang["Language-Specific Releases"]
            Python[Python<br/>packages a,b,c]
            Rust[Rust<br/>packages e,i]
            Go[Go<br/>package g]
            Cpp[C++<br/>package d]
            Java[Java<br/>package h]
            Swift[Swift<br/>package f]
        end
    end
    
    subgraph outputs["Outputs"]
        GHRelease[GitHub Release]
        Artifacts[Platform Artifacts]
        Checksums[SHA256 Checksums]
    end
    
    DevPush --> CI
    CI -->|tests pass| CreateTag
    CreateTag --> TagTypes
    TagTypes -->|v*.*.*| RootRelease
    TagTypes -->|package-*@v*| Python
    TagTypes -->|package-*@v*| Rust
    TagTypes -->|package-*@v*| Go
    TagTypes -->|package-*@v*| Cpp
    TagTypes -->|package-*@v*| Java
    TagTypes -->|package-*@v*| Swift
    
    RootRelease --> GHRelease
    Python --> GHRelease
    Rust --> GHRelease
    Go --> GHRelease
    Cpp --> GHRelease
    Java --> GHRelease
    Swift --> GHRelease
    
    GHRelease --> Artifacts
    GHRelease --> Checksums
    
    style dev fill:#e3f2fd,stroke:#1976d2
    style prep fill:#fff3e0,stroke:#f57c00
    style releases fill:#f3e5f5,stroke:#7b1fa2
    style root fill:#e1bee7,stroke:#8e24aa
    style lang fill:#ce93d8,stroke:#ab47bc
    style outputs fill:#c8e6c9,stroke:#388e3c
EOF

echo "  ✓ Created complete_workflow.mmd"

# 5. Package Build Pipeline
cat > "$OUTPUT_DIR/package_build_pipeline.mmd" << 'EOF'
flowchart TB
    Trigger[Tag Push<br/>package-*@v*.*.*]
    
    subgraph matrix["Build Matrix"]
        subgraph platform["Platform Setup"]
            SetupMatrix[Setup Build Matrix]
            Platforms[Linux x64/ARM64<br/>macOS x64/ARM64<br/>Windows x64]
        end
        
        subgraph build["Build Steps"]
            Checkout[Checkout Code]
            SetupEnv[Setup Build Environment]
            InstallDeps[Install Dependencies]
            Compile[Compile Binary]
            TestBinary[Test Binary]
            Package[Package Binary]
            GenChecksum[Generate SHA256]
        end
        
        subgraph upload["Upload Artifacts"]
            UploadBinary[Upload Binary]
            UploadChecksum[Upload Checksum]
        end
    end
    
    subgraph release["Release Creation"]
        CreateRelease[Create GitHub Release]
        AttachArtifacts[Attach All Artifacts]
        PublishRelease[Publish Release]
    end
    
    Trigger --> SetupMatrix --> Platforms
    Platforms --> Checkout --> SetupEnv --> InstallDeps
    InstallDeps --> Compile --> TestBinary --> Package
    Package --> GenChecksum
    GenChecksum --> UploadBinary
    GenChecksum --> UploadChecksum
    UploadBinary --> CreateRelease
    UploadChecksum --> CreateRelease
    CreateRelease --> AttachArtifacts --> PublishRelease
    
    style matrix fill:#e3f2fd,stroke:#1976d2
    style platform fill:#bbdefb,stroke:#1976d2
    style build fill:#c5cae9,stroke:#303f9f
    style upload fill:#d1c4e9,stroke:#512da8
    style release fill:#c8e6c9,stroke:#388e3c
EOF

echo "  ✓ Created package_build_pipeline.mmd"

# 6. Git Flow
cat > "$OUTPUT_DIR/git_flow.mmd" << 'EOF'
flowchart LR
    subgraph branches["Branches"]
        Main[main<br/>production]
        Develop[develop<br/>integration]
        Feature[feature/*<br/>new features]
        Release[release/*<br/>release prep]
        Hotfix[hotfix/*<br/>urgent fixes]
    end
    
    subgraph triggers["CI/CD Triggers"]
        CITrigger[CI Workflow<br/>test & build]
        ReleaseTrigger[Release Workflow<br/>publish]
    end
    
    subgraph outputs["Outputs"]
        GHRelease[GitHub Release]
        NPMPublish[npm Publish<br/>optional]
    end
    
    Feature -->|merge via PR| Develop
    Develop -->|create release| Release
    Release -->|merge when ready| Main
    Release -->|merge back| Develop
    Main -->|urgent fix| Hotfix
    Hotfix -->|merge| Main
    Hotfix -->|merge back| Develop
    
    Feature -->|push| CITrigger
    Develop -->|push| CITrigger
    Main -->|tag v*.*.*| ReleaseTrigger
    
    ReleaseTrigger --> GHRelease
    ReleaseTrigger --> NPMPublish
    
    style branches fill:#e3f2fd,stroke:#1976d2
    style triggers fill:#fff3e0,stroke:#f57c00
    style outputs fill:#c8e6c9,stroke:#388e3c
EOF

echo "  ✓ Created git_flow.mmd"

# 7. Automated Release Workflow
cat > "$OUTPUT_DIR/automated_release_workflow.mmd" << 'EOF'
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
EOF

echo "  ✓ Created automated_release_workflow.mmd"

echo ""
echo "Mermaid diagrams generated successfully in: $OUTPUT_DIR/"
echo ""
echo "Generated diagrams:"
echo "  - ci_workflow.mmd"
echo "  - release_workflow.mmd"
echo "  - package_release_workflow.mmd"
echo "  - complete_workflow.mmd"
echo "  - package_build_pipeline.mmd"
echo "  - git_flow.mmd"
echo "  - automated_release_workflow.mmd"
echo ""
echo "To render as images, install mermaid-cli:"
echo "  npm install -g @mermaid-js/mermaid-cli"
echo ""
echo "Then generate PNG/SVG:"
echo "  mmdc -i $OUTPUT_DIR/ci_workflow.mmd -o $OUTPUT_DIR/ci_workflow.png"
echo "  mmdc -i $OUTPUT_DIR/ci_workflow.mmd -o $OUTPUT_DIR/ci_workflow.svg"
