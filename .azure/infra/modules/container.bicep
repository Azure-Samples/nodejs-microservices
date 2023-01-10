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

// @description('Enable or disable ingress')
// ingress: bool = false

// @description('Allow access from outside of the Container Apps environment')
// param externalIngress bool = false

// @description('Target port for ingress')
// param targetPort int = 80

// @description('Allow insecure connections for ingress')
// param allowInsecure bool = false

// ---------------------------------------------------------------------------
// Options
// ---------------------------------------------------------------------------
var ingress = contains(options, 'ingress')
var external = contains(options.ingress, 'external') ? options.ingress.external : false
var targetPort = contains(options.ingress, 'targetPort') ? options.ingress.targetPort : false
var allowInsecure = contains(options.ingress, 'allowInsecure') ? options.ingress.allowInsecure : false

// TODO: CPU/memory resources, scaling rules, env

// ---------------------------------------------------------------------------

var uid = uniqueString(resourceGroup().id, projectName, environment, location)

// resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
//   name: 'kv-${uid}'
// }

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
            cpu: json('0.25')  // float values aren't currently supported
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        maxReplicas: 10
      }
      // revisionSuffix: 'string'
    }
  }
}

// ---------------------------------------------------------------------------

output containerName string = container.name
output containerUrl string = container.properties.configuration.ingress.fqdn
