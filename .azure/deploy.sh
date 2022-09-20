#!/usr/bin/env bash
##############################################################################
# Usage: ./deploy.sh <environment_name>
# Deploys the Azure resources for this project.
##############################################################################
# Dependencies: Azure CLI, Docker CLI, jq
##############################################################################

set -e
cd $(dirname ${BASH_SOURCE[0]})
if [ -f ".settings" ]; then
  source .settings
fi

environment="${environment:-prod}"
environment="${1:-$environment}"

if [ ! -f ".${environment}.env" ]; then
  echo "Error: file '.${environment}.env' not found."
  exit 1
fi
source ".${environment}.env"

echo "Deploying environment '${environment}'..."

subscription_id="$(echo $AZURE_CREDENTIALS | jq -r .subscriptionId)"
tenant_id="$(echo $AZURE_CREDENTIALS | jq -r .tenantId)"
commit_sha="$(git rev-parse HEAD)"

if [ ! -z "$registry_name" ]; then
  # Get registry credentials
  registry_username=$( \
    az acr credential show \
      --name ${registry_name} \
      --query "username" \
      --output tsv \
    )
  registry_password=$( \
    az acr credential show \
      --name ${registry_name} \
      --query "passwords[0].value" \
      --output tsv \
    )
fi

az config set extension.use_dynamic_install=yes_without_prompt
cd ..

# Deploy container apps
for i in ${!container_image_names[@]}; do
  container_image_name=${container_image_names[$i]}
  container_app_name=${container_app_names[$i]}
  conatiner_app_url=${container_app_urls[$i]}

  # echo "Building '${container_app_name}'..."
  # TODO: get src folder and build command from yaml
  # npm run docker:build

  echo "Deploying '${container_app_name}'..."
  docker login \
    --username ${registry_username} \
    --password ${registry_password} \
    ${registry_name}.azurecr.io

  docker image tag ${container_image_name} ${registry_name}.azurecr.io/${container_image_name}:${commit_sha}
  docker image push ${registry_server}/${container_image_name}:${commit_sha}

  az containerapp registry set \
    --name ${container_app_name} \
    --resource-group ${resource_group_name} \
    --server ${registry_server} \
    --username ${registry_username} \
    --password ${registry_password}

  az containerapp update \
    --name ${container_app_name} \
    --resource-group ${resource_group_name} \
    --image ${registry_server}/${container_image_name}:${commit_sha}
done

# Deploy static web apps
for i in ${!static_web_app_names[@]}; do
  static_web_app_name=${static_web_app_names[$i]}
  static_web_app_url=${static_web_app_public_urls[$i]}

  echo "Building '${static_web_app_name}'..."

  # TODO: get src folder and build process from yaml
  pushd ${static_web_app_name}
  npm install
  npm run build

  echo "Deploying '${static_web_app_name}'..."

  # Workaround because of https://github.com/Azure/azure-sdk-for-js/issues/22751
  deployment_token=$(\
    az staticwebapp secrets list \
      --name "${static_web_app_name}" \
      --query "properties.apiKey" \
      --output tsv \
    )
  
  # Not working at the moment for Next.js preview
  swa deploy \
    --output-location ".next" \
    --app-name "${static_web_app_name}" \
    --resource-group "${resource_group_name}" \
    --tenant-id "${tenant_id}" \
    --subscription-id "${subscription_id}" \
    --env "production" \
    --deployment-token "${deployment_token}" \
    --verbose

  popd
done

echo "Deployment complete for environment '${environment}'."
