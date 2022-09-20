#!/usr/bin/env bash
##############################################################################
# Usage: ./build.sh
# Builds the project before deployment.
##############################################################################
# THIS FILE IS AUTO-GENERATED, DO NOT EDIT IT MANUALLY!
# If you need to make changes, edit the file `blue.yaml`.
##############################################################################

set -e
cd $(dirname ${BASH_SOURCE[0]})
if [ -f ".settings" ]; then
  source .settings
fi

commit_sha="$(git rev-parse HEAD)"

echo "Building project '${project_name}'..."
cd ..

# TODO: get src folders and build commands from yaml

echo "Building 'nest-api'..."
pushd nest
npm run docker:build
popd

echo "Building 'express-api'..."
pushd express
npm run docker:build
popd

echo "Building 'fastify-api'..."
pushd fastify
npm run docker:build
popd

echo "Build complete for project '${project_name}'."
