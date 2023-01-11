#!/usr/bin/env bash
set -euo pipefail
cd $(dirname ${BASH_SOURCE[0]})
source .settings
source .prod.env
cd ..

client_id="$(echo $AZURE_CREDENTIALS | jq -r .clientId)"
client_secret="$(echo $AZURE_CREDENTIALS | jq -r .clientSecret)"
subscription_id="$(echo $AZURE_CREDENTIALS | jq -r .subscriptionId)"
tenant_id="$(echo $AZURE_CREDENTIALS | jq -r .tenantId)"
commit_sha="$(git rev-parse HEAD)"

az config set extension.use_dynamic_install=yes_without_prompt

echo "Logging into Docker..."
echo ${registry_password} | docker login \
  --username ${registry_username} \
  --password-stdin \
  ${registry_name}.azurecr.io

echo "Deploying 'settings-api'..."
docker image tag settings-api ${registry_name}.azurecr.io/settings-api:${commit_sha}
docker image push ${registry_server}/settings-api:${commit_sha}

az containerapp update \
  --name ${container_app_names[0]} \
  --resource-group ${resource_group_name} \
  --image ${registry_server}/settings-api:${commit_sha} \
  --set-env-vars \
    DATABASE_CONNECTION_STRING=${database_connection_string} \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv

echo "Deploying 'dice-api'..."
docker image tag dice-api ${registry_name}.azurecr.io/dice-api:${commit_sha}
docker image push ${registry_server}/dice-api:${commit_sha}

az containerapp update \
  --name ${container_app_names[1]} \
  --resource-group ${resource_group_name} \
  --image ${registry_server}/dice-api:${commit_sha} \
  --set-env-vars \
    DATABASE_CONNECTION_STRING=${database_connection_string} \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv

echo "Deploying 'gateway-api'..."
docker image tag gateway-api ${registry_name}.azurecr.io/gateway-api:${commit_sha}
docker image push ${registry_server}/gateway-api:${commit_sha}

az containerapp update \
  --name ${container_app_names[2]} \
  --resource-group ${resource_group_name} \
  --image ${registry_server}/gateway-api:${commit_sha} \
  --set-env-vars \
    SETTINGS_API_URL=https://${container_app_urls[0]} \
    DICE_API_URL=https://${container_app_urls[1]} \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv

echo "Deploying 'website'..."
cd packages/website

deployment_token=$(\
  az staticwebapp secrets list \
    --name "${static_web_app_names[0]}" \
    --query "properties.apiKey" \
    --output tsv \
)

swa deploy \
  --app-name "${static_web_app_names[0]}" \
  --resource-group "${resource_group_name}" \
  --tenant-id "${tenant_id}" \
  --subscription-id "${subscription_id}" \
  --deployment-token "${deployment_token}" \
  --env "production" \
  --no-use-keychain \
  --verbose
