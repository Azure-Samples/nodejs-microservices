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
  'Basic'
  'Standard'
  'Premium'
])
param tier string = 'Basic'

// ---------------------------------------------------------------------------

var uid = uniqueString(resourceGroup().id, projectName, environment, location)

// Azure Container Registry
// https://docs.microsoft.com/azure/templates/microsoft.containerregistry/registries?tabs=bicep
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: 'cr${projectName}${environment}${uid}'
  location: location
  tags: tags
  sku: {
    name: tier
  }
  properties: {
    adminUserEnabled: true
  }
}

// ---------------------------------------------------------------------------
// Secrets
// ---------------------------------------------------------------------------

// resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
//   name: 'kv-${uid}'

//   resource containerRegistryUserName 'secrets' = {
//     name: 'containerRegistryUserName'
//     properties: {
//       value: containerRegistry.listCredentials().username
//     }
//   }
//   resource containerRegistryPassword 'secrets' = {
//     name: 'containerRegistryPassword'
//     properties: {
//       value: containerRegistry.listCredentials().passwords[0].value
//     }
//   }
// }

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output registryName string = containerRegistry.name
output registryServer string = containerRegistry.properties.loginServer
