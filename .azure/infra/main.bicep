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

var config = loadJsonContent('./config.json')

var commonTags = {
  project: projectName
  environment: environment
  managedBy: 'blue'
}

targetScope = 'resourceGroup'

module logs './modules/logs.bicep' = {
  name: 'logs'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    location: location
    tags: commonTags
  }
}

module registry './modules/registry.bicep' = {
  name: 'registry'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    location: location
    tags: commonTags
  }
}

module database './modules/database.bicep' = {
  name: 'database'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    location: location
    tags: commonTags
  }
}

module containerEnvironment './modules/container-env.bicep' = {
  name: 'container-env'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    location: location
    tags: commonTags
  }
}

var containerNames = map(config.containers, c => c.name)

module containers './modules/container.bicep' = [for container in config.containers: {
  name: 'container-${container.name}'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    location: location
    tags: commonTags
    name: container.name
    options: container.options
  }
  dependsOn: [logs, registry, containerEnvironment]
}]

var websiteNames = map(config.websites, w => w.name)

module websites './modules/website.bicep' = [for website in config.websites: {
  name: 'website-${website.name}'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    location: location
    tags: commonTags
    options: website.options
  }
}]

output resourceGroupName string = resourceGroup().name

output logsWorkspaceName string = logs.outputs.logsWorkspaceName
output logsWorkspaceCustomerId string = logs.outputs.logsWorkspaceCustomerId

output registryName string = registry.outputs.registryName
output registryServer string = registry.outputs.registryServer

output databaseName string = database.outputs.databaseName

output containerAppEnvironmentName string = containerEnvironment.outputs.containerEnvironmentName
output containerAppEnvironmentId string = containerEnvironment.outputs.containerEnvironmentId

output containerNames array = containerNames
output containerAppNames array = [for (name, i) in containerNames: containers[i].outputs.containerName]
output containerAppUrls array = [for (name, i) in containerNames: containers[i].outputs.containerUrl]

output websiteNames array = websiteNames
output staticWebAppNames array = [for (name, i) in websiteNames: websites[i].outputs.staticWebAppName]
output staticWebAppPublicUrls array = [for (name, i) in websiteNames: websites[i].outputs.staticWebAppPublicUrl]
