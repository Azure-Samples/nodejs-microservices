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

time=`date +%s`
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
npm run docker:build --workspaces -- --platform=linux/amd64

# Build containers
# for i in ${!container_names[@]}; do
#   container_name=${container_names[$i]}

#   # TODO: get src folders and build commands from yaml
#   echo "Building '$container_name'..."
#   pushd packages/$container_name
#   npm run docker:build
#   popd
# done

# Build websites
for i in ${!websiteNames[@]}; do
  website_name=${websiteNames[$i]}

  # TODO: get src folders and build commands from yaml
  echo "Building '$website_name'..."
  pushd packages/$website_name
  npm run build
  popd

done

echo "Build complete for project '${project_name}'."
echo "Done in $(($(date +%s)-$time))s"
