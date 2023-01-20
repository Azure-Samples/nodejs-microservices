#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Install dependencies
npm ci

# Build all Docker images
npm run docker:build --if-present --workspaces

# Build the website
npm run build --workspace=website
