#!/usr/bin/env bash
# ==============================================================================
# DOCKER BUILD UTILITIES
# ==============================================================================
# Shared functions for Docker-based builds across all build scripts
# ==============================================================================

# Check if Docker is available
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "ERROR: Docker is not installed"
        echo "Please install Docker Desktop:"
        echo "  - macOS: https://docs.docker.com/desktop/install/mac-install/"
        echo "  - Linux: https://docs.docker.com/engine/install/"
        echo "  - Windows: https://docs.docker.com/desktop/install/windows-install/"
        return 1
    fi

    if ! docker ps > /dev/null 2>&1; then
        echo "ERROR: Docker is not running"
        echo "Please start Docker Desktop"
        return 1
    fi

    return 0
}

# Pull Docker image if not present
ensure_docker_image() {
    local image="$1"

    if ! docker image inspect "$image" &> /dev/null; then
        echo "Pulling Docker image: $image"
        docker pull "$image"
    fi
}

# Create a Docker volume for better performance on macOS
create_build_volume() {
    local volume_name="$1"

    if ! docker volume inspect "$volume_name" &> /dev/null; then
        echo "Creating Docker volume: $volume_name"
        docker volume create "$volume_name"
    fi
}

# Copy source to Docker volume (for better performance)
copy_to_volume() {
    local volume_name="$1"
    local source_dir="$2"
    local container_name="${volume_name}-copy-$$"

    # Create a temporary container to copy files
    docker run --name "$container_name" \
        -v "$volume_name:/workspace" \
        -v "$source_dir:/source:ro" \
        alpine:latest \
        sh -c "cp -r /source/. /workspace/" || return 1

    docker rm "$container_name" &> /dev/null
    return 0
}

# Copy artifacts from Docker volume back to host
copy_from_volume() {
    local volume_name="$1"
    local dest_dir="$2"
    local container_name="${volume_name}-extract-$$"

    mkdir -p "$dest_dir"

    # Create a temporary container to extract files
    docker run --name "$container_name" \
        -v "$volume_name:/workspace:ro" \
        -v "$dest_dir:/output" \
        alpine:latest \
        sh -c "cp -r /workspace/. /output/" || return 1

    docker rm "$container_name" &> /dev/null
    return 0
}

# Run build in Docker container
docker_build_exec() {
    local image="$1"
    local workdir="$2"
    local build_cmd="$3"
    shift 3
    local extra_args=("$@")

    docker run --rm \
        -v "$(pwd):$workdir" \
        -w "$workdir" \
        "${extra_args[@]}" \
        "$image" \
        sh -c "$build_cmd"
}

# Cleanup Docker resources
cleanup_docker_resources() {
    local volume_name="$1"

    if [ -n "$volume_name" ]; then
        docker volume rm "$volume_name" 2>/dev/null || true
    fi
}

# Comprehensive Docker cleanup for build artifacts
cleanup_docker_build() {
    local container_prefix="$1"
    local volume_prefix="$2"

    # Remove stopped containers matching prefix
    if [ -n "$container_prefix" ]; then
        docker ps -a --filter "name=${container_prefix}" --format "{{.ID}}" | xargs -r docker rm -f 2>/dev/null || true
    fi

    # Remove volumes matching prefix
    if [ -n "$volume_prefix" ]; then
        docker volume ls --filter "name=${volume_prefix}" --format "{{.Name}}" | xargs -r docker volume rm 2>/dev/null || true
    fi

    # Clean up dangling images (optional - can be aggressive)
    # docker image prune -f 2>/dev/null || true
}

# Setup cleanup trap for Docker builds
setup_docker_cleanup_trap() {
    local cleanup_function="$1"
    trap "$cleanup_function" EXIT INT TERM
}
