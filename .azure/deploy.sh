#!/usr/bin/env bash

set -e
cd $(dirname ${BASH_SOURCE[0]})
source .settings
source ".prod.env"
cd ..

client_id="$(echo $AZURE_CREDENTIALS | jq -r .clientId)"
client_secret="$(echo $AZURE_CREDENTIALS | jq -r .clientSecret)"
subscription_id="$(echo $AZURE_CREDENTIALS | jq -r .subscriptionId)"
tenant_id="$(echo $AZURE_CREDENTIALS | jq -r .tenantId)"
commit_sha="$(git rev-parse HEAD)"

az config set extension.use_dynamic_install=yes_without_prompt

# Deploy container apps
for i in ${!container_names[@]}; do
  container_name=${container_names[$i]}
  container_app_name=${container_app_names[$i]}
  container_app_url=${container_app_urls[$i]}

  echo "Deploying '${container_app_name}'..."
  echo ${registry_password} | docker login \
    --username ${registry_username} \
    --password-stdin \
    ${registry_name}.azurecr.io

  docker image tag ${container_name} ${registry_name}.azurecr.io/${container_name}:${commit_sha}
  docker image push ${registry_server}/${container_name}:${commit_sha}

  az containerapp update \
    --name ${container_app_name} \
    --resource-group ${resource_group_name} \
    --image ${registry_server}/${container_name}:${commit_sha} \
    --query "properties.configuration.ingress.fqdn" \
    --output tsv
done

# Deploy static web apps
for i in ${!website_names[@]}; do
  website_name=${website_names[$i]}
  static_web_app_name=${static_web_app_names[$i]}

  pushd packages/${website_name}
  echo "Deploying '${website_name}'..."

  deployment_token=$(\
    az staticwebapp secrets list \
      --name "${static_web_app_name}" \
      --query "properties.apiKey" \
      --output tsv \
    )
  
  swa deploy \
    --app-name "${static_web_app_name}" \
    --resource-group "${resource_group_name}" \
    --tenant-id "${tenant_id}" \
    --subscription-id "${subscription_id}" \
    --env "production" \
    --deployment-token "${deployment_token}" \
    --verbose --no-use-keychain

  popd
done
