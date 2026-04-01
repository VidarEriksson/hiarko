#!/bin/bash
set -e

# Must be run from the hiarko root (parent of all repos).
# Usage: ./hiarko/build.sh [tag]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTEXT_DIR="$(dirname "$SCRIPT_DIR")"
TAG="${1:-hiarko:latest}"

echo "Build context: $CONTEXT_DIR"
echo "Image tag:     $TAG"

podman build \
  --file "$SCRIPT_DIR/Dockerfile" \
  --tag "$TAG" \
  "$CONTEXT_DIR"

echo "Done. Run with:"
echo "  podman run --env-file .env -p 3000:3000 $TAG"
