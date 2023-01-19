#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source .settings
source .prod.env
cd ..

client_id="$(echo "$AZURE_CREDENTIALS" | jq -r .clientId)"
client_secret="$(echo "$AZURE_CREDENTIALS" | jq -r .clientSecret)"
subscription_id="$(echo "$AZURE_CREDENTIALS" | jq -r .subscriptionId)"
tenant_id="$(echo "$AZURE_CREDENTIALS" | jq -r .tenantId)"
commit_sha="$(git rev-parse HEAD)"

az config set extension.use_dynamic_install=yes_without_prompt

echo "Logging into Docker..."
echo "${REGISTRY_PASSWORD}" | docker login \
  --username "${REGISTRY_USERNAME}" \
  --password-stdin \
  "${REGISTRY_NAME}".azurecr.io

echo "Deploying 'settings-api'..."
docker image tag settings-api "${REGISTRY_NAME}".azurecr.io/settings-api:"${commit_sha}"
docker image push "${REGISTRY_SERVER}"/settings-api:"${commit_sha}"

az containerapp update \
  --name "${CONTAINER_APP_NAMES[0]}" \
  --resource-group "${RESOURCE_GROUP_NAME}" \
  --image "${REGISTRY_SERVER}"/settings-api:"${commit_sha}" \
  --set-env-vars \
    DATABASE_CONNECTION_STRING="${DATABASE_CONNECTION_STRING}" \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv

echo "Deploying 'dice-api'..."
docker image tag dice-api "${REGISTRY_NAME}".azurecr.io/dice-api:"${commit_sha}"
docker image push "${REGISTRY_SERVER}"/dice-api:"${commit_sha}"

az containerapp update \
  --name "${CONTAINER_APP_NAMES[1]}" \
  --resource-group "${RESOURCE_GROUP_NAME}" \
  --image "${REGISTRY_SERVER}"/dice-api:"${commit_sha}" \
  --set-env-vars \
    DATABASE_CONNECTION_STRING="${DATABASE_CONNECTION_STRING}" \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv

echo "Deploying 'gateway-api'..."
docker image tag gateway-api "${REGISTRY_NAME}".azurecr.io/gateway-api:"${commit_sha}"
docker image push "${REGISTRY_SERVER}"/gateway-api:"${commit_sha}"

az containerapp update \
  --name "${CONTAINER_APP_NAMES[2]}" \
  --resource-group "${RESOURCE_GROUP_NAME}" \
  --image "${REGISTRY_SERVER}"/gateway-api:"${commit_sha}" \
  --set-env-vars \
    SETTINGS_API_URL=https://"${CONTAINER_APP_HOSTNAMES[0]}" \
    DICE_API_URL=https://"${CONTAINER_APP_HOSTNAMES[1]}" \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv

echo "Deploying 'website'..."
cd packages/website

deployment_token=$(\
  az staticwebapp secrets list \
    --name "${STATIC_WEB_APP_NAMES[0]}" \
    --query "properties.apiKey" \
    --output tsv \
)

swa deploy \
  --app-name "${STATIC_WEB_APP_NAMES[0]}" \
  --resource-group "${RESOURCE_GROUP_NAME}" \
  --tenant-id "${tenant_id}" \
  --subscription-id "${subscription_id}" \
  --deployment-token "${deployment_token}" \
  --env "production" \
  --no-use-keychain \
  --verbose
