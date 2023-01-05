#!/usr/bin/env bash
##############################################################################
# Usage: ./create-samples.sh
# Creates the projects folders
##############################################################################

set -e
cd $(dirname ${BASH_SOURCE[0]})

target_folder=packages

cd ..
mkdir $target_folder
cd $target_folder

npx -y fastify-cli@latest generate settings-api --esm
npx -y @nestjs/cli@latest new dice-api --package-manager npm
npx -y express-generator@latest --no-view gateway-api
npx -y create-vite@latest website --template vanilla
