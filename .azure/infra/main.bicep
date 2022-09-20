// ***************************************************************************
// THIS FILE IS AUTO-GENERATED, DO NOT EDIT IT MANUALLY!
// If you need to make changes, edit the file `blue.yaml`.
// ***************************************************************************

// ---------------------------------------------------------------------------
// Global parameters 
// ---------------------------------------------------------------------------

@minLength(1)
@maxLength(24)
@description('The name of your project')
param projectName string

@minLength(1)
@maxLength(10)
@description('The name of the environment')
param environment string = 'prod'

@description('The Azure region where all resources will be created')
param location string = 'eastus'

// ---------------------------------------------------------------------------

var commonTags = {
  project: projectName
  environment: environment
  managedBy: 'blue'
}

targetScope = 'resourceGroup'

module logs './logs.bicep' = {
  name: 'logs'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    location: location
    tags: commonTags
  }
}

module registry './registry.bicep' = {
  name: 'registry'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    location: location
    tags: commonTags
  }
}

var containerImageNames = [
  'nest-api'
  'express-api'
  'fastify-api'
]

module containers './container.bicep' = [for imageName in containerImageNames: {
  name: 'container-${imageName}'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    location: location
    tags: commonTags
    imageName: imageName
  }
  dependsOn: [logs, registry]
}]

output resourceGroupName string = resourceGroup().name

output logsWorkspaceName string = logs.outputs.logsWorkspaceName
output logsWorkspaceCustomerId string = logs.outputs.logsWorkspaceCustomerId

output registryName string = registry.outputs.registryName
output registryServer string = registry.outputs.registryServer

output containerImageNames array = containerImageNames
output containerAppNames array = [for (name, i) in containerImageNames: containers[i].outputs.containerName]
output containerAppUrls array = [for (name, i) in containerImageNames: containers[i].outputs.containerUrl]
