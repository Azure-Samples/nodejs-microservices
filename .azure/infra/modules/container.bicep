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

@description('The container name')
param name string

@description('Container options')
param options object = {}

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------

var ingress = contains(options, 'ingress')
var external = ingress && contains(options.ingress, 'external') ? options.ingress.external : false
var targetPort = ingress && contains(options.ingress, 'targetPort') ? options.ingress.targetPort : false
var allowInsecure = ingress && contains(options.ingress, 'allowInsecure') ? options.ingress.allowInsecure : false

var resources = contains(options, 'resources')
var cpu = resources && contains(options.resources, 'cpu') ? options.resources.cpu : '0.25'
var memory = resources && contains(options.resources, 'memory') ? options.resources.memory : '0.5Gi'

var scale = contains(options, 'scale')
var minReplicas = scale && contains(options.scale, 'minReplicas') ? options.scale.minReplicas : 0
var maxReplicas = scale && contains(options.scale, 'maxReplicas') ? options.scale.maxReplicas : 10
var rules = scale && contains(options.scale, 'rules') ? options.scale.rules : []

// ---------------------------------------------------------------------------

var uid = uniqueString(resourceGroup().id, projectName, environment, location)

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: 'cr${uid}'
}

resource containerEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: 'cae-${projectName}-${environment}-${uid}'
}

var containerUid = uniqueString(uid, name)
var truncatedname = substring(name, 0, min(length(name), 15))

// Azure Container Apps
// https://docs.microsoft.com/azure/templates/microsoft.app/containerapps?tabs=bicep
resource container 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'ca-${truncatedname}-${containerUid}' // 32 characters max
  location: location
  tags: tags
  properties: {
    configuration: {
      // activeRevisionsMode: 'Single'
      ingress: ingress ? {
        allowInsecure: allowInsecure
        external: external
        targetPort: targetPort
        // transport: 'Auto'
      } : {}
      registries: [
        {
          server: containerRegistry.properties.loginServer
          username: containerRegistry.listCredentials().username
          passwordSecretRef: 'container-registry-password'
        }
      ]
      secrets: [
        {
          name: 'container-registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
    }
    managedEnvironmentId: containerEnvironment.id
    template: {
      containers: [
        {
          env: [
            // {
            //   name: 'string'
            //   secretRef: 'string'
            //   value: 'string'
            // }
          ]
          // image: '${containerRegistry.properties.loginServer}/${name}'
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          name: name
          resources: {
            cpu: json(cpu)  // float values aren't currently supported
            memory: memory
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
        rules: rules
      }
      // revisionSuffix: 'string'
    }
  }
}

// ---------------------------------------------------------------------------

output containerName string = container.name
output containerHostname string = container.properties.configuration.ingress.fqdn
