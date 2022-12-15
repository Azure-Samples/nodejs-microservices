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

@description('The name of the image to deploy')
param imageName string

// ---------------------------------------------------------------------------

var uid = uniqueString(resourceGroup().id, projectName, environment, location)

// resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
//   name: 'kv-${uid}'
// }

resource logsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: 'logs-${projectName}-${environment}-${uid}'
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: 'cr${uid}'
}

// Azure Container Environment
// https://docs.microsoft.com/azure/templates/microsoft.app/managedenvironments?tabs=bicep
resource containerEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: 'ce-${projectName}-${environment}-${uid}'
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

var containerUid = uniqueString(uid, imageName)

// Azure Container Apps
// https://docs.microsoft.com/azure/templates/microsoft.app/containerapps?tabs=bicep
resource container 'Microsoft.App/containerApps@2022-03-01' = {
  name: 'ca-${containerUid}'
  location: location
  tags: tags
  properties: {
    configuration: {
      // activeRevisionsMode: 'Single'
      ingress: {
        allowInsecure: false
        external: true
        targetPort: 3000
        // transport: 'Auto'
      }
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
          // image: '${containerRegistry.properties.loginServer}/${imageName}'
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          name: imageName
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
