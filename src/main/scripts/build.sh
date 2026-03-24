#!/bin/bash
set -e

# Default values for configuration
SOURCE_REPO_URL="${SOURCE_REPO_URL:-https://github.com/aws-samples/bedrock-access-gateway.git}"
DOCKERHUB_REPO="${DOCKERHUB_REPO:-warfront1bag/bedrock-access-gateway}"
# SOURCE_BRANCH specifies which branch to use as 'latest'
SOURCE_BRANCH="${SOURCE_BRANCH:-main}"

# Cleanup build directory on exit
BUILD_DIR=$(mktemp -d)
trap 'rm -rf "$BUILD_DIR"' EXIT

echo "Cloning source repository: $SOURCE_REPO_URL"
git clone "$SOURCE_REPO_URL" "$BUILD_DIR"
cd "$BUILD_DIR"

# Get all commits in chronological order (oldest first)
# This ensures that if multiple commits are missing, we build them in order
# and the latest commit truly becomes 'latest' at the end of the process.
COMMITS=$(git log --pretty=format:"%H" --reverse)
REMOTE_MAIN_TAG=$(git rev-parse "origin/$SOURCE_BRANCH")

for COMMIT_HASH in $COMMITS; do
    echo "Checking commit: $COMMIT_HASH"
    
    # Check if the tag already exists on DockerHub
    TAG_EXISTS=$(curl -s -f -L "https://hub.docker.com/v2/repositories/$DOCKERHUB_REPO/tags/$COMMIT_HASH/" > /dev/null && echo "true" || echo "false")
    
    if [ "$TAG_EXISTS" = "true" ]; then
        echo "Image for $COMMIT_HASH already exists on DockerHub. Skipping."
        continue
    fi
    
    echo "Image for $COMMIT_HASH not found. Building multi-arch..."
    git reset --hard
    git clean -fdx
    git checkout "$COMMIT_HASH"

    # Check if the Dockerfile exists (simple check in src directory)
    if [ ! -f "src/Dockerfile_ecs" ]; then
      echo "src/Dockerfile_ecs not found in commit $COMMIT_HASH. Skipping."
      continue
    fi

    cd src
    docker buildx build . \
      -f "Dockerfile_ecs" \
      --platform linux/amd64,linux/arm64 \
      -t "$DOCKERHUB_REPO:$COMMIT_HASH" \
      --push

    if [ "$COMMIT_HASH" = "$REMOTE_MAIN_TAG" ]; then
        echo "Tagging $COMMIT_HASH as latest"
        docker buildx build . \
          -f "Dockerfile_ecs" \
          --platform linux/amd64,linux/arm64 \
          -t "$DOCKERHUB_REPO:latest" \
          --push
    fi
    cd "$BUILD_DIR"
done
