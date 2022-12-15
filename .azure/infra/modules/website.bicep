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

// TODO: need custom domain support before we can add this
// @description('Enable enterprise-grade edge caching')
// param enterpriseEdge bool = false

// ---------------------------------------------------------------------------

var uid = uniqueString(resourceGroup().id, projectName, environment, location)

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
    allowConfigFileUpdates: false
    enterpriseGradeCdnStatus: 'Disabled'
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output staticWebAppName string = staticWebApp.name
output staticWebAppPublicUrl string = staticWebApp.properties.defaultHostname
