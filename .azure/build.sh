#!/usr/bin/env bash
##############################################################################
# THIS FILE IS AUTO-GENERATED, DO NOT EDIT IT MANUALLY!
# If you need to make changes, edit the file `blue.yaml`.
##############################################################################

##############################################################################
# Usage: ./build.sh
# Builds the project before deployment.
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
cd nest
npm run docker:build

echo "Building 'express-api'..."
cd express
npm run docker:build


echo "Building 'fastify-api'..."
cd fastify
npm run docker:build

echo "Build complete for project '${project_name}'."
