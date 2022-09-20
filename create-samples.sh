#!/usr/bin/env bash
##############################################################################
# Usage: ./create-samples.sh
# Creates the projects folders.
##############################################################################

npx @nestjs/cli new nest
npx express-generator --no-view express
npx fastify-cli generate fastify
