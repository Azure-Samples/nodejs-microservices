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

@description('Registry options')
param options object = {}

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------

// Allowed: 'Basic', 'Standard', 'Premium'
var tier = contains(options, 'tier') ? options.tier : 'Basic'
var anonymousPullEnabled = contains(options, 'anonymousPullEnabled') ? options.anonymousPullEnabled : false

// ---------------------------------------------------------------------------

var uid = uniqueString(resourceGroup().id, projectName, environment, location)

// Azure Container Registry
// https://docs.microsoft.com/azure/templates/microsoft.containerregistry/registries?tabs=bicep
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: 'cr${uid}'
  location: location
  tags: tags
  sku: {
    name: tier
  }
  properties: {
    adminUserEnabled: true
    anonymousPullEnabled: anonymousPullEnabled
  }
}

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output registryName string = containerRegistry.name
output registryServer string = containerRegistry.properties.loginServer
