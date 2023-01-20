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

var config = any(loadJsonContent('./config.json'))

var commonTags = {
  project: projectName
  environment: environment
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
    options: contains(config, 'registry') ? config.registry : {}
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
    options: contains(config, 'database') ? config.database : {}
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
  dependsOn: [logs]
}

var containersConfig = contains(config, 'containers') ? config.containers : []
var containerNames = map(containersConfig, c => c.name)

module containers './modules/container.bicep' = [for container in containersConfig: {
  name: 'container-${container.name}'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    location: location
    tags: commonTags
    name: container.name
    options: contains(container, 'options') ? container.options : {}
  }
  dependsOn: [registry, containerEnvironment]
}]

var websitesConfig = contains(config, 'websites') ? config.websites : []
var websiteNames = map(websitesConfig, w => w.name)

module websites './modules/website.bicep' = [for website in websitesConfig: {
  name: 'website-${website.name}'
  scope: resourceGroup()
  params: {
    projectName: projectName
    environment: environment
    location: location
    tags: commonTags
    options: contains(website, 'options') ? website.options : {}
  }
  dependsOn: containers
}]

output resourceGroupName string = resourceGroup().name

output logsWorkspaceName string = logs.outputs.logsWorkspaceName
output logsWorkspaceCustomerId string = logs.outputs.logsWorkspaceCustomerId

output registryName string = registry.outputs.registryName
output registryServer string = registry.outputs.registryServer

output databaseName string = database.outputs.databaseName

output containerAppEnvironmentName string = containerEnvironment.outputs.containerEnvironmentName

output containerNames array = containerNames
output containerAppNames array = [for (name, i) in containerNames: containers[i].outputs.containerName]
output containerAppHostnames array = [for (name, i) in containerNames: containers[i].outputs.containerHostname]

output websiteNames array = websiteNames
output staticWebAppNames array = [for (name, i) in websiteNames: websites[i].outputs.staticWebAppName]
output staticWebAppHostnames array = [for (name, i) in websiteNames: websites[i].outputs.staticWebAppHostname]
