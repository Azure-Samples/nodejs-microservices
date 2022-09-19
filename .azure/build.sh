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

# TODO: get src folder and build command from yaml
echo "Building 'nest-demo'..."
npm run docker:build

echo "Build complete for project '${project_name}'."
