// ---------------------------------------------------------------------------
// Common parameters for all modules
// ---------------------------------------------------------------------------

@minLength(1)
@maxLength(24)
@description('The name of your project')
param projectName string

@minLength(1)
@maxLength(10)
@description('The name of the environment')
param environment string

@description('The Azure region where all resources will be created')
param location string = resourceGroup().location

@description('Tags for the resources')
param tags object = {}

// ---------------------------------------------------------------------------
// Resource-specific parameters
// ---------------------------------------------------------------------------

@description('Specify the service tier')
@allowed([
  'Free'
  'Standard'
])
param tier string = 'Standard'

@description('Website options')
param options object = {}

// TODO: need custom domain support before we can add this
// @description('Enable enterprise-grade edge caching')
// param enterpriseEdge bool = false

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------
var linkedBackend = contains(options, 'linkedBackend')
var backendType = linkedBackend && contains(options.linkedBackend, 'type') ? options.linkedBackend.type : ''
var backendName = linkedBackend && contains(options.linkedBackend, 'name') ? options.linkedBackend.name : ''

// ---------------------------------------------------------------------------

var uid = uniqueString(resourceGroup().id, projectName, environment, location)

var containerUid = uniqueString(uid, backendName)
var truncatedname = substring(backendName, 0, min(length(backendName), 15))

// Azure Container Apps linked backend
resource container 'Microsoft.App/containerApps@2022-03-01' existing = if (linkedBackend && backendType == 'container') {
  name: 'ca-${truncatedname}-${containerUid}'
}

var linkedBackendId = backendType == 'container' ? container.id : ''
// TODO: support linked function

// Azure Static Web Apps
// https://docs.microsoft.com/azure/templates/microsoft.web/staticsites?tabs=bicep
resource staticWebApp 'Microsoft.Web/staticSites@2021-03-01' = {
  name: 'website-${projectName}-${environment}-${uid}'
  location: location
  tags: tags
  sku: {
    name: tier
  }
  properties: {
    provider: 'custom'
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    enterpriseGradeCdnStatus: 'Disabled'
  }

  // Azure Static Web Apps linked backends
  // https://learn.microsoft.com/fazure/templates/microsoft.web/staticsites/linkedbackends?pivots=deployment-language-bicep
  resource staticWebAppBackend 'linkedBackends@2022-03-01' = if (linkedBackend) {
    name: 'website-api-${projectName}-${environment}-${uid}'
    properties: {
      backendResourceId: linkedBackendId
      region: location
    }
    dependsOn: (linkedBackend && backendType == 'container') ? [container] : []
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output staticWebAppName string = staticWebApp.name
output staticWebAppPublicUrl string = staticWebApp.properties.defaultHostname
