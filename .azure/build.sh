#!/usr/bin/env bash
set -euo pipefail
cd $(dirname ${BASH_SOURCE[0]})/..

npm ci
npm run docker:build -- --platform=linux/amd64
npm run build:website
