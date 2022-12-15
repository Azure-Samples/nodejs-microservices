#!/usr/bin/env bash
##############################################################################
# Usage: ./create-samples.sh
# Creates the projects folders.
##############################################################################

mkdir packages/
cd packages
npx @nestjs/cli new dice-api
npx express-generator --no-view gateway-api
npx fastify-cli generate settings-api
npm create vite@latest website -- --template vanilla
