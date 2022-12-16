#!/usr/bin/env bash
##############################################################################
# Usage: ./build.sh
# Builds the project before deployment.
##############################################################################

set -e
cd $(dirname ${BASH_SOURCE[0]})
if [[ -f ".settings" ]]; then
  source .settings
fi

# TODO: remove, build need to be independant of environment
environment="${environment:-prod}"
environment="${1:-$environment}"

if [[ ! -f ".${environment}.env" ]]; then
  echo "Error: file '.${environment}.env' not found."
  exit 1
fi
source ".${environment}.env"

commit_sha="$(git rev-parse HEAD)"

echo "Building project '${project_name}'..."
cd ..

# TODO: get src folders and build commands from yaml
# echo "Building 'root'..."
# npm run docker:build --workspaces

# Build container apps
for i in ${!container_image_names[@]}; do
  container_image_name=${container_image_names[$i]}

  # TODO: get src folders and build commands from yaml
  echo "Building '$container_image_name'..."
  pushd packages/$container_image_name
  npm run docker:build
  popd
done

# Build static web apps
for i in ${!static_web_app_names[@]}; do
  static_web_app_name=${static_web_app_names[$i]}

  # TODO: get src folders and build commands from yaml
  echo "Building '$static_web_app_name'..."
  pushd packages/$static_web_app_name
  npm run build
  popd

done

echo "Build complete for project '${project_name}'."
