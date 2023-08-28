#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source .prod.env
cd ..

# Get current commit SHA
commit_sha="$(git rev-parse HEAD)"

# Allow silent installation of Azure CLI extensions
az config set extension.use_dynamic_install=yes_without_prompt

echo "Logging into Docker..."
echo "$REGISTRY_PASSWORD" | docker login \
  --username "$REGISTRY_USERNAME" \
  --password-stdin \
  "$REGISTRY_NAME.azurecr.io"

echo "Deploying settings-api..."
docker image tag settings-api "$REGISTRY_NAME.azurecr.io/settings-api:$commit_sha"
docker image push "$REGISTRY_SERVER/settings-api:$commit_sha"

az containerapp secret set \
  --name "${CONTAINER_APP_NAMES[0]}" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --secrets db-connection-string="$DATABASE_CONNECTION_STRING" \
  --output tsv

az containerapp update \
  --name "${CONTAINER_APP_NAMES[0]}" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --image "$REGISTRY_SERVER/settings-api:$commit_sha" \
  --set-env-vars \
    DATABASE_CONNECTION_STRING="secretref:db-connection-string" \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv

echo "Deploying dice-api..."
docker image tag dice-api "$REGISTRY_NAME.azurecr.io/dice-api:$commit_sha"
docker image push "$REGISTRY_SERVER/dice-api:$commit_sha"

az containerapp secret set \
  --name "${CONTAINER_APP_NAMES[1]}" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --secrets db-connection-string="$DATABASE_CONNECTION_STRING" \
  --output tsv

az containerapp update \
  --name "${CONTAINER_APP_NAMES[1]}" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --image "$REGISTRY_SERVER/dice-api:$commit_sha" \
  --set-env-vars \
    DATABASE_CONNECTION_STRING="secretref:db-connection-string" \
  --scale-rule-name http-rule \
  --scale-rule-type http \
  --scale-rule-http-concurrency 100 \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv

echo "Deploying gateway-api..."
docker image tag gateway-api "$REGISTRY_NAME.azurecr.io/gateway-api:$commit_sha"
docker image push "$REGISTRY_SERVER/gateway-api:$commit_sha"

az containerapp update \
  --name "${CONTAINER_APP_NAMES[2]}" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --image "$REGISTRY_SERVER/gateway-api:$commit_sha" \
  --set-env-vars \
    SETTINGS_API_URL="https://${CONTAINER_APP_HOSTNAMES[0]}" \
    DICE_API_URL="https://${CONTAINER_APP_HOSTNAMES[1]}" \
  --cpu 2 \
  --memory 4 \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv

echo "Deploying website..."
cd packages/website
npx swa deploy \
  --app-name "${STATIC_WEB_APP_NAMES[0]}" \
  --deployment-token "${STATIC_WEB_APP_DEPLOYMENT_TOKENS[0]}" \
  --env "production" \
  --verbose
