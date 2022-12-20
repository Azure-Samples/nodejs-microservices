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

@description('Specify the database type')
@allowed([
  'CoreSQL'
  'MongoDB'
])
param databaseType string = 'CoreSQL'

// Resource-specific parameters
param collections array = []

// ---------------------------------------------------------------------------

var uid = uniqueString(resourceGroup().id, projectName, environment, location)

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2021-06-15' = {
  name: 'db-${projectName}-${environment}-${uid}'
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    // enableMultipleWriteLocations: false
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    locations: [
      {
        locationName: location
        // isZoneRedundant: false
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
      }
    }
  }
}

resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-06-15' = {
  parent: cosmosDb
  name: '${projectName}db'
  properties: {
    resource: {
      id: '${projectName}db'
    }
  }

  resource cosmosDbContainer 'containers@2021-04-15' = {
    name: 'users'
    properties: {
      resource: {
        id: 'users'
        partitionKey: {
          paths: [
            '/id'
          ]
          kind: 'Hash'
        }
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Secrets
// ---------------------------------------------------------------------------

// resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
//   name: 'kv-${uid}'

//   resource databaseConnectionString 'secrets' = {
//     name: 'databaseConnectionString'
//     properties: {
//       value: cosmosDb.listConnectionStrings().connectionStrings[0].connectionString
//     }
//   }
// }

// ---------------------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------------------

output name string = cosmosDb.name
