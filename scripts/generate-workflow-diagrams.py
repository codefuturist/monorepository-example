#!/usr/bin/env python3
"""
Generate workflow diagrams for the monorepository CI/CD pipeline
using the Python diagrams library.
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.onprem.vcs import Github
from diagrams.onprem.ci import GithubActions
from diagrams.programming.language import Python, Rust, Go, Java, Swift
from diagrams.generic.blank import Blank
from diagrams.custom import Custom
import os

# Set output directory - generate diagrams in docs/diagrams
script_dir = os.path.dirname(__file__)
project_root = os.path.dirname(script_dir)
output_dir = os.path.join(project_root, "docs", "diagrams")
os.makedirs(output_dir, exist_ok=True)

# Graph attributes for better layout
graph_attr = {
    "fontsize": "12",
    "bgcolor": "white",
    "pad": "0.5",
}

node_attr = {
    "fontsize": "10",
}

edge_attr = {
    "fontsize": "9",
}


def create_ci_workflow_diagram():
    """Generate CI workflow diagram"""
    for fmt in ["png", "svg"]:
        with Diagram(
            "CI Workflow",
            filename=os.path.join(output_dir, "ci_workflow"),
            show=False,
            direction="TB",
            outformat=fmt,
            graph_attr=graph_attr,
            node_attr=node_attr,
            edge_attr=edge_attr,
        ):
            trigger = Github("Push/PR to\nmain/develop")
            
            with Cluster("CI Pipeline"):
                ci_job = GithubActions("CI Job")
                
                with Cluster("Build & Test Steps"):
                    checkout = Blank("Checkout\nCode")
                    setup_node = Blank("Setup\nNode.js 20")
                    install_deps = Blank("Install\nDependencies")
                    lint = Blank("Run\nLinter")
                    test = Blank("Run\nTests")
                    build = Blank("Build\nPackages")
            
            trigger >> ci_job
            ci_job >> checkout >> setup_node >> install_deps
            install_deps >> lint >> test >> build


def create_release_workflow_diagram():
    """Generate Release workflow diagram"""
    for fmt in ["png", "svg"]:
        with Diagram(
            "Root Release Workflow",
            filename=os.path.join(output_dir, "release_workflow"),
            show=False,
            direction="TB",
            outformat=fmt,
            graph_attr=graph_attr,
            node_attr=node_attr,
            edge_attr=edge_attr,
        ):
            trigger = Github("Push Tag\nv*.*.*")
            
            with Cluster("Release Pipeline"):
                release_job = GithubActions("Release Job")
                
                with Cluster("Build & Release Steps"):
                    checkout = Blank("Checkout\nCode")
                    setup_node = Blank("Setup\nNode.js 20")
                    install_deps = Blank("Install\nDependencies")
                    run_tests = Blank("Run\nTests")
                    build_packages = Blank("Build\nPackages")
                    extract_tag = Blank("Extract Tag\nInfo")
                    create_release = Blank("Create GitHub\nRelease")
                    publish_npm = Blank("Publish to\nnpm (optional)")
            
            trigger >> release_job
            release_job >> checkout >> setup_node >> install_deps
            install_deps >> run_tests >> build_packages >> extract_tag
            extract_tag >> create_release >> publish_npm


def create_package_release_workflow_diagram():
    """Generate package-specific release workflow diagram"""
    for fmt in ["png", "svg"]:
        with Diagram(
            "Package Release Workflow",
            filename=os.path.join(output_dir, "package_release_workflow"),
            show=False,
            direction="TB",
            outformat=fmt,
            graph_attr=graph_attr,
            node_attr=node_attr,
            edge_attr=edge_attr,
        ):
            with Cluster("Package Release Triggers"):
                python_tag = Github("package-{a,b,c}\n@v*.*.*")
                rust_tag = Github("package-{e,i}\n@v*.*.*")
                go_tag = Github("package-g\n@v*.*.*")
                cpp_tag = Github("package-d\n@v*.*.*")
                java_tag = Github("package-h\n@v*.*.*")
                swift_tag = Github("package-f\n@v*.*.*")
            
            with Cluster("Reusable Workflows"):
                with Cluster("Python Release"):
                    python_workflow = GithubActions("python-package\n-release.yml")
                    python_lang = Python("Build for\nmultiple platforms")
                
                with Cluster("Rust Release"):
                    rust_workflow = GithubActions("rust-package\n-release.yml")
                    rust_lang = Rust("Cross-compile\nfor targets")
                
                with Cluster("Go Release"):
                    go_workflow = GithubActions("go-package\n-release.yml")
                    go_lang = Go("Build\nbinaries")
                
                with Cluster("C++ Release"):
                    cpp_workflow = GithubActions("cpp-package\n-release.yml")
                    cpp_lang = Blank("CMake\nbuild")
                
                with Cluster("Java Release"):
                    java_workflow = GithubActions("java-release.yml")
                    java_lang = Java("Maven\nbuild")
                
                with Cluster("Swift Release"):
                    swift_workflow = GithubActions("swift-release.yml")
                    swift_lang = Swift("SPM\nbuild")
            
            release_output = Github("GitHub\nRelease")
            
            # Connect triggers to workflows
            python_tag >> python_workflow >> python_lang >> release_output
            rust_tag >> rust_workflow >> rust_lang >> release_output
            go_tag >> go_workflow >> go_lang >> release_output
            cpp_tag >> cpp_workflow >> cpp_lang >> release_output
            java_tag >> java_workflow >> java_lang >> release_output
            swift_tag >> swift_workflow >> swift_lang >> release_output


def create_complete_workflow_diagram():
    """Generate complete workflow overview diagram"""
    for fmt in ["png", "svg"]:
        with Diagram(
            "Complete Monorepository Workflow",
            filename=os.path.join(output_dir, "complete_workflow"),
            show=False,
            direction="LR",
            outformat=fmt,
            graph_attr=graph_attr,
            node_attr=node_attr,
            edge_attr=edge_attr,
        ):
            with Cluster("Development"):
                dev_push = Github("Push to\nfeature/develop")
                ci_workflow = GithubActions("CI\nWorkflow")
            
            with Cluster("Release Preparation"):
                create_tag = Blank("Create\nRelease Tag")
                tag_types = Blank("Tag Type:\nv*.*.* or\npackage-*@v*.*.*")
            
            with Cluster("Release Workflows"):
                with Cluster("Root Release"):
                    root_release = GithubActions("release.yml")
                
                with Cluster("Language-Specific Releases"):
                    python_releases = Python("Python\npackages a,b,c")
                    rust_releases = Rust("Rust\npackages e,i")
                    go_releases = Go("Go\npackage g")
                    cpp_releases = Blank("C++\npackage d")
                    java_releases = Java("Java\npackage h")
                    swift_releases = Swift("Swift\npackage f")
            
            with Cluster("Outputs"):
                github_release = Github("GitHub\nRelease")
                artifacts = Blank("Platform\nArtifacts")
                checksums = Blank("SHA256\nChecksums")
            
            # Flow
            dev_push >> ci_workflow >> Edge(label="tests pass") >> create_tag
            create_tag >> tag_types
            
            tag_types >> Edge(label="v*.*.*") >> root_release
            tag_types >> Edge(label="package-*@v*") >> python_releases
            tag_types >> Edge(label="package-*@v*") >> rust_releases
            tag_types >> Edge(label="package-*@v*") >> go_releases
            tag_types >> Edge(label="package-*@v*") >> cpp_releases
            tag_types >> Edge(label="package-*@v*") >> java_releases
            tag_types >> Edge(label="package-*@v*") >> swift_releases
            
            root_release >> github_release
            python_releases >> github_release
            rust_releases >> github_release
            go_releases >> github_release
            cpp_releases >> github_release
            java_releases >> github_release
            swift_releases >> github_release
            
            github_release >> artifacts
            github_release >> checksums


def create_package_build_pipeline_diagram():
    """Generate detailed package build pipeline diagram"""
    for fmt in ["png", "svg"]:
        with Diagram(
            "Package Build Pipeline",
            filename=os.path.join(output_dir, "package_build_pipeline"),
            show=False,
            direction="TB",
            outformat=fmt,
            graph_attr=graph_attr,
            node_attr=node_attr,
            edge_attr=edge_attr,
        ):
            trigger = Github("Tag Push\npackage-*@v*.*.*")
            
            with Cluster("Build Matrix"):
                with Cluster("Platform Setup"):
                    setup_matrix = Blank("Setup Build\nMatrix")
                    platforms = Blank("Linux x64/ARM64\nmacOS x64/ARM64\nWindows x64")
                
                with Cluster("Build Steps"):
                    checkout = Blank("Checkout\nCode")
                    setup_env = Blank("Setup Build\nEnvironment")
                    install_deps = Blank("Install\nDependencies")
                    compile = Blank("Compile\nBinary")
                    test_binary = Blank("Test\nBinary")
                    package_binary = Blank("Package\nBinary")
                    generate_checksum = Blank("Generate\nSHA256")
                
                with Cluster("Upload Artifacts"):
                    upload_binary = Blank("Upload\nBinary")
                    upload_checksum = Blank("Upload\nChecksum")
            
            with Cluster("Release Creation"):
                create_release = GithubActions("Create GitHub\nRelease")
                attach_artifacts = Blank("Attach All\nArtifacts")
                publish_release = Github("Publish\nRelease")
            
            trigger >> setup_matrix >> platforms
            platforms >> checkout >> setup_env >> install_deps
            install_deps >> compile >> test_binary >> package_binary
            package_binary >> generate_checksum
            
            generate_checksum >> upload_binary
            generate_checksum >> upload_checksum
            
            upload_binary >> create_release
            upload_checksum >> create_release
            create_release >> attach_artifacts >> publish_release


def create_git_flow_diagram():
    """Generate git-flow branching strategy diagram"""
    for fmt in ["png", "svg"]:
        with Diagram(
            "Git Flow Branching Strategy",
            filename=os.path.join(output_dir, "git_flow"),
            show=False,
            direction="LR",
            outformat=fmt,
            graph_attr=graph_attr,
            node_attr=node_attr,
            edge_attr=edge_attr,
        ):
            with Cluster("Branches"):
                main = Github("main\n(production)")
                develop = Github("develop\n(integration)")
                feature = Github("feature/*\n(new features)")
                release = Github("release/*\n(release prep)")
                hotfix = Github("hotfix/*\n(urgent fixes)")
            
            with Cluster("CI/CD Triggers"):
                ci_trigger = GithubActions("CI Workflow\n(test & build)")
                release_trigger = GithubActions("Release Workflow\n(publish)")
            
            with Cluster("Outputs"):
                github_release = Github("GitHub Release")
                npm_publish = Blank("npm Publish\n(optional)")
            
            # Development flow
            feature >> Edge(label="merge via PR") >> develop
            develop >> Edge(label="create release") >> release
            release >> Edge(label="merge when ready") >> main
            release >> Edge(label="merge back") >> develop
            main >> Edge(label="urgent fix") >> hotfix
            hotfix >> Edge(label="merge") >> main
            hotfix >> Edge(label="merge back") >> develop
            
            # CI/CD triggers
            feature >> Edge(label="push") >> ci_trigger
            develop >> Edge(label="push") >> ci_trigger
            main >> Edge(label="tag v*.*.*") >> release_trigger
            
            release_trigger >> github_release
            release_trigger >> npm_publish


def create_automated_release_workflow_diagram():
    """Generate automated release workflow with git flow and commitizen"""
    for fmt in ["png", "svg"]:
        with Diagram(
            "Automated Release Workflow (Git Flow + Commitizen)",
            filename=os.path.join(output_dir, "automated_release_workflow"),
            show=False,
            direction="LR",
            outformat=fmt,
            graph_attr=graph_attr,
            node_attr=node_attr,
            edge_attr=edge_attr,
        ):
            with Cluster("feature/* Branch"):
                start_feature = Github("git flow\nfeature start")
                write_code = Blank("Write Code")
                git_cz = Blank("git cz\n(conventional\ncommits)")
                push_feature = Github("Push &\nCreate PR")
            
            with Cluster("develop Branch"):
                ci_test = GithubActions("CI Tests")
                merge_feature = Github("Merge\nFeature")
                ready = Blank("Ready for\nRelease")
            
            with Cluster("release/* Branch"):
                start_release = Github("git flow\nrelease start")
                cz_bump = Blank("cz bump\n(auto version)")
                update_files = Blank("Update\nCHANGELOG\n& versions")
                commit_tag = Github("Commit &\nTag v*.*.*")
            
            with Cluster("main Branch"):
                finish_release = Github("git flow\nrelease finish")
                push_main = Github("Push Tag")
                trigger_ci = GithubActions("Release\nWorkflow")
                gh_release = Github("GitHub\nRelease")
            
            with Cluster("Back to develop"):
                auto_merge = Github("Auto-merge\nto develop")
                complete = Blank("Release\nComplete")
            
            # Flow
            start_feature >> write_code >> git_cz >> push_feature
            push_feature >> ci_test >> merge_feature >> ready
            ready >> start_release >> cz_bump >> update_files >> commit_tag
            commit_tag >> finish_release >> push_main >> trigger_ci >> gh_release
            gh_release >> auto_merge >> complete


if __name__ == "__main__":
    print("Generating workflow diagrams...")
    
    print("  Creating CI workflow diagram...")
    create_ci_workflow_diagram()
    
    print("  Creating release workflow diagram...")
    create_release_workflow_diagram()
    
    print("  Creating package release workflow diagram...")
    create_package_release_workflow_diagram()
    
    print("  Creating complete workflow diagram...")
    create_complete_workflow_diagram()
    
    print("  Creating package build pipeline diagram...")
    create_package_build_pipeline_diagram()
    
    print("  Creating git-flow diagram...")
    create_git_flow_diagram()
    
    print("  Creating automated release workflow diagram...")
    create_automated_release_workflow_diagram()
    
    print(f"\nDiagrams generated successfully in: {output_dir}/")
    print("\nGenerated diagrams (PNG and SVG formats):")
    print("  - ci_workflow.png / ci_workflow.svg")
    print("  - release_workflow.png / release_workflow.svg")
    print("  - package_release_workflow.png / package_release_workflow.svg")
    print("  - complete_workflow.png / complete_workflow.svg")
    print("  - package_build_pipeline.png / package_build_pipeline.svg")
    print("  - git_flow.png / git_flow.svg")
    print("  - automated_release_workflow.png / automated_release_workflow.svg")
