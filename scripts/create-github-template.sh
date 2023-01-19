#!/usr/bin/env bash
##############################################################################
# Usage: ./create-github-template.sh [--local]
# Creates the project template and push it to GitHub.
##############################################################################

set -euo pipefail
cd $(dirname ${BASH_SOURCE[0]})
cd ..

BASE_DIR=$(pwd)
TEMPLATE_HOME=/tmp/nodejs-microservices-template
TEMPLATE_REPO=git@github.com:azure-samples/nodejs-microservices-template.git

echo "Preparing GitHub project template..."
rm -rf $TEMPLATE_HOME
mkdir -p $TEMPLATE_HOME
find . -type d -not -path '*node_modules*' -not -path '*.git/*' -not -path './packages*' -exec mkdir -p '{}' "$TEMPLATE_HOME/{}" ';'
find . -type f -not -path '*node_modules*' -not -path '*.git/*' -not -path './packages*' -exec cp -r '{}' "$TEMPLATE_HOME/{}" ';'
cd $TEMPLATE_HOME
rm -rf .git
git init

# Create projects
./scripts/create-projects.sh

# Remove unnecessary files
rm -rf node_modules
rm -rf .github
rm -rf TODO
rm -rf docker-compose.yml
rm -rf package-lock.json
rm -rf scripts
rm -rf docs
rm -rf .azure/.*.env
rm -rf .azure/_*.sh
mkdir -p docs/assets
cp $BASE_DIR/docs/assets/architecture.drawio.png docs/assets/architecture.drawio.png

# Build script
echo -e '#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

' > .azure/build.sh

# Deploy script
echo -e '#!/usr/bin/env bash
set -eu
cd "$(dirname "${BASH_SOURCE[0]}")"
source .settings
source .prod.env
cd ..

client_id="$(echo "$AZURE_CREDENTIALS" | jq -r .clientId)"
client_secret="$(echo "$AZURE_CREDENTIALS" | jq -r .clientSecret)"
subscription_id="$(echo "$AZURE_CREDENTIALS" | jq -r .subscriptionId)"
tenant_id="$(echo "$AZURE_CREDENTIALS:" | jq -r .tenantId)"
commit_sha="$(git rev-parse HEAD)"

' > .azure/deploy.sh

if [[ ${1-} == "--local" ]]; then
  echo "Local mode: skipping GitHub push."
  open $TEMPLATE_HOME
else
  # Update git repo
  git remote add origin $TEMPLATE_REPO
  git add .
  git commit -m "chore: initial commit"
  git push -u origin main --force

  rm -rf $TEMPLATE_HOME
fi

echo "Successfully updated project template."
