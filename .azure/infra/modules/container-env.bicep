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

// ---------------------------------------------------------------------------

var uid = uniqueString(resourceGroup().id, projectName, environment, location)

// resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
//   name: 'kv-${uid}'
// }

resource logsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: 'logs-${projectName}-${environment}-${uid}'
}

// Azure Container Environment
// https://docs.microsoft.com/azure/templates/microsoft.app/managedenvironments?tabs=bicep
resource containerEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: 'cae-${projectName}-${environment}-${uid}'
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logsWorkspace.properties.customerId
        sharedKey: listKeys(logsWorkspace.id, '2021-06-01').primarySharedKey
      }
    }
    // zoneRedundant: false
  }
}

// ---------------------------------------------------------------------------

output containerEnvironmentName string = containerEnvironment.name
output containerEnvironmentId string = containerEnvironment.id