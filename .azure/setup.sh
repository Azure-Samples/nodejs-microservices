#!/usr/bin/env bash
##############################################################################
# Usage: ./setup.sh <project_name> [environment_name] [location] [options]
# Setup the current GitHub repo for deploying on Azure.
##############################################################################
# v1.0.2 | dependencies: Azure CLI, GitHub CLI, jq
##############################################################################

set -e
cd $(dirname ${BASH_SOURCE[0]})
if [[ -f ".settings" ]]; then
  source .settings
fi

showUsage() {
  script_name="$(basename "$0")"
  echo "Usage: ./$script_name <project_name>"
  echo "Setup the current GitHub repo for deploying on Azure."
  echo
  echo "Options:"
  echo "  -s, --skip-login    Skip Azure and GitHub login steps"
  echo "  -t, --terminate     Remove current setup and delete deployed resources"
  echo "  -l, --ci-login      Only perform Azure CLI login using environment credentials"
  echo
}

skip_login=false
terminate=false
ci_login=false
args=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--skip-login)
      skip_login=true
      shift
      ;;
    -t|--terminate)
      terminate=true
      shift
      ;;
    -l|--ci-login)
      ci_login=true
      shift
      ;;
    --help)
      showUsage
      exit 0
      ;;
    -*|--*)
      showUsage
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      # Save positional arg
      args+=("$1")
      shift
      ;;
  esac
done

# Restore positional args
set -- "${args[@]}"

project_name="${1:-$project_name}"
environment="${2:-$environment}"
location="${3:-$location}"

if ! command -v az &> /dev/null; then
  echo "Azure CLI not found."
  echo "See https://aka.ms/tools/azure-cli for installation instructions."
  exit 1
fi

if [[ "$ci_login" = true ]]; then
  echo "Logging in to Azure using \$AZURE_CREDENTIALS..."
  if [[ -z "${AZURE_CREDENTIALS}" ]]; then
    echo "Azure credentials not found."
    echo "Please run .azure/setup.sh locally to setup your deployment."
    exit 1
  fi
  client_id="$(echo $AZURE_CREDENTIALS | jq -r .clientId)"
  client_secret="$(echo $AZURE_CREDENTIALS | jq -r .clientSecret)"
  subscription_id="$(echo $AZURE_CREDENTIALS | jq -r .subscriptionId)"
  tenant_id="$(echo $AZURE_CREDENTIALS | jq -r .tenantId)"
  az login \
    --service-principal \
    --username "${client_id}" \
    --password "${client_secret}" \
    --tenant "${tenant_id}"
  az account set --subscription "${subscription_id}"
  echo "Login successful."
  exit 0
fi

if ! command -v gh &> /dev/null; then
  echo "GitHub CLI not found."
  echo "See https://cli.github.com for installation instructions."
  exit 1
fi

if [[ -z "$project_name" ]]; then
  showUsage
  echo "Error: project name is required."
  exit 1
fi

if [[ "$skip_login" = false ]]; then
  echo "Logging in to Azure..."
  az login
  echo "Logging in to GitHub..."
  gh auth login
  echo "Login successful."
fi

if [[ "$terminate" = true ]]; then
  echo "Deleting current setup..."
  .azure/infra.sh down ${project_name} ${environment} ${location}
  echo "Retrieving GitHub repository URL..."
  remote_repo=$(git config --get remote.origin.url)
  gh secret delete AZURE_CREDENTIALS -R $remote_repo
  echo "Setup deleted."
else
  echo "Retrieving Azure subscription..."
  subscription_id=$(
    az account show \
      --query id \
      --output tsv \
      --only-show-errors \
    )
  echo "Creating Azure service principal..."
  service_principal=$(
    MSYS_NO_PATHCONV=1 az ad sp create-for-rbac \
      --name="sp-${project_name}" \
      --role="Contributor" \
      --scopes="/subscriptions/$subscription_id" \
      --sdk-auth \
      --only-show-errors \
    )
  echo "Retrieving GitHub repository URL..."
  remote_repo=$(git config --get remote.origin.url)
  echo "Setting up GitHub repository secrets..."
  gh secret set AZURE_CREDENTIALS -b"$service_principal" -R $remote_repo
  echo "Triggering Azure deployment..."
  gh workflow run deploy.yml
  echo "Setup success!"
fi
