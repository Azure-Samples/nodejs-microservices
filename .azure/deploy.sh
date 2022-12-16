#!/usr/bin/env bash
##############################################################################
# Usage: ./deploy.sh <environment_name>
# Deploys the Azure resources for this project.
##############################################################################
# v0.1.1 | dependencies: Azure CLI, Azure Functions Core Tools, Docker CLI,
#                        Azure Static Web Apps CLI, jq
##############################################################################

set -e
cd $(dirname ${BASH_SOURCE[0]})
if [[ -f ".settings" ]]; then
  source .settings
fi

environment="${environment:-prod}"
environment="${1:-$environment}"

if [[ ! -f ".${environment}.env" ]]; then
  echo "Error: file '.${environment}.env' not found."
  exit 1
fi
source ".${environment}.env"

echo "Deploying environment '${environment}'..."

subscription_id="$(echo $AZURE_CREDENTIALS | jq -r .subscriptionId)"
tenant_id="$(echo $AZURE_CREDENTIALS | jq -r .tenantId)"
commit_sha="$(git rev-parse HEAD)"

az config set extension.use_dynamic_install=yes_without_prompt
cd ..

# Deploy function apps
for i in ${!function_names[@]}; do
  function_app_name=${function_app_names[$i]}
  function_app_url=${function_app_urls[$i]}

  echo "Deploying function app '${function_app_name}'..."
  pushd ${function_names[$i]}

  # TODO: retreive remote settings

  func azure functionapp publish ${function_app_name} --javascript
  popd
done

# Deploy container apps
for i in ${!container_image_names[@]}; do
  container_image_name=${container_image_names[$i]}
  container_app_name=${container_app_names[$i]}
  container_app_url=${container_app_urls[$i]}

  echo "Deploying '${container_app_name}'..."
  echo ${registry_password} | docker login \
    --username ${registry_username} \
    --password-stdin \
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
  pushd packages/${static_web_app_name}
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
    # --output-location "." \
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
