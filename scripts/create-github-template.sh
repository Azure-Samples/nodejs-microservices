#!/usr/bin/env bash
##############################################################################
# Usage: ./create-github-template.sh
# Creates the project template and push it to GitHub.
##############################################################################

set -euo pipefail
cd $(dirname ${BASH_SOURCE[0]})

TEMPLATE_HOME=/tmp/azure-nodejs-microservices-template
TEMPLATE_REPO=git@github.com:sinedied/azure-nodejs-microservices-template.git

mkdir -p $TEMPLATE_HOME
cp -r ../ $TEMPLATE_HOME
cd $TEMPLATE_HOME

# Create projects
rm -rf packages
./scripts/create-projects.sh

rm -rf .git
rm -rf .github
rm -rf TODO
rm -rf docker-compose.yml
rm -rf package-lock.json
rm -rf scripts
rm -rf docs
rm -rf .azure/*.env

# Build script
echo -e '#!/usr/bin/env bash
set -euo pipefail
cd $(dirname ${BASH_SOURCE[0]})/..

' > .azure/build.sh

# Deploy script
echo -e '#!/usr/bin/env bash
set -eu
cd $(dirname ${BASH_SOURCE[0]})
source .settings
source .prod.env
cd ..

client_id="$(echo $AZURE_CREDENTIALS | jq -r .clientId)"
client_secret="$(echo $AZURE_CREDENTIALS | jq -r .clientSecret)"
subscription_id="$(echo $AZURE_CREDENTIALS | jq -r .subscriptionId)"
tenant_id="$(echo $AZURE_CREDENTIALS | jq -r .tenantId)"
commit_sha="$(git rev-parse HEAD)"

' > .azure/deploy.sh

# Update git repo
# git init
# git remote add origin $TEMPLATE_REPO
# git add .
# git commit -m "chore: initial commit"
# git push -u origin main --force

open $TEMPLATE_HOME
#rm -rf $TEMPLATE_HOME

echo "Successfully updated project template."
