#!/usr/bin/env bash
##############################################################################
# Usage: ./create-samples.sh
# Creates the projects folders
##############################################################################

set -e
cd $(dirname ${BASH_SOURCE[0]})

cd..
mkdir packages/
cd packages

npx @nestjs/cli new dice-api
npx express-generator --no-view gateway-api
npx fastify-cli generate settings-api
npm create vite@latest website -- --template vanilla
